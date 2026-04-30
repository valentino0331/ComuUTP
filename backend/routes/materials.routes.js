// backend/routes/materials.routes.js

const express = require('express');
const multer = require('multer');
const materialController = require('../src/controllers/material.controller');
const authMiddleware = require('../src/middlewares/auth.middleware');

const router = express.Router();
const upload = multer({ storage: multer.memoryStorage() });

router.use(authMiddleware);

router.post('/upload', upload.single('file'), materialController.uploadMaterial);
router.get('/:materialId', materialController.getMaterial);
router.get('/course/:courseId', materialController.getMaterialsByCourse);
router.delete('/:materialId', materialController.deleteMaterial);

module.exports = router;
