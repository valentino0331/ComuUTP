const express = require('express');
const router = express.Router();
const likeController = require('../controllers/like.controller');
const { authenticate } = require('../middlewares/auth.middleware');

router.post('/', authenticate, likeController.like);
router.delete('/', authenticate, likeController.unlike);

module.exports = router;
