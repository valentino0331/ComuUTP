const express = require('express');
const router = express.Router();
const postController = require('../controllers/post.controller');
const { authenticate } = require('../middlewares/auth.middleware');

// Validación Joi temporalmente deshabilitada hasta que Railway reinstale dependencias
// const { validate, createPostSchema } = require('../validators/user.validator');

router.post('/', authenticate, postController.create);
router.get('/', authenticate, postController.list);
router.get('/community/:id', postController.listByCommunity);
router.delete('/:id', authenticate, postController.delete);

module.exports = router;
