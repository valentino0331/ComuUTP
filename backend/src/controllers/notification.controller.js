const pool = require('../config/db');

exports.list = async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM notificaciones WHERE usuario_id = $1', [req.user.id]);
    res.json({ notificaciones: result.rows });
  } catch (err) {
    res.status(500).json({ error: 'Error al obtener notificaciones' });
  }
};
