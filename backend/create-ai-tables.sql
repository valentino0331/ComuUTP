-- Crear tabla para respuestas de IA (sin foreign keys para evitar dependencias)
-- CORREGIDO: usar 'content' en vez de 'response' para coincidir con el código
CREATE TABLE IF NOT EXISTS ai_responses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id VARCHAR(255),
  course_id VARCHAR(255),
  type VARCHAR(50) DEFAULT 'general',
  content TEXT NOT NULL,
  prompt TEXT,
  from_cache BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Si la tabla ya existe con columnas incorrectas, recrearla
DROP TABLE IF EXISTS ai_responses_backup;
ALTER TABLE IF EXISTS ai_responses RENAME TO ai_responses_backup;

-- Crear tabla correcta
CREATE TABLE ai_responses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id VARCHAR(255),
  course_id VARCHAR(255),
  type VARCHAR(50) DEFAULT 'general',
  content TEXT NOT NULL,
  prompt TEXT,
  from_cache BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
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
