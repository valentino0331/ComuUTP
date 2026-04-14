const express = require('express');
const router = express.Router();
const authController = require('../controllers/auth.controller');
const { validateRegister, validateLogin } = require('../middlewares/auth.validation');
const authMiddleware = require('../middlewares/auth.middleware');

// Handle CORS preflight for all auth routes
router.options('*', (req, res) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, PATCH, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With');
  res.header('Access-Control-Allow-Credentials', 'true');
  res.status(200).send();
});

// Firebase Auth + Neon endpoints
router.post('/register', validateRegister, authController.register);
router.post('/login', validateLogin, authController.login);
router.post('/sync-user', authController.syncUser);
router.get('/me', authMiddleware, authController.me);

// Email verification endpoints
router.get('/verify-email', authController.verifyEmail);
router.post('/resend-verification', authController.resendVerification);

module.exports = router;
