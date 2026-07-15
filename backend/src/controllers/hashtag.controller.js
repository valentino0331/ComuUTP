const pool = require('../config/db');

// Procesar hashtags en un post
exports.processHashtags = async (req, res) => {
  const { post_id, contenido } = req.body;

  try {
    // Extraer hashtags del contenido (#hashtag)
    const hashtagRegex = /#(\w+)/g;
    const matches = contenido.match(hashtagRegex);

    if (!matches || matches.length === 0) {
      return res.json({ hashtags: [] });
    }

    const hashtagNames = matches.map(m => m.substring(1).toLowerCase());

    // Insertar o actualizar hashtags
    const hashtagPromises = hashtagNames.map(async (name) => {
      const result = await pool.query(
        'INSERT INTO hashtags (nombre, contador) VALUES ($1, 1) ON CONFLICT (nombre) DO UPDATE SET contador = hashtags.contador + 1 RETURNING id',
        [name]
      );

      const hashtagId = result.rows[0].id;

      // Relacionar post con hashtag
      await pool.query(
        'INSERT INTO post_hashtags (post_id, hashtag_id) VALUES ($1, $2) ON CONFLICT DO NOTHING',
        [post_id, hashtagId]
      );

      return { id: hashtagId, nombre: name };
    });

    const hashtags = await Promise.all(hashtagPromises);
    res.json({ hashtags });
  } catch (err) {
    console.error('Error al procesar hashtags:', err.message);
    res.status(500).json({ error: 'Error al procesar hashtags' });
  }
};

// Obtener trending hashtags
exports.getTrending = async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT nombre, contador FROM hashtags ORDER BY contador DESC LIMIT 20'
    );

    res.json({ hashtags: result.rows });
  } catch (err) {
    console.error('Error al obtener trending hashtags:', err.message);
    res.status(500).json({ error: 'Error al obtener trending hashtags' });
  }
};

// Buscar posts por hashtag
exports.searchByHashtag = async (req, res) => {
  const { hashtag } = req.params;

  try {
    const result = await pool.query(
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
       JOIN post_hashtags ph ON p.id = ph.post_id
       JOIN hashtags h ON ph.hashtag_id = h.id
       WHERE h.nombre = $1
       ORDER BY p.fecha DESC`,
      [hashtag.toLowerCase()]
    );

    res.json({ posts: result.rows });
  } catch (err) {
    console.error('Error al buscar posts por hashtag:', err.message);
    res.status(500).json({ error: 'Error al buscar posts por hashtag' });
  }
};
