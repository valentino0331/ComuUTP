const express = require('express');
const router = express.Router();
const friendshipController = require('../controllers/friendship.controller');
const authMiddleware = require('../middlewares/auth.middleware');

// Enviar solicitud de amistad
router.post('/send', authMiddleware, friendshipController.sendFriendRequest);

// Aceptar solicitud de amistad
router.put('/accept/:solicitudId', authMiddleware, friendshipController.acceptFriendRequest);

// Rechazar solicitud de amistad
router.delete('/reject/:solicitudId', authMiddleware, friendshipController.rejectFriendRequest);

// Obtener solicitudes pendientes
router.get('/pending', authMiddleware, friendshipController.getPendingRequests);

// Obtener lista de amigos
router.get('/friends', authMiddleware, friendshipController.getFriends);

// Verificar estado de amistad
router.get('/status/:targetUserId', authMiddleware, friendshipController.checkFriendshipStatus);

module.exports = router;
