-- ARREGLAR TODOS LOS PROBLEMAS DE BASE DE DATOS
-- Ejecutar esto en Neon SQL Editor

-- 1. RECREAR ai_responses con columnas CORRECTAS
DROP TABLE IF EXISTS ai_responses CASCADE;

CREATE TABLE ai_responses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id VARCHAR(255),
  course_id VARCHAR(255),
  material_id UUID,
  type VARCHAR(50) DEFAULT 'general',
  content TEXT NOT NULL,
  prompt TEXT,
  from_cache BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_ai_responses_user_id ON ai_responses(user_id);
CREATE INDEX idx_ai_responses_course_id ON ai_responses(course_id);
CREATE INDEX idx_ai_responses_material_id ON ai_responses(material_id);

-- 2. Arreglar study_courses - asegurar que user_id existe
ALTER TABLE study_courses ADD COLUMN IF NOT EXISTS user_id VARCHAR(255);

-- 3. Arreglar tabla de solicitudes (columna aceptada)
ALTER TABLE solicitudes_amistad ADD COLUMN IF NOT EXISTS aceptada BOOLEAN DEFAULT FALSE;

-- 4. Verificar que study_materials tiene las columnas correctas
ALTER TABLE study_materials ADD COLUMN IF NOT EXISTS user_id VARCHAR(255);

-- 5. Insertar datos de prueba si no hay nada
INSERT INTO study_courses (id, user_id, name, course_code, description, created_by_user_id, semester, year, created_at)
SELECT 
  gen_random_uuid(), 
  'test-user', 
  'Curso de Prueba', 
  'TEST-101', 
  'Curso para verificar funcionalidad', 
  'test-user', 
  1, 
  2024, 
  CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM study_courses LIMIT 1);

SELECT 'Base de datos arreglada correctamente' as status;
