const pool = require('../config/db');

exports.create = async (req, res) => {
  const { comunidad_id, contenido } = req.body;
  try {
    console.log('CREATE POST REQUEST:', { comunidad_id, contenido, userId: req.user.id });
    
    if (!comunidad_id || !contenido) {
      return res.status(400).json({ error: 'Comunidad y contenido son requeridos' });
    }

    // Verificar que el usuario es miembro de la comunidad
    const isMember = await pool.query(
      'SELECT id FROM miembros_comunidad WHERE usuario_id = $1 AND comunidad_id = $2',
      [req.user.id, comunidad_id]
    );

    if (isMember.rows.length === 0) {
      return res.status(403).json({ error: 'No eres miembro de esta comunidad' });
    }

    const result = await pool.query(
      'INSERT INTO publicaciones (usuario_id, comunidad_id, contenido, fecha) VALUES ($1, $2, $3, NOW()) RETURNING *',
      [req.user.id, comunidad_id, contenido]
    );
    
    await pool.query('INSERT INTO logs_sistema (usuario_id, accion, descripcion) VALUES ($1, $2, $3)', [req.user.id, 'crear_post', `Post en comunidad ${comunidad_id}`]);
    
    console.log('POST CREATED:', result.rows[0]);
    res.status(201).json({ publicacion: result.rows[0] });
  } catch (err) {
    console.error('Error creating post:', err.message);
    res.status(500).json({ error: 'Error al crear publicación', details: err.message });
  }
};

exports.list = async (req, res) => {
  try {
    console.log('LIST POSTS - userId:', req.user.id);
    
    const result = await pool.query(
      `SELECT 
        p.id,
        p.usuario_id,
        p.comunidad_id,
        p.contenido,
        p.fecha,
        u.nombre as nombre_usuario,
        c.nombre as nombre_comunidad,
        (SELECT COUNT(*) FROM likes WHERE publicacion_id = p.id) as likes,
        (SELECT COUNT(*) FROM comentarios WHERE publicacion_id = p.id) as comentarios
      FROM publicaciones p
      JOIN usuarios u ON p.usuario_id = u.id
      JOIN comunidades c ON p.comunidad_id = c.id
      WHERE p.comunidad_id IN (
        SELECT comunidad_id FROM miembros_comunidad WHERE usuario_id = $1
      )
      ORDER BY p.fecha DESC`,
      [req.user.id]
    );
    
    console.log('POSTS FOUND:', result.rows.length);
    res.json({ publicaciones: result.rows });
  } catch (err) {
    console.error('Error listing posts:', err.message);
    res.status(500).json({ error: 'Error al listar publicaciones', details: err.message });
  }
};

exports.listByCommunity = async (req, res) => {
  const { id } = req.params;
  try {
    console.log('LIST POSTS BY COMMUNITY:', { id });
    
    const result = await pool.query(
      `SELECT 
        p.id,
        p.usuario_id,
        p.comunidad_id,
        p.contenido,
        p.fecha,
        u.nombre as nombre_usuario,
        c.nombre as nombre_comunidad,
        (SELECT COUNT(*) FROM likes WHERE publicacion_id = p.id) as likes,
        (SELECT COUNT(*) FROM comentarios WHERE publicacion_id = p.id) as comentarios
      FROM publicaciones p
      JOIN usuarios u ON p.usuario_id = u.id
      JOIN comunidades c ON p.comunidad_id = c.id
      WHERE p.comunidad_id = $1
      ORDER BY p.fecha DESC`,
      [id]
    );
    
    console.log('POSTS FOUND:', result.rows.length);
    res.json({ publicaciones: result.rows });
  } catch (err) {
    console.error('Error listing posts:', err.message);
    res.status(500).json({ error: 'Error al listar publicaciones', details: err.message });
  }
};
