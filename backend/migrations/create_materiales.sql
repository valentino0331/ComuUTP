-- Tabla de materiales de estudio
CREATE TABLE IF NOT EXISTS study_materials (
    id VARCHAR(36) PRIMARY KEY,
    course_id VARCHAR(36) REFERENCES study_courses(id) ON DELETE CASCADE,
    user_id INTEGER REFERENCES usuarios(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    file_url TEXT NOT NULL,
    file_size_bytes BIGINT,
    file_type VARCHAR(50) DEFAULT 'pdf',
    page_count INTEGER,
    category VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_study_materials_course ON study_materials(course_id);
CREATE INDEX idx_study_materials_user ON study_materials(user_id);
