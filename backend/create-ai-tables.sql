-- Crear tabla para respuestas de IA
CREATE TABLE IF NOT EXISTS ai_responses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  course_id UUID REFERENCES courses(id),
  question TEXT NOT NULL,
  response TEXT NOT NULL,
  type VARCHAR(50) DEFAULT 'general',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  from_cache BOOLEAN DEFAULT FALSE
);

-- Crear índices
CREATE INDEX IF NOT EXISTS idx_ai_responses_user_id ON ai_responses(user_id);
CREATE INDEX IF NOT EXISTS idx_ai_responses_course_id ON ai_responses(course_id);
CREATE INDEX IF NOT EXISTS idx_ai_responses_created_at ON ai_responses(created_at);

-- Comentarios
COMMENT ON TABLE ai_responses IS 'Almacena respuestas generadas por la IA para preguntas de usuarios';
COMMENT ON COLUMN ai_responses.question IS 'La pregunta realizada por el usuario';
COMMENT ON COLUMN ai_responses.response IS 'La respuesta generada por la IA';
COMMENT ON COLUMN ai_responses.type IS 'Tipo de respuesta: general, summary, quiz, tips, etc.';

-- Verificar que se creó
SELECT 'Tabla ai_responses creada exitosamente' as status;
