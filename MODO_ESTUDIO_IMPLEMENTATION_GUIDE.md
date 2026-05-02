# ⚙️ MODO ESTUDIO | GUÍA TÉCNICA DE IMPLEMENTACIÓN

**Documento:** Technical Implementation Guide  
**Audiencia:** Full-stack developers  
**Nivel:** Senior  
**Duración estimada:** 2-3 semanas (MVP)

---

## 📋 QUICK START (5 min)

### Checklist Pre-Implementación

```
ANTES DE EMPEZAR:
☐ PostgreSQL Neon ya está corriendo
☐ Backend Express.js levantado en :5000
☐ Flutter app funciona en emulator
☐ Cloudinary API key configurada
☐ OpenAI API key en .env
☐ Git branch clean

STACK CONFIRMADO:
✓ Backend: Express.js + PostgreSQL
✓ Frontend: Flutter + Provider
✓ Storage: Cloudinary
✓ Auth: Firebase UID
✓ IA: OpenAI GPT-4 Mini
```

---

## 🗄️ PARTE 1: DATABASE SETUP

### Crear Tablas (Run in Neon Console)

```sql
-- ============================================================
-- MODO ESTUDIO - Database Schema
-- ============================================================

-- 1. COURSES TABLE
CREATE TABLE study_courses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    name VARCHAR(255) NOT NULL,
    course_code VARCHAR(50),
    professor_name VARCHAR(255),
    description TEXT,
    photo_url TEXT,
    created_by_user_id UUID NOT NULL,
    semester INT,
    year INT,
    is_archived BOOLEAN DEFAULT FALSE,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by_user_id) REFERENCES usuarios(id)
);

CREATE INDEX idx_user_courses ON study_courses(user_id, created_at DESC) WHERE NOT is_archived;
CREATE INDEX idx_course_created_by ON study_courses(created_by_user_id);

-- 2. MATERIALS TABLE (PDFs, Apuntes, etc)
CREATE TABLE study_materials (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id UUID NOT NULL,
    uploaded_by_user_id UUID NOT NULL,
    name VARCHAR(255) NOT NULL,
    file_url TEXT NOT NULL,
    file_size_bytes INT,
    file_type VARCHAR(50),
    cloudinary_public_id VARCHAR(255),
    page_count INT,
    text_content TEXT,
    embeddings_generated BOOLEAN DEFAULT FALSE,
    category VARCHAR(100),
    topic VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (course_id) REFERENCES study_courses(id) ON DELETE CASCADE,
    FOREIGN KEY (uploaded_by_user_id) REFERENCES usuarios(id)
);

CREATE INDEX idx_course_materials ON study_materials(course_id, created_at DESC);
CREATE INDEX idx_materials_embeddings ON study_materials(embeddings_generated) WHERE NOT embeddings_generated;

-- 3. AI RESPONSES CACHE
CREATE TABLE ai_responses_cache (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    material_id UUID,
    user_id UUID NOT NULL,
    response_type VARCHAR(50),
    prompt TEXT,
    response_content TEXT NOT NULL,
    ai_model VARCHAR(50),
    tokens_used INT,
    user_feedback VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (material_id) REFERENCES study_materials(id) ON DELETE SET NULL,
    FOREIGN KEY (user_id) REFERENCES usuarios(id) ON DELETE CASCADE
);

CREATE INDEX idx_cache_lookup ON ai_responses_cache(material_id, response_type, user_id);
CREATE INDEX idx_cache_created ON ai_responses_cache(created_at DESC);

-- 4. STUDY QUESTIONS (Quiz Bank)
CREATE TABLE study_questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id UUID NOT NULL,
    question_text TEXT NOT NULL,
    options JSONB NOT NULL,
    correct_option VARCHAR(1),
    explanation TEXT,
    difficulty_level VARCHAR(20),
    source_material_id UUID,
    created_by_user_id UUID,
    ai_generated BOOLEAN DEFAULT FALSE,
    tags JSONB DEFAULT '[]',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (course_id) REFERENCES study_courses(id) ON DELETE CASCADE,
    FOREIGN KEY (source_material_id) REFERENCES study_materials(id),
    FOREIGN KEY (created_by_user_id) REFERENCES usuarios(id)
);

CREATE INDEX idx_questions_course ON study_questions(course_id);
CREATE INDEX idx_questions_difficulty ON study_questions(course_id, difficulty_level);

-- 5. QUIZ ATTEMPTS (Historial de respuestas)
CREATE TABLE quiz_attempts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    course_id UUID NOT NULL,
    quiz_id VARCHAR(255),
    score INT,
    total_questions INT,
    time_spent_seconds INT,
    answers JSONB,
    completed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES study_courses(id) ON DELETE CASCADE
);

CREATE INDEX idx_quiz_attempts_user ON quiz_attempts(user_id, completed_at DESC);
CREATE INDEX idx_quiz_attempts_course ON quiz_attempts(course_id);

-- 6. STUDY HISTORY (Analytics + Auditoría)
CREATE TABLE study_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    course_id UUID,
    material_id UUID,
    action_type VARCHAR(50),
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES study_courses(id) ON DELETE SET NULL,
    FOREIGN KEY (material_id) REFERENCES study_materials(id) ON DELETE SET NULL
);

CREATE INDEX idx_study_history_user ON study_history(user_id, created_at DESC);

-- 7. USER STREAKS (Gamificación)
CREATE TABLE user_streaks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE,
    current_streak INT DEFAULT 0,
    max_streak INT DEFAULT 0,
    last_activity_date DATE,
    badges JSONB DEFAULT '[]',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES usuarios(id) ON DELETE CASCADE
);

CREATE INDEX idx_streaks_user ON user_streaks(user_id);
```

