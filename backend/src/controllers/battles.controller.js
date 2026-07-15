// filepath: backend/src/controllers/battles.controller.js
const pool = require('../config/db');
const axios = require('axios');
const { logger } = require('../utils/logger');

/**
 * POST /battles/challenge
 * Crear nuevo desafío batalla entre comunidades
 */
exports.challengeCommunity = async (req, res) => {
  try {
    const { challenger_community_id, challenged_community_id, difficulty, career } = req.body;
    const leader_id = req.user.id;

    // Validar que las comunidades existen
    const commCheck = await pool.query(
      'SELECT id FROM communities WHERE id = $1 OR id = $2',
      [challenger_community_id, challenged_community_id]
    );
    
    if (commCheck.rows.length < 2) {
      return res.status(404).json({ error: 'Una o ambas comunidades no existen' });
    }

    // Validar que usuario es líder de comunidad retadora
    const leaderCheck = await pool.query(
      'SELECT id FROM communities WHERE id = $1 AND leader_id = $2',
      [challenger_community_id, leader_id]
    );
    
    if (leaderCheck.rows.length === 0) {
      return res.status(403).json({ error: 'No eres líder de la comunidad retadora' });
    }

    // Crear batalla
    const battleResult = await pool.query(
      `INSERT INTO battles 
       (challenger_community_id, challenged_community_id, leader_id, difficulty, career, status, created_at)
       VALUES ($1, $2, $3, $4, $5, $6, NOW())
       RETURNING *`,
      [challenger_community_id, challenged_community_id, leader_id, difficulty, career, 'pending']
    );

    const battle = battleResult.rows[0];
    
    logger.info('Battle', `Batalla creada: ${battle.id}`, { leader_id, challenger_community_id, challenged_community_id });
    
    res.status(201).json({
      success: true,
      battle_id: battle.id,
      status: battle.status,
      created_at: battle.created_at
    });
  } catch (error) {
    logger.error('Battle', 'Error creando batalla', error);
    res.status(500).json({ error: 'Error creando batalla' });
  }
};

/**
 * PUT /battles/:battleId/respond
 * Responder a desafío (aceptar/rechazar)
 */
exports.respondToChallenge = async (req, res) => {
  try {
    const { battleId } = req.params;
    const { response, leader_id } = req.body; // response: 'accept' | 'reject'
    const user_id = req.user.id;

    // Obtener batalla
    const battleQuery = await pool.query('SELECT * FROM battles WHERE id = $1', [battleId]);
    
    if (battleQuery.rows.length === 0) {
      return res.status(404).json({ error: 'Batalla no encontrada' });
    }

    const battle = battleQuery.rows[0];

    if (battle.status !== 'pending') {
      return res.status(400).json({ error: 'Batalla no está en estado pendiente' });
    }

    // Validar que respondedor es líder de comunidad desafiada
    const leaderCheck = await pool.query(
      'SELECT id FROM communities WHERE id = $1 AND leader_id = $2',
      [battle.challenged_community_id, leader_id]
    );
    
    if (leaderCheck.rows.length === 0) {
      return res.status(403).json({ error: 'No eres líder de la comunidad desafiada' });
    }

    if (response === 'accept') {
      // Actualizar estado a 'waiting_start'
      await pool.query(
        'UPDATE battles SET status = $1, opponent_leader_id = $2 WHERE id = $3',
        ['waiting_start', user_id, battleId]
      );

      res.json({ success: true, status: 'waiting_start' });
    } else if (response === 'reject') {
      // Cancelar batalla
      await pool.query(
        'UPDATE battles SET status = $1 WHERE id = $2',
        ['rejected', battleId]
      );

      res.json({ success: true, status: 'rejected' });
    } else {
      res.status(400).json({ error: 'Respuesta inválida' });
    }
  } catch (error) {
    logger.error('Battle', 'Error respondiendo a desafío', error);
    res.status(500).json({ error: 'Error respondiendo a desafío' });
  }
};

/**
 * POST /battles/:battleId/start
 * Iniciar batalla (líder retador)
 */
