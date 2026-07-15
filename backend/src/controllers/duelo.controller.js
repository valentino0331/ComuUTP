// filepath: backend/src/controllers/duelo.controller.js
const pool = require('../config/db');
const axios = require('axios');

// Iniciar un duelo entre dos usuarios
exports.iniciarDuelo = async (req, res) => {
  try {
    const { liga_id, opponent_id, tema, material_id } = req.body;
    const usuario1_id = req.user.id;
    const usuario2_id = opponent_id;

    if (usuario1_id === usuario2_id) {
      return res.status(400).json({ error: 'No puedes duelo contigo mismo' });
    }

    // Verificar que la liga existe
    const liga = await pool.query('SELECT * FROM ligas WHERE id = $1', [liga_id]);
    if (liga.rows.length === 0) {
      return res.status(404).json({ error: 'Liga no encontrada' });
    }

    // Crear duelo
    const dueloResult = await pool.query(
      `INSERT INTO duelos (liga_id, usuario1_id, usuario2_id, tema, material_id, estado)
       VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`,
      [liga_id, usuario1_id, usuario2_id, tema, material_id || null, 'pendiente']
    );

    const duelo = dueloResult.rows[0];

    // Generar preguntas con IA (simulado por ahora)
    await _generarPreguntasDuelo(duelo.id, tema, material_id, 5);

    res.status(201).json({ duelo, mensaje: 'Duelo iniciado' });
  } catch (err) {
    console.error('Error al iniciar duelo:', err);
    res.status(500).json({ error: 'Error al iniciar duelo' });
  }
};

// Obtener duelo por ID
exports.getDuelo = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const result = await pool.query(
      `SELECT * FROM duelos WHERE id = $1 AND (usuario1_id = $2 OR usuario2_id = $2)`,
      [id, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Duelo no encontrado' });
    }

    const duelo = result.rows[0];

    // Obtener preguntas del duelo
    const preguntas = await pool.query(
      'SELECT * FROM duelo_preguntas WHERE duelo_id = $1 ORDER BY ronda ASC',
      [id]
    );

    res.json({ duelo, preguntas: preguntas.rows });
  } catch (err) {
    console.error('Error al obtener duelo:', err);
    res.status(500).json({ error: 'Error al obtener duelo' });
  }
};

// Enviar respuesta en duelo
exports.enviarRespuesta = async (req, res) => {
  try {
    const { duelo_id, duelo_pregunta_id, respuesta_seleccionada, tiempo_respuesta } = req.body;
    const usuario_id = req.user.id;

    // Verificar que el usuario es parte del duelo
    const duelo = await pool.query(
      'SELECT * FROM duelos WHERE id = $1 AND (usuario1_id = $2 OR usuario2_id = $2)',
      [duelo_id, usuario_id]
    );

    if (duelo.rows.length === 0) {
      return res.status(403).json({ error: 'No tienes acceso a este duelo' });
    }

    // Obtener pregunta
    const preguntaResult = await pool.query(
      'SELECT * FROM duelo_preguntas WHERE id = $1',
      [duelo_pregunta_id]
    );

    if (preguntaResult.rows.length === 0) {
      return res.status(404).json({ error: 'Pregunta no encontrada' });
    }

    const pregunta = preguntaResult.rows[0];
    const es_correcta = respuesta_seleccionada === pregunta.respuesta_correcta;
    const puntos = es_correcta ? 10 : 0;

    // Guardar respuesta
    const respuestaResult = await pool.query(
      `INSERT INTO duelo_respuestas (duelo_pregunta_id, usuario_id, respuesta_seleccionada, es_correcta, tiempo_respuesta, puntos_obtenidos)
       VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`,
      [duelo_pregunta_id, usuario_id, respuesta_seleccionada, es_correcta, tiempo_respuesta, puntos]
    );

    // Actualizar puntos en duelo
    if (usuario_id === duelo.rows[0].usuario1_id) {
      await pool.query(
        'UPDATE duelos SET puntos_usuario1 = puntos_usuario1 + $1 WHERE id = $2',
        [puntos, duelo_id]
      );
    } else {
      await pool.query(
        'UPDATE duelos SET puntos_usuario2 = puntos_usuario2 + $1 WHERE id = $2',
        [puntos, duelo_id]
      );
    }

    res.json({ respuesta: respuestaResult.rows[0], es_correcta, puntos });
  } catch (err) {
    console.error('Error al enviar respuesta:', err);
    res.status(500).json({ error: 'Error al enviar respuesta' });
  }
};

