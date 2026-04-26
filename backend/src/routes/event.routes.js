const express = require('express');
const router = express.Router();
const eventController = require('../controllers/event.controller');
const authMiddleware = require('../middlewares/auth.middleware');

// Crear evento
router.post('/create', authMiddleware, eventController.createEvent);

// Obtener eventos de una comunidad
router.get('/community/:comunidad_id', authMiddleware, eventController.getCommunityEvents);

// RSVP a evento
router.post('/rsvp', authMiddleware, eventController.rsvpEvent);

// Obtener RSVP del usuario a un evento
router.get('/rsvp/:evento_id', authMiddleware, eventController.getUserRsvp);

module.exports = router;
