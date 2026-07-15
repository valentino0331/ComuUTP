// filepath: backend/src/routes/ranking.routes.js
const express = require('express');
const router = express.Router();
const rankingController = require('../controllers/ranking.controller');
const { authenticate } = require('../middlewares/auth.middleware');

// Obtener ranking general
router.get('/', rankingController.getRankingGeneral);

// Obtener ranking por comunidad
router.get('/comunidad/:comunidad_id', rankingController.getRankingComunidad);

// Obtener ranking de una liga
router.get('/liga/:liga_id', rankingController.getRankingLiga);

// Obtener mi posición en una liga (requiere autenticación)
router.get('/liga/:liga_id/mi-posicion', authenticate, rankingController.getMiPosicion);

// Obtener mis insignias
router.get('/usuario/insignias', authenticate, rankingController.getMisInsignias);

// Obtener mis estadísticas
router.get('/usuario/estadisticas', authenticate, rankingController.getMisEstadisticas);

module.exports = router;
