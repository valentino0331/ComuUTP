const express = require('express');
const router = express.Router();
const reactionController = require('../controllers/reaction.controller');
const authMiddleware = require('../middlewares/auth.middleware');

// Dar o quitar reacción
router.post('/toggle', authMiddleware, reactionController.toggleReaction);

// Obtener reacciones de una publicación
router.get('/post/:publicacion_id', authMiddleware, reactionController.getPostReactions);

// Obtener reacción del usuario actual
router.get('/user/:publicacion_id', authMiddleware, reactionController.getUserReaction);

module.exports = router;
