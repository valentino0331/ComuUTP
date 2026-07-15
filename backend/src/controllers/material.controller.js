// backend/src/controllers/material.controller.js

const materialService = require('../services/material.service');
const cloudinary = require('cloudinary').v2;
const pool = require('../config/db');

cloudinary.config({
  cloud_name: process.env.CLOUDINARY_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET
});

// Allowed file types for study materials
const ALLOWED_FILE_TYPES = ['application/pdf', 'text/plain', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'];
const MAX_FILE_SIZE = 50 * 1024 * 1024; // 50 MB

exports.uploadMaterial = async (req, res) => {
  try {
    const userId = req.user.id;
    const { courseId } = req.body;
    const file = req.file;

    if (!file) {
      return res.status(400).json({ error: 'No file provided' });
    }

    if (!courseId) {
      return res.status(400).json({ error: 'courseId required' });
    }

    // Validate file type
    if (!ALLOWED_FILE_TYPES.includes(file.mimetype)) {
      return res.status(400).json({ 
        error: 'Tipo de archivo no permitido. Solo PDF, TXT y DOCX.' 
      });
    }

    // Validate file size
    if (file.size > MAX_FILE_SIZE) {
      return res.status(400).json({ 
        error: `Archivo demasiado grande. Máximo: 50MB. Actual: ${(file.size / 1024 / 1024).toFixed(2)}MB` 
      });
    }

    // Validar que el curso pertenece al usuario
    const courseCheck = await pool.query(
      'SELECT id FROM study_courses WHERE id = $1 AND user_id = $2',
      [courseId, userId]
    );

    if (courseCheck.rows.length === 0) {
      return res.status(403).json({ error: 'No tienes acceso a este curso' });
    }

    // Upload a Cloudinary
    const uploadResult = await new Promise((resolve, reject) => {
      const stream = cloudinary.uploader.upload_stream(
        {
          folder: `utp/study/${courseId}`,
          resource_type: 'auto',
          public_id: `${Date.now()}_${file.originalname.replace(/\s+/g, '_')}`,
          timeout: 60000
        },
        (error, result) => {
          if (error) reject(error);
          else resolve(result);
        }
      );
      stream.end(file.buffer);
    });

    // Guardar en BD
    const material = await materialService.saveMaterial(courseId, userId, file, uploadResult);

    res.status(201).json({
      success: true,
      data: material,
      message: 'Material subido exitosamente'
    });
  } catch (err) {
    console.error('Error:', err);
    res.status(500).json({ error: err.message });
  }
};

exports.getMaterial = async (req, res) => {
  try {
    const { materialId } = req.params;
    const material = await materialService.getMaterialById(materialId);
    
    res.status(200).json({
      success: true,
      data: material
    });
  } catch (err) {
    console.error('Error:', err);
    res.status(404).json({ error: err.message });
  }
};

exports.getMaterialsByCourse = async (req, res) => {
  try {
    const { courseId } = req.params;
    const materials = await materialService.getMaterialsByCourse(courseId);
    
    res.status(200).json({
      success: true,
      data: materials,
      count: materials.length
    });
  } catch (err) {
    console.error('Error:', err);
    res.status(500).json({ error: err.message });
  }
};

exports.deleteMaterial = async (req, res) => {
  try {
    const userId = req.user.id;
    const { materialId } = req.params;
    
    await materialService.deleteMaterial(materialId, userId);
    
    res.status(200).json({
      success: true,
      message: 'Material deleted'
    });
  } catch (err) {
    console.error('Error:', err);
    res.status(400).json({ error: err.message });
  }
};
