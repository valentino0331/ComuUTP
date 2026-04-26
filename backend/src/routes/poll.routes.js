const express = require('express');
const router = express.Router();
const pollController = require('../controllers/poll.controller');
const authMiddleware = require('../middlewares/auth.middleware');

// Crear encuesta
router.post('/create', authMiddleware, pollController.createPoll);

// Votar en encuesta
router.post('/vote', authMiddleware, pollController.votePoll);

// Obtener resultados de encuesta
router.get('/results/:encuesta_id', authMiddleware, pollController.getPollResults);

// Obtener voto del usuario en encuesta
router.get('/vote/:encuesta_id', authMiddleware, pollController.getUserVote);

module.exports = router;
