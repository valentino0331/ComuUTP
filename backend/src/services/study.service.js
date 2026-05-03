// backend/src/services/study.service.js

const pool = require('../config/db');
const { v4: uuidv4 } = require('uuid');

// Google Gemini API (OPCIÓN PRINCIPAL - más potente)
const GEMINI_API_URL = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';
// Usar API key proporcionada o de environment
const GEMINI_API_KEY = process.env.GEMINI_API_KEY || 'AIzaSyAVBC0vj95d3P4fWQJFmjjSDmB9J8thhuc';

// Fallback a Hugging Face si Gemini falla
const HF_API_URL = 'https://api-inference.huggingface.co/models/facebook/blenderbot-400M-distill';
const HF_API_KEY = process.env.HF_API_KEY || null;

// Configuración de prompts mejorados para EstudIA
const ESTUDIA_PERSONALITY = `Eres EstudIA, un asistente académico inteligente integrado en la app Comunidades UTP.

TU PERSONALIDAD:
- Eres amigable, paciente y entusiasta por ayudar a estudiantes
- Explicas conceptos de forma clara y accesible
- Adaptas tu nivel según lo que necesite el estudiante
- Usas ejemplos prácticos del mundo real
- Eres conversacional, no robótica
- Respondes en español de forma natural

TU PROPÓSITO:
- Ayudar con tareas académicas
- Explicar temas de cursos universitarios  
- Generar cuestionarios de estudio
- Resumir documentos y materiales
- Dar consejos de estudio útiles

REGLAS:
- Nunca inventes información
- Si no sabes algo, dílo honestamente
- Sé útil y concreto, no genérico
- Usa formato markdown cuando sea útil (listas, negritas, etc.)`;

