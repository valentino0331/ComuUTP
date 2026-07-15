const express = require('express');
const router = express.Router();
const hashtagController = require('../controllers/hashtag.controller');
const { authenticate } = require('../middlewares/auth.middleware');

// Procesar hashtags en un post
router.post('/process', authenticate, hashtagController.processHashtags);

// Obtener trending hashtags
router.get('/trending', authenticate, hashtagController.getTrending);

// Buscar posts por hashtag
router.get('/search/:hashtag', authenticate, hashtagController.searchByHashtag);

module.exports = router;
