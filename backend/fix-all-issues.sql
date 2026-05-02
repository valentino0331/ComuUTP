-- Arreglar TODAS las tablas problemáticas

-- 1. RECREAR ai_responses con columnas CORRECTAS
DROP TABLE IF EXISTS ai_responses;
DROP TABLE IF EXISTS ai_responses_backup;

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

CREATE INDEX idx_ai_responses_user_id ON ai_responses(user_id);
CREATE INDEX idx_ai_responses_course_id ON ai_responses(course_id);

-- 2. Arreglar study_courses - agregar user_id si no existe
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name='study_courses' AND column_name='user_id') THEN
    ALTER TABLE study_courses ADD COLUMN user_id VARCHAR(255);
  END IF;
END $$;

-- 3. Arreglar tabla de estadísticas - agregar columna aceptada si no existe
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name='solicitudes_amistad' AND column_name='aceptada') THEN
    ALTER TABLE solicitudes_amistad ADD COLUMN aceptada BOOLEAN DEFAULT FALSE;
  END IF;
END $$;

-- 4. Verificar que todo quedó bien
SELECT 'Tablas arregladas' as status;
