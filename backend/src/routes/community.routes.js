const express = require('express');
const router = express.Router();
const communityController = require('../controllers/community.controller');
const { authenticate } = require('../middlewares/auth.middleware');

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
router.post('/', authenticate, communityController.create);
router.get('/my-communities', authenticate, communityController.getMyCommunities);
router.post('/join', authenticate, communityController.join);
router.post('/leave', authenticate, communityController.leave);
router.get('/is-member/:comunidad_id', authenticate, communityController.isMember);
router.get('/members/:comunidadId', authenticate, communityController.getMembers);

// Rutas genéricas al final
router.get('/', (req, res) => {
  // Pasar el usuario si está autenticado, pero no requerir autenticación
  if (req.headers.authorization) {
    authenticate(req, res, () => {
      communityController.list(req, res);
    });
  } else {
    communityController.list(req, res);
  }
});

// Eliminar comunidad (solo creador o admin)
router.delete('/:id', authenticate, communityController.delete);

module.exports = router;