---

## 🔧 PARTE 2: BACKEND SETUP (Express.js)

### 2.1 Crear Carpetas de Estructura

```bash
backend/src/
├── controllers/
│   ├── study.controller.js
│   ├── material.controller.js
│   ├── ai.controller.js
│   ├── quiz.controller.js
│   └── streak.controller.js
├── routes/
│   ├── study.routes.js
│   ├── materials.routes.js
│   ├── ai.routes.js
│   ├── quiz.routes.js
│   └── streak.routes.js
├── services/
│   ├── study.service.js
│   ├── material.service.js
│   ├── ai.service.js
│   ├── pdf.service.js
│   ├── quiz.service.js
│   └── cache.service.js
├── models/
│   └── StudyModels.js
└── utils/
    └── aiPrompts.js
```

### 2.2 Actualizar package.json

```json
{
  "dependencies": {
    "pdfjs-dist": "^4.0.379",
    "pdf-parse": "^1.1.1",
    "openai": "^4.0.0",
    "redis": "^4.6.0",
    "multer": "^1.4.5-lts.1",
    "cloudinary": "^2.2.0"
  }
}
```

### 2.3 Study.controller.js (CRUD Básico)

```javascript
// backend/src/controllers/study.controller.js

const pool = require('../config/db');
const { v4: uuidv4 } = require('uuid');

// GET todas los cursos del usuario
exports.getUserCourses = async (req, res) => {
  try {
    const { userId } = req.auth;
    
    const result = await pool.query(
      `SELECT * FROM study_courses 
       WHERE user_id = $1 AND NOT is_archived
       ORDER BY created_at DESC`,
      [userId]
    );

    res.status(200).json({
      success: true,
      data: result.rows,
      count: result.rows.length
    });
  } catch (err) {
    console.error('Error fetching courses:', err);
    res.status(500).json({ error: err.message });
  }
};

// POST crear curso
exports.createCourse = async (req, res) => {
  try {
    const { userId } = req.auth;
    const { name, courseCode, professorName, description, semester, year } = req.body;

    // Validar
    if (!name) {
      return res.status(400).json({ error: 'Nombre del curso es requerido' });
    }

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

    res.status(201).json({
      success: true,
      data: result.rows[0],
      message: 'Curso creado exitosamente'
    });
  } catch (err) {
    console.error('Error creating course:', err);
    res.status(500).json({ error: err.message });
  }
};

// GET detalle de curso
exports.getCourseDetail = async (req, res) => {
  try {
    const { courseId } = req.params;
    const { userId } = req.auth;

    const courseResult = await pool.query(
      `SELECT * FROM study_courses 
       WHERE id = $1 AND user_id = $2`,
      [courseId, userId]
    );

    if (courseResult.rows.length === 0) {
      return res.status(404).json({ error: 'Curso no encontrado' });
    }

    const course = courseResult.rows[0];

    // Obtener materiales del curso
    const materialsResult = await pool.query(
      `SELECT * FROM study_materials 
       WHERE course_id = $1
       ORDER BY created_at DESC`,
      [courseId]
    );

    // Obtener stats
    const statsResult = await pool.query(
      `SELECT 
         COUNT(*) as total_materials,
         SUM(CASE WHEN file_type = 'pdf' THEN 1 ELSE 0 END) as pdf_count,
         SUM(CASE WHEN response_type = 'summary' THEN 1 ELSE 0 END) as summaries
       FROM study_materials
       WHERE course_id = $1`,
      [courseId]
    );

    res.status(200).json({
      success: true,
      data: {
        course,
        materials: materialsResult.rows,
        stats: statsResult.rows[0]
      }
    });
  } catch (err) {
    console.error('Error fetching course detail:', err);
    res.status(500).json({ error: err.message });
  }
};

// PUT actualizar curso
exports.updateCourse = async (req, res) => {
  try {
    const { courseId } = req.params;
    const { userId } = req.auth;
    const { name, professorName, description } = req.body;

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
      return res.status(404).json({ error: 'Curso no encontrado' });
    }

    res.status(200).json({
      success: true,
      data: result.rows[0]
    });
  } catch (err) {
    console.error('Error updating course:', err);
    res.status(500).json({ error: err.message });
  }
};

// DELETE archivar curso
exports.archiveCourse = async (req, res) => {
  try {
    const { courseId } = req.params;
    const { userId } = req.auth;

    const result = await pool.query(
      `UPDATE study_courses 
       SET is_archived = TRUE, updated_at = CURRENT_TIMESTAMP
       WHERE id = $1 AND user_id = $2
       RETURNING *`,
      [courseId, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Curso no encontrado' });
    }

    res.status(200).json({
      success: true,
      message: 'Curso archivado'
    });
  } catch (err) {
    console.error('Error archiving course:', err);
    res.status(500).json({ error: err.message });
  }
};
```

