// UTP Comunidades - Backend Server (Root Entry Point)
const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');

// Load environment variables
const result = dotenv.config({ path: './backend/.env' });
if (result.error) {
  console.log('Using Railway environment variables');
}

const app = express();

// CORS - Allow all origins
app.use(cors({
  origin: '*',
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With']
}));

// Parse JSON
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ limit: '10mb', extended: true }));

// Import routes from backend
const routes = require('./backend/src/routes');
const initDatabase = require('./backend/src/config/db-init');

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// API routes
app.use('/api', routes);

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

// Error handler
app.use((err, req, res, next) => {
  console.error('Error:', err.message);
  res.status(500).json({ error: 'Internal server error' });
});

// Start server
const PORT = process.env.PORT || 3000;
const HOST = process.env.HOST || '0.0.0.0';

const start = async () => {
  try {
    console.log('\n' + '='.repeat(50));
    console.log('🚀 UTP COMUNIDADES - Iniciando servidor');
    console.log('='.repeat(50));
    console.log(`Entorno: ${process.env.NODE_ENV || 'development'}`);
    console.log(`Puerto: ${PORT}`);
    console.log(`Host: ${HOST}`);
    
    // Initialize database
    const dbInitialized = await initDatabase();
    if (!dbInitialized) {
      console.error('❌ Database initialization failed');
      process.exit(1);
    }
    console.log('✅ Database connected');
    
    // Start HTTP server
    app.listen(PORT, HOST, () => {
      console.log('='.repeat(50));
      console.log('✅ Servidor escuchando');
      console.log('='.repeat(50));
      console.log(`🌐 API: http://${HOST}:${PORT}/api`);
      console.log(`❤️  Health: http://${HOST}:${PORT}/health`);
      console.log('');
    });
  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
};

start();
