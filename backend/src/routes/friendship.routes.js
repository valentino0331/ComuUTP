const express = require('express');
const router = express.Router();
const friendshipController = require('../controllers/friendship.controller');
const { authenticate } = require('../middlewares/auth.middleware');

// Enviar solicitud de amistad
router.post('/send', authenticate, friendshipController.sendFriendRequest);

// Aceptar solicitud de amistad
router.put('/accept/:solicitudId', authenticate, friendshipController.acceptFriendRequest);

// Rechazar solicitud de amistad
router.delete('/reject/:solicitudId', authenticate, friendshipController.rejectFriendRequest);

// Obtener solicitudes pendientes
router.get('/pending', authenticate, friendshipController.getPendingRequests);

// Obtener lista de amigos
router.get('/friends', authenticate, friendshipController.getFriends);

// Verificar estado de amistad
router.get('/status/:targetUserId', authenticate, friendshipController.checkFriendshipStatus);

module.exports = router;
