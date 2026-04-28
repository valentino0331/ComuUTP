-- Tabla de preguntas/cuestionarios
CREATE TABLE IF NOT EXISTS study_questions (
    id VARCHAR(36) PRIMARY KEY,
    course_id VARCHAR(36) REFERENCES study_courses(id) ON DELETE CASCADE,
    user_id INTEGER REFERENCES usuarios(id) ON DELETE CASCADE,
    question_text TEXT NOT NULL,
    options JSONB NOT NULL, -- {"A": "Opción A", "B": "Opción B", ...}
    correct_option VARCHAR(10) NOT NULL, -- 'A', 'B', 'C', 'D'
    explanation TEXT,
    difficulty_level VARCHAR(20) DEFAULT 'medium', -- 'easy', 'medium', 'hard'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_study_questions_course ON study_questions(course_id);
CREATE INDEX idx_study_questions_user ON study_questions(user_id);

-- Tabla de intentos de cuestionario
CREATE TABLE IF NOT EXISTS quiz_attempts (
    id VARCHAR(36) PRIMARY KEY,
    user_id INTEGER REFERENCES usuarios(id) ON DELETE CASCADE,
    course_id VARCHAR(36) REFERENCES study_courses(id) ON DELETE CASCADE,
    answers JSONB NOT NULL, -- {"pregunta_id": "respuesta", ...}
    time_seconds INTEGER,
    score INTEGER,
    total_questions INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_quiz_attempts_user ON quiz_attempts(user_id);
CREATE INDEX idx_quiz_attempts_course ON quiz_attempts(course_id);
