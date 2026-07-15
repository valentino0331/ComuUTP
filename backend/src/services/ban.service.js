const pool = require('../config/db');

exports.banUser = async (usuario_id, motivo, comunidad_id, moderador_id) => {
  try {
    await pool.query('INSERT INTO baneos (usuario_id, motivo, comunidad_id, moderador_id) VALUES ($1, $2, $3, $4)', [usuario_id, motivo, comunidad_id, moderador_id]);
  } catch (err) {
    console.error('Error al banear usuario:', err);
  }
};
