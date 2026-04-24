const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

async function runMigration() {
  try {
    console.log('Ejecutando migración: agregar imagen_url a publicaciones...');
    await pool.query('ALTER TABLE publicaciones ADD COLUMN IF NOT EXISTS imagen_url TEXT');
    console.log('✅ Migración ejecutada exitosamente');
    await pool.end();
  } catch (error) {
    console.error('❌ Error ejecutando migración:', error);
    process.exit(1);
  }
}

runMigration();
