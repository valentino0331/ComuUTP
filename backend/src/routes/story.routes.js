const express = require('express');
const storyController = require('../controllers/story.controller');
const { authenticate } = require('../middlewares/auth.middleware');

const router = express.Router();

// Todas las rutas requieren autenticación
router.use(authenticate);

// Crear historia
router.post('/create', storyController.create);

// Obtener historias de amigos
router.get('/friends', storyController.getFriendsStories);

// Marcar como vista
router.post('/mark-viewed', storyController.markAsViewed);

// Obtener quiénes vieron mi historia
router.get('/viewers/:historia_id', storyController.getViewers);

// Eliminar historia
router.delete('/:historia_id', storyController.delete);

// Limpiar historias expiradas
router.post('/admin/clean-expired', storyController.cleanExpired);

module.exports = router;