exports.startBattle = async (req, res) => {
  try {
    const { battleId } = req.params;
    const user_id = req.user.id;
    const io = req.app.get('io');

    // Obtener batalla
    const battleQuery = await pool.query('SELECT * FROM battles WHERE id = $1', [battleId]);
    
    if (battleQuery.rows.length === 0) {
      return res.status(404).json({ error: 'Batalla no encontrada' });
    }

    const battle = battleQuery.rows[0];

    // Validar estado
    if (battle.status !== 'waiting_start') {
      return res.status(400).json({ error: 'Batalla no lista para iniciar' });
    }

    // Validar que es líder retador
    if (battle.leader_id !== user_id) {
      return res.status(403).json({ error: 'Solo el líder retador puede iniciar' });
    }

    // Obtener preguntas del AI
    const questionsResult = await pool.query(
      `SELECT * FROM questions WHERE difficulty = $1 AND career = $2 ORDER BY RANDOM() LIMIT 5`,
      [battle.difficulty, battle.career]
    );

    if (questionsResult.rows.length < 5) {
      return res.status(400).json({ error: 'No hay suficientes preguntas disponibles' });
    }

    // Crear ronda
    const now = new Date();
    const startTime = now.toISOString();
    
    const roundResult = await pool.query(
      `INSERT INTO battle_rounds (battle_id, round_number, status, start_time)
       VALUES ($1, $2, $3, $4)
       RETURNING *`,
      [battleId, 1, 'active', startTime]
    );

    const round = roundResult.rows[0];

    // Guardar preguntas en BD
    for (let i = 0; i < questionsResult.rows.length; i++) {
      await pool.query(
        `INSERT INTO round_questions (round_id, question_id, question_order)
         VALUES ($1, $2, $3)`,
        [round.id, questionsResult.rows[i].id, i + 1]
      );
    }

    // Actualizar batalla a 'active'
    await pool.query(
      'UPDATE battles SET status = $1, start_time = $2 WHERE id = $3',
      ['active', startTime, battleId]
    );

    // Emit Socket evento: batalla iniciada
    io.to(`battle_${battleId}`).emit('battle:start', {
      battle_id: battleId,
      start_time: startTime,
      round_id: round.id,
      total_questions: questionsResult.rows.length
    });

    res.json({ 
      success: true, 
      status: 'active',
      round_id: round.id,
      start_time: startTime
    });
  } catch (error) {
    logger.error('Battle', 'Error iniciando batalla', error);
    res.status(500).json({ error: 'Error iniciando batalla' });
  }
};

/**
 * GET /battles/:battleId
 * Obtener detalles de batalla
 */
exports.getBattle = async (req, res) => {
  try {
    const { battleId } = req.params;

    const battleQuery = await pool.query(
      `SELECT b.*, 
              c1.name as challenger_name, c2.name as challenged_name,
              u1.username as leader_username, u2.username as opponent_username
       FROM battles b
       LEFT JOIN communities c1 ON b.challenger_community_id = c1.id
       LEFT JOIN communities c2 ON b.challenged_community_id = c2.id
       LEFT JOIN users u1 ON b.leader_id = u1.id
       LEFT JOIN users u2 ON b.opponent_leader_id = u2.id
       WHERE b.id = $1`,
      [battleId]
    );

    if (battleQuery.rows.length === 0) {
      return res.status(404).json({ error: 'Batalla no encontrada' });
    }

    const battle = battleQuery.rows[0];

    // Obtener score actual
    const scoreQuery = await pool.query(
      `SELECT 
        SUM(CASE WHEN team = 'challenger' THEN 1 ELSE 0 END) as challenger_score,
        SUM(CASE WHEN team = 'challenged' THEN 1 ELSE 0 END) as challenged_score
       FROM battle_members bm
       JOIN round_answers ra ON bm.id = ra.member_id
       WHERE bm.battle_id = $1 AND ra.is_correct = true`,
      [battleId]
    );

    res.json({
      ...battle,
      challenger_score: scoreQuery.rows[0]?.challenger_score || 0,
      challenged_score: scoreQuery.rows[0]?.challenged_score || 0
    });
  } catch (error) {
    logger.error('Battle', 'Error obteniendo batalla', error);
    res.status(500).json({ error: 'Error obteniendo batalla' });
  }
};

