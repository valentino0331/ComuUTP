const { Pool } = require('pg');
require('dotenv').config();

const isProduction = process.env.NODE_ENV === 'production';
const useSSL = process.env.DB_SSL === 'true' || isProduction || (process.env.DB_HOST && process.env.DB_HOST.includes('neon.tech'));

// Configuración para Neon (usa DATABASE_URL si está disponible, sino usa variables individuales)
const pool = process.env.DATABASE_URL
  ? new Pool({
      connectionString: process.env.DATABASE_URL,
      ssl: {
        rejectUnauthorized: false,
      },
    })
  : new Pool({
      host: process.env.DB_HOST,
      port: parseInt(process.env.DB_PORT) || 5432,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME,
      ssl: useSSL ? { rejectUnauthorized: false } : false,
    });

module.exports = pool;
