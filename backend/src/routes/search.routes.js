const express = require('express');
const router = express.Router();
const searchController = require('../controllers/search.controller');
const authMiddleware = require('../middlewares/auth.middleware');

// Búsqueda avanzada
router.get('/', authMiddleware, searchController.search);

module.exports = router;