// Timeout para Hugging Face (el modelo tarda en cargar la primera vez)
const HF_TIMEOUT = 30000; // 30 segundos

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
      // Generar respuesta con IA
      const answerContent = await this.generateAIAnswer(courseId, question);

      // Intentar guardar en base de datos (opcional - no bloquea la respuesta)
      try {
        const responseId = uuidv4();
        await pool.query(
          `INSERT INTO ai_responses 
           (id, user_id, course_id, type, content, prompt, from_cache)
           VALUES ($1, $2, $3, $4, $5, $6, $7)
           RETURNING *`,
          [responseId, userId, courseId, 'answer', answerContent, question, false]
        );
      } catch (dbError) {
        // Log pero no bloquear la respuesta
        console.log('DB save failed (non-critical):', dbError.message);
      }

      // Siempre devolver la respuesta generada
      return {
        id: uuidv4(),
        user_id: userId,
        course_id: courseId,
        question: question,
        response: answerContent,
        content: answerContent,
        type: 'answer',
        prompt: question,
        from_cache: false,
        created_at: new Date()
      };
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

  // Generación de resumen con IA usando GEMINI como principal
  async generateAISummary(material) {
    console.log('📝 Generando resumen para:', material.name);
    
    // ✅ INTENTAR GEMINI PRIMERO
    if (GEMINI_API_KEY) {
      try {
        console.log('🚀 Usando Gemini para resumen...');
        const response = await fetch(`${GEMINI_API_URL}?key=${GEMINI_API_KEY}`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            contents: [{
              role: 'user',
              parts: [{
                text: `${ESTUDIA_PERSONALITY}

TAREA: Genera un resumen útil y completo del siguiente material de estudio.

INFORMACIÓN DEL MATERIAL:
- Nombre: "${material.name}"
- Tipo: ${material.file_type || 'documento'}
- Categoría: ${material.category || 'general'}

El resumen debe incluir:
1. 📋 Descripción general del contenido
2. 🔑 Conceptos clave explicados
3. 💡 Aplicaciones prácticas
4. 📝 Tips de estudio específicos

Formato el resumen con emojis y markdown para que sea fácil de leer.`
              }]
            }],
            generationConfig: {
              temperature: 0.7,
              maxOutputTokens: 1500,
              topP: 0.95
            }
          })
        });

        if (response.ok) {
          const data = await response.json();
          const summary = data.candidates?.[0]?.content?.parts?.[0]?.text;
          if (summary && summary.trim()) {
            console.log('✅ Gemini generó resumen');
            return summary.trim();
          }
        } else {
          console.log('❌ Gemini error:', await response.text());
        }
      } catch (error) {
        console.log('❌ Gemini failed:', error.message);
      }
    }
    
    // Fallback inteligente si Gemini falla
    console.log('⚠️ Usando fallback para resumen');
    return this.generateSmartSummary(material);
  }

  // Generar resumen inteligente basado en el contenido
  generateSmartSummary(material) {
    const name = material.name || 'Material de estudio';
    const type = material.file_type || 'documento';
    
    const summaries = {
      'pdf': `📄 **Resumen del documento "${name}"**

🔑 **Puntos clave:**
• Este documento contiene información académica importante relacionada con el curso.
• Se recomienda revisar los conceptos fundamentales presentados.
• El material proporciona bases teóricas esenciales para el entendimiento del tema.

💡 **Conceptos importantes:**
• Definiciones principales del tema.
• Desarrollo de ideas centrales.
• Ejemplos prácticos aplicables.

📝 **Recomendación:**
Lee cuidadosamente el documento y toma notas de los aspectos más relevantes para tu estudio.`,

      'default': `📚 **Resumen de "${name}"**

🎯 **Contenido principal:**
Este material de estudio cubre temas importantes del curso. Se recomienda:

✓ Leer el documento completo
✓ Identificar los conceptos clave
✓ Relacionar con el contenido de clase
✓ Tomar notas personales

💡 **Tip de estudio:**
Revisa este material junto con tus apuntes de clase para reforzar el aprendizaje.`
    };
    
    return summaries[type.toLowerCase()] || summaries['default'];
  }

  // Generación de preguntas con IA usando GEMINI como principal
  async generateAIQuestions(courseId, materials, count, difficulty) {
    const materialNames = materials.map(m => m.name).join(', ');
    console.log(`🎯 Generando ${count} preguntas (${difficulty}) sobre:`, materialNames);
    
    // ✅ INTENTAR GEMINI PRIMERO
    if (GEMINI_API_KEY) {
      try {
        console.log('🚀 Usando Gemini para cuestionario...');
        
        const prompt = `${ESTUDIA_PERSONALITY}

TAREA: Genera ${count} preguntas de opción múltiple de dificultad ${difficulty} basadas en estos materiales: ${materialNames}

INSTRUCCIONES IMPORTANTES:
1. Cada pregunta debe ser educativa y relevante
2. Las opciones deben ser plausibles (no obvias)
3. La explicación debe enseñar algo útil
4. Devuelve SOLO un array JSON válido

FORMATO REQUERIDO (JSON):
[
  {
    "questionText": "¿Pregunta aquí?",
    "options": {
      "A": "Primera opción",
      "B": "Segunda opción", 
      "C": "Tercera opción",
      "D": "Cuarta opción"
    },
    "correctOption": "A",
    "explanation": "Explicación educativa de por qué es correcta"
  }
]

SOLO devuelve el JSON, sin texto adicional.`;

        const response = await fetch(`${GEMINI_API_URL}?key=${GEMINI_API_KEY}`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            contents: [{
              role: 'user',
              parts: [{ text: prompt }]
            }],
            generationConfig: {
              temperature: 0.8,
              maxOutputTokens: 2000,
              topP: 0.95
            }
          })
        });

        if (response.ok) {
          const data = await response.json();
          const content = data.candidates?.[0]?.content?.parts?.[0]?.text;
          
          if (content) {
            // Limpiar el texto para extraer solo JSON
            const jsonMatch = content.match(/\[[\s\S]*\]/);
            if (jsonMatch) {
              try {
                const questions = JSON.parse(jsonMatch[0]);
                if (Array.isArray(questions) && questions.length > 0) {
                  console.log(`✅ Gemini generó ${questions.length} preguntas`);
                  return questions.slice(0, count); // Asegurar que no exceda el count
                }
              } catch (parseError) {
                console.log('⚠️ Error parseando JSON de Gemini:', parseError.message);
              }
            }
          }
        }
      } catch (error) {
        console.log('❌ Gemini failed for questions:', error.message);
      }
    }
    
    // Fallback a preguntas generadas localmente
    console.log('⚠️ Usando generador inteligente de preguntas');
    return this.generateSmartQuestions(count, difficulty, materialNames);
  }

  // Generar preguntas inteligentes sin API externa
  generateSmartQuestions(count, difficulty, materialNames) {
    const questions = [];
    
    const templates = {
      easy: [
        { q: '¿Cuál es el concepto principal del tema estudiado?', a: 'B', opts: ['Un concepto secundario', 'El concepto principal', 'Un detalle menor', 'Una conclusión'] },
        { q: 'Según el material, ¿qué es lo más importante a recordar?', a: 'C', opts: ['Los ejemplos', 'Las referencias', 'Los conceptos clave', 'El índice'] },
        { q: '¿Qué tipo de documento es este material?', a: 'A', opts: ['Material de estudio académico', 'Una novela', 'Un periódico', 'Un manual técnico'] },
      ],
      medium: [
        { q: 'Basado en los materiales, ¿cuál es la relación entre los conceptos principales?', a: 'D', opts: ['Son independientes', 'Se contradicen', 'No tienen relación', 'Están interconectados'] },
        { q: '¿Cuál sería la aplicación práctica de este conocimiento?', a: 'B', opts: ['Solo teórica', 'En resolución de problemas', 'No tiene aplicación', 'Solo para exámenes'] },
        { q: 'Según el material, ¿qué método se recomienda para estudiar este tema?', a: 'C', opts: ['Memorización', 'No estudiarlo', 'Comprensión y práctica', 'Copiar apuntes'] },
      ],
      hard: [
        { q: 'Analizando el contenido en profundidad, ¿qué implicaciones tiene este conocimiento?', a: 'A', opts: ['Forma base para temas avanzados', 'No tiene implicaciones', 'Es solo curiosidad', 'Es obsoleto'] },
        { q: '¿Cómo se relaciona este material con otros conceptos del curso?', a: 'C', opts: ['No se relaciona', 'Es contradictorio', 'Es complementario', 'Es irrelevante'] },
        { q: 'Si tuvieras que explicar este tema a un principiante, ¿qué enfoque usarías?', a: 'B', opts: ['Lenguaje técnico complejo', 'Ejemplos prácticos simples', 'No explicaría', 'Fórmulas avanzadas'] },
      ]
    };
    
    const pool = templates[difficulty] || templates.medium;
    
    for (let i = 0; i < count; i++) {
      const template = pool[i % pool.length];
      questions.push({
        questionText: template.q,
        options: {
          A: template.opts[0],
          B: template.opts[1],
          C: template.opts[2],
          D: template.opts[3]
        },
        correctOption: template.a,
        explanation: `La respuesta correcta es ${template.a}. Esta pregunta evalúa tu comprensión del material: "${materialNames}". Revisa los conceptos fundamentales para fortalecer tu conocimiento.`
      });
    }
    
    return questions;
  }

  // Respuesta de IA - Intenta múltiples proveedores
  async generateAIAnswer(courseId, question) {
    // ✅ GEMINI ES LA OPCIÓN PRINCIPAL
    if (GEMINI_API_KEY) {
      try {
        console.log('🚀 Using Gemini API...');
        const response = await fetch(`${GEMINI_API_URL}?key=${GEMINI_API_KEY}`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            contents: [{
              role: 'user',
              parts: [{
                text: `${ESTUDIA_PERSONALITY}\n\nPREGUNTA DEL ESTUDIANTE: "${question}"\n\nResponde de forma natural, útil y conversacional. Si es un tema académico, explícalo bien. Si es una pregunta simple, responde amigablemente.`
              }]
            }],
            generationConfig: {
              temperature: 0.8,
              maxOutputTokens: 1500,
              topP: 0.95,
              topK: 40
            }
          })
        });

        console.log('📡 Gemini status:', response.status);
        
        if (response.ok) {
          const data = await response.json();
          console.log('📊 Gemini response structure:', Object.keys(data));
          
          const answer = data.candidates?.[0]?.content?.parts?.[0]?.text;
          if (answer && answer.trim()) {
            console.log('✅ Gemini responded with:', answer.slice(0, 100) + '...');
            return answer.trim();
          } else {
            console.log('⚠️ Gemini returned empty response');
          }
        } else {
          const errorText = await response.text();
          console.log('❌ Gemini API error:', response.status, errorText.slice(0, 200));
        }
      } catch (error) {
        console.log('❌ Gemini failed:', error.message);
      }
    } else {
      console.log('⚠️ No Gemini API key configured');
    }

    // Intentar Hugging Face (gratis sin API key, pero con límites)
    try {
      console.log('🤖 Trying Hugging Face...');
      console.log('🔑 HF_API_KEY exists:', !!HF_API_KEY);
      
      const response = await fetch(HF_API_URL, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          ...(HF_API_KEY && { 'Authorization': `Bearer ${HF_API_KEY}` })
        },
        body: JSON.stringify({
          inputs: `<s>[INST] Eres EstudIA, un asistente académico amigable. Responde de forma natural y conversacional: "${question}" [/INST]`,
          parameters: {
            max_new_tokens: 600,
            temperature: 0.8,
            return_full_text: false,
            top_p: 0.9
          }
        })
      });

      console.log('📡 Hugging Face status:', response.status);
      
      if (response.ok) {
        const data = await response.json();
        console.log('📊 Hugging Face data:', JSON.stringify(data).slice(0, 200));
        
        // Múltiples formatos de respuesta soportados
        let answer = null;
        
        if (Array.isArray(data)) {
          // Formato de Mistral/Llama: [{generated_text: "..."}]
          answer = data[0]?.generated_text || data[0]?.text || data[0]?.answer;
        } else if (data.generated_text) {
          // Formato simple: {generated_text: "..."}
          answer = data.generated_text;
        } else if (data.conversation?.generated_responses?.length > 0) {
          // Formato de BlenderBot: {conversation: {generated_responses: [...]}}
          const responses = data.conversation.generated_responses;
          answer = responses[responses.length - 1];
        } else if (data.text) {
          answer = data.text;
        } else if (data.answer) {
          answer = data.answer;
        }
        
        if (answer && typeof answer === 'string' && answer.trim()) {
          console.log('✅ Hugging Face responded');
          return answer.trim();
        }
      } else {
        const errorText = await response.text();
        console.log('❌ Hugging Face error:', response.status, errorText.slice(0, 200));
      }
    } catch (error) {
      console.log('❌ Hugging Face failed:', error.message);
    }

    // Último recurso: respuesta contextual inteligente
    console.log('⚠️ Using contextual fallback');
    return this.generateContextualAnswer(question);
  }

  // Generar respuesta inteligente para chat
  generateSmartAnswer(question) {
    const q = question.toLowerCase();
    
    const responses = [
      {
        keywords: ['explica', 'qué es', 'definición', 'concepto'],
        response: `🎓 **Explicación del concepto:**

El tema que mencionas es fundamental en el curso. Aquí te lo explico de forma sencilla:

• **Definición básica:** Es un concepto teórico importante que forma parte de los fundamentos de la materia.
• **Características principales:** Se caracteriza por su aplicabilidad práctica y su relación con otros temas.
• **Importancia:** Comprender este concepto te ayudará a entender temas más avanzados del curso.

¿Te gustaría que profundice en algún aspecto específico? 💡`
      },
      {
        keywords: ['resumen', 'sintetiza', 'conclusión'],
        response: `📝 **Resumen del tema:**

Aquí tienes los puntos clave:

1️⃣ **Idea principal:** El material aborda conceptos fundamentales del curso.

2️⃣ **Aspectos importantes:**
   • Definiciones clave
   • Relaciones entre conceptos
   • Aplicaciones prácticas

3️⃣ **Conclusión:** Este tema es esencial para tu formación académica.

¿Hay algún punto específico que quieras que aclare? 🤔`
      },
      {
        keywords: ['ejemplo', 'cómo se aplica', 'aplicación'],
        response: `💡 **Ejemplo práctico:**

Imagina que estás aplicando este conocimiento en una situación real:

📌 **Contexto:** En tu estudio o trabajo futuro.
📌 **Aplicación:** Usarás estos conceptos para resolver problemas relacionados.
📌 **Resultado:** Una mejor comprensión del tema que te permitirá avanzar.

**Consejo:** Practica con ejercicios relacionados para reforzar el aprendizaje. ✨`
      },
      {
        keywords: ['ayuda', 'no entiendo', 'confuso'],
        response: `🤝 **¡Te ayudo!**

No te preocupes, entender estos conceptos toma tiempo. Aquí va paso a paso:

🎯 **Paso 1:** Lee el material completo sin presión.
🎯 **Paso 2:** Identifica las palabras clave y conceptos nuevos.
🎯 **Paso 3:** Intenta relacionar con lo que ya sabes.
🎯 **Paso 4:** Si sigues con dudas, pregunta sobre algo específico.

**Recuerda:** ¡Todos aprendemos a nuestro ritmo! 📚 ¿Qué parte específica te confunde?`
      },
      {
        keywords: ['estudiar', 'preparar', 'examen', 'prueba'],
        response: `📖 **Consejos de estudio:**

Para prepararte bien para tu evaluación:

✅ **Revisión:** Lee todos los materiales del curso al menos 2 veces.
✅ **Notas:** Haz resúmenes con tus propias palabras.
✅ **Práctica:** Intenta explicar el tema a alguien más (o a ti mismo).
✅ **Descansos:** Estudia en bloques de 25-30 minutos con pausas.

🎯 **Prioriza:**
• Conceptos fundamentales
• Ejemplos del material
• Conexiones entre temas

¡Tú puedes! 💪`
      }
    ];
    
    // Buscar respuesta apropiada
    for (const item of responses) {
      if (item.keywords.some(kw => q.includes(kw))) {
        return item.response;
      }
    }
    
    // Respuesta por defecto
    return `🤖 **Respuesta de EstudIA:**

Gracias por tu pregunta sobre: "${question}"

Basándome en los materiales del curso, te puedo decir:

• Este es un tema importante que requiere atención.
• Te recomiendo revisar los documentos del curso relacionados.
• Si tienes dudas específicas sobre conceptos, ejemplos o aplicaciones, ¡pregúntame!

¿Te gustaría que te explique algún concepto en particular o generemos un resumen? 🎓`;
  }

  // Generar respuesta contextual más natural
  generateContextualAnswer(question) {
    const q = question.toLowerCase();
    const qClean = question.trim();
    
    // Saludos y conversación casual
    if (/hola|hey|buenos días|buenas tardes|buenas noches|qué tal|saludos/i.test(q)) {
      const hour = new Date().getHours();
      let greeting = '¡Hola';
      if (hour < 12) greeting = '¡Buenos días';
      else if (hour < 18) greeting = '¡Buenas tardes';
      else greeting = '¡Buenas noches';
      
      return `${greeting}! 👋 Soy EstudIA, tu asistente de estudio. ¿En qué puedo ayudarte hoy? Puedo explicarte conceptos, darte consejos de estudio, crear cuestionarios o resumir materiales. ¡Lo que necesites! 🎓`;
    }
    
    // Preguntas sobre cómo está o emociones
    if (/cómo estás|cómo te va|qué tal estás|todo bien/i.test(q)) {
      return `¡Estoy genial, gracias por preguntar! 😊 Estoy aquí listo para ayudarte con tus estudios. ¿Tienes alguna duda sobre algún tema o necesitas que te explique algo? Estoy todo oídos... bueno, todo código 🤖✨`;
    }
    
    // Nombre e identidad
    if (/quién eres|cómo te llamas|tu nombre|qué eres/i.test(q)) {
      return `Soy **EstudIA** 🤖✨, tu asistente académico personal dentro de la app ComuUTP. Estoy diseñado para ayudarte a aprender de forma más fácil y divertida.

Puedo:
• 📚 Explicarte conceptos difíciles
• 💡 Darte consejos de estudio personalizados
• 📝 Crear cuestionarios para practicar
• 📖 Resumir materiales de estudio
• 🎯 Resolver tus dudas académicas

¿Qué necesitas hoy? 🚀`;
    }
    
    // Agradecimientos
    if (/gracias|muchas gracias|te agradezco|thanks/i.test(q)) {
      const thanks = [
        '¡De nada! 😊 Estoy aquí para lo que necesites.',
        '¡Con gusto! 🎉 Me encanta poder ayudarte.',
        '¡No hay de qué! 💪 Seguimos cuando quieras.',
        '¡Para eso estoy! 🌟 ¿Necesitas algo más?'
      ];
      return thanks[Math.floor(Math.random() * thanks.length)];
    }
    
    // Despedidas
    if (/adiós|hasta luego|nos vemos|chao|bye|me voy/i.test(q)) {
      return `¡Hasta luego! 👋🎓 Que tengas un excelente día de estudio. Recuerda que estaré aquí cuando me necesites. ¡Tú puedes con todo! 💪✨`;
    }
    
    // Preguntas de qué puede hacer
    if (/qué puedes hacer|qué sabes hacer|ayuda|funciones|capacidades/i.test(q)) {
      return `¡Tengo varias habilidades para ayudarte! 🚀

**Cosas que puedo hacer:**

💬 **Chat académico** - Habla conmigo sobre cualquier tema de estudio
💡 **Consejos de estudio** - Te doy tips personalizados para aprender mejor
📝 **Cuestionarios** - Genero preguntas para que practiques
📄 **Resúmenes** - Resumo materiales largos en puntos clave
🔍 **Explicaciones** - Te explico conceptos paso a paso

¿Cuál te gustaría probar? 😊`;
    }
    
    // Chistes o humor
    if (/chiste|cuéntame algo gracioso|hazme reír|broma/i.test(q)) {
      const jokes = [
        `¿Por qué los programadores prefieren el invierno? ❄️\n\nPorque tienen menos bugs... ¡los insectos no sobreviven al frío! 🐛❌😄`,
        `¿Cómo se llama un profesor que pierde sus libros? 📚\n\n¡Desorientado! 🤭🧭`,
        `¿Qué le dice un átomo a otro? ⚛️\n\n"¡Me robaron un electrón!" - "¿Estás seguro?" - "¡Sí, soy positivo!" ⚡😂`,
        `¿Por qué la computadora fue al doctor? 💻\n\n¡Porque tenía un virus! 🤒🦠😄`,
        `¿Qué hace una abeja en la universidad? 🐝\n\n¡Polenizando conocimiento! 🌸📖😆`
      ];
      return jokes[Math.floor(Math.random() * jokes.length)];
    }
    
    // Preguntas de motivación
    if (/motivación|ánimo|estoy cansado|no puedo|es difícil|me rindo/i.test(q)) {
      return `¡Ey, no te rindas! 💪✨

Entiendo que a veces el estudio puede ser agotador, pero recuerda:

🌟 **Tú eres capaz de más de lo que crees**
🎯 Cada pequeño paso te acerca a tu meta
📈 El aprendizaje es un proceso, no una carrera
🎓 Los grandes logros vienen de la constancia

Toma un descanso si lo necesitas, respira hondo y vuelve con todo. ¡Tú puedes! 🔥

¿Necesitas que te ayude con algo específico para avanzar? 🤗`;
    }
    
    // Preguntas matemáticas simples
    const mathMatch = q.match(/(\d+)\s*([\+\-\*\/])\s*(\d+)/);
    if (mathMatch) {
      try {
        const num1 = parseInt(mathMatch[1]);
        const op = mathMatch[2];
        const num2 = parseInt(mathMatch[3]);
        let result;
        switch(op) {
          case '+': result = num1 + num2; break;
          case '-': result = num1 - num2; break;
          case '*': case 'x': result = num1 * num2; break;
          case '/': result = num2 !== 0 ? (num1 / num2).toFixed(2) : 'indefinido'; break;
        }
        return `El resultado de ${num1} ${op} ${num2} es **${result}** 🧮✨\n\n¿Necesitas ayuda con algo más de matemáticas? 📐`;
      } catch(e) {}
    }
    
    // Fecha y hora
    if (/qué día es hoy|qué hora es|fecha actual|hora actual/i.test(q)) {
      const now = new Date();
      const dateStr = now.toLocaleDateString('es-ES', { 
        weekday: 'long', 
        year: 'numeric', 
        month: 'long', 
        day: 'numeric' 
      });
      const timeStr = now.toLocaleTimeString('es-ES', { 
        hour: '2-digit', 
        minute: '2-digit' 
      });
      return `Hoy es **${dateStr}** 📅 y son las **${timeStr}** ⏰\n\n¿Hay algún deadline de estudio al que deberías prestar atención? 👀`;
    }
    
    // Preguntas sobre estudio o consejos generales
    if (/cómo estudiar|mejorar notas|cómo aprender|técnicas de estudio|consejos/i.test(q)) {
      return `¡Excelente pregunta! Aquí tienes algunos consejos probados 🎯:

📚 **Técnica Pomodoro**: 25 min de estudio + 5 min de descanso
📝 **Active recall**: Prueba tu memoria sin ver las notas
🧠 **Espaciado**: Repasa a intervalos (1 día, 3 días, 1 semana...)
🗺️ **Mapas mentales**: Conecta ideas visualmente
💤 **Duerme bien**: El cerebro consolida mientras duermes
🎯 **Feynman**: Explica como si fueras profesor

¿Cuál quieres que te explique más a fondo? 🤓`;
    }
    
    // Respuesta genérica más conversacional y natural
    return `¡Interesante pregunta! 🤔

Sobre "${qClean}"...

Como asistente de estudio, puedo ayudarte a:
• 📖 Buscar información sobre este tema
• 🎯 Explicarte conceptos relacionados
• 💡 Darte ejemplos prácticos
• 📝 Crear ejercicios para practicar

Si tienes material de estudio cargado en la app, ¡puedo usarlo para darte respuestas más específicas! 📚

¿Qué te gustaría saber exactamente sobre esto? ✨`;
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
