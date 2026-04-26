const express = require('express');
const router = express.Router();
const savedController = require('../controllers/saved.controller');
const authMiddleware = require('../middlewares/auth.middleware');

// Guardar post
router.post('/save', authMiddleware, savedController.savePost);

// Desguardar post
router.delete('/unsave/:post_id', authMiddleware, savedController.unsavePost);

// Obtener posts guardados del usuario
router.get('/posts', authMiddleware, savedController.getSavedPosts);

// Crear colección
router.post('/collection', authMiddleware, savedController.createCollection);

// Obtener colecciones del usuario
router.get('/collections', authMiddleware, savedController.getCollections);

module.exports = router;
