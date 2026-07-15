const pool = require('../config/db');

// Enviar solicitud de amistad
exports.sendFriendRequest = async (req, res) => {
  try {
    const userId = req.user.id;
    const { amigoId } = req.body;

    if (!amigoId) {
      return res.status(400).json({ error: 'El ID del amigo es requerido' });
    }

    if (userId === amigoId) {
      return res.status(400).json({ error: 'No puedes enviarte una solicitud a ti mismo' });
    }

    // Verificar si ya existe una amistad o solicitud
    const existingFriendship = await pool.query(
      'SELECT * FROM amistades WHERE (usuario_id = $1 AND amigo_id = $2) OR (usuario_id = $2 AND amigo_id = $1)',
      [userId, amigoId]
    );

    if (existingFriendship.rows.length > 0) {
      return res.status(400).json({ error: 'Ya existe una amistad o solicitud pendiente' });
    }

    // Crear solicitud de amistad
    const result = await pool.query(
      `INSERT INTO amistades (usuario_id, amigo_id, estado) 
       VALUES ($1, $2, 'pendiente') 
       RETURNING id, usuario_id, amigo_id, estado, created_at`,
      [userId, amigoId]
    );

    // Obtener información del usuario que envió la solicitud
    const userResult = await pool.query(
      'SELECT nombre, foto_perfil FROM usuarios WHERE id = $1',
      [userId]
    );

    res.status(201).json({
      friendship: result.rows[0],
      user: userResult.rows[0]
    });
  } catch (err) {
    console.error('Error al enviar solicitud de amistad:', err.message);
    res.status(500).json({ error: 'Error al enviar solicitud de amistad', details: err.message });
  }
};

// Aceptar solicitud de amistad
exports.acceptFriendRequest = async (req, res) => {
  try {
    const userId = req.user.id;
    const { solicitudId } = req.params;

    // Verificar que la solicitud pertenezca al usuario
    const friendship = await pool.query(
      'SELECT * FROM amistades WHERE id = $1 AND amigo_id = $2',
      [solicitudId, userId]
    );

    if (friendship.rows.length === 0) {
      return res.status(404).json({ error: 'Solicitud no encontrada' });
    }

    // Actualizar estado a aceptada
    const result = await pool.query(
      `UPDATE amistades 
       SET estado = 'aceptada', updated_at = CURRENT_TIMESTAMP 
       WHERE id = $1 
       RETURNING *`,
      [solicitudId]
    );

    res.json(result.rows[0]);
  } catch (err) {
    console.error('Error al aceptar solicitud de amistad:', err.message);
    res.status(500).json({ error: 'Error al aceptar solicitud de amistad', details: err.message });
  }
};

// Rechazar solicitud de amistad
exports.rejectFriendRequest = async (req, res) => {
  try {
    const userId = req.user.id;
    const { solicitudId } = req.params;

    // Verificar que la solicitud pertenezca al usuario
    const friendship = await pool.query(
      'SELECT * FROM amistades WHERE id = $1 AND amigo_id = $2',
      [solicitudId, userId]
    );

    if (friendship.rows.length === 0) {
      return res.status(404).json({ error: 'Solicitud no encontrada' });
    }

    // Actualizar estado a rechazada o eliminar
    await pool.query(
      'DELETE FROM amistades WHERE id = $1',
      [solicitudId]
    );

    res.json({ message: 'Solicitud rechazada' });
  } catch (err) {
    console.error('Error al rechazar solicitud de amistad:', err.message);
    res.status(500).json({ error: 'Error al rechazar solicitud de amistad', details: err.message });
  }
};

// Obtener solicitudes de amistad pendientes
exports.getPendingRequests = async (req, res) => {
  try {
    const userId = req.user.id;

    const result = await pool.query(
      `SELECT a.id, a.usuario_id, a.amigo_id, a.estado, a.created_at,
              u.nombre, u.foto_perfil, u.email
       FROM amistades a
       JOIN usuarios u ON a.usuario_id = u.id
       WHERE a.amigo_id = $1 AND a.estado = 'pendiente'
       ORDER BY a.created_at DESC`,
      [userId]
    );

    res.json(result.rows);
  } catch (err) {
    console.error('Error al obtener solicitudes pendientes:', err.message);
    res.status(500).json({ error: 'Error al obtener solicitudes pendientes', details: err.message });
  }
};

// Obtener lista de amigos
exports.getFriends = async (req, res) => {
  try {
    const userId = req.user.id;

    const result = await pool.query(
      `SELECT u.id, u.nombre, u.foto_perfil, u.email
       FROM usuarios u
       JOIN amistades a ON (a.usuario_id = u.id OR a.amigo_id = u.id)
       WHERE (a.usuario_id = $1 OR a.amigo_id = $1) 
       AND a.estado = 'aceptada'
       AND u.id != $1`,
      [userId]
    );

    res.json(result.rows);
  } catch (err) {
    console.error('Error al obtener amigos:', err.message);
    res.status(500).json({ error: 'Error al obtener amigos', details: err.message });
  }
};

// Verificar estado de amistad
exports.checkFriendshipStatus = async (req, res) => {
  try {
    const userId = req.user.id;
    const { targetUserId } = req.params;

    const result = await pool.query(
      `SELECT estado FROM amistades 
       WHERE (usuario_id = $1 AND amigo_id = $2) OR (usuario_id = $2 AND amigo_id = $1)`,
      [userId, targetUserId]
    );

    if (result.rows.length === 0) {
      return res.json({ status: 'none' });
    }

    res.json({ status: result.rows[0].estado });
  } catch (err) {
    console.error('Error al verificar estado de amistad:', err.message);
    res.status(500).json({ error: 'Error al verificar estado de amistad', details: err.message });
  }
};