### 2.4 Material.controller.js (Upload & Processing)

```javascript
// backend/src/controllers/material.controller.js

const pool = require('../config/db');
const pdfService = require('../services/pdf.service');
const cloudinary = require('cloudinary').v2;
const { v4: uuidv4 } = require('uuid');

// POST upload material
exports.uploadMaterial = async (req, res) => {
  try {
    const { userId } = req.auth;
    const { courseId, category, topic } = req.body;
    const file = req.file;

    if (!file) {
      return res.status(400).json({ error: 'No file provided' });
    }

    if (!courseId) {
      return res.status(400).json({ error: 'courseId required' });
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
          folder: `utp/study-materials/${courseId}`,
          resource_type: 'auto',
          public_id: `${Date.now()}_${file.originalname}`
        },
        (error, result) => {
          if (error) reject(error);
          else resolve(result);
        }
      );
      stream.end(file.buffer);
    });

    // Extraer contenido si es PDF
    let textContent = null;
    let pageCount = null;

    if (file.mimetype === 'application/pdf') {
      const pdfData = await pdfService.extractText(file.buffer);
      textContent = pdfData.text;
      pageCount = pdfData.pageCount;
    }

    // Guardar en BD
    const materialId = uuidv4();
    
    const result = await pool.query(
      `INSERT INTO study_materials 
       (id, course_id, uploaded_by_user_id, name, file_url, file_size_bytes, 
        file_type, cloudinary_public_id, page_count, text_content, category, topic)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
       RETURNING *`,
      [
        materialId,
        courseId,
        userId,
        file.originalname,
        uploadResult.secure_url,
        file.size,
        file.mimetype.includes('pdf') ? 'pdf' : 'document',
        uploadResult.public_id,
        pageCount,
        textContent,
        category || 'apuntes',
        topic || null
      ]
    );

    // Log en study_history
    await pool.query(
      `INSERT INTO study_history (user_id, course_id, material_id, action_type)
       VALUES ($1, $2, $3, 'material_uploaded')`,
      [userId, courseId, materialId]
    );

    res.status(201).json({
      success: true,
      data: result.rows[0],
      message: 'Material subido exitosamente'
    });
  } catch (err) {
    console.error('Error uploading material:', err);
    res.status(500).json({ error: err.message });
  }
};

// GET material por ID
exports.getMaterial = async (req, res) => {
  try {
    const { materialId } = req.params;

    const result = await pool.query(
      'SELECT * FROM study_materials WHERE id = $1',
      [materialId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Material not found' });
    }

    res.status(200).json({
      success: true,
      data: result.rows[0]
    });
  } catch (err) {
    console.error('Error fetching material:', err);
    res.status(500).json({ error: err.message });
  }
};

// DELETE material
exports.deleteMaterial = async (req, res) => {
  try {
    const { materialId } = req.params;
    const { userId } = req.auth;

    const material = await pool.query(
      'SELECT * FROM study_materials WHERE id = $1',
      [materialId]
    );

    if (material.rows.length === 0) {
      return res.status(404).json({ error: 'Material not found' });
    }

    if (material.rows[0].uploaded_by_user_id !== userId) {
      return res.status(403).json({ error: 'Unauthorized' });
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

    res.status(200).json({
      success: true,
      message: 'Material deleted'
    });
  } catch (err) {
    console.error('Error deleting material:', err);
    res.status(500).json({ error: err.message });
  }
};
```

### 2.5 AI.controller.js (IA Integration)

