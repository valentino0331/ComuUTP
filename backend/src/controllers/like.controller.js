const pool = require('../config/db');

exports.like = async (req, res) => {
  const { publicacion_id } = req.body;
  try {
    await pool.query(
      'INSERT INTO likes_publicaciones (usuario_id, publicacion_id) VALUES ($1, $2) ON CONFLICT DO NOTHING',
      [req.user.id, publicacion_id]
    );
    res.json({ message: 'Like registrado' });
  } catch (err) {
    res.status(500).json({ error: 'Error al dar like' });
  }
};

exports.unlike = async (req, res) => {
  const { publicacion_id } = req.body;
  try {
    await pool.query(
      'DELETE FROM likes_publicaciones WHERE usuario_id = $1 AND publicacion_id = $2',
      [req.user.id, publicacion_id]
    );
    res.json({ message: 'Like eliminado' });
  } catch (err) {
    res.status(500).json({ error: 'Error al quitar like' });
  }
};
