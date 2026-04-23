const express = require('express');
const router = express.Router();
const postController = require('../controllers/post.controller');
const authMiddleware = require('../middlewares/auth.middleware');

// Validación Joi temporalmente deshabilitada hasta que Railway reinstale dependencias
// const { validate, createPostSchema } = require('../validators/user.validator');

router.post('/', authMiddleware, postController.create);
router.get('/', authMiddleware, postController.list);
router.get('/community/:id', postController.listByCommunity);
router.delete('/:id', authMiddleware, postController.delete);

module.exports = router;
