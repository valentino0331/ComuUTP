const express = require('express');
const router = express.Router();
const mentionController = require('../controllers/mention.controller');
const authMiddleware = require('../middlewares/auth.middleware');

// Crear menciones
router.post('/create', authMiddleware, mentionController.createMentions);

// Obtener menciones del usuario
router.get('/user', authMiddleware, mentionController.getUserMentions);

// Marcar mención como leída
router.put('/:mencion_id/read', authMiddleware, mentionController.markAsRead);

// Buscar usuarios para autocompletado
router.get('/search', authMiddleware, mentionController.searchUsers);

module.exports = router;