```javascript
// backend/src/controllers/ai.controller.js

const pool = require('../config/db');
const aiService = require('../services/ai.service');
const cacheService = require('../services/cache.service');
const { v4: uuidv4 } = require('uuid');

// POST summarize PDF
exports.summarizePDF = async (req, res) => {
  try {
    const { userId } = req.auth;
    const { materialId } = req.body;

    // Obtener material
    const material = await pool.query(
      'SELECT * FROM study_materials WHERE id = $1',
      [materialId]
    );

    if (material.rows.length === 0) {
      return res.status(404).json({ error: 'Material not found' });
    }

    const content = material.rows[0];

    // Verificar cache (24 horas)
    const cacheKey = `summary_${materialId}`;
    const cached = await cacheService.get(cacheKey);

    if (cached) {
      return res.status(200).json({
        success: true,
        data: cached,
        fromCache: true
      });
    }

    // Generar resumen con IA
    const summary = await aiService.summarize(
      content.text_content || content.file_url,
      { title: content.name }
    );

    // Guardar en cache
    const responseId = uuidv4();
    
    await pool.query(
      `INSERT INTO ai_responses_cache 
       (id, material_id, user_id, response_type, response_content, ai_model, tokens_used)
       VALUES ($1, $2, $3, 'summary', $4, $5, $6)`,
      [
        responseId,
        materialId,
        userId,
        summary.content,
        'gpt-4-turbo',
        summary.tokensUsed
      ]
    );

    await cacheService.set(cacheKey, summary.content, 86400); // 24h

    res.status(200).json({
      success: true,
      data: {
        id: responseId,
        type: 'summary',
        content: summary.content,
        tokensUsed: summary.tokensUsed,
        generatedAt: new Date()
      }
    });
  } catch (err) {
    console.error('Error summarizing:', err);
    res.status(500).json({ error: err.message });
  }
};

// POST explain content
exports.explainContent = async (req, res) => {
  try {
    const { userId } = req.auth;
    const { materialId, concept, level = 'basic' } = req.body;

    const material = await pool.query(
      'SELECT * FROM study_materials WHERE id = $1',
      [materialId]
    );

    if (material.rows.length === 0) {
      return res.status(404).json({ error: 'Material not found' });
    }

    // Explicación con nivel
    const explanation = await aiService.explain(concept, level, {
      context: material.rows[0].text_content
    });

    const responseId = uuidv4();

    await pool.query(
      `INSERT INTO ai_responses_cache 
       (id, material_id, user_id, response_type, response_content, ai_model)
       VALUES ($1, $2, $3, 'explanation', $4, $5)`,
      [responseId, materialId, userId, explanation.content, 'gpt-4-turbo']
    );

    res.status(200).json({
      success: true,
      data: {
        id: responseId,
        type: 'explanation',
        content: explanation.content,
        generatedAt: new Date()
      }
    });
  } catch (err) {
    console.error('Error explaining:', err);
    res.status(500).json({ error: err.message });
  }
};

// POST generate quiz
exports.generateQuiz = async (req, res) => {
  try {
    const { userId } = req.auth;
    const { courseId, count = 5, difficulty = 'medium' } = req.body;

    // Validar curso
    const course = await pool.query(
      'SELECT * FROM study_courses WHERE id = $1',
      [courseId]
    );

    if (course.rows.length === 0) {
      return res.status(404).json({ error: 'Course not found' });
    }

    // Obtener últimos materiales del curso para contexto
    const materials = await pool.query(
      `SELECT text_content FROM study_materials 
       WHERE course_id = $1
       ORDER BY created_at DESC LIMIT 3`,
      [courseId]
    );

    const context = materials.rows
      .map(m => m.text_content)
      .join('\n')
      .substring(0, 3000);

    // Generar preguntas
    const quiz = await aiService.generateQuiz(context, {
      count,
      difficulty
    });

    // Guardar preguntas
    const questionIds = [];

    for (const q of quiz.questions) {
      const qId = uuidv4();

      await pool.query(
        `INSERT INTO study_questions 
         (id, course_id, question_text, options, correct_option, 
          explanation, difficulty_level, ai_generated, created_by_user_id)
         VALUES ($1, $2, $3, $4, $5, $6, $7, TRUE, $8)`,
        [
          qId,
          courseId,
          q.question,
          JSON.stringify(q.options),
          q.correctOption,
          q.explanation,
          difficulty,
          userId
        ]
      );

      questionIds.push(qId);
    }

    res.status(200).json({
      success: true,
      data: {
        quizId: uuidv4(),
        questions: questionIds,
        count: quiz.questions.length,
        difficulty
      }
    });
  } catch (err) {
    console.error('Error generating quiz:', err);
    res.status(500).json({ error: err.message });
  }
};

// POST ask question
exports.askQuestion = async (req, res) => {
  try {
    const { userId } = req.auth;
    const { courseId, question } = req.body;

    if (!question) {
      return res.status(400).json({ error: 'Question required' });
    }

    // Obtener contexto del curso
    const materials = await pool.query(
      `SELECT text_content FROM study_materials 
       WHERE course_id = $1
       LIMIT 5`,
      [courseId]
    );

    const context = materials.rows
      .map(m => m.text_content)
      .join('\n')
      .substring(0, 4000);

    // Responder
    const answer = await aiService.answerQuestion(question, context);

    const responseId = uuidv4();

    await pool.query(
      `INSERT INTO ai_responses_cache 
       (id, user_id, response_type, prompt, response_content, ai_model)
       VALUES ($1, $2, 'qa', $3, $4, $5)`,
      [responseId, userId, question, answer.content, 'gpt-4-turbo']
    );

    res.status(200).json({
      success: true,
      data: {
        id: responseId,
        type: 'qa',
        question,
        answer: answer.content,
        generatedAt: new Date()
      }
    });
  } catch (err) {
    console.error('Error answering question:', err);
    res.status(500).json({ error: err.message });
  }
};

// GET cached responses
exports.getResponses = async (req, res) => {
  try {
    const { materialId } = req.params;
    const { userId } = req.auth;

    const result = await pool.query(
      `SELECT * FROM ai_responses_cache 
       WHERE material_id = $1 AND user_id = $2
       ORDER BY created_at DESC LIMIT 20`,
      [materialId, userId]
    );

    res.status(200).json({
      success: true,
      data: result.rows,
      count: result.rows.length
    });
  } catch (err) {
    console.error('Error fetching responses:', err);
    res.status(500).json({ error: err.message });
  }
};
```

