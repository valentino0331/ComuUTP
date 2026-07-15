const pool = require('../config/db');

// Guardar post
exports.savePost = async (req, res) => {
  const { post_id, coleccion_id } = req.body;
  const usuario_id = req.user.id;

  try {
    const result = await pool.query(
      'INSERT INTO posts_guardados (usuario_id, post_id, coleccion_id) VALUES ($1, $2, $3) ON CONFLICT (usuario_id, post_id) DO NOTHING RETURNING *',
      [usuario_id, post_id, coleccion_id || null]
    );

    if (result.rows.length > 0) {
      res.status(201).json({ saved: result.rows[0] });
    } else {
      res.json({ message: 'Post ya guardado' });
    }
  } catch (err) {
    console.error('Error al guardar post:', err.message);
    res.status(500).json({ error: 'Error al guardar post' });
  }
};

// Desguardar post
exports.unsavePost = async (req, res) => {
  const { post_id } = req.params;
  const usuario_id = req.user.id;

  try {
    await pool.query(
      'DELETE FROM posts_guardados WHERE usuario_id = $1 AND post_id = $2',
      [usuario_id, post_id]
    );

    res.json({ message: 'Post desguardado' });
  } catch (err) {
    console.error('Error al desguardar post:', err.message);
    res.status(500).json({ error: 'Error al desguardar post' });
  }
};

// Obtener posts guardados del usuario
exports.getSavedPosts = async (req, res) => {
  const usuario_id = req.user.id;

  try {
    const result = await pool.query(
      `SELECT 
        pg.id,
        pg.post_id,
        pg.created_at as guardado_en,
        p.contenido,
        p.fecha,
        u.nombre as usuario_nombre,
        u.foto_perfil as usuario_foto,
        c.nombre as comunidad_nombre
       FROM posts_guardados pg
       JOIN publicaciones p ON pg.post_id = p.id
       JOIN usuarios u ON p.usuario_id = u.id
       JOIN comunidades c ON p.comunidad_id = c.id
       WHERE pg.usuario_id = $1
       ORDER BY pg.created_at DESC`,
      [usuario_id]
    );

    res.json({ posts: result.rows });
  } catch (err) {
    console.error('Error al obtener posts guardados:', err.message);
    res.status(500).json({ error: 'Error al obtener posts guardados' });
  }
};

// Crear colección
exports.createCollection = async (req, res) => {
  const { nombre, descripcion, privada } = req.body;
  const usuario_id = req.user.id;

  try {
    const result = await pool.query(
      'INSERT INTO colecciones (usuario_id, nombre, descripcion, privada) VALUES ($1, $2, $3, $4) RETURNING *',
      [usuario_id, nombre, descripcion, privada !== false]
    );

    res.status(201).json({ coleccion: result.rows[0] });
  } catch (err) {
    console.error('Error al crear colección:', err.message);
    res.status(500).json({ error: 'Error al crear colección' });
  }
};

// Obtener colecciones del usuario
exports.getCollections = async (req, res) => {
  const usuario_id = req.user.id;

  try {
    const result = await pool.query(
      `SELECT 
        c.*,
        (SELECT COUNT(*) FROM posts_guardados WHERE coleccion_id = c.id) as total_posts
       FROM colecciones c
       WHERE c.usuario_id = $1
       ORDER BY c.created_at DESC`,
      [usuario_id]
    );

    res.json({ colecciones: result.rows });
  } catch (err) {
    console.error('Error al obtener colecciones:', err.message);
    res.status(500).json({ error: 'Error al obtener colecciones' });
  }
};
