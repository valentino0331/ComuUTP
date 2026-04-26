const express = require('express');
const router = express.Router();
const hashtagController = require('../controllers/hashtag.controller');
const authMiddleware = require('../middlewares/auth.middleware');

// Procesar hashtags en un post
router.post('/process', authMiddleware, hashtagController.processHashtags);

// Obtener trending hashtags
router.get('/trending', authMiddleware, hashtagController.getTrending);

// Buscar posts por hashtag
router.get('/search/:hashtag', authMiddleware, hashtagController.searchByHashtag);

module.exports = router;
