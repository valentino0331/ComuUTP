const pool = require('./src/config/db');

async function addRoleColumn() {
  try {
    console.log('\n1. Verificando si la columna role existe...');
    
    // Intentar agregar la columna si no existe
    const result = await pool.query(`
      ALTER TABLE usuarios
      ADD COLUMN IF NOT EXISTS role VARCHAR(20) DEFAULT 'user'
    `);
    
    console.log('✅ Columna role creada/verificada');
    
    // 2. Actualizar el usuario admin
    console.log('\n2. Actualizando usuario a admin...');
    const updated = await pool.query(
      'UPDATE usuarios SET role = $1, puede_crear_comunidad = $2 WHERE email = $3 RETURNING id, email, nombre, role, puede_crear_comunidad',
      ['admin', true, 'u22247388@utp.edu.pe']
    );
    
    if (updated.rows.length > 0) {
      console.log('✅ Usuario actualizado:', updated.rows[0]);
    } else {
      console.log('⚠️ Usuario no encontrado');
    }
    
    process.exit(0);
  } catch (err) {
    console.error('❌ Error:', err.message);
    process.exit(1);
  }
}

addRoleColumn();
