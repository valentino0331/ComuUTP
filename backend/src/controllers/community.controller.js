const pool = require('../config/db');

exports.create = async (req, res) => {
  const { nombre, descripcion } = req.body;
  try {
    // Validar que los campos no estén vacíos
    if (!nombre || !descripcion) {
      return res.status(400).json({ error: 'Nombre y descripción son requeridos' });
    }

    // Check if user has permission to create community
    const user = await pool.query('SELECT puede_crear_comunidad FROM usuarios WHERE id = $1', [req.user.id]);
    
    if (user.rows.length === 0) {
      return res.status(404).json({ error: 'Usuario no encontrado' });
    }

    if (!user.rows[0].puede_crear_comunidad) {
      return res.status(403).json({ 
        error: 'No tienes permiso para crear comunidades. Contacta a un administrador.',
      });
    }

    // Crear la comunidad
    const result = await pool.query(
      'INSERT INTO comunidades (nombre, descripcion, usuario_creador_id) VALUES ($1, $2, $3) RETURNING *',
      [nombre, descripcion, req.user.id]
    );
    
    const comunidadId = result.rows[0].id;
    
    // Agregar al creador automáticamente como miembro
    try {
      await pool.query(
        'INSERT INTO miembros_comunidad (usuario_id, comunidad_id) VALUES ($1, $2) ON CONFLICT DO NOTHING',
        [req.user.id, comunidadId]
      );
    } catch (err) {
      console.error('Error adding user as member:', err.message);
    }
    
    // Log the action
    await pool.query('INSERT INTO logs_sistema (usuario_id, accion, descripcion) VALUES ($1, $2, $3)', [req.user.id, 'crear_comunidad', `Comunidad: ${nombre}`]);
    
    res.status(201).json({ comunidad: result.rows[0] });
  } catch (err) {
    console.error('Error creating community:', err.message);
    res.status(500).json({ error: 'Error al crear comunidad', details: err.message });
  }
};

exports.list = async (req, res) => {
  try {
    const userId = req.user?.id;
    const isAdmin = req.user?.role === 'admin';

    let result;

    if (isAdmin) {
      // Admins ven TODAS las comunidades con estado de membresía
      result = await pool.query(
        `SELECT
          c.*,
          CASE WHEN mc.id IS NOT NULL THEN true ELSE false END as es_miembro,
          (SELECT COUNT(*) FROM miembros_comunidad WHERE comunidad_id = c.id) as total_miembros
        FROM comunidades c
        LEFT JOIN miembros_comunidad mc ON c.id = mc.comunidad_id AND mc.usuario_id = $1
        ORDER BY c.id DESC`,
        [userId]
      );
    } else if (userId) {
      // Usuarios normales ven todas las comunidades con estado de membresía
      result = await pool.query(
        `SELECT
          c.*,
          CASE WHEN mc.id IS NOT NULL THEN true ELSE false END as es_miembro,
          (SELECT COUNT(*) FROM miembros_comunidad WHERE comunidad_id = c.id) as total_miembros
        FROM comunidades c
        LEFT JOIN miembros_comunidad mc ON c.id = mc.comunidad_id AND mc.usuario_id = $1
        ORDER BY c.id DESC`,
        [userId]
      );
    } else {
      // No autenticados ven todas las comunidades pero sin estado de membresía
      result = await pool.query(
        `SELECT
          c.*,
          false as es_miembro,
          (SELECT COUNT(*) FROM miembros_comunidad WHERE comunidad_id = c.id) as total_miembros
        FROM comunidades c
        ORDER BY c.id DESC`
      );
    }

    res.json({ comunidades: result.rows });
  } catch (err) {
    console.error('Error listing communities:', err.message);
    res.status(500).json({ error: 'Error al listar comunidades', details: err.message });
  }
};

