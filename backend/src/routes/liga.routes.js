// filepath: backend/src/routes/liga.routes.js
const express = require('express');
const router = express.Router();
const ligaController = require('../controllers/liga.controller');
const { authenticate } = require('../middlewares/auth.middleware');

// Obtener todas las ligas
router.get('/', ligaController.getLigas);

// Obtener una liga específica
router.get('/:id', ligaController.getLiga);

// Crear liga (requiere autenticación)
router.post('/', authenticate, ligaController.createLiga);

// Actualizar liga
router.put('/:id', authenticate, ligaController.updateLiga);

// Obtener participantes de una liga
router.get('/:id/participantes', ligaController.getLigaParticipantes);

module.exports = router;
