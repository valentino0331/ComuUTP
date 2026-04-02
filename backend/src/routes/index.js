const express = require('express');
const router = express.Router();

router.use('/auth', require('./auth.routes'));
router.use('/users', require('./user.routes'));
router.use('/communities', require('./community.routes'));
router.use('/posts', require('./post.routes'));
router.use('/comments', require('./comment.routes'));
router.use('/likes', require('./like.routes'));
router.use('/reports', require('./report.routes'));
router.use('/ban', require('./ban.routes'));
router.use('/notifications', require('./notification.routes'));

module.exports = router;
