const pool = require('./src/config/db');

async function verifyAdmin() {
  try {
    const email = 'u22247388@utp.edu.pe';
    
    // 1. Ver usuario actual
    console.log('\n1. Buscando usuario...');
    const user = await pool.query('SELECT id, email, nombre, role FROM usuarios WHERE email = $1', [email]);
    
    if (user.rows.length === 0) {
      console.log('❌ Usuario no encontrado');
      process.exit(1);
    }
    
    console.log('✅ Usuario encontrado:', user.rows[0]);
    
    // 2. Actualizar role a admin si no lo es
    if (user.rows[0].role !== 'admin') {
      console.log('\n2. Actualizando role a admin...');
      const updated = await pool.query(
        'UPDATE usuarios SET role = $1 WHERE email = $2 RETURNING id, email, nombre, role',
        ['admin', email]
      );
      console.log('✅ Actualizado:', updated.rows[0]);
    } else {
      console.log('\n✅ El usuario ya es admin');
    }
    
    // 3. Actualizar puede_crear_comunidad a true
    console.log('\n3. Actualizando puede_crear_comunidad...');
    const updated2 = await pool.query(
      'UPDATE usuarios SET puede_crear_comunidad = $1 WHERE email = $2 RETURNING id, email, nombre, role, puede_crear_comunidad',
      [true, email]
    );
    console.log('✅ Actualizado:', updated2.rows[0]);
    
    console.log('\n✅ Usuario verificado y actualizado correctamente!');
    process.exit(0);
  } catch (err) {
    console.error('❌ Error:', err.message);
    process.exit(1);
  }
}

verifyAdmin();
