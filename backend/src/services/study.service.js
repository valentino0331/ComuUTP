// backend/src/services/study.service.js

const pool = require('../config/db');
const { v4: uuidv4 } = require('uuid');

// Hugging Face Inference API (gratuito)
const HF_API_URL = 'https://api-inference.huggingface.co/models/mistralai/Mistral-7B-Instruct-v0.2';
const HF_API_KEY = process.env.HF_API_KEY || null; // Opcional, pero recomendado para mayor límite

class StudyService {
  
  // Obtener todos los cursos del usuario
  async getUserCourses(userId) {
    try {
      const result = await pool.query(
        `SELECT * FROM study_courses 
         WHERE user_id = $1 AND NOT is_archived
         ORDER BY created_at DESC`,
        [userId]
      );
      return result.rows;
    } catch (err) {
      throw new Error(`Error fetching courses: ${err.message}`);
    }
  }

  // Crear curso
  async createCourse(userId, courseData) {
    try {
      const { name, courseCode, professorName, description, semester, year } = courseData;
      
      if (!name) throw new Error('Course name is required');

      const courseId = uuidv4();
      const result = await pool.query(
        `INSERT INTO study_courses 
         (id, user_id, name, course_code, professor_name, description, 
          created_by_user_id, semester, year, metadata)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
         RETURNING *`,
        [
          courseId,
          userId,
          name,
          courseCode || null,
          professorName || null,
          description || null,
          userId,
          semester || null,
          year || new Date().getFullYear(),
          JSON.stringify({ temas: [], ciclos: [] })
        ]
      );

      return result.rows[0];
    } catch (err) {
      throw new Error(`Error creating course: ${err.message}`);
    }
  }

  // Obtener detalle del curso
  async getCourseDetail(courseId, userId) {
    try {
      const courseResult = await pool.query(
        `SELECT * FROM study_courses 
         WHERE id = $1 AND user_id = $2`,
        [courseId, userId]
      );

      if (courseResult.rows.length === 0) {
        throw new Error('Course not found');
      }

      const course = courseResult.rows[0];

      const materialsResult = await pool.query(
        `SELECT * FROM study_materials 
         WHERE course_id = $1
         ORDER BY created_at DESC`,
        [courseId]
      );

      return {
        course,
        materials: materialsResult.rows
      };
    } catch (err) {
      throw new Error(`Error fetching course detail: ${err.message}`);
    }
  }

  // Actualizar curso
  async updateCourse(courseId, userId, updateData) {
    try {
      const { name, professorName, description } = updateData;

      const result = await pool.query(
        `UPDATE study_courses 
         SET name = COALESCE($1, name),
             professor_name = COALESCE($2, professor_name),
             description = COALESCE($3, description),
             updated_at = CURRENT_TIMESTAMP
         WHERE id = $4 AND user_id = $5
         RETURNING *`,
        [name, professorName, description, courseId, userId]
      );

      if (result.rows.length === 0) {
        throw new Error('Course not found');
      }

      return result.rows[0];
    } catch (err) {
      throw new Error(`Error updating course: ${err.message}`);
    }
  }

  // Archivar curso
  async archiveCourse(courseId, userId) {
    try {
      const result = await pool.query(
        `UPDATE study_courses 
         SET is_archived = TRUE, updated_at = CURRENT_TIMESTAMP
         WHERE id = $1 AND user_id = $2
         RETURNING *`,
        [courseId, userId]
      );

      if (result.rows.length === 0) {
        throw new Error('Course not found');
      }

      return result.rows[0];
    } catch (err) {
      throw new Error(`Error archiving course: ${err.message}`);
    }
  }

  // Subir material
  async uploadMaterial(userId, courseId, materialData) {
    try {
      const { name, fileUrl, fileSizeBytes, fileType, pageCount, category, cloudinaryPublicId } = materialData;
      
      if (!name || !fileUrl) throw new Error('Name and fileUrl are required');

      const materialId = uuidv4();
      const result = await pool.query(
        `INSERT INTO study_materials 
         (id, course_id, uploaded_by_user_id, name, file_url, file_size_bytes, file_type, page_count, category, cloudinary_public_id)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
         RETURNING *`,
        [materialId, courseId, userId, name, fileUrl, fileSizeBytes, fileType || 'pdf', pageCount, category, cloudinaryPublicId]
      );

      return result.rows[0];
    } catch (err) {
      throw new Error(`Error uploading material: ${err.message}`);
    }
  }

  // Eliminar material
  async deleteMaterial(materialId, userId) {
    try {
      const result = await pool.query(
        `DELETE FROM study_materials 
         WHERE id = $1 AND user_id = $2
         RETURNING *`,
        [materialId, userId]
      );

      if (result.rows.length === 0) {
        throw new Error('Material not found');
      }

      return result.rows[0];
    } catch (err) {
      throw new Error(`Error deleting material: ${err.message}`);
    }
  }

