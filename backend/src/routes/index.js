const express = require('express');
const router = express.Router();

router.use('/auth', require('./auth.routes'));
router.use('/users', require('./user.routes'));
router.use('/communities', require('./community.routes'));
router.use('/posts', require('./post.routes'));
router.use('/comments', require('./comment.routes'));
router.use('/likes', require('./like.routes'));
router.use('/reactions', require('./reaction.routes'));
router.use('/messages', require('./message.routes'));
router.use('/mentions', require('./mention.routes'));
router.use('/hashtags', require('./hashtag.routes'));
router.use('/saved', require('./saved.routes'));
router.use('/search', require('./search.routes'));
router.use('/events', require('./event.routes'));
router.use('/polls', require('./poll.routes'));
router.use('/reports', require('./report.routes'));
router.use('/ban', require('./ban.routes'));
router.use('/notifications', require('./notification.routes'));
router.use('/stories', require('./story.routes'));
router.use('/admin', require('./admin.routes'));
router.use('/friendship', require('./friendship.routes'));

module.exports = router;