exports.getMyCommunities = async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT 
        c.*,
        mc.fecha_union,
        (SELECT COUNT(*) FROM miembros_comunidad WHERE comunidad_id = c.id) as total_miembros,
        (SELECT COUNT(*) FROM publicaciones WHERE comunidad_id = c.id) as total_posts
      FROM comunidades c
      JOIN miembros_comunidad mc ON c.id = mc.comunidad_id
      WHERE mc.usuario_id = $1
      ORDER BY mc.fecha_union DESC`,
      [req.user.id]
    );
    
    res.json({ comunidades: result.rows, total: result.rows.length });
  } catch (err) {
    console.error('Error listing my communities:', err.message);
    res.status(500).json({ error: 'Error al listar mis comunidades', details: err.message });
  }
};

exports.join = async (req, res) => {
  const { comunidad_id } = req.body;
  
  try {
    if (!comunidad_id) {
      return res.status(400).json({ error: 'ID de comunidad es requerido' });
    }
    
    // Verificar que la comunidad exista
    const comunidad = await pool.query('SELECT * FROM comunidades WHERE id = $1', [comunidad_id]);
    
    if (comunidad.rows.length === 0) {
      return res.status(404).json({ error: 'Comunidad no encontrada' });
    }

    // Verificar que no ya sea miembro
    const existingMember = await pool.query(
      'SELECT * FROM miembros_comunidad WHERE usuario_id = $1 AND comunidad_id = $2',
      [req.user.id, comunidad_id]
    );

    if (existingMember.rows.length > 0) {
      return res.status(409).json({ error: 'Ya eres miembro de esta comunidad' });
    }

    // Agregar como miembro
    const result = await pool.query(
      'INSERT INTO miembros_comunidad (usuario_id, comunidad_id, fecha_union) VALUES ($1, $2, NOW()) RETURNING *',
      [req.user.id, comunidad_id]
    );

    await pool.query('INSERT INTO logs_sistema (usuario_id, accion, descripcion) VALUES ($1, $2, $3)', 
      [req.user.id, 'unirse_comunidad', `Comunidad: ${comunidad_id}`]);

    res.status(201).json({ message: 'Unido a la comunidad', miembro: result.rows[0] });
  } catch (err) {
    console.error('Error joining community:', err.message);
    res.status(500).json({ error: 'Error al unirse a la comunidad', details: err.message });
  }
};

exports.isMember = async (req, res) => {
  const { comunidad_id } = req.params;
  try {
    const result = await pool.query(
      'SELECT * FROM miembros_comunidad WHERE usuario_id = $1 AND comunidad_id = $2',
      [req.user.id, comunidad_id]
    );

    const esMiembro = result.rows.length > 0;
    res.json({ es_miembro: esMiembro });
  } catch (err) {
    console.error('Error checking membership:', err.message);
    res.status(500).json({ error: 'Error al verificar membresía', details: err.message });
  }
};

exports.leave = async (req, res) => {
  const { comunidad_id } = req.body;
  const userId = req.user.id;

  try {
    if (!comunidad_id) {
      return res.status(400).json({ error: 'ID de comunidad es requerido' });
    }

    // Verificar que la comunidad exista
    const comunidad = await pool.query('SELECT * FROM comunidades WHERE id = $1', [comunidad_id]);
    if (comunidad.rows.length === 0) {
      return res.status(404).json({ error: 'Comunidad no encontrada' });
    }

    // Verificar que el usuario sea miembro
    const memberCheck = await pool.query(
      'SELECT * FROM miembros_comunidad WHERE usuario_id = $1 AND comunidad_id = $2',
      [userId, comunidad_id]
    );

    if (memberCheck.rows.length === 0) {
      return res.status(400).json({ error: 'No eres miembro de esta comunidad' });
    }

    // El creador no puede salir de su propia comunidad
    if (comunidad.rows[0].usuario_creador_id === userId) {
      return res.status(403).json({ error: 'El creador no puede salir de la comunidad. Debes eliminarla.' });
    }

    // Eliminar al usuario de la comunidad
    await pool.query(
      'DELETE FROM miembros_comunidad WHERE usuario_id = $1 AND comunidad_id = $2',
      [userId, comunidad_id]
    );

    // Log
    await pool.query(
      'INSERT INTO logs_sistema (usuario_id, accion, descripcion) VALUES ($1, $2, $3)',
      [userId, 'salir_comunidad', `Salió de comunidad: ${comunidad_id}`]
    );

    res.status(200).json({ message: 'Saliste de la comunidad' });
  } catch (err) {
    console.error('Error leaving community:', err.message);
    res.status(500).json({ error: 'Error al salir de la comunidad', details: err.message });
  }
};

exports.delete = async (req, res) => {
  const { id } = req.params;
  const userId = req.user.id;
  
  try {
    // Verificar que la comunidad existe
    const community = await pool.query(
      'SELECT * FROM comunidades WHERE id = $1',
      [id]
    );
    
    if (community.rows.length === 0) {
      return res.status(404).json({ error: 'Comunidad no encontrada' });
    }
    
    // Verificar que el usuario es el creador o es admin
    const communityData = community.rows[0];
    if (communityData.usuario_creador_id !== userId && req.user.role !== 'admin') {
      return res.status(403).json({ error: 'No tienes permiso para eliminar esta comunidad' });
    }
    
    // Eliminar en cascada: likes de posts de la comunidad
    await pool.query(
      'DELETE FROM likes WHERE publicacion_id IN (SELECT id FROM publicaciones WHERE comunidad_id = $1)',
      [id]
    );
    
    // Eliminar comentarios de posts de la comunidad
    await pool.query(
      'DELETE FROM comentarios WHERE publicacion_id IN (SELECT id FROM publicaciones WHERE comunidad_id = $1)',
      [id]
    );
    
    // Eliminar posts de la comunidad
    await pool.query('DELETE FROM publicaciones WHERE comunidad_id = $1', [id]);
    
    // Eliminar miembros de la comunidad
    await pool.query('DELETE FROM miembros_comunidad WHERE comunidad_id = $1', [id]);
    
    // Eliminar la comunidad
    await pool.query('DELETE FROM comunidades WHERE id = $1', [id]);
    
    // Log
    await pool.query(
      'INSERT INTO logs_sistema (usuario_id, accion, descripcion) VALUES ($1, $2, $3)',
      [userId, 'eliminar_comunidad', `Comunidad ${id} eliminada`]
    );
    
    res.status(200).json({ message: 'Comunidad eliminada correctamente' });
  } catch (err) {
    console.error('Error deleting community:', err.message);
    res.status(500).json({ error: 'Error al eliminar comunidad', details: err.message });
  }
};