### 2.6 AI.service.js (OpenAI Integration)

```javascript
// backend/src/services/ai.service.js

const { OpenAI } = require('openai');
const aiPrompts = require('../utils/aiPrompts');

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY
});

class AIService {
  
  // Resumir PDF
  async summarize(content, options = {}) {
    try {
      // Limitar contenido a 2000 caracteres
      const truncated = content.substring(0, 2000);

      const message = await openai.chat.completions.create({
        model: 'gpt-4-turbo',
        messages: [
          { role: 'system', content: aiPrompts.SYSTEM_SUMMARY },
          { 
            role: 'user', 
            content: `Documento: "${options.title || 'Documento'}"\n\n${aiPrompts.summarizePrompt(truncated)}`
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
      console.error('Error in summarize:', err);
      throw err;
    }
  }

  // Explicar concepto
  async explain(concept, level = 'basic', options = {}) {
    try {
      const message = await openai.chat.completions.create({
        model: 'gpt-4-turbo',
        messages: [
          { role: 'system', content: aiPrompts.SYSTEM_EXPLAIN },
          { 
            role: 'user', 
            content: aiPrompts.explainPrompt(concept, level, options.context)
          }
        ],
        temperature: 0.8,
        max_tokens: 600
      });

      return {
        content: message.choices[0].message.content
      };
    } catch (err) {
      console.error('Error in explain:', err);
      throw err;
    }
  }

  // Generar Quiz
  async generateQuiz(content, options = {}) {
    try {
      const { count = 5, difficulty = 'medium' } = options;

      const message = await openai.chat.completions.create({
        model: 'gpt-4-turbo',
        messages: [
          { role: 'system', content: aiPrompts.SYSTEM_QUIZ },
          { 
            role: 'user', 
            content: aiPrompts.quizPrompt(content, count, difficulty)
          }
        ],
        temperature: 0.9,
        max_tokens: 1500
      });

      const responseText = message.choices[0].message.content;
      
      // Parse JSON de respuesta
      const jsonMatch = responseText.match(/\{[\s\S]*\}/);
      if (!jsonMatch) {
        throw new Error('Invalid JSON response from OpenAI');
      }

      const parsed = JSON.parse(jsonMatch[0]);

      return {
        questions: parsed.questions || [],
        tokensUsed: message.usage.total_tokens
      };
    } catch (err) {
      console.error('Error in generateQuiz:', err);
      throw err;
    }
  }

  // Responder pregunta
  async answerQuestion(question, context) {
    try {
      const message = await openai.chat.completions.create({
        model: 'gpt-4-turbo',
        messages: [
          { 
            role: 'system', 
            content: 'Eres un tutor experto universitario. Responde preguntas de estudiantes de forma clara y educativa.' 
          },
          {
            role: 'user',
            content: `Contexto del curso:\n${context}\n\nPregunta del estudiante:\n${question}`
          }
        ],
        temperature: 0.7,
        max_tokens: 800
      });

      return {
        content: message.choices[0].message.content
      };
    } catch (err) {
      console.error('Error in answerQuestion:', err);
      throw err;
    }
  }
}

module.exports = new AIService();
```

### 2.7 Routes Setup

```javascript
// backend/routes/index.js

const express = require('express');
const authMiddleware = require('../middlewares/auth.middleware');

const studyRoutes = require('./study.routes');
const materialRoutes = require('./materials.routes');
const aiRoutes = require('./ai.routes');
const quizRoutes = require('./quiz.routes');

const router = express.Router();

// Todas las rutas de study necesitan auth
router.use('/study', authMiddleware, studyRoutes);
router.use('/materials', authMiddleware, materialRoutes);
router.use('/ai', authMiddleware, aiRoutes);
router.use('/quiz', authMiddleware, quizRoutes);

module.exports = router;

// ======================================

// backend/routes/study.routes.js
const express = require('express');
const studyController = require('../controllers/study.controller');

const router = express.Router();

router.get('/courses', studyController.getUserCourses);
router.post('/courses', studyController.createCourse);
router.get('/courses/:courseId', studyController.getCourseDetail);
router.put('/courses/:courseId', studyController.updateCourse);
router.delete('/courses/:courseId', studyController.archiveCourse);

module.exports = router;

// ======================================

// backend/routes/materials.routes.js
const express = require('express');
const multer = require('multer');
const materialController = require('../controllers/material.controller');

const router = express.Router();
const upload = multer({ storage: multer.memoryStorage() });

router.post('/upload', upload.single('file'), materialController.uploadMaterial);
router.get('/:materialId', materialController.getMaterial);
router.delete('/:materialId', materialController.deleteMaterial);

module.exports = router;

// ======================================

// backend/routes/ai.routes.js
const express = require('express');
const aiController = require('../controllers/ai.controller');

const router = express.Router();

router.post('/summarize', aiController.summarizePDF);
router.post('/explain', aiController.explainContent);
router.post('/generate-quiz', aiController.generateQuiz);
router.post('/ask-question', aiController.askQuestion);
router.get('/responses/:materialId', aiController.getResponses);

module.exports = router;
```