/**
 * GET /battles/:battleId/questions
 * Obtener preguntas de ronda actual
 */
exports.getQuestions = async (req, res) => {
  try {
    const { battleId } = req.params;

    const questionsQuery = await pool.query(
      `SELECT rq.question_order, q.id, q.title, q.options
       FROM round_questions rq
       JOIN questions q ON rq.question_id = q.id
       JOIN battle_rounds br ON rq.round_id = br.id
       WHERE br.battle_id = $1 AND br.status = 'active'
       ORDER BY rq.question_order`,
      [battleId]
    );

    if (questionsQuery.rows.length === 0) {
      return res.status(404).json({ error: 'No hay ronda activa' });
    }

    res.json({
      questions: questionsQuery.rows.map(q => ({
        id: q.id,
        order: q.question_order,
        title: q.title,
        options: q.options
        // NO INCLUIR: correct_answer
      }))
    });
  } catch (error) {
    logger.error('Battle', 'Error obteniendo preguntas', error);
    res.status(500).json({ error: 'Error obteniendo preguntas' });
  }
};

/**
 * POST /battles/:battleId/answer
 * Enviar respuesta a pregunta
 */
exports.submitAnswer = async (req, res) => {
  try {
    const { battleId } = req.params;
    const { question_id, selected_option } = req.body;
    const user_id = req.user.id;
    const io = req.app.get('io');

    // Obtener battle_member
    const memberQuery = await pool.query(
      'SELECT * FROM battle_members WHERE battle_id = $1 AND member_id = $2',
      [battleId, user_id]
    );

    if (memberQuery.rows.length === 0) {
      return res.status(403).json({ error: 'No eres miembro de esta batalla' });
    }

    const member = memberQuery.rows[0];

    // Validar que no está en excluded state
    if (member.excluded_until && new Date(member.excluded_until) > new Date()) {
      return res.status(400).json({ error: 'Usuario excluido temporalmente' });
    }

    // Obtener pregunta
    const questionQuery = await pool.query(
      'SELECT * FROM questions WHERE id = $1',
      [question_id]
    );

    const question = questionQuery.rows[0];
    const isCorrect = question.correct_answer === selected_option;

    // Registrar respuesta
    const answerResult = await pool.query(
      `INSERT INTO round_answers (member_id, question_id, selected_option, is_correct)
       VALUES ($1, $2, $3, $4)
       RETURNING *`,
      [member.id, question_id, selected_option, isCorrect]
    );

    // Emit Socket: result privado al usuario
    io.to(user_id).emit('battle:answer_result', {
      is_correct: isCorrect,
      correct_answer: question.correct_answer
    });

    // Emit Socket: team update (sin detalles)
    io.to(`battle_${battleId}_team_${member.team}`).emit('battle:team_update', {
      member_id: user_id,
      answered: true
    });

    res.json({ 
      success: true, 
      is_correct: isCorrect 
    });
  } catch (error) {
    logger.error('Battle', 'Error enviando respuesta', error);
    res.status(500).json({ error: 'Error enviando respuesta' });
  }
};

/**
 * PUT /battles/:battleId/cancel
 * Cancelar batalla
 */
exports.cancelBattle = async (req, res) => {
  try {
    const { battleId } = req.params;
    const user_id = req.user.id;
    const io = req.app.get('io');

    const battleQuery = await pool.query('SELECT * FROM battles WHERE id = $1', [battleId]);
    
    if (battleQuery.rows.length === 0) {
      return res.status(404).json({ error: 'Batalla no encontrada' });
    }

    const battle = battleQuery.rows[0];

    if (battle.leader_id !== user_id) {
      return res.status(403).json({ error: 'Solo el líder puede cancelar' });
    }

    // Liberar locked_until
    await pool.query(
      'UPDATE battle_members SET locked_until = NULL WHERE battle_id = $1',
      [battleId]
    );

    // Actualizar estado
    await pool.query(
      'UPDATE battles SET status = $1 WHERE id = $2',
      ['cancelled', battleId]
    );

    io.to(`battle_${battleId}`).emit('battle:cancelled', { battle_id: battleId });

    res.json({ success: true, status: 'cancelled' });
  } catch (error) {
    logger.error('Battle', 'Error cancelando batalla', error);
    res.status(500).json({ error: 'Error cancelando batalla' });
  }
};

