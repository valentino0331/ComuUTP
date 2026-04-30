const express = require('express');
const router = express.Router();
const { authenticate } = require('../middlewares/auth.middleware');
const { upload } = require('../middlewares/upload.middleware');
const studyController = require('../controllers/study.controller');

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

// ===== RUTA DIRECTA PARA MATERIALS (compatibilidad con frontend) =====
router.post('/materials/upload', authenticate, upload.single('file'), (req, res, next) => {
  const courseId = req.body.courseId || req.query.courseId;
  if (!courseId) {
    return res.status(400).json({ error: 'courseId is required' });
  }
  req.params.courseId = courseId;
  studyController.uploadMaterial(req, res, next);
});
router.delete('/materials/:materialId', authenticate, studyController.deleteMaterial);

// ===== MODO ESTUDIO =====
router.use('/study', require('./study.routes'));

// ===== RUTAS AI (para compatibilidad con frontend) =====
router.use('/ai', require('./ai.routes')); // AI endpoints específicos

module.exports = router;
