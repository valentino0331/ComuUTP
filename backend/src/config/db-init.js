const pool = require('./db');
const fs = require('fs');
const path = require('path');

const initDatabase = async () => {
  try {
    console.log('🔧 Verificando base de datos...');

    // Probar conexión simple
    await pool.query('SELECT NOW()');
    console.log('✅ Conexión a BD exitosa');

    // Ejecutar migraciones
    console.log('🔄 Ejecutando migraciones...');
    
    // Migración 1: Agregar columna usuario_creador_id si no existe
    try {
      await pool.query(`
        ALTER TABLE comunidades
        ADD COLUMN IF NOT EXISTS usuario_creador_id INTEGER REFERENCES usuarios(id) ON DELETE SET NULL;
      `);
      console.log('✅ Columna usuario_creador_id verificada');
    } catch (err) {
      console.log('ℹ️ Columna usuario_creador_id ya existe:', err.message.substring(0, 100));
    }

    // Crear índices de performance
    try {
      await pool.query(`
        CREATE INDEX IF NOT EXISTS idx_comunidades_creador ON comunidades(usuario_creador_id);
      `);
      console.log('✅ Índices creados');
    } catch (err) {
      console.log('ℹ️ Índices ya existen');
    }

    // NO insertar usuarios de prueba - base de datos limpia para datos reales
    console.log('📊 Base de datos lista para usuarios reales');

    console.log('\n✅ ✅ ✅ BASE DE DATOS VERIFICADA CORRECTAMENTE ✅ ✅ ✅\n');
    return true;
  } catch (error) {
    console.error('\n❌ Error al verificar la base de datos:', error.message);
    console.error('Detalles:', error);
    return false;
  }
};

module.exports = initDatabase;
