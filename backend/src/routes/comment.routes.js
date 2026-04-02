const express = require('express');
const router = express.Router();
const commentController = require('../controllers/comment.controller');
const authMiddleware = require('../middlewares/auth.middleware');

router.post('/', authMiddleware, commentController.create);

module.exports = router;
