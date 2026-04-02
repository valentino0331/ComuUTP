const pool = require('../config/db');

exports.create = async (req, res) => {
  const { publicacion_id, contenido } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO comentarios (usuario_id, publicacion_id, contenido) VALUES ($1, $2, $3) RETURNING *',
      [req.user.id, publicacion_id, contenido]
    );
    await pool.query('INSERT INTO logs_sistema (usuario_id, accion, descripcion) VALUES ($1, $2, $3)', [req.user.id, 'crear_comentario', `Comentario en publicación ${publicacion_id}`]);
    res.status(201).json({ comentario: result.rows[0] });
  } catch (err) {
    res.status(500).json({ error: 'Error al crear comentario' });
  }
};
