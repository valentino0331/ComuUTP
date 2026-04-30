// backend/routes/ai.routes.js

const express = require('express');
const aiController = require('../src/controllers/ai.controller');
const authMiddleware = require('../src/middlewares/auth.middleware');

const router = express.Router();

router.use(authMiddleware);

// AI endpoints
router.post('/summarize', aiController.summarizeMaterial);
router.post('/explain', aiController.explainContent);
router.post('/generate-quiz', aiController.generateQuiz);
router.post('/ask-question', aiController.askQuestion);
router.get('/responses/:materialId', aiController.getCachedResponses);
router.get('/questions/:courseId', aiController.getQuestions);
router.post('/quiz-attempt', aiController.submitQuizAttempt);

module.exports = router;