  // Resumir material con IA
  async summarizeMaterial(userId, materialId) {
    try {
      // Verificar si ya existe un resumen en caché
      const cachedResult = await pool.query(
        `SELECT * FROM ai_responses 
         WHERE material_id = $1 AND type = 'summary' 
         ORDER BY created_at DESC LIMIT 1`,
        [materialId]
      );

      if (cachedResult.rows.length > 0) {
        return {
          ...cachedResult.rows[0],
          fromCache: true
        };
      }

      // Obtener el material
      const materialResult = await pool.query(
        `SELECT * FROM study_materials WHERE id = $1`,
        [materialId]
      );

      if (materialResult.rows.length === 0) {
        throw new Error('Material not found');
      }

      const material = materialResult.rows[0];

      // Generar resumen con IA (placeholder - se integrará OpenAI después)
      const summaryContent = await this.generateAISummary(material);

      // Guardar en base de datos
      const responseId = uuidv4();
      const result = await pool.query(
        `INSERT INTO ai_responses 
         (id, user_id, material_id, course_id, type, content, prompt, from_cache)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
         RETURNING *`,
        [responseId, userId, materialId, material.course_id, 'summary', summaryContent, JSON.stringify(material), false]
      );

      return result.rows[0];
    } catch (err) {
      throw new Error(`Error summarizing material: ${err.message}`);
    }
  }

  // Generar cuestionario con IA
  async generateQuiz(userId, courseId, count, difficulty) {
    try {
      // Obtener materiales del curso
      const materialsResult = await pool.query(
        `SELECT * FROM study_materials WHERE course_id = $1`,
        [courseId]
      );

      if (materialsResult.rows.length === 0) {
        throw new Error('No materials found for this course');
      }

      // Generar preguntas con IA (placeholder)
      const questions = await this.generateAIQuestions(courseId, materialsResult.rows, count, difficulty);

      // Guardar preguntas en base de datos
      const savedQuestions = [];
      for (const question of questions) {
        const questionId = uuidv4();
        const result = await pool.query(
          `INSERT INTO study_questions 
           (id, course_id, user_id, question_text, options, correct_option, explanation, difficulty_level)
           VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
           RETURNING *`,
          [questionId, courseId, userId, question.questionText, JSON.stringify(question.options), question.correctOption, question.explanation, difficulty]
        );
        savedQuestions.push(result.rows[0]);
      }

      return savedQuestions;
    } catch (err) {
      throw new Error(`Error generating quiz: ${err.message}`);
    }
  }

  // Hacer pregunta a IA
  async askQuestion(userId, courseId, question) {
    try {
      // Generar respuesta con IA (placeholder)
      const answerContent = await this.generateAIAnswer(courseId, question);

      // Guardar en base de datos
      const responseId = uuidv4();
      const result = await pool.query(
        `INSERT INTO ai_responses 
         (id, user_id, course_id, type, content, prompt, from_cache)
         VALUES ($1, $2, $3, $4, $5, $6, $7)
         RETURNING *`,
        [responseId, userId, courseId, 'answer', answerContent, question, false]
      );

      return result.rows[0];
    } catch (err) {
      throw new Error(`Error asking question: ${err.message}`);
    }
  }

  // Obtener preguntas de un curso
  async getQuestions(courseId) {
    try {
      const result = await pool.query(
        `SELECT * FROM study_questions WHERE course_id = $1 ORDER BY created_at DESC`,
        [courseId]
      );
      return result.rows;
    } catch (err) {
      throw new Error(`Error fetching questions: ${err.message}`);
    }
  }

  // Enviar intento de cuestionario
  async submitQuizAttempt(userId, courseId, answers, timeSpent) {
    try {
      const questions = await this.getQuestions(courseId);
      
      let correctCount = 0;
      for (const [questionId, answer] of Object.entries(answers)) {
        const question = questions.find(q => q.id === questionId);
        if (question && question.correct_option === answer) {
          correctCount++;
        }
      }

      const score = Math.round((correctCount / questions.length) * 100);

      const attemptId = uuidv4();
      const result = await pool.query(
        `INSERT INTO quiz_attempts 
         (id, user_id, course_id, answers, time_seconds, score, total_questions)
         VALUES ($1, $2, $3, $4, $5, $6, $7)
         RETURNING *`,
        [attemptId, userId, courseId, JSON.stringify(answers), timeSpent, score, questions.length]
      );

      return {
        ...result.rows[0],
        correctCount,
        totalQuestions: questions.length
      };
    } catch (err) {
      throw new Error(`Error submitting quiz attempt: ${err.message}`);
    }
  }

