const express = require('express');
const router = express.Router();
const notificationController = require('../controllers/notification.controller');
const { authenticate } = require('../middlewares/auth.middleware');
const adminController = require('../controllers/admin.controller');

router.get('/', authenticate, notificationController.list);

// Broadcast notification to all users (admin only)
router.post('/broadcast', authenticate, adminController.checkIsAdmin, notificationController.broadcast);

module.exports = router;
