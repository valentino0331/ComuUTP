// backend/src/services/gemini.service.js
// Servicio unificado para API Gemini con reintentos y manejo de errores

const { logger } = require('../utils/logger');

const GEMINI_API_URL = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';
const GEMINI_KEY = process.env.GEMINI_KEY;

class GeminiService {
  
  constructor() {
    if (!GEMINI_KEY) {
      logger.warn('GEMINI', 'API key not configured. Set GEMINI_KEY in .env');
    }
  }

  /**
   * Validar que Gemini esté configurado
   */
  isConfigured() {
    return !!GEMINI_KEY;
  }

  /**
   * Llamada genérica a Gemini con reintentos
   */
  async call(prompt, options = {}) {
    const {
      maxRetries = 2,
      temperature = 0.7,
      maxTokens = 1500,
      timeout = 30000
    } = options;

    if (!this.isConfigured()) {
      throw new Error('Gemini API key not configured');
    }

    for (let attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        logger.debug('GEMINI', `Calling API (attempt ${attempt}/${maxRetries})`, {
          promptLength: prompt.length,
          temperature,
          maxTokens
        });

        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), timeout);

        const response = await fetch(`${GEMINI_API_URL}?key=${GEMINI_KEY}`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            contents: [{
              role: 'user',
              parts: [{
                text: prompt
              }]
            }],
            generationConfig: {
              temperature,
              maxOutputTokens: maxTokens,
              topP: 0.95
            }
          }),
          signal: controller.signal
        });

        clearTimeout(timeoutId);

        if (!response.ok) {
          const errorData = await response.json();
          throw new Error(`HTTP ${response.status}: ${errorData?.error?.message || response.statusText}`);
        }

        const data = await response.json();
        const result = data.candidates?.[0]?.content?.parts?.[0]?.text;

        if (!result) {
          throw new Error('No response text from Gemini');
        }

        logger.info('GEMINI', 'API call successful', {
          attempt,
          promptLength: prompt.length,
          resultLength: result.length
        });

        return result;

      } catch (error) {
        logger.warn('GEMINI', `API call failed (attempt ${attempt}/${maxRetries})`, {
          error: error.message
        });

        if (attempt === maxRetries) {
          throw error;
        }

        // Esperar antes de reintentar (exponential backoff)
        await new Promise(resolve => setTimeout(resolve, 1000 * attempt));
      }
    }
  }

  /**
   * Generar resumen de texto
   */
  async summarize(content, title = 'documento', options = {}) {
    if (content.length < 50) {
      return 'El contenido es muy corto para generar un resumen.';
    }

    const prompt = `Eres EstudIA, un asistente académico inteligente para estudiantes universitarios.

TAREA: Genera un resumen útil y educativo del siguiente contenido.

CONTENIDO A RESUMIR:
Título: "${title}"
Texto: ${content}

FORMATO DEL RESUMEN:
1. 📋 Descripción general (2-3 líneas)
2. 🔑 Conceptos clave (lista de 5-7 puntos)
3. 💡 Aplicaciones prácticas (2-3 ejemplos)
4. 📝 Tips de estudio (2-3 recomendaciones)

Usa emojis y markdown para que sea fácil de leer. Sé conciso pero completo.`;

    return await this.call(prompt, {
      ...options,
      maxTokens: 1500,
      temperature: 0.7
    });
  }

  /**
   * Generar preguntas de quiz
   */
  async generateQuiz(content, count = 5, difficulty = 'medium', options = {}) {
    if (content.length < 100) {
      return {
        questions: []
      };
    }

    const prompt = `Eres EstudIA, profesor universitario creando preguntas de examen.

CONTENIDO:
${content.substring(0, 3000)}

TAREA:
Genera exactamente ${count} preguntas de opción múltiple, dificultad ${difficulty}.

IMPORTANTE: Devuelve SOLO JSON válido, sin markdown ni explicaciones. Formato:
{
  "questions": [
    {
      "question": "¿Pregunta aquí?",
      "options": {
        "a": "Opción A",
        "b": "Opción B",
        "c": "Opción C",
        "d": "Opción D"
      },
      "correctOption": "b",
      "explanation": "Explicación corta"
    }
  ]
}`;

    try {
      const response = await this.call(prompt, {
        ...options,
        maxTokens: 2000,
        temperature: 0.9
      });

      // Parsear JSON
      const jsonMatch = response.match(/\{[\s\S]*\}/);
      if (!jsonMatch) {
        logger.warn('GEMINI', 'No JSON found in response');
        return { questions: [] };
      }

      const parsed = JSON.parse(jsonMatch[0]);
      return {
        questions: parsed.questions || [],
        tokensUsed: parsed.tokensUsed
      };

    } catch (error) {
      logger.error('GEMINI', 'Quiz generation failed', { error: error.message });
      return { questions: [] };
    }
  }

  /**
   * Responder pregunta académica
   */
  async answerQuestion(question, context = '', options = {}) {
    const prompt = `Eres EstudIA, tutor experto universitario en varias disciplinas.

${context ? `CONTEXTO:\n${context}\n\n` : ''}

PREGUNTA DEL ESTUDIANTE:
${question}

Responde de forma:
- Clara y educativa
- Con ejemplos cuando sea posible
- En español natural
- Máximo 500 palabras

Sé amable y empático. Si la pregunta sale del contexto académico, amablemente redirecciona.`;

    return await this.call(prompt, {
      ...options,
      maxTokens: 800,
      temperature: 0.7
    });
  }

  /**
   * Generar script de podcast de dos voces
   */
  async generatePodcastScript(content, voiceStyle = 'balanced', options = {}) {
    if (content.length < 200) {
      return {
        voice1: 'Contenido muy corto para podcast',
        voice2: 'Intenta con un documento más completo',
        fullText: 'Contenido insuficiente'
      };
    }

    const styleGuide = {
      casual: 'Conversación relajada, amistosa, como dos amigos estudiando',
      formal: 'Académico, profesional, como una clase magistral',
      balanced: 'Mezcla educativo con entretenido, como un podcast informativo'
    };

    const prompt = `Eres guionista de podcast educativo. Crea un diálogo de dos voces.

ESTILO: ${styleGuide[voiceStyle] || styleGuide.balanced}

CONTENIDO A ADAPTAR:
${content.substring(0, 3000)}

TAREA: Crea un script con:
- Speaker 1: Presenta conceptos
- Speaker 2: Hace preguntas y da ejemplos
- Duración: ~5-7 minutos (400-500 palabras totales)
- Interactivo: preguntas naturales
- Conclusión clara

FORMATO JSON (IMPORTANTE - SOLO JSON):
{
  "title": "Título del podcast",
  "duration_seconds": 420,
  "speaker1": {
    "name": "Host 1",
    "lines": ["Línea 1...", "Línea 2..."]
  },
  "speaker2": {
    "name": "Host 2",
    "lines": ["Pregunta 1...", "Observación..."]
  },
  "fullText": "Transcripción completa combinada..."
}`;

    try {
      const response = await this.call(prompt, {
        ...options,
        maxTokens: 2000,
        temperature: 0.8
      });

      const jsonMatch = response.match(/\{[\s\S]*\}/);
      if (!jsonMatch) {
        throw new Error('No JSON found in podcast response');
      }

      const parsed = JSON.parse(jsonMatch[0]);
      return {
        title: parsed.title || 'Audio-Lección',
        duration_seconds: parsed.duration_seconds || 420,
        speaker1: parsed.speaker1 || { name: 'Host 1', lines: [] },
        speaker2: parsed.speaker2 || { name: 'Host 2', lines: [] },
        fullText: parsed.fullText || '',
        voiceStyle
      };

    } catch (error) {
      logger.error('GEMINI', 'Podcast script generation failed', { error: error.message });
      return {
        title: 'Audio-Lección',
        duration_seconds: 0,
        speaker1: { name: 'Error', lines: [] },
        speaker2: { name: 'Error', lines: [] },
        fullText: `Error generando script: ${error.message}`,
        voiceStyle
      };
    }
  }

  /**
   * Extraer conceptos clave
   */
  async extractKeyConcepts(content, maxConcepts = 10, options = {}) {
    const prompt = `Eres especialista en educación. Extrae conceptos clave del texto.

CONTENIDO:
${content.substring(0, 2000)}

TAREA: Extrae exactamente ${maxConcepts} conceptos clave en JSON:
{
  "concepts": [
    {
      "term": "Concepto",
      "definition": "Definición breve",
      "importance": "alta|media|baja"
    }
  ]
}`;

    try {
      const response = await this.call(prompt, {
        ...options,
        maxTokens: 1000,
        temperature: 0.6
      });

      const jsonMatch = response.match(/\{[\s\S]*\}/);
      if (!jsonMatch) {
        return { concepts: [] };
      }

      const parsed = JSON.parse(jsonMatch[0]);
      return parsed.concepts ? { concepts: parsed.concepts } : { concepts: [] };

    } catch (error) {
      logger.error('GEMINI', 'Concept extraction failed', { error: error.message });
      return { concepts: [] };
    }
  }
}

module.exports = new GeminiService();
