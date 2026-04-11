const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const morgan = require('morgan');
const routes = require('./src/routes');
const { logger } = require('./src/utils/logger');
const { HTTP_STATUS, ERROR_MESSAGES } = require('./src/utils/constants');

dotenv.config();

const app = express();

// Configuración de CORS segura
const corsOptions = {
  origin: function (origin, callback) {
    const NODE_ENV = process.env.NODE_ENV || 'development';
    const FRONTEND_URL = process.env.FRONTEND_URL;
    
    // En desarrollo, permitir localhost en cualquier puerto
    if (NODE_ENV === 'development') {
      if (!origin || origin.startsWith('http://localhost') || origin.startsWith('http://127.0.0.1')) {
        return callback(null, true);
      }
    }
    
    // En producción, usar URL específica
    if (FRONTEND_URL && origin === FRONTEND_URL) {
      return callback(null, true);
    }
    
    // Si origin no es permitido
    if (FRONTEND_URL && origin !== FRONTEND_URL && NODE_ENV === 'production') {
      return callback(new Error('CORS not allowed'));
    }
    
    // Permitir en desarrollo si no hay origin (como en herramientas de testing)
    if (!origin && NODE_ENV === 'development') {
      return callback(null, true);
    }
    
    callback(null, false);
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
  maxAge: 86400 // 24 horas
};

app.use(cors(corsOptions));

// Limit request payload
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

// Rutas principales
app.use('/api', routes);

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
