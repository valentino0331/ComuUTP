const pool = require('../config/db');

// Crear menciones al procesar contenido
exports.createMentions = async (req, res) => {
  const { publicacion_id, comentario_id, contenido } = req.body;
  const usuario_id = req.user.id;

  try {
    // Extraer menciones del contenido (@usuario)
    const mentionRegex = /@(\w+)/g;
    const matches = contenido.match(mentionRegex);

    if (!matches || matches.length === 0) {
      return res.json({ menciones: [] });
    }

    // Obtener IDs de usuarios mencionados
    const usernames = matches.map(m => m.substring(1));
    const usersResult = await pool.query(
      'SELECT id, nombre FROM usuarios WHERE nombre = ANY($1)',
      [usernames]
    );

    const mentionedUsers = usersResult.rows;
    const mentionPromises = mentionedUsers.map(user => {
      const data = {
        usuario_id,
        mencionado_id: user.id,
        leida: false
      };

      if (publicacion_id) {
        data.publicacion_id = publicacion_id;
      }
      if (comentario_id) {
        data.comentario_id = comentario_id;
      }

      return pool.query(
        'INSERT INTO menciones (usuario_id, publicacion_id, comentario_id, mencionado_id, leida) VALUES ($1, $2, $3, $4, $5) ON CONFLICT DO NOTHING',
        [data.usuario_id, data.publicacion_id || null, data.comentario_id || null, data.mencionado_id, data.leida]
      );
    });

    await Promise.all(mentionPromises);

    res.json({ menciones: mentionedUsers.map(u => u.nombre) });
  } catch (err) {
    console.error('Error al crear menciones:', err.message);
    res.status(500).json({ error: 'Error al crear menciones' });
  }
};

// Obtener menciones del usuario
exports.getUserMentions = async (req, res) => {
  const usuario_id = req.user.id;

  try {
    const result = await pool.query(
      `SELECT 
        m.id,
        m.usuario_id,
        m.publicacion_id,
        m.comentario_id,
        m.leida,
        m.created_at,
        u.nombre as usuario_nombre,
        u.foto_perfil as usuario_foto,
        p.contenido as publicacion_contenido,
        c.contenido as comentario_contenido
       FROM menciones m
       JOIN usuarios u ON m.usuario_id = u.id
       LEFT JOIN publicaciones p ON m.publicacion_id = p.id
       LEFT JOIN comentarios c ON m.comentario_id = c.id
       WHERE m.mencionado_id = $1
       ORDER BY m.created_at DESC`,
      [usuario_id]
    );

    res.json({ menciones: result.rows });
  } catch (err) {
    console.error('Error al obtener menciones:', err.message);
    res.status(500).json({ error: 'Error al obtener menciones' });
  }
};

// Marcar mención como leída
exports.markAsRead = async (req, res) => {
  const { mencion_id } = req.params;
  const usuario_id = req.user.id;

  try {
    await pool.query(
      'UPDATE menciones SET leida = true WHERE id = $1 AND mencionado_id = $2',
      [mencion_id, usuario_id]
    );

    res.json({ message: 'Mención marcada como leída' });
  } catch (err) {
    console.error('Error al marcar mención como leída:', err.message);
    res.status(500).json({ error: 'Error al marcar mención como leída' });
  }
};

// Buscar usuarios para autocompletado
exports.searchUsers = async (req, res) => {
  const { query } = req.query;

  try {
    if (!query || query.length < 2) {
      return res.json({ usuarios: [] });
    }

    const result = await pool.query(
      'SELECT id, nombre, foto_perfil FROM usuarios WHERE nombre ILIKE $1 LIMIT 10',
      [`%${query}%`]
    );

    res.json({ usuarios: result.rows });
  } catch (err) {
    console.error('Error al buscar usuarios:', err.message);
    res.status(500).json({ error: 'Error al buscar usuarios' });
  }
};
