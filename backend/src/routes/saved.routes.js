const express = require('express');
const router = express.Router();
const savedController = require('../controllers/saved.controller');
const { authenticate } = require('../middlewares/auth.middleware');

// Guardar post
router.post('/save', authenticate, savedController.savePost);

// Desguardar post
router.delete('/unsave/:post_id', authenticate, savedController.unsavePost);

// Obtener posts guardados del usuario
router.get('/posts', authenticate, savedController.getSavedPosts);

// Crear colección
router.post('/collection', authenticate, savedController.createCollection);

// Obtener colecciones del usuario
router.get('/collections', authenticate, savedController.getCollections);

module.exports = router;
