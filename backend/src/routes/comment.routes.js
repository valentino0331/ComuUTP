const express = require('express');
const router = express.Router();
const commentController = require('../controllers/comment.controller');
const { authenticate } = require('../middlewares/auth.middleware');

router.post('/', authenticate, commentController.create);

module.exports = router;
