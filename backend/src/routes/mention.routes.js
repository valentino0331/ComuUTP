const express = require('express');
const router = express.Router();
const mentionController = require('../controllers/mention.controller');
const { authenticate } = require('../middlewares/auth.middleware');

// Crear menciones
router.post('/create', authenticate, mentionController.createMentions);

// Obtener menciones del usuario
router.get('/user', authenticate, mentionController.getUserMentions);

// Marcar mención como leída
router.put('/:mencion_id/read', authenticate, mentionController.markAsRead);

// Buscar usuarios para autocompletado
router.get('/search', authenticate, mentionController.searchUsers);

module.exports = router;
