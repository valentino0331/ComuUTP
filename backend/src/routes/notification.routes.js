const express = require('express');
const router = express.Router();
const notificationController = require('../controllers/notification.controller');
const authMiddleware = require('../middlewares/auth.middleware');
const adminController = require('../controllers/admin.controller');

router.get('/', authMiddleware, notificationController.list);

// Broadcast notification to all users (admin only)
router.post('/broadcast', authMiddleware, adminController.checkIsAdmin, notificationController.broadcast);

module.exports = router;
