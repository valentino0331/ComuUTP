// filepath: backend/src/utils/battle-socket-handlers.js
const pool = require('../config/db');
const { logger } = require('./logger');

/**
 * Configurar handlers Socket.IO para batallas
 */
const setupBattleHandlers = (io) => {
  io.on('connection', (socket) => {
    console.log('⚔️ Conexión Socket:', socket.id);

    /**
     * Unirse a sala de batalla
     * Eventos: join_battle
     */
    socket.on('join_battle', async (data) => {
      const { battle_id, user_id, member_id } = data;
      const battleRoom = `battle_${battle_id}`;
      const teamRoom = `battle_${battle_id}_team_${data.team}`;

      socket.join(battleRoom);
      socket.join(teamRoom);
      
      // Guardar en socket para referencia
      socket.battle_id = battle_id;
      socket.user_id = user_id;
      socket.member_id = member_id;
      socket.team = data.team;

      console.log(`👤 ${user_id} se unió a batalla ${battle_id}`);

      // Emitir que jugador está listo
      io.to(battleRoom).emit('battle:player_ready', {
        user_id,
        member_id,
        team: data.team,
        timestamp: new Date().toISOString()
      });
    });

    /**
     * Sincronizar cronómetro
     * Evento: sync_timer
     */
    socket.on('sync_timer', (data) => {
      const { battle_id, timestamp } = data;
      socket.emit('battle:timer_sync', {
        server_timestamp: new Date().toISOString(),
        battle_start_time: timestamp
      });
    });

    /**
     * Enviar respuesta a pregunta
     * Evento: submit_answer
     */
    socket.on('submit_answer', async (data) => {
      try {
        const { battle_id, question_id, selected_option } = data;
        const user_id = socket.user_id;
        const member_id = socket.member_id;

        // Validar respuesta en BD
        const questionQuery = await pool.query(
          'SELECT correct_answer FROM questions WHERE id = $1',
          [question_id]
        );

        const question = questionQuery.rows[0];
        const isCorrect = question.correct_answer === selected_option;

        // Registrar
        await pool.query(
          `INSERT INTO round_answers (member_id, question_id, selected_option, is_correct)
           VALUES ($1, $2, $3, $4)`,
          [member_id, question_id, selected_option, isCorrect]
        );

        // Enviar resultado SOLO al usuario
        socket.emit('battle:answer_result', {
          is_correct: isCorrect,
          correct_answer: question.correct_answer,
          question_id
        });

        // Notificar al equipo (sin revelar respuesta)
        socket.to(`battle_${battle_id}_team_${socket.team}`).emit('battle:team_update', {
          user_id,
          answered: true,
          timestamp: new Date().toISOString()
        });
      } catch (error) {
        logger.error('BattleSocket', 'Error procesando respuesta', error);
        socket.emit('battle:error', { message: 'Error enviando respuesta' });
      }
    });

    /**
     * Salir de batalla
     * Evento: leave_battle
     */
    socket.on('leave_battle', () => {
      if (socket.battle_id) {
        socket.leave(`battle_${socket.battle_id}`);
        socket.leave(`battle_${socket.battle_id}_team_${socket.team}`);
        console.log(`👋 ${socket.user_id} salió de batalla ${socket.battle_id}`);
      }
    });

    socket.on('disconnect', () => {
      console.log('❌ Desconexión Socket:', socket.id);
      if (socket.battle_id) {
        io.to(`battle_${socket.battle_id}`).emit('battle:player_disconnected', {
          user_id: socket.user_id
        });
      }
    });
  });
};

module.exports = setupBattleHandlers;
