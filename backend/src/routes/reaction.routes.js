const express = require('express');
const router = express.Router();
const reactionController = require('../controllers/reaction.controller');
const { authenticate } = require('../middlewares/auth.middleware');

// Dar o quitar reacción
router.post('/toggle', authenticate, reactionController.toggleReaction);

// Obtener reacciones de una publicación
router.get('/post/:publicacion_id', authenticate, reactionController.getPostReactions);

// Obtener reacción del usuario actual
router.get('/user/:publicacion_id', authenticate, reactionController.getUserReaction);

module.exports = router;
