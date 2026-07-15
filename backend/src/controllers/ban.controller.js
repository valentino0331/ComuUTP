const pool = require('../config/db');

exports.ban = async (req, res) => {
  const { usuario_id, motivo, comunidad_id } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO baneos (usuario_id, motivo, comunidad_id, moderador_id) VALUES ($1, $2, $3, $4) RETURNING *',
      [usuario_id, motivo, comunidad_id, req.user.id]
    );
    res.status(201).json({ baneo: result.rows[0] });
  } catch (err) {
    res.status(500).json({ error: 'Error al banear usuario' });
  }
};
