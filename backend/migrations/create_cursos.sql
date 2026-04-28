-- Tabla de cursos de estudio
CREATE TABLE IF NOT EXISTS study_courses (
    id VARCHAR(36) PRIMARY KEY,
    user_id INTEGER REFERENCES usuarios(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    course_code VARCHAR(50),
    professor_name VARCHAR(255),
    description TEXT,
    semester INTEGER,
    year INTEGER,
    is_archived BOOLEAN DEFAULT FALSE,
    created_by_user_id INTEGER REFERENCES usuarios(id),
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_study_courses_user ON study_courses(user_id);
CREATE INDEX idx_study_courses_code ON study_courses(course_code);
