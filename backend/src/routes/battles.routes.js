// filepath: backend/src/routes/battles.routes.js
const express = require('express');
const router = express.Router();
const battlesController = require('../controllers/battles.controller');
const { authenticate } = require('../middlewares/auth.middleware');

// Todas las rutas requieren autenticación
router.use(authenticate);

// Desafiar a comunidad rival
router.post('/challenge', battlesController.challengeCommunity);

// Responder a desafío (aceptar/rechazar)
router.put('/:battleId/respond', battlesController.respondToChallenge);

// Iniciar batalla (líder)
router.post('/:battleId/start', battlesController.startBattle);

// Obtener batalla específica
router.get('/:battleId', battlesController.getBattle);

// Obtener preguntas de ronda actual
router.get('/:battleId/questions', battlesController.getQuestions);

// Enviar respuesta a pregunta
router.post('/:battleId/answer', battlesController.submitAnswer);

// Cancelar batalla
router.put('/:battleId/cancel', battlesController.cancelBattle);

// Obtener batallas de comunidad
router.get('/community/:communityId', battlesController.getCommunityBattles);

// Obtener mis batallas
router.get('/user/my-battles', battlesController.getMyBattles);

// Finalizar batalla (trigger manual)
router.post('/:battleId/finish', battlesController.finishBattle);

module.exports = router;
