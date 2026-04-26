const express = require('express');
const router = express.Router();
const messageController = require('../controllers/message.controller');
const authMiddleware = require('../middlewares/auth.middleware');

// Obtener todas las conversaciones del usuario
router.get('/conversations', authMiddleware, messageController.getConversations);

// Obtener mensajes de una conversación
router.get('/conversation/:conversacion_id/messages', authMiddleware, messageController.getMessages);

// Enviar mensaje
router.post('/send', authMiddleware, messageController.sendMessage);

// Crear nueva conversación
router.post('/conversation', authMiddleware, messageController.createConversation);

// Eliminar conversación
router.delete('/conversation/:conversacion_id', authMiddleware, messageController.deleteConversation);

module.exports = router;
