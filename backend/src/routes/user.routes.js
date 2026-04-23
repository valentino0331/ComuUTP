const express = require('express');
const router = express.Router();
const userController = require('../controllers/user.controller');
const authMiddleware = require('../middlewares/auth.middleware');

router.get('/profile', authMiddleware, userController.profile);
router.post('/edit', authMiddleware, userController.updateProfile);
router.get('/followers/:id?', authMiddleware, userController.getFollowers);
router.get('/following/:id?', authMiddleware, userController.getFollowing);
router.delete('/account', authMiddleware, userController.deleteAccount);

module.exports = router;