// Finalizar duelo
exports.finalizarDuelo = async (req, res) => {
  try {
    const { duelo_id } = req.params;
    const usuario_id = req.user.id;

    // Obtener duelo
    const dueloResult = await pool.query(
      'SELECT * FROM duelos WHERE id = $1',
      [duelo_id]
    );

    if (dueloResult.rows.length === 0) {
      return res.status(404).json({ error: 'Duelo no encontrado' });
    }

    const duelo = dueloResult.rows[0];

    // Determinar ganador
    let ganador_id = null;
    if (duelo.puntos_usuario1 > duelo.puntos_usuario2) {
      ganador_id = duelo.usuario1_id;
    } else if (duelo.puntos_usuario2 > duelo.puntos_usuario1) {
      ganador_id = duelo.usuario2_id;
    }

    // Actualizar duelo
    const result = await pool.query(
      'UPDATE duelos SET estado = $1, ganador_id = $2, fecha_fin = NOW() WHERE id = $3 RETURNING *',
      ['finalizado', ganador_id, duelo_id]
    );

    // Actualizar ranking
    await _actualizarRanking(duelo.liga_id, duelo.usuario1_id, duelo.puntos_usuario1, ganador_id === duelo.usuario1_id);
    await _actualizarRanking(duelo.liga_id, duelo.usuario2_id, duelo.puntos_usuario2, ganador_id === duelo.usuario2_id);

    res.json({ duelo: result.rows[0], ganador_id });
  } catch (err) {
    console.error('Error al finalizar duelo:', err);
    res.status(500).json({ error: 'Error al finalizar duelo' });
  }
};

// Obtener duelos del usuario
exports.getMisDuelos = async (req, res) => {
  try {
    const usuario_id = req.user.id;
    const liga_id = req.query.liga_id;
    const estado = req.query.estado || 'en_progreso';

    let query = `SELECT * FROM duelos WHERE (usuario1_id = $1 OR usuario2_id = $1)`;
    const params = [usuario_id];

    if (liga_id) {
      query += ` AND liga_id = $${params.length + 1}`;
      params.push(liga_id);
    }

    if (estado) {
      query += ` AND estado = $${params.length + 1}`;
      params.push(estado);
    }

    query += ` ORDER BY fecha_inicio DESC`;

    const result = await pool.query(query, params);
    res.json({ duelos: result.rows });
  } catch (err) {
    console.error('Error al obtener duelos:', err);
    res.status(500).json({ error: 'Error al obtener duelos' });
  }
};

// ===== FUNCIONES AUXILIARES =====

// Generar preguntas del duelo (integración con IA)
async function _generarPreguntasDuelo(duelo_id, tema, material_id, cantidad) {
  try {
    // Aquí iría la integración con Claude o la IA elegida
    // Por ahora, preguntas simuladas
    const preguntas = [
      {
        pregunta: `¿Cuál es el concepto principal de "${tema}"?`,
        opciones: [
          { id: 0, texto: 'Opción A' },
          { id: 1, texto: 'Opción B' },
          { id: 2, texto: 'Opción C' },
          { id: 3, texto: 'Opción D' },
        ],
        respuesta_correcta: 0,
        dificultad: 'media',
        tiempo_limite: 30,
      },
    ];

    for (let i = 0; i < Math.min(cantidad, preguntas.length); i++) {
      await pool.query(
        `INSERT INTO duelo_preguntas (duelo_id, ronda, pregunta, opciones, respuesta_correcta, dificultad, tiempo_limite)
         VALUES ($1, $2, $3, $4, $5, $6, $7)`,
        [
          duelo_id,
          i + 1,
          preguntas[i].pregunta,
          JSON.stringify(preguntas[i].opciones),
          preguntas[i].respuesta_correcta,
          preguntas[i].dificultad,
          preguntas[i].tiempo_limite,
        ]
      );
    }
  } catch (err) {
    console.error('Error generando preguntas:', err);
  }
}

// Actualizar ranking del usuario en la liga
async function _actualizarRanking(liga_id, usuario_id, puntos, gano) {
  try {
    // Intentar actualizar
    const updateResult = await pool.query(
      `UPDATE ranking_ligas SET 
        puntos_totales = puntos_totales + $1,
        duelos_jugados = duelos_jugados + 1,
        duelos_ganados = duelos_ganados + $2,
        updated_at = NOW()
       WHERE liga_id = $3 AND usuario_id = $4`,
      [puntos, gano ? 1 : 0, liga_id, usuario_id]
    );

    // Si no existe, crear
    if (updateResult.rowCount === 0) {
      await pool.query(
        `INSERT INTO ranking_ligas (liga_id, usuario_id, puntos_totales, duelos_jugados, duelos_ganados)
         VALUES ($1, $2, $3, $4, $5)`,
        [liga_id, usuario_id, puntos, 1, gano ? 1 : 0]
      );
    }

    // Recalcular tasa de victoria y posiciones
    await _recalcularPosiciones(liga_id);
  } catch (err) {
    console.error('Error actualizando ranking:', err);
  }
}

// Recalcular posiciones en ranking
async function _recalcularPosiciones(liga_id) {
  try {
    // Actualizar tasa de victoria
    await pool.query(
      `UPDATE ranking_ligas SET 
        tasa_victoria = CASE WHEN duelos_jugados > 0 THEN (duelos_ganados::FLOAT / duelos_jugados) * 100 ELSE 0 END
       WHERE liga_id = $1`,
      [liga_id]
    );

    // Actualizar posiciones
    const users = await pool.query(
      `SELECT id FROM ranking_ligas WHERE liga_id = $1 ORDER BY puntos_totales DESC, tasa_victoria DESC`,
      [liga_id]
    );

    for (let i = 0; i < users.rows.length; i++) {
      await pool.query(
        'UPDATE ranking_ligas SET posicion = $1 WHERE id = $2',
        [i + 1, users.rows[i].id]
      );
    }
  } catch (err) {
    console.error('Error recalculando posiciones:', err);
  }
}
