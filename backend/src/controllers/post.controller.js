const pool = require('../config/db');

exports.create = async (req, res) => {
  const { comunidad_id, contenido } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO publicaciones (usuario_id, comunidad_id, contenido) VALUES ($1, $2, $3) RETURNING *',
      [req.user.id, comunidad_id, contenido]
    );
    await pool.query('INSERT INTO logs_sistema (usuario_id, accion, descripcion) VALUES ($1, $2, $3)', [req.user.id, 'crear_post', `Post en comunidad ${comunidad_id}`]);
    res.status(201).json({ publicacion: result.rows[0] });
  } catch (err) {
    res.status(500).json({ error: 'Error al crear publicación' });
  }
};

exports.listByCommunity = async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query('SELECT * FROM publicaciones WHERE comunidad_id = $1', [id]);
    res.json({ publicaciones: result.rows });
  } catch (err) {
    res.status(500).json({ error: 'Error al listar publicaciones' });
  }
};
