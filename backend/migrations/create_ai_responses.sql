-- Tabla de respuestas de IA
CREATE TABLE IF NOT EXISTS ai_responses (
    id VARCHAR(36) PRIMARY KEY,
    user_id INTEGER REFERENCES usuarios(id) ON DELETE CASCADE,
    material_id VARCHAR(36) REFERENCES study_materials(id) ON DELETE CASCADE,
    course_id VARCHAR(36) REFERENCES study_courses(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL, -- 'summary', 'answer', 'explanation'
    content TEXT NOT NULL,
    prompt TEXT,
    from_cache BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_ai_responses_user ON ai_responses(user_id);
CREATE INDEX idx_ai_responses_material ON ai_responses(material_id);
CREATE INDEX idx_ai_responses_course ON ai_responses(course_id);
CREATE INDEX idx_ai_responses_type ON ai_responses(type);
