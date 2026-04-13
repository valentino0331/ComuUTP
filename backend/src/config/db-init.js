const pool = require('./db');

const initDatabase = async () => {
  try {
    console.log('🔧 Verificando base de datos...');

    // Probar conexión simple
    await pool.query('SELECT NOW()');
    console.log('✅ Conexión a BD exitosa');

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
