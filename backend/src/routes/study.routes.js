// backend/src/routes/study.routes.js

const express = require('express');
const router = express.Router();
const studyController = require('../controllers/study.controller');
const { authenticate } = require('../middlewares/auth.middleware');

// Rutas de cursos
router.get('/courses', authenticate, studyController.getUserCourses);
router.post('/courses', authenticate, studyController.createCourse);
router.get('/courses/:courseId', authenticate, studyController.getCourseDetail);
router.put('/courses/:courseId', authenticate, studyController.updateCourse);
router.patch('/courses/:courseId/archive', authenticate, studyController.archiveCourse);

// Rutas de materiales
router.post('/courses/:courseId/materials', authenticate, studyController.uploadMaterial);
router.delete('/materials/:materialId', authenticate, studyController.deleteMaterial);

// Rutas de IA
router.post('/ai/summarize', authenticate, studyController.summarizeMaterial);
router.post('/ai/generate-quiz', authenticate, studyController.generateQuiz);
router.post('/ai/ask-question', authenticate, studyController.askQuestion);
router.get('/ai/questions/:courseId', authenticate, studyController.getQuestions);
router.post('/ai/quiz-attempt', authenticate, studyController.submitQuizAttempt);

module.exports = router;
