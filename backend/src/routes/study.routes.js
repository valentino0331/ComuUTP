// backend/src/routes/study.routes.js
// Study routes - Modo Estudio + IA

const express = require('express');
const router = express.Router();
const studyController = require('../controllers/study.controller');
const { authenticate } = require('../middlewares/auth.middleware');
const { upload } = require('../middlewares/upload.middleware');

// Rutas de cursos
router.get('/courses', authenticate, studyController.getUserCourses);
router.post('/courses', authenticate, studyController.createCourse);
router.get('/courses/:courseId', authenticate, studyController.getCourseDetail);
router.put('/courses/:courseId', authenticate, studyController.updateCourse);
router.patch('/courses/:courseId/archive', authenticate, studyController.archiveCourse);

// Rutas de materiales
router.post('/courses/:courseId/materials', authenticate, upload.single('file'), studyController.uploadMaterial);
router.post('/materials/upload', authenticate, upload.single('file'), (req, res, next) => {
  // Compatibilidad con frontend - extraer courseId del body o query
  const courseId = req.body.courseId || req.query.courseId;
  if (!courseId) {
    return res.status(400).json({ error: 'courseId is required' });
  }
  // Llamar al controlador con el courseId en params
  req.params.courseId = courseId;
  studyController.uploadMaterial(req, res, next);
});
router.delete('/materials/:materialId', authenticate, studyController.deleteMaterial);

// Rutas de IA
router.post('/ai/summarize', authenticate, studyController.summarizeMaterial);
router.post('/ai/generate-quiz', authenticate, studyController.generateQuiz);
router.post('/ai/ask-question', authenticate, studyController.askQuestion);
router.get('/ai/questions/:courseId', authenticate, studyController.getQuestions);
router.post('/ai/quiz-attempt', authenticate, studyController.submitQuizAttempt);

module.exports = router;
