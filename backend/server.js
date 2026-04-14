// CORS FIX v5 - Force redeploy - Added forced headers middleware
const express = require('express');
const cors = require('cors');

const app = express();

// Handle OPTIONS preflight globally (MUST be first!)
app.options('*', (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, PATCH, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With');
  res.setHeader('Access-Control-Allow-Credentials', 'true');
  res.status(200).send();
});

// CORS global - permitir TODOS los orígenes
app.use(cors({
  origin: '*',
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With']
}));

// Force CORS headers on EVERY response (middleware)
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, PATCH, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With');
  res.header('Access-Control-Allow-Credentials', 'true');
  next();
});

const initDatabase = require('./src/config/db-init');
const { logger } = require('./src/utils/logger');
const { LOG_MESSAGES } = require('./src/utils/constants');
const routes = require('./src/routes');
const dotenv = require('dotenv');

dotenv.config();

// Cargar rutas después del CORS
app.use('/api', routes);

const PORT = process.env.PORT || 3000;
const HOST = process.env.HOST || '0.0.0.0';
const NODE_ENV = process.env.NODE_ENV || 'development';

/**
 * Validar variables de entorno requeridas
 * Soporta DATABASE_URL (Neon) o variables individuales (local)
 */
const validateEnvironment = () => {
  // Verificar que tengamos DATABASE_URL o las variables individuales
  const hasDatabaseUrl = !!process.env.DATABASE_URL;
  const hasIndividualDb = !!(
    process.env.DB_HOST && 
    process.env.DB_USER && 
    process.env.DB_PASSWORD && 
    process.env.DB_NAME
  );
  
  if (!hasDatabaseUrl && !hasIndividualDb) {
    logger.error('ServerInit', 'Variables de entorno de base de datos faltantes', null, {
      error: 'Se requiere DATABASE_URL o DB_HOST/DB_USER/DB_PASSWORD/DB_NAME'
    });
    console.error('❌ Error: Variables de entorno de base de datos faltantes');
    console.error('   Opción 1 (Neon): DATABASE_URL=postgresql://...');
    console.error('   Opción 2 (Local): DB_HOST, DB_USER, DB_PASSWORD, DB_NAME');
    process.exit(1);
  }
  
  // Verificar JWT_SECRET
  if (!process.env.JWT_SECRET) {
    logger.error('ServerInit', 'JWT_SECRET faltante');
    console.error('❌ Error: JWT_SECRET es requerido');
    process.exit(1);
  }

  // Validar JWT_SECRET en producción
  if (process.env.JWT_SECRET.length < 32 && NODE_ENV === 'production') {
    logger.warn('ServerInit', 'JWT_SECRET muy corto', {
      nodeEnv: NODE_ENV,
      length: process.env.JWT_SECRET.length
    });
    console.warn('⚠️  Advertencia: JWT_SECRET muy corto en producción (mínimo 32 caracteres)');
  }

  logger.debug('Environment', 'Validación de variables completada', {
    usingNeon: hasDatabaseUrl
  });
};

/**
 * Iniciar servidor
 */
const start = async () => {
  try {
    // Validar entorno
    validateEnvironment();
    
    console.log('\n' + '='.repeat(50));
    console.log('🚀 UTP COMUNIDADES - Iniciando servidor');
    console.log('='.repeat(50));
    console.log(`Entorno: ${NODE_ENV}`);
    console.log(`Puerto: ${PORT}`);
    console.log(`Host: ${HOST}`);
    
    // Inicializar base de datos
    logger.info('ServerInit', 'Conectando a base de datos...');
    const dbInitialized = await initDatabase();
    
    if (!dbInitialized) {
      logger.critical(
        'ServerInit',
        'Fallo crítico: No se pudo inicializar la base de datos',
        new Error('Database initialization failed')
      );
      console.error('\n❌ Error: No se pudo inicializar la base de datos');
      console.error('   Verifica la conexión a PostgreSQL');
      console.error('   Comprueba las variables de entorno: DB_HOST, DB_USER, DB_PASSWORD, DB_NAME');
      process.exit(1);
    }
    
    logger.info('ServerInit', LOG_MESSAGES.DB_CONNECTED);
    console.log('✅ Conexión a BD establecida');
    
    // Iniciar listener HTTP
    const server = app.listen(PORT, HOST, () => {
      logger.info('ServerInit', LOG_MESSAGES.SERVER_STARTED, {
        port: PORT,
        host: HOST,
        nodeEnv: NODE_ENV
      });
      
      console.log('\n' + '='.repeat(50));
      console.log('✅ Servidor escuchando');
      console.log('='.repeat(50));
      console.log(`🌐 API disponible en http://${HOST}:${PORT}/api`);
      console.log(`❤️  Health check: http://${HOST}:${PORT}/health`);
      console.log('\n📝 Presiona Ctrl+C para detener\n');
    });
    
    // Configurar timeout
    server.setTimeout(120000); // 2 minutos
    
    // Graceful shutdown
    process.on('SIGTERM', () => {
      logger.info('ServerShutdown', 'SIGTERM recibido - iniciando shutdown graceful');
      console.log('\n⏹️  Deteniendo servidor...');
      
      server.close(() => {
        logger.info('ServerShutdown', 'Servidor detenido correctamente');
        console.log('✅ Servidor detenido');
        process.exit(0);
      });
      
      // Forzar cierre después de 30 segundos
      setTimeout(() => {
        logger.error('ServerShutdown', 'Timeout en shutdown graceful - forzando cierre');
        console.error('⚠️  Timeout - forzando cierre');
        process.exit(1);
      }, 30000);
    });
    
    process.on('SIGINT', () => {
      logger.info('ServerShutdown', 'SIGINT recibido - iniciando shutdown graceful');
      console.log('\n⏹️  Deteniendo servidor...');
      
      server.close(() => {
        logger.info('ServerShutdown', 'Servidor detenido correctamente');
        console.log('✅ Servidor detenido');
        process.exit(0);
      });
    });
    
  } catch (error) {
    logger.critical('ServerInit', 'Error crítico durante iniciación', error);
    console.error('\n❌ Error fatal:', error.message);
    console.error('\nDetalles técnicos:');
    console.error(error.stack);
    process.exit(1);
  }
};

// Iniciar aplicación
start();
