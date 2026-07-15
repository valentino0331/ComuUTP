const pool = require('../config/db');

// Crear encuesta
exports.createPoll = async (req, res) => {
  const { publicacion_id, pregunta, opciones, expiracion } = req.body;
  const usuario_id = req.user.id;

  try {
    // Crear encuesta
    const pollResult = await pool.query(
      'INSERT INTO encuestas (publicacion_id, pregunta, expiracion) VALUES ($1, $2, $3) RETURNING *',
      [publicacion_id, pregunta, expiracion || null]
    );

    const encuesta_id = pollResult.rows[0].id;

    // Crear opciones
    const optionPromises = opciones.map((opcion, index) => {
      return pool.query(
        'INSERT INTO encuesta_opciones (encuesta_id, opcion, orden) VALUES ($1, $2, $3) RETURNING *',
        [encuesta_id, opcion, index]
      );
    });

    const optionResults = await Promise.all(optionPromises);

    res.status(201).json({
      encuesta: pollResult.rows[0],
      opciones: optionResults.map(r => r.rows[0])
    });
  } catch (err) {
    console.error('Error al crear encuesta:', err.message);
    res.status(500).json({ error: 'Error al crear encuesta' });
  }
};

// Votar en encuesta
exports.votePoll = async (req, res) => {
  const { encuesta_id, opcion_id } = req.body;
  const usuario_id = req.user.id;

  try {
    const result = await pool.query(
      'INSERT INTO encuesta_votos (encuesta_id, opcion_id, usuario_id) VALUES ($1, $2, $3) ON CONFLICT (encuesta_id, usuario_id) DO UPDATE SET opcion_id = $3 RETURNING *',
      [encuesta_id, opcion_id, usuario_id]
    );

    res.json({ voto: result.rows[0] });
  } catch (err) {
    console.error('Error al votar en encuesta:', err.message);
    res.status(500).json({ error: 'Error al votar en encuesta' });
  }
};

// Obtener resultados de encuesta
exports.getPollResults = async (req, res) => {
  const { encuesta_id } = req.params;

  try {
    // Obtener opciones con conteo de votos
    const optionsResult = await pool.query(
      `SELECT 
        eo.id,
        eo.opcion,
        eo.orden,
        (SELECT COUNT(*) FROM encuesta_votos WHERE opcion_id = eo.id) as votos
       FROM encuesta_opciones eo
       WHERE eo.encuesta_id = $1
       ORDER BY eo.orden`,
      [encuesta_id]
    );

    // Obtener total de votos
    const totalVotesResult = await pool.query(
      'SELECT COUNT(*) as total FROM encuesta_votos WHERE encuesta_id = $1',
      [encuesta_id]
    );

    const total = parseInt(totalVotesResult.rows[0].total);

    // Calcular porcentajes
    const opciones = optionsResult.rows.map(opt => ({
      ...opt,
      votos: parseInt(opt.votos),
      porcentaje: total > 0 ? (parseInt(opt.votos) / total * 100).toFixed(1) : 0
    }));

    res.json({ opciones, total });
  } catch (err) {
    console.error('Error al obtener resultados de encuesta:', err.message);
    res.status(500).json({ error: 'Error al obtener resultados de encuesta' });
  }
};

// Obtener voto del usuario en encuesta
exports.getUserVote = async (req, res) => {
  const { encuesta_id } = req.params;
  const usuario_id = req.user.id;

  try {
    const result = await pool.query(
      'SELECT opcion_id FROM encuesta_votos WHERE encuesta_id = $1 AND usuario_id = $2',
      [encuesta_id, usuario_id]
    );

    if (result.rows.length > 0) {
      res.json({ opcion_id: result.rows[0].opcion_id });
    } else {
      res.json({ opcion_id: null });
    }
  } catch (err) {
    console.error('Error al obtener voto del usuario:', err.message);
    res.status(500).json({ error: 'Error al obtener voto del usuario' });
  }
};
