const express = require('express');
const router = express.Router();
const likeController = require('../controllers/like.controller');
const authMiddleware = require('../middlewares/auth.middleware');

router.post('/', authMiddleware, likeController.like);
router.delete('/', authMiddleware, likeController.unlike);

module.exports = router;
