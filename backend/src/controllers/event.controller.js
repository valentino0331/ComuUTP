const pool = require('../config/db');

// Crear evento
exports.createEvent = async (req, res) => {
  const { comunidad_id, titulo, descripcion, fecha_evento, ubicacion } = req.body;
  const usuario_id = req.user.id;

  try {
    const result = await pool.query(
      'INSERT INTO eventos (comunidad_id, usuario_id, titulo, descripcion, fecha_evento, ubicacion) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *',
      [comunidad_id, usuario_id, titulo, descripcion, fecha_evento, ubicacion]
    );

    res.status(201).json({ evento: result.rows[0] });
  } catch (err) {
    console.error('Error al crear evento:', err.message);
    res.status(500).json({ error: 'Error al crear evento' });
  }
};

// Obtener eventos de una comunidad
exports.getCommunityEvents = async (req, res) => {
  const { comunidad_id } = req.params;

  try {
    const result = await pool.query(
      `SELECT 
        e.*,
        u.nombre as creador_nombre,
        u.foto_perfil as creador_foto,
        (SELECT COUNT(*) FROM evento_rsvp WHERE evento_id = e.id AND estado = 'confirmado') as confirmados
       FROM eventos e
       JOIN usuarios u ON e.usuario_id = u.id
       WHERE e.comunidad_id = $1
       ORDER BY e.fecha_evento ASC`,
      [comunidad_id]
    );

    res.json({ eventos: result.rows });
  } catch (err) {
    console.error('Error al obtener eventos:', err.message);
    res.status(500).json({ error: 'Error al obtener eventos' });
  }
};

// RSVP a evento
exports.rsvpEvent = async (req, res) => {
  const { evento_id, estado } = req.body;
  const usuario_id = req.user.id;

  try {
    const result = await pool.query(
      'INSERT INTO evento_rsvp (evento_id, usuario_id, estado) VALUES ($1, $2, $3) ON CONFLICT (evento_id, usuario_id) DO UPDATE SET estado = $3 RETURNING *',
      [evento_id, usuario_id, estado]
    );

    res.json({ rsvp: result.rows[0] });
  } catch (err) {
    console.error('Error al hacer RSVP:', err.message);
    res.status(500).json({ error: 'Error al hacer RSVP' });
  }
};

// Obtener RSVP del usuario a un evento
exports.getUserRsvp = async (req, res) => {
  const { evento_id } = req.params;
  const usuario_id = req.user.id;

  try {
    const result = await pool.query(
      'SELECT estado FROM evento_rsvp WHERE evento_id = $1 AND usuario_id = $2',
      [evento_id, usuario_id]
    );

    if (result.rows.length > 0) {
      res.json({ estado: result.rows[0].estado });
    } else {
      res.json({ estado: null });
    }
  } catch (err) {
    console.error('Error al obtener RSVP:', err.message);
    res.status(500).json({ error: 'Error al obtener RSVP' });
  }
};
