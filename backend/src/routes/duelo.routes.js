// filepath: backend/src/routes/duelo.routes.js
const express = require('express');
const router = express.Router();
const dueloController = require('../controllers/duelo.controller');
const { authenticate } = require('../middlewares/auth.middleware');

// Todas las rutas requieren autenticación
router.use(authenticate);

// Iniciar duelo
router.post('/iniciar', dueloController.iniciarDuelo);

// Obtener duelo específico
router.get('/:id', dueloController.getDuelo);

// Enviar respuesta en duelo
router.post('/responder', dueloController.enviarRespuesta);

// Finalizar duelo
router.post('/:duelo_id/finalizar', dueloController.finalizarDuelo);

// Obtener mis duelos
router.get('/usuario/mis-duelos', dueloController.getMisDuelos);

module.exports = router;
