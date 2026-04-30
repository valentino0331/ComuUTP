// backend/src/services/material.service.js

const pool = require('../config/db');
const cloudinary = require('cloudinary').v2;
const { v4: uuidv4 } = require('uuid');

cloudinary.config({
  cloud_name: process.env.CLOUDINARY_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET
});

class MaterialService {
  
  // Guardar material en BD después de upload a Cloudinary
  async saveMaterial(courseId, userId, fileData, cloudinaryResult) {
    try {
      const materialId = uuidv4();

      const result = await pool.query(
        `INSERT INTO study_materials 
         (id, course_id, uploaded_by_user_id, name, file_url, file_size_bytes, 
          file_type, cloudinary_public_id, created_at)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, CURRENT_TIMESTAMP)
         RETURNING *`,
        [
          materialId,
          courseId,
          userId,
          fileData.originalname,
          cloudinaryResult.secure_url,
          fileData.size,
          fileData.mimetype.includes('pdf') ? 'pdf' : 'document',
          cloudinaryResult.public_id
        ]
      );

      return result.rows[0];
    } catch (err) {
      throw new Error(`Error saving material: ${err.message}`);
    }
  }

  // Obtener material por ID
  async getMaterialById(materialId) {
    try {
      const result = await pool.query(
        'SELECT * FROM study_materials WHERE id = $1',
        [materialId]
      );

      if (result.rows.length === 0) {
        throw new Error('Material not found');
      }

      return result.rows[0];
    } catch (err) {
      throw new Error(`Error fetching material: ${err.message}`);
    }
  }

  // Obtener materiales por curso
  async getMaterialsByCourse(courseId) {
    try {
      const result = await pool.query(
        `SELECT * FROM study_materials 
         WHERE course_id = $1
         ORDER BY created_at DESC`,
        [courseId]
      );

      return result.rows;
    } catch (err) {
      throw new Error(`Error fetching materials: ${err.message}`);
    }
  }

  // Eliminar material
  async deleteMaterial(materialId, userId) {
    try {
      const material = await pool.query(
        'SELECT * FROM study_materials WHERE id = $1',
        [materialId]
      );

      if (material.rows.length === 0) {
        throw new Error('Material not found');
      }

      if (material.rows[0].uploaded_by_user_id !== userId) {
        throw new Error('Unauthorized');
      }

      // Borrar de Cloudinary
      if (material.rows[0].cloudinary_public_id) {
        await cloudinary.uploader.destroy(material.rows[0].cloudinary_public_id);
      }

      // Borrar de BD
      await pool.query(
        'DELETE FROM study_materials WHERE id = $1',
        [materialId]
      );

      return { success: true };
    } catch (err) {
      throw new Error(`Error deleting material: ${err.message}`);
    }
  }
}

module.exports = new MaterialService();