### 2.8 Auth Middleware

```javascript
// backend/middlewares/auth.middleware.js

const jwt = require('jsonwebtoken');
const admin = require('firebase-admin');

module.exports = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'No token provided' });
    }

    const token = authHeader.substring(7);

    // Verificar con Firebase
    const decoded = await admin.auth().verifyIdToken(token);
    
    req.auth = {
      userId: decoded.uid,
      email: decoded.email
    };

    next();
  } catch (err) {
    console.error('Auth error:', err);
    res.status(401).json({ error: 'Invalid token' });
  }
};
```

---

## 📱 PARTE 3: FLUTTER IMPLEMENTATION

### 3.1 Models

```dart
// lib/models/study_models.dart

class StudyCourse {
  final String id;
  final String name;
  final String? courseCode;
  final String? professorName;
  final String? description;
  final int? semester;
  final int? year;
  final bool isArchived;
  final DateTime createdAt;

  StudyCourse({
    required this.id,
    required this.name,
    this.courseCode,
    this.professorName,
    this.description,
    this.semester,
    this.year,
    this.isArchived = false,
    required this.createdAt,
  });

  factory StudyCourse.fromJson(Map<String, dynamic> json) {
    return StudyCourse(
      id: json['id'],
      name: json['name'],
      courseCode: json['course_code'],
      professorName: json['professor_name'],
      description: json['description'],
      semester: json['semester'],
      year: json['year'],
      isArchived: json['is_archived'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class StudyMaterial {
  final String id;
  final String courseId;
  final String name;
  final String fileUrl;
  final int? fileSizeBytes;
  final String fileType;
  final int? pageCount;
  final String? category;
  final DateTime createdAt;

  StudyMaterial({
    required this.id,
    required this.courseId,
    required this.name,
    required this.fileUrl,
    this.fileSizeBytes,
    required this.fileType,
    this.pageCount,
    this.category,
    required this.createdAt,
  });

  factory StudyMaterial.fromJson(Map<String, dynamic> json) {
    return StudyMaterial(
      id: json['id'],
      courseId: json['course_id'],
      name: json['name'],
      fileUrl: json['file_url'],
      fileSizeBytes: json['file_size_bytes'],
      fileType: json['file_type'],
      pageCount: json['page_count'],
      category: json['category'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class AIResponse {
  final String id;
  final String type; // 'summary', 'explanation', 'qa'
  final String content;
  final DateTime generatedAt;
  final bool fromCache;

  AIResponse({
    required this.id,
    required this.type,
    required this.content,
    required this.generatedAt,
    this.fromCache = false,
  });

  factory AIResponse.fromJson(Map<String, dynamic> json) {
    return AIResponse(
      id: json['id'],
      type: json['type'],
      content: json['content'],
      generatedAt: DateTime.parse(json['generatedAt']),
      fromCache: json['fromCache'] ?? false,
    );
  }
}

class StudyQuestion {
  final String id;
  final String questionText;
  final Map<String, String> options;
  final String correctOption;
  final String explanation;
  final String difficultyLevel;

  StudyQuestion({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctOption,
    required this.explanation,
    required this.difficultyLevel,
  });

  factory StudyQuestion.fromJson(Map<String, dynamic> json) {
    return StudyQuestion(
      id: json['id'],
      questionText: json['question_text'],
      options: Map<String, String>.from(json['options']),
      correctOption: json['correct_option'],
      explanation: json['explanation'],
      difficultyLevel: json['difficulty_level'],
    );
  }
}
```

### 3.2 Study Mode Provider

