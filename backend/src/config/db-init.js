const pool = require('./db');

const initDatabase = async () => {
  try {
    console.log('🔧 Verificando base de datos...');

    // Probar conexión simple
    await pool.query('SELECT NOW()');
    console.log('✅ Conexión a BD exitosa');

    // Insertar usuarios de prueba si no existen
    console.log('👥 Insertando usuarios de prueba...');
    await pool.query(`
      INSERT INTO usuarios (email, nombre, password) VALUES 
        ('u20221234@utp.edu.pe', 'Carlos Rodríguez', '$2b$10$Di86xWv/4v/BwLsgjm.RUuZdZPO5TGQ/Rs.FFsEYgPl1RkL0D31Eu'),
        ('u20234567@utp.edu.pe', 'Ana Martínez', '$2b$10$Di86xWv/4v/BwLsgjm.RUuZdZPO5TGQ/Rs.FFsEYgPl1RkL0D31Eu'),
        ('u20245678@utp.edu.pe', 'Luis Fernández', '$2b$10$Di86xWv/4v/BwLsgjm.RUuZdZPO5TGQ/Rs.FFsEYgPl1RkL0D31Eu'),
        ('u22247388@utp.edu.pe', 'María López', '$2b$10$Di86xWv/4v/BwLsgjm.RUuZdZPO5TGQ/Rs.FFsEYgPl1RkL0D31Eu'),
        ('u20238901@utp.edu.pe', 'Pedro Gómez', '$2b$10$Di86xWv/4v/BwLsgjm.RUuZdZPO5TGQ/Rs.FFsEYgPl1RkL0D31Eu'),
        ('u20247890@utp.edu.pe', 'Sofía Ramírez', '$2b$10$Di86xWv/4v/BwLsgjm.RUuZdZPO5TGQ/Rs.FFsEYgPl1RkL0D31Eu'),
        ('u20236789@utp.edu.pe', 'Diego Torres', '$2b$10$Di86xWv/4v/BwLsgjm.RUuZdZPO5TGQ/Rs.FFsEYgPl1RkL0D31Eu'),
        ('u20245612@utp.edu.pe', 'Lucía Vargas', '$2b$10$Di86xWv/4v/BwLsgjm.RUuZdZPO5TGQ/Rs.FFsEYgPl1RkL0D31Eu')
      ON CONFLICT (email) DO UPDATE SET password = EXCLUDED.password
    `);
    console.log('✅ Usuarios de prueba insertados/actualizados');

    console.log('\n✅ ✅ ✅ BASE DE DATOS VERIFICADA CORRECTAMENTE ✅ ✅ ✅\n');
    return true;
  } catch (error) {
    console.error('\n❌ Error al verificar la base de datos:', error.message);
    console.error('Detalles:', error);
    return false;
  }
};

module.exports = initDatabase;
