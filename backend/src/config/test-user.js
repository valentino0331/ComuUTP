const pool = require('./db');
const bcrypt = require('bcryptjs');

const testUser = async () => {
  try {
    // Verificar usuarios existentes
    console.log('📋 Usuarios en la BD:');
    const users = await pool.query('SELECT id, email, nombre FROM usuarios');
    console.log(users.rows);

    // Crear usuario de prueba si no existe
    const email = 'u22247388@utp.edu.pe';
    const password = 'Valepro0331.';
    const nombre = 'Vale Pro';

    const exists = await pool.query('SELECT * FROM usuarios WHERE email = $1', [email]);
    
    if (exists.rows.length > 0) {
      console.log('✅ Usuario ya existe:', exists.rows[0]);
    } else {
      console.log('➕ Creando usuario de prueba...');
      const hashedPassword = await bcrypt.hash(password, 10);
      const result = await pool.query(
        'INSERT INTO usuarios (email, password, nombre) VALUES ($1, $2, $3) RETURNING id, email, nombre',
        [email, hashedPassword, nombre]
      );
      console.log('✅ Usuario creado:', result.rows[0]);
    }

    process.exit(0);
  } catch (err) {
    console.error('❌ Error:', err.message);
    process.exit(1);
  }
};

testUser();
