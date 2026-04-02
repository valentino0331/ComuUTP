const pool = require('../config/db');

exports.profile = async (req, res) => {
  try {
    const user = await pool.query('SELECT id, email, nombre FROM usuarios WHERE id = $1', [req.user.id]);
    if (user.rows.length === 0) {
      return res.status(404).json({ error: 'Usuario no encontrado' });
    }
    res.json({ user: user.rows[0] });
  } catch (err) {
    res.status(500).json({ error: 'Error al obtener perfil' });
  }
};