```dart
// lib/providers/study_provider.dart

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/study_models.dart';
import '../services/api_service.dart';

class StudyModeProvider extends ChangeNotifier {
  
  List<StudyCourse> _courses = [];
  Map<String, List<StudyMaterial>> _materials = {};
  Map<String, AIResponse> _aiResponsesCache = {};
  bool _isLoading = false;
  String? _error;

  // Getters
  List<StudyCourse> get courses => _courses;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  List<StudyMaterial> getMaterialsByCourse(String courseId) => 
    _materials[courseId] ?? [];

  // Fetch all courses
  Future<void> fetchCourses() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await ApiService.get('/study/courses');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _courses = (data['data'] as List)
            .map((json) => StudyCourse.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load courses');
      }
    } catch (err) {
      _error = err.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create course
  Future<StudyCourse?> createCourse(Map<String, dynamic> courseData) async {
    try {
      final response = await ApiService.post(
        '/study/courses',
        body: courseData,
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final course = StudyCourse.fromJson(data['data']);
        _courses.insert(0, course);
        notifyListeners();
        return course;
      }
    } catch (err) {
      _error = err.toString();
    }
    return null;
  }

  // Fetch materials for course
  Future<void> fetchMaterials(String courseId) async {
    try {
      if (_materials.containsKey(courseId)) {
        return; // Already loaded
      }

      final response = await ApiService.get('/study/courses/$courseId');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _materials[courseId] = (data['data']['materials'] as List)
            .map((json) => StudyMaterial.fromJson(json))
            .toList();
      }
    } catch (err) {
      _error = err.toString();
    }
    notifyListeners();
  }

  // Upload material
  Future<StudyMaterial?> uploadMaterial(
    String courseId,
    String filePath,
    String fileName,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiService.baseUrl}/materials/upload'),
      );

      request.fields['courseId'] = courseId;
      request.files.add(
        await http.MultipartFile.fromPath('file', filePath),
      );

      request.headers['Authorization'] = 'Bearer ${await ApiService.getToken()}';

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        final data = jsonDecode(responseBody);
        final material = StudyMaterial.fromJson(data['data']);
        
        if (_materials[courseId] == null) {
          _materials[courseId] = [];
        }
        _materials[courseId]!.insert(0, material);
        notifyListeners();
        return material;
      }
    } catch (err) {
      _error = err.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }

  // Summarize material
  Future<AIResponse?> summarizeMaterial(String materialId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await ApiService.post(
        '/ai/summarize',
        body: {'materialId': materialId},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse = AIResponse.fromJson(data['data']);
        _aiResponsesCache[materialId] = aiResponse;
        notifyListeners();
        return aiResponse;
      }
    } catch (err) {
      _error = err.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }

  // Explain concept
  Future<AIResponse?> explainConcept(
    String materialId,
    String concept,
    {String level = 'basic'},
  ) async {
    try {
      final response = await ApiService.post(
        '/ai/explain',
        body: {
          'materialId': materialId,
          'concept': concept,
          'level': level,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse = AIResponse.fromJson(data['data']);
        return aiResponse;
      }
    } catch (err) {
      _error = err.toString();
    }
    return null;
  }

  // Generate quiz
  Future<List<StudyQuestion>?> generateQuiz(
    String courseId,
    {int count = 5, String difficulty = 'medium'},
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await ApiService.post(
        '/ai/generate-quiz',
        body: {
          'courseId': courseId,
          'count': count,
          'difficulty': difficulty,
        },
      );

      if (response.statusCode == 200) {
        // Aquí iríamos a buscar las preguntas por ID
        return [];
      }
    } catch (err) {
      _error = err.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }

  // Ask AI question
  Future<AIResponse?> askQuestion(String courseId, String question) async {
    try {
      final response = await ApiService.post(
        '/ai/ask-question',
        body: {
          'courseId': courseId,
          'question': question,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse = AIResponse.fromJson(data['data']);
        return aiResponse;
      }
    } catch (err) {
      _error = err.toString();
    }
    return null;
  }
}
```

### 3.3 Study Hub Screen

```dart
// lib/screens/study_hub_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/study_provider.dart';
import '../models/study_models.dart';
import '../widgets/course_card.dart';

class StudyHubScreen extends StatefulWidget {
  const StudyHubScreen({Key? key}) : super(key: key);

  @override
  State<StudyHubScreen> createState() => _StudyHubScreenState();
}

class _StudyHubScreenState extends State<StudyHubScreen> {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StudyModeProvider>(context, listen: false).fetchCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📚 Modo Estudio'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Consumer<StudyModeProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.courses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.book_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No tienes cursos aún'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showCreateCourseDialog(context),
                    child: const Text('+ Crear Curso'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchCourses(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar curso...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'TUS CURSOS (${provider.courses.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 12),
                ...provider.courses.map((course) =>
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StudyCourseDetailScreen(course: course),
                      ),
                    ),
                    child: CourseCard(course: course),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _showCreateCourseDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('+ Crear Curso'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showCreateCourseDialog(BuildContext context) {
    final nameController = TextEditingController();
    final professorController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear Curso'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: 'Nombre del curso',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: professorController,
              decoration: const InputDecoration(
                hintText: 'Profesor (opcional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final provider = Provider.of<StudyModeProvider>(context, listen: false);
              await provider.createCourse({
                'name': nameController.text,
                'professorName': professorController.text,
              });
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }
}
```

### 3.4 Course Card Widget

