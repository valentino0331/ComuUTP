// backend/src/services/study.service.js

const pool = require('../config/db');
const { v4: uuidv4 } = require('uuid');
const OpenAI = require('openai');

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

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
      const { name, fileUrl, fileSizeBytes, fileType, pageCount, category } = materialData;
      
      if (!name || !fileUrl) throw new Error('Name and fileUrl are required');

      const materialId = uuidv4();
      const result = await pool.query(
        `INSERT INTO study_materials 
         (id, course_id, user_id, name, file_url, file_size_bytes, file_type, page_count, category)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
         RETURNING *`,
        [materialId, courseId, userId, name, fileUrl, fileSizeBytes, fileType || 'pdf', pageCount, category]
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

  // Generación de resumen con IA usando OpenAI
  async generateAISummary(material) {
    try {
      if (!process.env.OPENAI_API_KEY) {
        return `Resumen generado para "${material.name}":\n\nEste es un resumen automático del material. Para usar la funcionalidad completa de IA, configura OPENAI_API_KEY en Railway.`;
      }

      const response = await openai.chat.completions.create({
        model: "gpt-3.5-turbo",
        messages: [
          {
            role: "system",
            content: "Eres un asistente académico experto que genera resúmenes concisos y útiles de materiales de estudio universitario."
          },
          {
            role: "user",
            content: `Genera un resumen del siguiente material de estudio: "${material.name}". El resumen debe incluir los puntos clave, conceptos importantes y cualquier información relevante para estudiar.`
          }
        ],
        max_tokens: 500,
        temperature: 0.7,
      });

      return response.choices[0].message.content || 'No se pudo generar el resumen.';
    } catch (error) {
      console.error('Error calling OpenAI:', error);
      return `Error al generar resumen con IA: ${error.message}`;
    }
  }

  // Generación de preguntas con IA usando OpenAI
  async generateAIQuestions(courseId, materials, count, difficulty) {
    try {
      if (!process.env.OPENAI_API_KEY) {
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

      const materialNames = materials.map(m => m.name).join(', ');
      
      const response = await openai.chat.completions.create({
        model: "gpt-3.5-turbo",
        messages: [
          {
            role: "system",
            content: "Eres un profesor experto que genera preguntas de opción múltiple para cuestionarios académicos. Genera preguntas en formato JSON con estructura: {questionText, options: {A, B, C, D}, correctOption, explanation}."
          },
          {
            role: "user",
            content: `Genera ${count} preguntas de opción múltiple de dificultad ${difficulty} basadas en los siguientes materiales: ${materialNames}. Devuelve SOLO un array JSON con las preguntas.`
          }
        ],
        max_tokens: 1000,
        temperature: 0.7,
      });

      const content = response.choices[0].message.content;
      const questions = JSON.parse(content);
      
      return Array.isArray(questions) ? questions : [questions];
    } catch (error) {
      console.error('Error calling OpenAI for questions:', error);
      // Fallback a preguntas placeholder si falla OpenAI
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

  // Respuesta de IA usando OpenAI
  async generateAIAnswer(courseId, question) {
    try {
      if (!process.env.OPENAI_API_KEY) {
        return `Respuesta generada por IA para: "${question}"\n\nPara usar la funcionalidad completa de IA, configura OPENAI_API_KEY en Railway.`;
      }

      const response = await openai.chat.completions.create({
        model: "gpt-3.5-turbo",
        messages: [
          {
            role: "system",
            content: "Eres un tutor académico experto que responde preguntas de estudiantes de manera clara y útil."
          },
          {
            role: "user",
            content: question
          }
        ],
        max_tokens: 500,
        temperature: 0.7,
      });

      return response.choices[0].message.content || 'No se pudo generar la respuesta.';
    } catch (error) {
      console.error('Error calling OpenAI for answer:', error);
      return `Error al generar respuesta con IA: ${error.message}`;
    }
  }
}

module.exports = new StudyService();
