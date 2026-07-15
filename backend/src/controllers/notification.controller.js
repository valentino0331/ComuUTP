const pool = require('../config/db');

exports.list = async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM notificaciones WHERE usuario_id = $1', [req.user.id]);
    res.json({ notificaciones: result.rows });
  } catch (err) {
    res.status(500).json({ error: 'Error al obtener notificaciones' });
  }
};

// Broadcast notification to all users (admin only)
exports.broadcast = async (req, res) => {
  try {
    const { mensaje, tipo = 'general' } = req.body;
    const adminId = req.user.id;

    if (!mensaje || mensaje.trim().length === 0) {
      return res.status(400).json({ error: 'El mensaje es requerido' });
    }

    // Get all users
    const usersResult = await pool.query('SELECT id FROM usuarios');
    const users = usersResult.rows;

    // Insert notification for each user
    const insertPromises = users.map(user =>
      pool.query(
        'INSERT INTO notificaciones (usuario_id, tipo, mensaje, leida, created_at) VALUES ($1, $2, $3, false, CURRENT_TIMESTAMP)',
        [user.id, tipo, mensaje]
      )
    );

    await Promise.all(insertPromises);

    // Log the action
    await pool.query(
      'INSERT INTO logs_sistema (usuario_id, accion, descripcion) VALUES ($1, $2, $3)',
      [adminId, 'broadcast_notificacion', `Broadcast a ${users.length} usuarios: ${mensaje.substring(0, 50)}...`]
    );

    res.json({
      message: 'Notificación enviada a todos los usuarios',
      totalUsuarios: users.length,
    });
  } catch (err) {
    console.error('Error broadcasting notification:', err.message);
    res.status(500).json({ error: 'Error al enviar notificaciones' });
  }
};
