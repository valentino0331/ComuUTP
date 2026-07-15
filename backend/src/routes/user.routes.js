const express = require('express');
const router = express.Router();
const userController = require('../controllers/user.controller');
const { authenticate } = require('../middlewares/auth.middleware');

router.get('/profile', authenticate, userController.profile);
router.post('/edit', authenticate, userController.updateProfile);
router.get('/followers/:id?', authenticate, userController.getFollowers);
router.get('/following/:id?', authenticate, userController.getFollowing);
router.get('/stats', authenticate, userController.getStats);
router.post('/dark-mode', authenticate, userController.toggleDarkMode);
router.delete('/account', authenticate, userController.deleteAccount);

module.exports = router;
