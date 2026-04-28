const express = require('express');
const router = express.Router();
const pollController = require('../controllers/poll.controller');
const { authenticate } = require('../middlewares/auth.middleware');

// Crear encuesta
router.post('/create', authenticate, pollController.createPoll);

// Votar en encuesta
router.post('/vote', authenticate, pollController.votePoll);

// Obtener resultados de encuesta
router.get('/results/:encuesta_id', authenticate, pollController.getPollResults);

// Obtener voto del usuario en encuesta
router.get('/vote/:encuesta_id', authenticate, pollController.getUserVote);

module.exports = router;