/**
 * GET /battles/community/:communityId
 * Obtener batallas de comunidad
 */
exports.getCommunityBattles = async (req, res) => {
  try {
    const { communityId } = req.params;
    const { status } = req.query; // opcional: 'active', 'completed', etc

    let query = `
      SELECT * FROM battles
      WHERE challenger_community_id = $1 OR challenged_community_id = $1
    `;
    const params = [communityId];

    if (status) {
      query += ` AND status = $2`;
      params.push(status);
    }

    query += ` ORDER BY created_at DESC`;

    const battlesQuery = await pool.query(query, params);

    res.json({ battles: battlesQuery.rows });
  } catch (error) {
    logger.error('Battle', 'Error obteniendo batallas comunidad', error);
    res.status(500).json({ error: 'Error obteniendo batallas' });
  }
};

/**
 * GET /battles/user/my-battles
 * Obtener mis batallas (como representante)
 */
exports.getMyBattles = async (req, res) => {
  try {
    const user_id = req.user.id;

    const battlesQuery = await pool.query(
      `SELECT DISTINCT b.* FROM battles b
       JOIN battle_members bm ON b.id = bm.battle_id
       WHERE bm.member_id = $1
       ORDER BY b.created_at DESC`,
      [user_id]
    );

    res.json({ battles: battlesQuery.rows });
  } catch (error) {
    logger.error('Battle', 'Error obteniendo mis batallas', error);
    res.status(500).json({ error: 'Error obteniendo mis batallas' });
  }
};

/**
 * POST /battles/:battleId/finish
 * Finalizar batalla manualmente
 */
exports.finishBattle = async (req, res) => {
  try {
    const { battleId } = req.params;
    const user_id = req.user.id;
    const io = req.app.get('io');

    const battleQuery = await pool.query('SELECT * FROM battles WHERE id = $1', [battleId]);
    
    if (battleQuery.rows.length === 0) {
      return res.status(404).json({ error: 'Batalla no encontrada' });
    }

    const battle = battleQuery.rows[0];

    if (battle.leader_id !== user_id && battle.opponent_leader_id !== user_id) {
      return res.status(403).json({ error: 'No tienes permiso' });
    }

    // Calcular winner
    const scoreQuery = await pool.query(
      `SELECT 
        SUM(CASE WHEN bm.team = 'challenger' THEN 1 ELSE 0 END) as challenger_score,
        SUM(CASE WHEN bm.team = 'challenged' THEN 1 ELSE 0 END) as challenged_score
       FROM battle_members bm
       JOIN round_answers ra ON bm.id = ra.member_id
       WHERE bm.battle_id = $1 AND ra.is_correct = true`,
      [battleId]
    );

    const scores = scoreQuery.rows[0];
    let winner_team = scores.challenger_score > scores.challenged_score ? 'challenger' : 
                      scores.challenged_score > scores.challenger_score ? 'challenged' : null;

    // Liberar locked_until
    await pool.query(
      'UPDATE battle_members SET locked_until = NULL WHERE battle_id = $1',
      [battleId]
    );

    // Actualizar batalla
    await pool.query(
      'UPDATE battles SET status = $1, winner_team = $2 WHERE id = $3',
      ['completed', winner_team, battleId]
    );

    io.to(`battle_${battleId}`).emit('battle:finished', { 
      battle_id: battleId,
      winner_team: winner_team,
      final_scores: {
        challenger: scores.challenger_score,
        challenged: scores.challenged_score
      }
    });

    res.json({ 
      success: true, 
      status: 'completed',
      winner_team: winner_team
    });
  } catch (error) {
    logger.error('Battle', 'Error finalizando batalla', error);
    res.status(500).json({ error: 'Error finalizando batalla' });
  }
};
