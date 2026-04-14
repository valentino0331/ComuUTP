const express = require('express');
const router = express.Router();
const communityController = require('../controllers/community.controller');
const authMiddleware = require('../middlewares/auth.middleware');

// Handle CORS preflight
router.options('*', (req, res) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, PATCH, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With');
  res.status(200).send();
});

router.post('/', authMiddleware, communityController.create);
router.get('/', communityController.list);
router.post('/join', authMiddleware, communityController.join);

module.exports = router;
