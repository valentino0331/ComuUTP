// backend/src/routes/ai.routes.js
// AI routes for EstudIA - Compatible con frontend

const express = require('express');
const router = express.Router();
const studyController = require('../controllers/study.controller');
const { authenticate } = require('../middlewares/auth.middleware');

// AI endpoints (sin prefijo /ai porque se montan en /api/ai)
router.post('/summarize', authenticate, studyController.summarizeMaterial);
router.post('/generate-quiz', authenticate, studyController.generateQuiz);
router.post('/ask-question', authenticate, studyController.askQuestion);
router.get('/questions/:courseId', authenticate, studyController.getQuestions);
router.post('/quiz-attempt', authenticate, studyController.submitQuizAttempt);

module.exports = router;
