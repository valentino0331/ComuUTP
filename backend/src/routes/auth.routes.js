const express = require('express');
const router = express.Router();
const authController = require('../controllers/auth.controller');
const { validateRegister, validateLogin } = require('../middlewares/auth.validation');
const authMiddleware = require('../middlewares/auth.middleware');

// Firebase Auth + Neon endpoints
router.post('/register', validateRegister, authController.register);
router.post('/login', validateLogin, authController.login);
router.post('/sync-user', authController.syncUser);
router.get('/me', authMiddleware, authController.me);

// Email verification endpoints
router.get('/verify-email', authController.verifyEmail);
router.post('/resend-verification', authController.resendVerification);

module.exports = router;
