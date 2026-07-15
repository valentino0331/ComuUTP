// backend/src/services/ai.service.js

const { OpenAI } = require('openai');
const pool = require('../config/db');
const { v4: uuidv4 } = require('uuid');

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY
});

class AIService {
  
  // Generar resumen
  async summarize(content, options = {}) {
    try {
      const truncated = content.substring(0, 2000);

      const message = await openai.chat.completions.create({
        model: 'gpt-3.5-turbo',
        messages: [
          { 
            role: 'system', 
            content: 'Eres un tutor experto. Crea resúmenes concisos en 5 puntos numerados. Sé claro y educativo.'
          },
          { 
            role: 'user', 
            content: `Documento: "${options.title || 'Material'}"\n\nResume en 5 puntos clave:\n\n${truncated}`
          }
        ],
        temperature: 0.7,
        max_tokens: 500
      });

      return {
        content: message.choices[0].message.content,
        tokensUsed: message.usage.total_tokens
      };
    } catch (err) {
      throw new Error(`Error summarizing: ${err.message}`);
    }
  }

  // Generar explicación
  async explain(concept, level = 'basic', context = '') {
    try {
      const message = await openai.chat.completions.create({
        model: 'gpt-3.5-turbo',
        messages: [
          { 
            role: 'system', 
            content: 'Explica conceptos de forma simple y con ejemplos reales. Sé empático.'
          },
          { 
            role: 'user', 
            content: `Nivel: ${level}\nConcepto: ${concept}\nContexto: ${context}\n\nExplica esto de forma simple con 1-2 ejemplos.`
          }
        ],
        temperature: 0.8,
        max_tokens: 600
      });

      return {
        content: message.choices[0].message.content
      };
    } catch (err) {
      throw new Error(`Error explaining: ${err.message}`);
    }
  }

  // Generar preguntas de quiz
  async generateQuiz(content, options = {}) {
    try {
      const { count = 5, difficulty = 'medium' } = options;

      const message = await openai.chat.completions.create({
        model: 'gpt-3.5-turbo',
        messages: [
          { 
            role: 'system', 
            content: 'Eres un profesor creando preguntas tipo examen. Devuelve SOLO JSON válido.'
          },
          { 
            role: 'user', 
            content: `Dificultad: ${difficulty}\nCantidad: ${count}\n\nContenido:\n${content.substring(0, 2000)}\n\nGenera ${count} preguntas JSON así:\n{\n  "questions": [\n    {\n      "question": "...",\n      "options": {"a": "...", "b": "...", "c": "...", "d": "..."},\n      "correctOption": "b",\n      "explanation": "..."\n    }\n  ]\n}`
          }
        ],
        temperature: 0.9,
        max_tokens: 1500
      });

      const responseText = message.choices[0].message.content;
      const jsonMatch = responseText.match(/\{[\s\S]*\}/);
      
      if (!jsonMatch) {
        return { questions: [] };
      }

      const parsed = JSON.parse(jsonMatch[0]);
      return {
        questions: parsed.questions || [],
        tokensUsed: message.usage.total_tokens
      };
    } catch (err) {
      console.error('Error generating quiz:', err);
      return { questions: [] };
    }
  }

  // Responder pregunta
  async answerQuestion(question, context) {
    try {
      const message = await openai.chat.completions.create({
        model: 'gpt-3.5-turbo',
        messages: [
          { 
            role: 'system', 
            content: 'Eres tutor experto universitario. Responde preguntas de forma clara y educativa.'
          },
          {
            role: 'user',
            content: `Contexto:\n${context.substring(0, 2000)}\n\nPregunta:\n${question}`
          }
        ],
        temperature: 0.7,
        max_tokens: 800
      });

      return {
        content: message.choices[0].message.content
      };
    } catch (err) {
      throw new Error(`Error answering question: ${err.message}`);
    }
  }

  // Guardar respuesta en cache
  async cacheResponse(materialId, userId, responseType, prompt, content, tokensUsed) {
    try {
      const responseId = uuidv4();

      await pool.query(
        `INSERT INTO ai_responses_cache 
         (id, material_id, user_id, response_type, prompt, response_content, ai_model, tokens_used, created_at)
         VALUES ($1, $2, $3, $4, $5, $6, 'gpt-3.5-turbo', $7, CURRENT_TIMESTAMP)`,
        [responseId, materialId, userId, responseType, prompt, content, tokensUsed]
      );

      return responseId;
    } catch (err) {
      console.error('Error caching response:', err);
      return null;
    }
  }

  // Obtener respuestas cacheadas
  async getCachedResponses(materialId, userId) {
    try {
      const result = await pool.query(
        `SELECT * FROM ai_responses_cache 
         WHERE material_id = $1 AND user_id = $2
         ORDER BY created_at DESC LIMIT 20`,
        [materialId, userId]
      );

      return result.rows;
    } catch (err) {
      throw new Error(`Error fetching cached responses: ${err.message}`);
    }
  }
}

module.exports = new AIService();