  // Generación de resumen con IA usando Hugging Face
  async generateAISummary(material) {
    try {
      const response = await fetch(HF_API_URL, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          ...(HF_API_KEY && { 'Authorization': `Bearer ${HF_API_KEY}` })
        },
        body: JSON.stringify({
          inputs: `<s>[INST] Eres un asistente académico experto. Genera un resumen conciso del siguiente material de estudio: "${material.name}". Incluye puntos clave y conceptos importantes. [/INST]`,
          parameters: {
            max_new_tokens: 500,
            temperature: 0.7,
            return_full_text: false
          }
        })
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const data = await response.json();
      const summary = Array.isArray(data) ? data[0]?.generated_text : data?.generated_text;
      
      return summary || 'No se pudo generar el resumen.';
    } catch (error) {
      console.error('Error calling Hugging Face:', error);
      return `Resumen generado para "${material.name}":\n\nEste es un resumen automático. La API de IA está teniendo problemas temporales.`;
    }
  }

  // Generación de preguntas con IA usando Hugging Face
  async generateAIQuestions(courseId, materials, count, difficulty) {
    try {
      const materialNames = materials.map(m => m.name).join(', ');
      
      const response = await fetch(HF_API_URL, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          ...(HF_API_KEY && { 'Authorization': `Bearer ${HF_API_KEY}` })
        },
        body: JSON.stringify({
          inputs: `<s>[INST] Eres un profesor experto. Genera ${count} preguntas de opción múltiple de dificultad ${difficulty} basadas en: ${materialNames}. Formato JSON: [{"questionText", "options": {"A", "B", "C", "D"}, "correctOption", "explanation"}]. [/INST]`,
          parameters: {
            max_new_tokens: 1000,
            temperature: 0.7,
            return_full_text: false
          }
        })
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const data = await response.json();
      const content = Array.isArray(data) ? data[0]?.generated_text : data?.generated_text;
      
      // Intentar parsear JSON, si falla usar placeholders
      try {
        const questions = JSON.parse(content);
        return Array.isArray(questions) ? questions : [questions];
      } catch {
        // Fallback a preguntas generadas
        const questions = [];
        for (let i = 0; i < count; i++) {
          questions.push({
            questionText: `Pregunta ${i + 1} sobre el curso (dificultad: ${difficulty})`,
            options: {
              A: 'Opción A',
              B: 'Opción B',
              C: 'Opción C',
              D: 'Opción D'
            },
            correctOption: 'A',
            explanation: 'Explicación de la respuesta correcta'
          });
        }
        return questions;
      }
    } catch (error) {
      console.error('Error calling Hugging Face for questions:', error);
      const questions = [];
      for (let i = 0; i < count; i++) {
        questions.push({
          questionText: `Pregunta ${i + 1} sobre el curso (dificultad: ${difficulty})`,
          options: {
            A: 'Opción A',
            B: 'Opción B',
            C: 'Opción C',
            D: 'Opción D'
          },
          correctOption: 'A',
          explanation: 'Explicación de la respuesta correcta'
        });
      }
      return questions;
    }
  }

  // Respuesta de IA usando Hugging Face
  async generateAIAnswer(courseId, question) {
    try {
      const response = await fetch(HF_API_URL, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          ...(HF_API_KEY && { 'Authorization': `Bearer ${HF_API_KEY}` })
        },
        body: JSON.stringify({
          inputs: `<s>[INST] Eres un tutor académico experto. Responde esta pregunta de estudiante de manera clara y útil: "${question}" [/INST]`,
          parameters: {
            max_new_tokens: 500,
            temperature: 0.7,
            return_full_text: false
          }
        })
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const data = await response.json();
      const answer = Array.isArray(data) ? data[0]?.generated_text : data?.generated_text;
      
      return answer || 'No se pudo generar la respuesta.';
    } catch (error) {
      console.error('Error calling Hugging Face for answer:', error);
      return `Respuesta generada para: "${question}"\n\nLa API de IA está teniendo problemas temporales. Intenta más tarde.`;
    }
  }

  // Eliminar curso y todos sus materiales
  async deleteCourse(courseId, userId) {
    try {
      // Verificar que el curso existe y pertenece al usuario
      const checkResult = await db.query(
        'SELECT id FROM study_courses WHERE id = $1 AND user_id = $2',
        [courseId, userId]
      );
      
      if (checkResult.rows.length === 0) {
        throw new Error('Curso no encontrado o no pertenece al usuario');
      }
      
      // Obtener todos los materiales para eliminar de Cloudinary
      const materialsResult = await db.query(
        'SELECT id, cloudinary_public_id FROM study_materials WHERE course_id = $1',
        [courseId]
      );
      
      // Eliminar archivos de Cloudinary
      const cloudinary = require('../config/cloudinary');
      for (const material of materialsResult.rows) {
        if (material.cloudinary_public_id) {
          try {
            await cloudinary.uploader.destroy(material.cloudinary_public_id);
          } catch (err) {
            console.warn('Error deleting from Cloudinary:', err.message);
          }
        }
      }
      
      // Eliminar curso (cascade eliminará materiales, preguntas, etc.)
      await db.query('DELETE FROM study_courses WHERE id = $1', [courseId]);
      
      return { deleted: true };
    } catch (err) {
      throw new Error(`Error deleting course: ${err.message}`);
    }
  }
}

module.exports = new StudyService();
