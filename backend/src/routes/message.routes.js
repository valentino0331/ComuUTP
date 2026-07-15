const express = require('express');
const router = express.Router();
const messageController = require('../controllers/message.controller');
const { authenticate } = require('../middlewares/auth.middleware');

// Obtener todas las conversaciones del usuario
router.get('/conversations', authenticate, messageController.getConversations);

// Obtener mensajes de una conversación
router.get('/conversation/:conversacion_id/messages', authenticate, messageController.getMessages);

// Enviar mensaje
router.post('/send', authenticate, messageController.sendMessage);

// Crear nueva conversación
router.post('/conversation', authenticate, messageController.createConversation);

// Eliminar conversación
router.delete('/conversation/:conversacion_id', authenticate, messageController.deleteConversation);

module.exports = router;
