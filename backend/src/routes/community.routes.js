const express = require('express');
const router = express.Router();
const communityController = require('../controllers/community.controller');
const authMiddleware = require('../middlewares/auth.middleware');

router.post('/', authMiddleware, communityController.create);
router.get('/', communityController.list);
router.post('/join', authMiddleware, communityController.join);

module.exports = router;