```dart
// lib/widgets/course_card.dart

import 'package:flutter/material.dart';
import '../models/study_models.dart';

class CourseCard extends StatelessWidget {
  final StudyCourse course;

  const CourseCard({
    Key? key,
    required this.course,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (course.professorName != null)
                        Text(
                          'Prof: ${course.professorName}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.auto_awesome, size: 16, color: Colors.blue),
                      SizedBox(width: 4),
                      Text(
                        'IA',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Último acceso: ${course.createdAt.toString().split(' ')[0]}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 🔌 PARTE 4: INTEGRACIÓN EN APP EXISTENTE

### 4.1 Actualizar main_scaffold.dart

```dart
// Reemplazar lista de screens con:

import 'study_hub_screen.dart'; // NUEVO

final List<Widget> screens = [
  HomeScreen(),
  CommunitiesScreen(communities: communities),
  StudyHubScreen(), // NUEVO - Reemplazar NotificationsScreen o agregar como 5to tab
  NotificationsScreen(),
  user != null ? ProfileScreen(user: user) : const Center(child: Text('No autenticado')),
];
```

### 4.2 Actualizar Bottom Navigation

```dart
// Opción 1: Reemplazar NotificationsScreen con StudyHubScreen
// Opción 2: Agregar 5to tab (requiere refactorizar BottomNav)

// Recomendación: Opción 1 (más limpio)
// Cambiar orden: Home | Communities | Study Mode | Notifications | Profile
```

---

## 📊 PARTE 5: TESTING CHECKLIST

### Tests Manuales MVP (2-3 horas)

```
BACKEND:
□ POST /study/courses - Crear curso
□ GET /study/courses - Listar cursos
□ GET /study/courses/:courseId - Detalle
□ POST /materials/upload - Subir PDF
□ GET /materials/:materialId - Ver material
□ POST /ai/summarize - Generar resumen
□ POST /ai/explain - Explicar
□ POST /ai/generate-quiz - Crear quiz
□ POST /ai/ask-question - Hacer pregunta

FRONTEND:
□ Navegar a Modo Estudio
□ Crear curso (UI + llamada API)
□ Ver lista cursos
□ Subir PDF
□ Generar resumen (loading + respuesta)
□ Explicar concepto
□ Generar quiz
□ Responder pregunta

EDGE CASES:
□ PDF > 50MB (rechazar)
□ IA timeout > 20s (error)
□ Usuario sin autenticación
□ Curso de otro usuario (403)
□ Conectividad offline (graceful)
```

---

## 🚀 DEPLOYMENT CHECKLIST

### Pre-Production

```bash
# 1. Environment variables
OPENAI_API_KEY=sk-...
CLOUDINARY_NAME=...
CLOUDINARY_API_KEY=...
REDIS_URL=redis://...

# 2. Database migrations
psql $DATABASE_URL < migrations/study_schema.sql

# 3. Build Flutter
flutter build apk --release
flutter build ios --release

# 4. Backend
npm run build
npm start

# 5. Test endpoints
curl -X GET http://localhost:5000/study/courses \
  -H "Authorization: Bearer $TOKEN"
```

---

## 💰 COST SUMMARY (1000 users)

```
Monthly Costs:
├─ OpenAI API: $13/mes
├─ Cloudinary: $50/mes
├─ PostgreSQL: $50/mes
├─ Redis: $0 (free tier) → $15/mes (if needed)
└─ Monitoring/Tools: $25/mes
─────────────────────────
TOTAL: ~$150/mes ($0.15 per user)

Scaling to 100K users:
├─ OpenAI (if 80% cache hit): $150/mes
├─ Infrastructure: $2000/mes
├─ Database: $300/mes
└─ Other: $500/mes
─────────────────────────
TOTAL: ~$3000/mes ($0.03 per user) ✓
```

---

## 📚 ARCHIVOS A CREAR/MODIFICAR

```
CREAR (Backend):
✓ controllers/study.controller.js
✓ controllers/material.controller.js
✓ controllers/ai.controller.js
✓ controllers/quiz.controller.js
✓ services/ai.service.js
✓ services/pdf.service.js
✓ services/cache.service.js
✓ routes/study.routes.js
✓ routes/materials.routes.js
✓ routes/ai.routes.js
✓ routes/quiz.routes.js
✓ utils/aiPrompts.js

CREAR (Frontend):
✓ models/study_models.dart
✓ providers/study_provider.dart
✓ screens/study_hub_screen.dart
✓ screens/study_course_detail_screen.dart
✓ screens/pdf_viewer_screen.dart
✓ screens/quiz_screen.dart
✓ widgets/course_card.dart
✓ widgets/material_card.dart
✓ widgets/ai_response_card.dart
✓ widgets/quiz_card.dart

MODIFICAR:
✓ backend/package.json
✓ backend/server.js (agregar routes)
✓ utp_comunidades_app/lib/main.dart (agregar provider)
✓ utp_comunidades_app/lib/screens/main_scaffold.dart
```

---

**LISTO PARA EMPEZAR IMPLEMENTACIÓN**

¿Quieres que comience con el setup del backend o prefieres empezar con la parte de Flutter?
