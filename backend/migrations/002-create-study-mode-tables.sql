-- ============================================================
-- MODO ESTUDIO - Database Schema (Ready for Neon)
-- Run this in: Neon Console > SQL Editor
-- ============================================================

-- 1. STUDY COURSES TABLE
CREATE TABLE IF NOT EXISTS study_courses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id INTEGER NOT NULL,
    name VARCHAR(255) NOT NULL,
    course_code VARCHAR(50),
    professor_name VARCHAR(255),
    description TEXT,
    photo_url TEXT,
    created_by_user_id INTEGER NOT NULL,
    semester INT,
    year INT,
    is_archived BOOLEAN DEFAULT FALSE,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by_user_id) REFERENCES usuarios(id)
);

CREATE INDEX IF NOT EXISTS idx_user_courses ON study_courses(user_id, created_at DESC) WHERE NOT is_archived;
CREATE INDEX IF NOT EXISTS idx_course_created_by ON study_courses(created_by_user_id);

-- 2. STUDY MATERIALS TABLE (PDFs, Apuntes, etc)
CREATE TABLE IF NOT EXISTS study_materials (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id UUID NOT NULL,
    uploaded_by_user_id INTEGER NOT NULL,
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

CREATE INDEX IF NOT EXISTS idx_course_materials ON study_materials(course_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_materials_embeddings ON study_materials(embeddings_generated) WHERE NOT embeddings_generated;

-- 3. AI RESPONSES CACHE
CREATE TABLE IF NOT EXISTS ai_responses_cache (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    material_id UUID,
    user_id INTEGER NOT NULL,
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

CREATE INDEX IF NOT EXISTS idx_cache_lookup ON ai_responses_cache(material_id, response_type, user_id);
CREATE INDEX IF NOT EXISTS idx_cache_created ON ai_responses_cache(created_at DESC);

-- 4. STUDY QUESTIONS (Quiz Bank)
CREATE TABLE IF NOT EXISTS study_questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id UUID NOT NULL,
    question_text TEXT NOT NULL,
    options JSONB NOT NULL,
    correct_option VARCHAR(1),
    explanation TEXT,
    difficulty_level VARCHAR(20),
    source_material_id UUID,
    created_by_user_id INTEGER,
    ai_generated BOOLEAN DEFAULT FALSE,
    tags JSONB DEFAULT '[]',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (course_id) REFERENCES study_courses(id) ON DELETE CASCADE,
    FOREIGN KEY (source_material_id) REFERENCES study_materials(id),
    FOREIGN KEY (created_by_user_id) REFERENCES usuarios(id)
);

CREATE INDEX IF NOT EXISTS idx_questions_course ON study_questions(course_id);
CREATE INDEX IF NOT EXISTS idx_questions_difficulty ON study_questions(course_id, difficulty_level);

-- 5. QUIZ ATTEMPTS (Historial de respuestas)
CREATE TABLE IF NOT EXISTS quiz_attempts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id INTEGER NOT NULL,
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

CREATE INDEX IF NOT EXISTS idx_quiz_attempts_user ON quiz_attempts(user_id, completed_at DESC);
CREATE INDEX IF NOT EXISTS idx_quiz_attempts_course ON quiz_attempts(course_id);

-- 6. STUDY HISTORY (Analytics + Auditoría)
CREATE TABLE IF NOT EXISTS study_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id INTEGER NOT NULL,
    course_id UUID,
    material_id UUID,
    action_type VARCHAR(50),
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES study_courses(id) ON DELETE SET NULL,
    FOREIGN KEY (material_id) REFERENCES study_materials(id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_study_history_user ON study_history(user_id, created_at DESC);

-- 7. USER STREAKS (Gamificación)
CREATE TABLE IF NOT EXISTS user_streaks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id INTEGER NOT NULL UNIQUE,
    current_streak INT DEFAULT 0,
    max_streak INT DEFAULT 0,
    last_activity_date DATE,
    badges JSONB DEFAULT '[]',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES usuarios(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_streaks_user ON user_streaks(user_id);

-- ============================================================
-- DONE! All tables created successfully.
-- ============================================================
