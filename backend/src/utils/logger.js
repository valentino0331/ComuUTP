const pool = require('../config/db');

exports.log = async (usuario_id, accion, descripcion) => {
  try {
    await pool.query('INSERT INTO logs_sistema (usuario_id, accion, descripcion) VALUES ($1, $2, $3)', [usuario_id, accion, descripcion]);
  } catch (err) {
    console.error('Error al guardar log:', err);
  }
};
