const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
const routes = require('./src/routes');
const { logger } = require('./src/utils/logger');
const { HTTP_STATUS, ERROR_MESSAGES } = require('./src/utils/constants');

dotenv.config();

const app = express();

// Rate limiting general
const generalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutos
  max: 100, // máximo 100 requests por ventana
  message: { error: 'Demasiadas solicitudes, intenta más tarde' },
  standardHeaders: true,
  legacyHeaders: false,
});

// Rate limiting más estricto para auth
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutos
  max: 5, // máximo 5 intentos de login
  message: { error: 'Demasiados intentos de login, espera 15 minutos' },
  standardHeaders: true,
  legacyHeaders: false,
});

// Configuración de CORS
const corsOptions = {
  origin: function (origin, callback) {
    // En producción, SOLO permitir dominios específicos
    if (process.env.NODE_ENV === 'production') {
      const allowedOrigins = [
        process.env.FRONTEND_URL,
        'https://utp-comunidades.vercel.app', // dominio de producción
        'capacitor://localhost', // app móvil
        'http://localhost', // para desarrollo en producción temporal
        'http://localhost:3000',
        'http://localhost:49232',
        'http://localhost:8080',
        'http://127.0.0.1:3000',
        'http://127.0.0.1:49232',
        'http://127.0.0.1:8080',
      ];

      if (!origin || allowedOrigins.includes(origin) || origin?.startsWith('http://localhost') || origin?.startsWith('http://127.0.0.1')) {
        return callback(null, true);
      }
      logger.warn('CORS', 'Origin not allowed', { origin });
      return callback(new Error('CORS not allowed'));
    }

    // En desarrollo, permitir localhost
    if (!origin || origin.startsWith('http://localhost') || origin.startsWith('http://127.0.0.1')) {
      return callback(null, true);
    }
    return callback(new Error('CORS not allowed'));
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
  maxAge: 86400
};

app.use(cors(corsOptions));

// Sanitizar input para prevenir XSS
const sanitizeInput = require('./src/middlewares/sanitize.middleware');
app.use(sanitizeInput);

// Limit request payload (aumentado a 10MB para permitir imágenes en base64)
// Railway deployment: force redeploy
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ limit: '10mb', extended: true }));

// Morgan para logs HTTP combinados
app.use(morgan(':method :url :status :res[content-length] - :response-time ms'));

// Middleware para log de requests
app.use((req, res, next) => {
  const startTime = Date.now();
  
  // Log básico del request
  logger.debug('HTTP', 'Request received', {
    method: req.method,
    path: req.path,
    ip: req.ip || req.connection.remoteAddress,
    userAgent: req.get('User-Agent')?.substring(0, 100)
  });
  
  // Capturar el método res.json original para loguear responses
  const originalJson = res.json.bind(res);
  
  res.json = function(data) {
    const duration = Date.now() - startTime;
    const statusCode = res.statusCode;
    
    // Log del response (no loguear payloads grandes)
    if (statusCode >= 400) {
      logger.warn('HTTP', 'Response error', {
        method: req.method,
        path: req.path,
        status: statusCode,
        duration: `${duration}ms`
      });
    }
    
    logger.debug('HTTP', 'Request completed', {
      method: req.method,
      path: req.path,
      status: statusCode,
      duration: `${duration}ms`
    });
    
    // Agregur headers de seguridad
    res.set({
      'X-Content-Type-Options': 'nosniff',
      'X-Frame-Options': 'DENY',
      'X-XSS-Protection': '1; mode=block',
      'Strict-Transport-Security': 'max-age=31536000; includeSubDomains'
    });
    
    return originalJson(data);
  };
  
  next();
});

// Rutas de salud
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development'
  });
});

app.get('/health/ready', (req, res) => {
  // Aquí se podría verificar conexión a BD, etc.
  res.json({ ready: true });
});

// Política de privacidad
app.get('/privacy-policy', (req, res) => {
  res.sendFile(require('path').join(__dirname, 'PRIVACY_POLICY.md'));
});

// Rutas principales
app.use('/api', generalLimiter, routes);

// Rate limit específico para login
app.use('/api/auth/login', authLimiter);

// Manejo 404
app.use((req, res) => {
  logger.warn('HTTP', 'Route not found', {
    method: req.method,
    path: req.path,
    ip: req.ip
  });
  
  res.status(HTTP_STATUS.NOT_FOUND).json({
    error: ERROR_MESSAGES.NOT_FOUND,
    status: HTTP_STATUS.NOT_FOUND,
    timestamp: new Date().toISOString()
  });
});

// Middleware de manejo de errores global (DEBE ir al final)
app.use((err, req, res, next) => {
  const startTime = new Date().toISOString();
  const requestId = req.id || Math.random().toString(36).substring(7);
  
  // Log del error
  logger.error('GlobalErrorHandler', `${err.message || 'Unknown error'}`, err, {
    requestId,
    method: req.method,
    path: req.path,
    ip: req.ip,
    timestamp: startTime
  });
  
  // No exponer detalles internos del error
  let statusCode = err.status || HTTP_STATUS.INTERNAL_SERVER_ERROR;
  let message = ERROR_MESSAGES.INTERNAL_ERROR;
  
  // Errores conocidos con mensajes específicos
  if (err.message.includes('Unexpected token')) {
    statusCode = HTTP_STATUS.BAD_REQUEST;
    message = ERROR_MESSAGES.INVALID_INPUT;
  } else if (err.message.includes('JWT')) {
    statusCode = HTTP_STATUS.UNAUTHORIZED;
    message = ERROR_MESSAGES.INVALID_TOKEN;
  } else if (err.status === HTTP_STATUS.BAD_REQUEST) {
    message = err.message || ERROR_MESSAGES.INVALID_INPUT;
  } else if (err.status === HTTP_STATUS.UNAUTHORIZED) {
    message = err.message || ERROR_MESSAGES.UNAUTHORIZED;
  } else if (err.status === HTTP_STATUS.FORBIDDEN) {
    message = err.message || ERROR_MESSAGES.FORBIDDEN;
  } else if (err.status === HTTP_STATUS.NOT_FOUND) {
    message = err.message || ERROR_MESSAGES.NOT_FOUND;
  } else if (err.status === HTTP_STATUS.CONFLICT) {
    message = err.message || ERROR_MESSAGES.DUPLICATE;
  }
  
  // Response de error
  res.status(statusCode).json({
    error: message,
    status: statusCode,
    requestId: requestId,
    timestamp: startTime,
    // Incluir detalles solo en desarrollo
    ...(process.env.NODE_ENV === 'development' && { details: err.message })
  });
});

// Manejo de errores no capturados (graceful shutdown)
process.on('uncaughtException', (err) => {
  logger.critical('UncaughtException', 'Uncaught exception occurred', err);
  // En producción, esto debería triggear un graceful shutdown
  if (process.env.NODE_ENV === 'production') {
    process.exit(1);
  }
});

process.on('unhandledRejection', (err) => {
  logger.critical('UnhandledRejection', 'Unhandled promise rejection', err);
  // En producción, esto debería triggear un graceful shutdown
  if (process.env.NODE_ENV === 'production') {
    process.exit(1);
  }
});

module.exports = app;
