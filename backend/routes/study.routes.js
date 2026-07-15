// backend/routes/study.routes.js

const express = require('express');
const studyController = require('../src/controllers/study.controller');
const authMiddleware = require('../src/middlewares/auth.middleware');

const router = express.Router();

// Middleware: Verificar autenticación en todas las rutas
router.use(authMiddleware);

// Cursos
router.get('/courses', studyController.getUserCourses);
router.post('/courses', studyController.createCourse);
router.get('/courses/:courseId', studyController.getCourseDetail);
router.put('/courses/:courseId', studyController.updateCourse);
router.delete('/courses/:courseId', studyController.archiveCourse);

module.exports = router;
