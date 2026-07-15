const express = require('express');
const router = express.Router();
const commentController = require('../controllers/comment.controller');
const { authenticate } = require('../middlewares/auth.middleware');

router.post('/', authenticate, commentController.create);
router.delete('/:id', authenticate, commentController.delete);
router.put('/:id', authenticate, commentController.update);

module.exports = router;
