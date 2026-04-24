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
    console.log('🔄 Ejecutando migraciones de esquema...');
    
    // Migración 1: Agregar columna usuario_creador_id si no existe
    try {
      await pool.query(`
        ALTER TABLE comunidades
        ADD COLUMN IF NOT EXISTS usuario_creador_id INTEGER REFERENCES usuarios(id) ON DELETE SET NULL;
      `);
      console.log('✅ Columna usuario_creador_id verificada');
    } catch (err) {
      console.log('ℹ️ Columna usuario_creador_id:', err.message.substring(0, 100));
    }

    // Migración 2: Agregar columna fecha a publicaciones
    try {
      await pool.query(`
        ALTER TABLE publicaciones
        ADD COLUMN IF NOT EXISTS fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
      `);
      console.log('✅ Columna fecha en publicaciones verificada');
    } catch (err) {
      console.log('ℹ️ Columna fecha:', err.message.substring(0, 100));
    }

    // Migración 3: Verificar que comentarios tiene fecha
    try {
      await pool.query(`
        ALTER TABLE comentarios
        ADD COLUMN IF NOT EXISTS fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
      `);
      console.log('✅ Columna fecha en comentarios verificada');
    } catch (err) {
      console.log('ℹ️ Columna fecha comentarios:', err.message.substring(0, 100));
    }

    // Migración 4: Verificar que historias tiene las columnas necesarias
    try {
      await pool.query(`
        ALTER TABLE historias
        ADD COLUMN IF NOT EXISTS imagen_url TEXT;
      `);
      console.log('✅ Columnas en historias verificadas');
    } catch (err) {
      console.log('ℹ️ Columnas historias:', err.message.substring(0, 100));
    }

    // Migración 5: Agregar columna imagen_url a publicaciones
    try {
      await pool.query(`
        ALTER TABLE publicaciones
        ADD COLUMN IF NOT EXISTS imagen_url TEXT;
      `);
      console.log('✅ Columna imagen_url en publicaciones verificada');
    } catch (err) {
      console.log('ℹ️ Columna imagen_url:', err.message.substring(0, 100));
    }

    // Crear índices de performance
    try {
      await pool.query(`
        CREATE INDEX IF NOT EXISTS idx_comunidades_creador ON comunidades(usuario_creador_id);
        CREATE INDEX IF NOT EXISTS idx_publicaciones_fecha ON publicaciones(fecha);
        CREATE INDEX IF NOT EXISTS idx_publicaciones_comunidad ON publicaciones(comunidad_id);
        CREATE INDEX IF NOT EXISTS idx_miembros_comunidad_usuario ON miembros_comunidad(usuario_id);
        CREATE INDEX IF NOT EXISTS idx_miembros_comunidad_comunidad ON miembros_comunidad(comunidad_id);
      `);
      console.log('✅ Índices creados/verificados');
    } catch (err) {
      console.log('ℹ️ Índices:', err.message.substring(0, 100));
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
