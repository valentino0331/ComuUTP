const express = require('express');
const router = express.Router();
const adminController = require('../controllers/admin.controller');
const { authenticate } = require('../middlewares/auth.middleware');

// All admin routes require authentication and admin role
router.use(authenticate);
router.use(adminController.checkIsAdmin);

// User management
router.get('/usuarios', adminController.getAllUsers);
router.get('/usuarios/:userId', adminController.getUser);
router.patch('/usuarios/:userId', adminController.updateUserPermissions);
router.patch('/usuarios/:userId/permisos', adminController.updateUserPermissions);

// Content creation helpers
router.post('/comunidades', adminController.createCommunityAdmin);
router.post('/posts', adminController.createPostAdmin);

// Dashboard
router.get('/stats', adminController.getAdminStats);

module.exports = router;
