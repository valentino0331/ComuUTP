const pool = require('../config/db');

// Búsqueda avanzada
exports.search = async (req, res) => {
  const { query, type = 'all' } = req.query;

  try {
    if (!query || query.length < 2) {
      return res.json({ results: [] });
    }

    const searchTerm = `%${query}%`;
    let results = {};

    if (type === 'all' || type === 'users') {
      const users = await pool.query(
        'SELECT id, nombre, foto_perfil, biografia FROM usuarios WHERE nombre ILIKE $1 OR biografia ILIKE $1 LIMIT 10',
        [searchTerm]
      );
      results.users = users.rows;
    }

    if (type === 'all' || type === 'posts') {
      const posts = await pool.query(
        `SELECT 
          p.id,
          p.contenido,
          p.fecha,
          u.nombre as usuario_nombre,
          u.foto_perfil as usuario_foto,
          c.nombre as comunidad_nombre
         FROM publicaciones p
         JOIN usuarios u ON p.usuario_id = u.id
         JOIN comunidades c ON p.comunidad_id = c.id
         WHERE p.contenido ILIKE $1
         ORDER BY p.fecha DESC
         LIMIT 10`,
        [searchTerm]
      );
      results.posts = posts.rows;
    }

    if (type === 'all' || type === 'communities') {
      const communities = await pool.query(
        'SELECT id, nombre, descripcion FROM comunidades WHERE nombre ILIKE $1 OR descripcion ILIKE $1 LIMIT 10',
        [searchTerm]
      );
      results.communities = communities.rows;
    }

    if (type === 'all' || type === 'hashtags') {
      const hashtags = await pool.query(
        'SELECT nombre, contador FROM hashtags WHERE nombre ILIKE $1 ORDER BY contador DESC LIMIT 10',
        [searchTerm]
      );
      results.hashtags = hashtags.rows;
    }

    res.json({ results });
  } catch (err) {
    console.error('Error en búsqueda:', err.message);
    res.status(500).json({ error: 'Error en búsqueda' });
  }
};
