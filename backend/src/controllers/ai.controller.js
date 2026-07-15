// backend/src/controllers/ai.controller.js

const aiService = require('../services/ai.service');
const materialService = require('../services/material.service');
const pool = require('../config/db');

exports.summarizeMaterial = async (req, res) => {
  try {
    const userId = req.user.id;
    const { materialId, forceRefresh = false } = req.body;

    // Obtener material
    const material = await materialService.getMaterialById(materialId);

    // Check cache si no es forceRefresh
    if (!forceRefresh) {
      const cached = await pool.query(
        `SELECT * FROM ai_responses_cache 
         WHERE material_id = $1 AND response_type = 'summary' AND user_id = $2
         ORDER BY created_at DESC LIMIT 1`,
        [materialId, userId]
      );

      if (cached.rows.length > 0) {
        return res.status(200).json({
          success: true,
          data: cached.rows[0],
          fromCache: true
        });
      }
    }

    // Generar resumen
    const summary = await aiService.summarize(material.text_content || material.file_url, {
      title: material.name
    });

    // Guardar en cache
    await aiService.cacheResponse(
      materialId,
      userId,
      'summary',
      'summarize',
      summary.content,
      summary.tokensUsed
    );

    res.status(200).json({
      success: true,
      data: {
        type: 'summary',
        content: summary.content,
        tokensUsed: summary.tokensUsed,
        generatedAt: new Date()
      }
    });
  } catch (err) {
    console.error('Error:', err);
    res.status(500).json({ error: err.message });
  }
};

exports.explainContent = async (req, res) => {
  try {
    const userId = req.user.id;
    const { materialId, concept, level = 'basic' } = req.body;

    const material = await materialService.getMaterialById(materialId);

    const explanation = await aiService.explain(
      concept,
      level,
      material.text_content || ''
    );

    await aiService.cacheResponse(
      materialId,
      userId,
      'explanation',
      concept,
      explanation.content,
      0
    );

    res.status(200).json({
      success: true,
      data: {
        type: 'explanation',
        content: explanation.content,
        generatedAt: new Date()
      }
    });
  } catch (err) {
    console.error('Error:', err);
    res.status(500).json({ error: err.message });
  }
};

exports.generateQuiz = async (req, res) => {
  try {
    const userId = req.user.id;
    const { courseId, count = 5, difficulty = 'medium' } = req.body;

    // Obtener materiales del curso para contexto
    const materials = await pool.query(
      `SELECT text_content FROM study_materials 
       WHERE course_id = $1 AND text_content IS NOT NULL
       ORDER BY created_at DESC LIMIT 3`,
      [courseId]
    );

    const context = materials.rows
      .map(m => m.text_content)
      .join('\n')
      .substring(0, 3000) || 'General knowledge';

    // Generar preguntas
    const quiz = await aiService.generateQuiz(context, { count, difficulty });

    // Guardar preguntas
    const questionIds = [];

    for (const q of quiz.questions) {
      const result = await pool.query(
        `INSERT INTO study_questions 
         (course_id, question_text, options, correct_option, explanation, difficulty_level, ai_generated, created_by_user_id)
         VALUES ($1, $2, $3, $4, $5, $6, TRUE, $7)
         RETURNING id`,
        [
          courseId,
          q.question,
          JSON.stringify(q.options),
          q.correctOption,
          q.explanation,
          difficulty,
          userId
        ]
      );

      questionIds.push(result.rows[0].id);
    }

    res.status(200).json({
      success: true,
      data: {
        quizId: `quiz_${Date.now()}`,
        questionIds,
        count: quiz.questions.length,
        difficulty
      }
    });
  } catch (err) {
    console.error('Error:', err);
    res.status(500).json({ error: err.message });
  }
};

exports.askQuestion = async (req, res) => {
  try {
    const userId = req.user.id;
    const { courseId, question } = req.body;

    if (!question) {
      return res.status(400).json({ error: 'Question required' });
    }

    // Obtener contexto del curso
    const materials = await pool.query(
      `SELECT text_content FROM study_materials 
       WHERE course_id = $1 AND text_content IS NOT NULL
       LIMIT 5`,
      [courseId]
    );

    const context = materials.rows
      .map(m => m.text_content)
      .join('\n')
      .substring(0, 4000) || 'General study context';

    // Responder
    const answer = await aiService.answerQuestion(question, context);

    res.status(200).json({
      success: true,
      data: {
        type: 'qa',
        question,
        answer: answer.content,
        generatedAt: new Date()
      }
    });
  } catch (err) {
    console.error('Error:', err);
    res.status(500).json({ error: err.message });
  }
};

exports.getCachedResponses = async (req, res) => {
  try {
    const userId = req.user.id;
    const { materialId } = req.params;

    const responses = await aiService.getCachedResponses(materialId, userId);

    res.status(200).json({
      success: true,
      data: responses,
      count: responses.length
    });
  } catch (err) {
    console.error('Error:', err);
    res.status(500).json({ error: err.message });
  }
};

exports.getQuestions = async (req, res) => {
  try {
    const { courseId } = req.params;

    const result = await pool.query(
      `SELECT * FROM study_questions 
       WHERE course_id = $1
       ORDER BY created_at DESC`,
      [courseId]
    );

    res.status(200).json({
      success: true,
      data: result.rows,
      count: result.rows.length
    });
  } catch (err) {
    console.error('Error:', err);
    res.status(500).json({ error: err.message });
  }
};

exports.submitQuizAttempt = async (req, res) => {
  try {
    const userId = req.user.id;
    const { courseId, answers, timeSpent } = req.body;

    let correctCount = 0;

    // Validar respuestas
    for (const [questionId, selectedOption] of Object.entries(answers)) {
      const question = await pool.query(
        'SELECT correct_option FROM study_questions WHERE id = $1',
        [questionId]
      );

      if (question.rows.length > 0 && question.rows[0].correct_option === selectedOption) {
        correctCount++;
      }
    }

    const totalQuestions = Object.keys(answers).length;
    const score = Math.round((correctCount / totalQuestions) * 100);

    // Guardar intento
    await pool.query(
      `INSERT INTO quiz_attempts (user_id, course_id, score, total_questions, time_spent_seconds, answers)
       VALUES ($1, $2, $3, $4, $5, $6)`,
      [userId, courseId, score, totalQuestions, timeSpent, JSON.stringify(answers)]
    );

    res.status(200).json({
      success: true,
      data: {
        score,
        correctCount,
        totalQuestions,
        percentage: `${score}%`
      }
    });
  } catch (err) {
    console.error('Error:', err);
    res.status(500).json({ error: err.message });
  }
};
