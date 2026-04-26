const pool = require('../config/db');

exports.profile = async (req, res) => {
  try {
    const user = await pool.query(`
      SELECT id, email, nombre, foto_perfil, bio, gustos,
        notificaciones_activas, email_notificaciones, notificaciones_menciones,
        modo_oscuro, privacidad_perfil_publico, privacidad_mostrar_email, idioma
      FROM usuarios WHERE id = $1
    `, [req.user.id]);
    
    if (user.rows.length === 0) {
      return res.status(404).json({ error: 'Usuario no encontrado' });
    }

    // Obtener comunidades del usuario
    const comunidades = await pool.query(`
      SELECT 
        c.id,
        c.nombre,
        c.descripcion,
        c.usuario_creador_id,
        mc.fecha_union,
        (SELECT COUNT(*) FROM miembros_comunidad WHERE comunidad_id = c.id) as total_miembros,
        (SELECT COUNT(*) FROM publicaciones WHERE comunidad_id = c.id) as total_posts
      FROM comunidades c
      JOIN miembros_comunidad mc ON c.id = mc.comunidad_id
      WHERE mc.usuario_id = $1
      ORDER BY mc.fecha_union DESC
    `, [req.user.id]);

    res.json({ 
      usuario: user.rows[0],
      comunidades: comunidades.rows,
      total_comunidades: comunidades.rows.length
    });
  } catch (err) {
    console.error('Error al obtener perfil:', err.message);
    res.status(500).json({ error: 'Error al obtener perfil', details: err.message });
  }
};

// Actualizar perfil del usuario
exports.updateProfile = async (req, res) => {
  try {
    const userId = req.user.id;
    const {
      nombre, bio, carrera, gustos, foto_perfil, foto_portada,
      notificaciones_activas, email_notificaciones, notificaciones_menciones,
      modo_oscuro, privacidad_perfil_publico, privacidad_mostrar_email, idioma
    } = req.body;

    console.log('Actualizando perfil para usuario:', userId);
    console.log('foto_perfil length:', foto_perfil ? foto_perfil.length : 0);
    console.log('foto_portada length:', foto_portada ? foto_portada.length : 0);

    if (!nombre) {
      return res.status(400).json({ error: 'El nombre es requerido' });
    }

    // Convertir gustos array a string si es necesario
    const gustosStr = Array.isArray(gustos) ? gustos.join(',') : gustos;

    const result = await pool.query(
      `UPDATE usuarios
         SET nombre = $1, bio = COALESCE($2, bio), carrera = COALESCE($3, carrera), gustos = COALESCE($4, gustos),
         foto_perfil = COALESCE($5, foto_perfil),
         foto_portada = COALESCE($6, foto_portada),
         notificaciones_activas = COALESCE($7, notificaciones_activas),
         email_notificaciones = COALESCE($8, email_notificaciones),
         notificaciones_menciones = COALESCE($9, notificaciones_menciones),
         modo_oscuro = COALESCE($10, modo_oscuro),
         privacidad_perfil_publico = COALESCE($11, privacidad_perfil_publico),
         privacidad_mostrar_email = COALESCE($12, privacidad_mostrar_email),
         idioma = COALESCE($13, idioma),
         updated_at = CURRENT_TIMESTAMP
       WHERE id = $14
       RETURNING id, email, nombre, bio, carrera, gustos, notificaciones_activas, email_notificaciones, notificaciones_menciones, modo_oscuro, privacidad_perfil_publico, privacidad_mostrar_email, idioma, foto_perfil, foto_portada, created_at`,
      [
        nombre,
        bio,
        carrera,
        gustosStr,
        foto_perfil,
        foto_portada,
        notificaciones_activas,
        email_notificaciones,
        notificaciones_menciones,
        modo_oscuro,
        privacidad_perfil_publico,
        privacidad_mostrar_email,
        idioma,
        userId
      ]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Usuario no encontrado' });
    }

    res.json({
      message: 'Perfil actualizado exitosamente',
      usuario: result.rows[0]
    });
  } catch (err) {
    console.error('Error al actualizar perfil:', err.message);
    res.status(500).json({ error: 'Error al actualizar perfil: ' + err.message });
  }
};

// Obtener seguidores de un usuario
exports.getFollowers = async (req, res) => {
  try {
    const userId = req.params.id || req.user.id;

    const result = await pool.query(
      `SELECT 
        s.id,
        s.seguidor_id,
        s.seguido_id,
        s.estado,
        s.created_at,
        u.nombre as seguidor_nombre,
        u.email as seguidor_email,
        u.foto_perfil as seguidor_foto_perfil,
        u.biografia as seguidor_biografia
       FROM seguidores s
       JOIN usuarios u ON s.seguidor_id = u.id
       WHERE s.seguido_id = $1 AND s.estado = 'aceptado'
       ORDER BY s.created_at DESC`,
      [userId]
    );

    res.json({ 
      seguidores: result.rows,
      total: result.rows.length 
    });
  } catch (err) {
    console.error('Error al obtener seguidores:', err.message);
    res.status(500).json({ error: 'Error al obtener seguidores' });
  }
};

// Obtener a quiénes sigue un usuario
exports.getFollowing = async (req, res) => {
  try {
    const userId = req.params.id || req.user.id;

    const result = await pool.query(
      `SELECT 
        s.id,
        s.seguidor_id,
        s.seguido_id,
        s.estado,
        s.created_at,
        u.nombre as seguido_nombre,
        u.email as seguido_email,
        u.foto_perfil as seguido_foto_perfil,
        u.biografia as seguido_biografia
       FROM seguidores s
       JOIN usuarios u ON s.seguido_id = u.id
       WHERE s.seguidor_id = $1 AND s.estado = 'aceptado'
       ORDER BY s.created_at DESC`,
      [userId]
    );

    res.json({ 
      siguiendo: result.rows,
      total: result.rows.length 
    });
  } catch (err) {
    console.error('Error al obtener seguidos:', err.message);
    res.status(500).json({ error: 'Error al obtener seguidos' });
  }
};

// Eliminar cuenta de usuario (GDPR Art. 17 - Derecho al olvido)
exports.deleteAccount = async (req, res) => {
  try {
    const userId = req.user.id;
    
    // Eliminar datos del usuario en cascada (orden importa por foreign keys)
    await pool.query('DELETE FROM likes WHERE usuario_id = $1', [userId]);
    await pool.query('DELETE FROM comentarios WHERE usuario_id = $1', [userId]);
    await pool.query('DELETE FROM publicaciones WHERE usuario_id = $1', [userId]);
    await pool.query('DELETE FROM miembros_comunidad WHERE usuario_id = $1', [userId]);
    await pool.query('DELETE FROM seguidores WHERE seguidor_id = $1 OR seguido_id = $1', [userId]);
    await pool.query('DELETE FROM notificaciones WHERE usuario_id = $1', [userId]);
    await pool.query('DELETE FROM reportes WHERE usuario_id = $1', [userId]);
    await pool.query('DELETE FROM logs_sistema WHERE usuario_id = $1', [userId]);
    await pool.query('DELETE FROM usuarios WHERE id = $1', [userId]);
    
    res.json({ 
      message: 'Cuenta eliminada correctamente. Todos tus datos han sido borrados del sistema.' 
    });
  } catch (err) {
    console.error('Error al eliminar cuenta:', err.message);
    res.status(500).json({ error: 'Error al eliminar cuenta' });
  }
};
