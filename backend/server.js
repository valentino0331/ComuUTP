const app = require('./app');
const initDatabase = require('./src/config/db-init');
const { logger } = require('./src/utils/logger');
const { LOG_MESSAGES } = require('./src/utils/constants');
const { createServer } = require('http');
const { Server } = require('socket.io');

const PORT = process.env.PORT || 3000;
const HOST = process.env.HOST || '0.0.0.0';
const NODE_ENV = process.env.NODE_ENV || 'development';

/**
 * Validar variables de entorno requeridas
 */
const validateEnvironment = () => {
  // Aceptar DATABASE_URL O variables individuales
  const hasIndividualVars = process.env.DB_HOST && process.env.DB_PORT && process.env.DB_USER && process.env.DB_PASSWORD && process.env.DB_NAME;
  const hasDatabaseUrl = process.env.DATABASE_URL;
  
  if (!hasIndividualVars && !hasDatabaseUrl) {
    const required = [
      'DB_HOST',
      'DB_PORT',
      'DB_USER',
      'DB_PASSWORD',
      'DB_NAME',
    ];
    logger.error('ServerInit', 'Variables de entorno faltantes', null, {
      missing: required.join(', ')
    });
    console.error('❌ Error: Variables de entorno requeridas faltantes:');
    console.error(`   ${required.join(', ')} O DATABASE_URL`);
    console.error('   Copiar .env.example a .env y completar los valores');
    process.exit(1);
  }

  // JWT_SECRET es CRÍTICO en producción
  if (process.env.NODE_ENV === 'production' && !process.env.JWT_SECRET) {
    logger.critical('Security', 'JWT_SECRET no definido en producción - DETENIENDO SERVIDOR');
    console.error('❌ CRÍTICO: JWT_SECRET es requerido en producción');
    console.error('   Genera uno seguro: node -e "console.log(require(\'crypto\').randomBytes(64).toString(\'hex\'))"');
    process.exit(1);
  }
  
  if (!process.env.JWT_SECRET) {
    console.warn('⚠️  JWT_SECRET no definido en desarrollo, usando valor por defecto (NO USAR EN PRODUCCIÓN)');
  }

  logger.debug('Environment', 'Validación de variables completada');
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
    
    // Crear servidor HTTP
    const httpServer = createServer(app);
    
    // Configurar Socket.io
    const io = new Server(httpServer, {
      cors: {
        origin: process.env.NODE_ENV === 'production' 
          ? process.env.FRONTEND_URL 
          : ['http://localhost:3000', 'http://localhost:49232', 'http://localhost:8080'],
        credentials: true
      }
    });
    
    // Exponer io en app para que los controladores puedan acceder
    app.set('io', io);
    
    // Manejar conexiones Socket.io
    io.on('connection', (socket) => {
      console.log('Usuario conectado:', socket.id);
      
      // Unirse a sala de conversación
      socket.on('join_conversation', (conversationId) => {
        socket.join(`conversation_${conversationId}`);
        console.log(`Usuario ${socket.id} se unió a conversación ${conversationId}`);
      });
      
      // Salir de sala de conversación
      socket.on('leave_conversation', (conversationId) => {
        socket.leave(`conversation_${conversationId}`);
        console.log(`Usuario ${socket.id} salió de conversación ${conversationId}`);
      });
      
      // Enviar mensaje a sala
      socket.on('send_message', (data) => {
        const { conversationId, message } = data;
        io.to(`conversation_${conversationId}`).emit('new_message', message);
        console.log(`Mensaje enviado a conversación ${conversationId}`);
      });
      
      socket.on('disconnect', () => {
        console.log('Usuario desconectado:', socket.id);
      });
    });
    
    // Iniciar listener HTTP
    httpServer.listen(PORT, HOST, () => {
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
    httpServer.setTimeout(120000); // 2 minutos
    
    // Graceful shutdown
    process.on('SIGTERM', () => {
      logger.info('ServerShutdown', 'SIGTERM recibido - iniciando shutdown graceful');
      console.log('\n⏹️  Deteniendo servidor...');
      
      httpServer.close(() => {
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
      
      httpServer.close(() => {
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
