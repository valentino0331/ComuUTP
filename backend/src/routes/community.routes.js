const express = require('express');
const router = express.Router();
const communityController = require('../controllers/community.controller');
const authMiddleware = require('../middlewares/auth.middleware');

// Validación Joi temporalmente deshabilitada hasta que Railway reinstale dependencias
// const { validate, createCommunitySchema } = require('../validators/user.validator');

// Handle CORS preflight
router.options('*', (req, res) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, PATCH, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With');
  res.status(200).send();
});

// Rutas específicas primero
router.post('/', authMiddleware, communityController.create);
router.get('/my-communities', authMiddleware, communityController.getMyCommunities);
router.post('/join', authMiddleware, communityController.join);
router.post('/leave', authMiddleware, communityController.leave);
router.get('/is-member/:comunidad_id', authMiddleware, communityController.isMember);

// Rutas genéricas al final
router.get('/', (req, res) => {
  // Pasar el usuario si está autenticado, pero no requerir autenticación
  if (req.headers.authorization) {
    authMiddleware(req, res, () => {
      communityController.list(req, res);
    });
  } else {
    communityController.list(req, res);
  }
});

// Eliminar comunidad (solo creador o admin)
router.delete('/:id', authMiddleware, communityController.delete);

module.exports = router;
