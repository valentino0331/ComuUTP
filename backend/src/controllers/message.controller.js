const pool = require('../config/db');

// Obtener todas las conversaciones del usuario
exports.getConversations = async (req, res) => {
  const usuario_id = req.user.id;

  try {
    const result = await pool.query(
      `SELECT 
        c.id,
        c.usuario1_id,
        c.usuario2_id,
        c.updated_at,
        u1.nombre as usuario1_nombre,
        u1.foto_perfil as usuario1_foto,
        u2.nombre as usuario2_nombre,
        u2.foto_perfil as usuario2_foto,
        (SELECT COUNT(*) FROM mensajes m WHERE m.conversacion_id = c.id AND m.remitente_id != $1 AND m.leido = false) as mensajes_no_leidos,
        (SELECT contenido FROM mensajes m WHERE m.conversacion_id = c.id ORDER BY m.fecha_envio DESC LIMIT 1) as ultimo_mensaje,
        (SELECT fecha_envio FROM mensajes m WHERE m.conversacion_id = c.id ORDER BY m.fecha_envio DESC LIMIT 1) as ultimo_mensaje_fecha
       FROM conversaciones c
       JOIN usuarios u1 ON c.usuario1_id = u1.id
       JOIN usuarios u2 ON c.usuario2_id = u2.id
       WHERE c.usuario1_id = $1 OR c.usuario2_id = $1
       ORDER BY c.updated_at DESC`,
      [usuario_id]
    );

    res.json({ conversaciones: result.rows });
  } catch (err) {
    console.error('Error al obtener conversaciones:', err.message);
    res.status(500).json({ error: 'Error al obtener conversaciones' });
  }
};

// Obtener mensajes de una conversación
exports.getMessages = async (req, res) => {
  const { conversacion_id } = req.params;
  const usuario_id = req.user.id;

  try {
    // Verificar que el usuario es parte de la conversación
    const conversation = await pool.query(
      'SELECT id FROM conversaciones WHERE id = $1 AND (usuario1_id = $2 OR usuario2_id = $2)',
      [conversacion_id, usuario_id]
    );

    if (conversation.rows.length === 0) {
      return res.status(403).json({ error: 'No tienes acceso a esta conversación' });
    }

    const result = await pool.query(
      `SELECT 
        m.id,
        m.conversacion_id,
        m.remitente_id,
        m.contenido,
        m.leido,
        m.fecha_envio,
        u.nombre as remitente_nombre,
        u.foto_perfil as remitente_foto
       FROM mensajes m
       JOIN usuarios u ON m.remitente_id = u.id
       WHERE m.conversacion_id = $1
       ORDER BY m.fecha_envio ASC`,
      [conversacion_id]
    );

    // Marcar mensajes como leídos
    await pool.query(
      'UPDATE mensajes SET leido = true WHERE conversacion_id = $1 AND remitente_id != $2',
      [conversacion_id, usuario_id]
    );

    res.json({ mensajes: result.rows });
  } catch (err) {
    console.error('Error al obtener mensajes:', err.message);
    res.status(500).json({ error: 'Error al obtener mensajes' });
  }
};

// Enviar mensaje
exports.sendMessage = async (req, res) => {
  const { conversacion_id, contenido } = req.body;
  const remitente_id = req.user.id;

  try {
    if (!contenido || contenido.trim().length === 0) {
      return res.status(400).json({ error: 'El contenido es requerido' });
    }

    // Verificar que el usuario es parte de la conversación
    const conversation = await pool.query(
      'SELECT id FROM conversaciones WHERE id = $1 AND (usuario1_id = $2 OR usuario2_id = $2)',
      [conversacion_id, remitente_id]
    );

    if (conversation.rows.length === 0) {
      return res.status(403).json({ error: 'No tienes acceso a esta conversación' });
    }

    const result = await pool.query(
      'INSERT INTO mensajes (conversacion_id, remitente_id, contenido) VALUES ($1, $2, $3) RETURNING *',
      [conversacion_id, remitente_id, contenido.trim()]
    );

    // Emitir evento de Socket.io para mensaje en tiempo real
    const io = req.app.get('io');
    if (io) {
      io.to(`conversation_${conversacion_id}`).emit('new_message', result.rows[0]);
    }

    res.status(201).json({ mensaje: result.rows[0] });
  } catch (err) {
    console.error('Error al enviar mensaje:', err.message);
    res.status(500).json({ error: 'Error al enviar mensaje' });
  }
};

// Crear nueva conversación
exports.createConversation = async (req, res) => {
  const { usuario2_id } = req.body;
  const usuario1_id = req.user.id;

  try {
    if (usuario2_id === usuario1_id) {
      return res.status(400).json({ error: 'No puedes crear una conversación contigo mismo' });
    }

    // Verificar que los usuarios sean amigos
    const friendship = await pool.query(
      `SELECT id FROM amistades 
       WHERE ((usuario1_id = $1 AND usuario2_id = $2) 
       OR (usuario1_id = $2 AND usuario2_id = $1))
       AND estado = 'aceptada'`,
      [usuario1_id, usuario2_id]
    );

    if (friendship.rows.length === 0) {
      return res.status(403).json({ error: 'Solo puedes enviar mensajes a tus amigos' });
    }

    // Verificar si ya existe una conversación entre estos usuarios
    const existing = await pool.query(
      `SELECT id FROM conversaciones 
       WHERE (usuario1_id = $1 AND usuario2_id = $2) 
       OR (usuario1_id = $2 AND usuario2_id = $1)`,
      [usuario1_id, usuario2_id]
    );

    if (existing.rows.length > 0) {
      return res.json({ conversacion: existing.rows[0] });
    }

    // Crear nueva conversación
    const result = await pool.query(
      'INSERT INTO conversaciones (usuario1_id, usuario2_id) VALUES ($1, $2) RETURNING *',
      [usuario1_id, usuario2_id]
    );

    res.status(201).json({ conversacion: result.rows[0] });
  } catch (err) {
    console.error('Error al crear conversación:', err.message);
    res.status(500).json({ error: 'Error al crear conversación' });
  }
};

// Eliminar conversación
exports.deleteConversation = async (req, res) => {
  const { conversacion_id } = req.params;
  const usuario_id = req.user.id;

  try {
    // Verificar que el usuario es parte de la conversación
    const conversation = await pool.query(
      'SELECT id FROM conversaciones WHERE id = $1 AND (usuario1_id = $2 OR usuario2_id = $2)',
      [conversacion_id, usuario_id]
    );

    if (conversation.rows.length === 0) {
      return res.status(403).json({ error: 'No tienes acceso a esta conversación' });
    }

    await pool.query('DELETE FROM conversaciones WHERE id = $1', [conversacion_id]);

    res.json({ message: 'Conversación eliminada' });
  } catch (err) {
    console.error('Error al eliminar conversación:', err.message);
    res.status(500).json({ error: 'Error al eliminar conversación' });
  }
};
