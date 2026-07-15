const pool = require('../config/db');

exports.create = async (req, res) => {
  const { tipo, referencia_id, motivo } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO reportes (usuario_id, tipo, referencia_id, motivo) VALUES ($1, $2, $3, $4) RETURNING *',
      [req.user.id, tipo, referencia_id, motivo]
    );
    res.status(201).json({ reporte: result.rows[0] });
  } catch (err) {
    res.status(500).json({ error: 'Error al crear reporte' });
  }
};
