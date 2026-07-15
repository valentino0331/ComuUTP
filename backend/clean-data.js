/**
 * Script para limpiar toda la data falsa de la base de datos
 * Mantiene la estructura pero elimina todos los datos
 * 
 * Uso: node clean-data.js
 */

require('dotenv').config();
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

async function cleanDatabase() {
  const client = await pool.connect();
  try {
    console.log('🧹 Iniciando limpieza de base de datos...\n');

    // Desactivar verificación de foreign keys temporalmente
    await client.query('SET session_replication_role = REPLICA;');

    // Limpiar todas las tablas (en orden de dependencias)
    const tables = [
      'logs',
      'reportes',
      'notificaciones',
      'historias',
      'likes',
      'comentarios',
      'publicaciones',
      'miembros_comunidad',
      'bloqueos',
      'comunidades',
      'usuarios',
    ];

    for (const table of tables) {
      try {
        const result = await client.query(`TRUNCATE TABLE ${table} CASCADE;`);
        console.log(`✓ Tabla '${table}' limpiada`);
      } catch (error) {
        console.log(`⊘ Tabla '${table}' no existe o no se pudo limpiar`);
      }
    }

    // Reactivar verificación de foreign keys
    await client.query('SET session_replication_role = DEFAULT;');

    console.log('\n✅ Base de datos limpiada completamente!');
    console.log('📝 La BD está lista para recibir datos 100% de usuarios reales logeados.\n');
  } catch (error) {
    console.error('❌ Error al limpiar la BD:', error);
  } finally {
    client.release();
    await pool.end();
  }
}

cleanDatabase();
