const pool = require('../config/db');

exports.createNotification = async (usuario_id, mensaje) => {
  try {
    await pool.query('INSERT INTO notificaciones (usuario_id, mensaje) VALUES ($1, $2)', [usuario_id, mensaje]);
  } catch (err) {
    console.error('Error al crear notificación:', err);
  }
};
