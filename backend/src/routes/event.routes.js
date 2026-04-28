const express = require('express');
const router = express.Router();
const eventController = require('../controllers/event.controller');
const { authenticate } = require('../middlewares/auth.middleware');

// Crear evento
router.post('/create', authenticate, eventController.createEvent);

// Obtener eventos de una comunidad
router.get('/community/:comunidad_id', authenticate, eventController.getCommunityEvents);

// RSVP a evento
router.post('/rsvp', authenticate, eventController.rsvpEvent);

// Obtener RSVP del usuario a un evento
router.get('/rsvp/:evento_id', authenticate, eventController.getUserRsvp);

module.exports = router;
