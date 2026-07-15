-- ============================================================
-- UTP COMUNIDADES - MASTER DATABASE INITIALIZATION SCRIPT
-- Run this in: Neon Console > SQL Editor
-- ============================================================
-- This script consolidates all migrations and creates the complete schema
-- Created: 2024
-- Version: 1.0

-- ============================================================
-- 1. SCHEMA MODIFICATIONS & CORE COLUMNS
-- ============================================================

-- 1.1 Add missing columns and relationships to comunidades
ALTER TABLE comunidades
ADD COLUMN IF NOT EXISTS usuario_creador_id INTEGER REFERENCES usuarios(id) ON DELETE SET NULL;

-- 1.2 Ensure fecha column exists in publicaciones
ALTER TABLE publicaciones
ADD COLUMN IF NOT EXISTS fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

DO $$ 
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='publicaciones' AND column_name='creado_en' AND NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='publicaciones' AND column_name='fecha')) THEN
    ALTER TABLE publicaciones RENAME COLUMN creado_en TO fecha;
  END IF;
END $$;

-- 1.3 Add image/media columns to publicaciones
ALTER TABLE publicaciones ADD COLUMN IF NOT EXISTS imagen_url TEXT;

-- 1.4 Add profile and cover photos (converted to TEXT for base64 support)
ALTER TABLE usuarios ALTER COLUMN foto_perfil TYPE TEXT;
ALTER TABLE usuarios ADD COLUMN IF NOT EXISTS foto_portada TEXT;

-- 1.5 Add profile settings and user preferences
ALTER TABLE usuarios 
ADD COLUMN IF NOT EXISTS bio TEXT,
ADD COLUMN IF NOT EXISTS gustos TEXT,
ADD COLUMN IF NOT EXISTS notificaciones_activas BOOLEAN DEFAULT TRUE,
ADD COLUMN IF NOT EXISTS email_notificaciones BOOLEAN DEFAULT TRUE,
ADD COLUMN IF NOT EXISTS notificaciones_menciones BOOLEAN DEFAULT TRUE,
ADD COLUMN IF NOT EXISTS modo_oscuro BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS privacidad_perfil_publico BOOLEAN DEFAULT TRUE,
ADD COLUMN IF NOT EXISTS privacidad_mostrar_email BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS idioma VARCHAR(10) DEFAULT 'es',
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- 1.6 Add amistades timestamps if missing
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'amistades' AND column_name = 'created_at'
    ) THEN
        ALTER TABLE amistades ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'amistades' AND column_name = 'updated_at'
    ) THEN
        ALTER TABLE amistades ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
    END IF;
END $$;

-- ============================================================
-- 2. STUDY MODE TABLES (PDFs, Apuntes, Lecciones)
-- ============================================================

-- 2.1 Study Courses
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

-- 2.2 Study Materials (PDFs, Apuntes, etc)
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

-- 2.3 Audio Lessons (NEW - Generadas con IA)
CREATE TABLE IF NOT EXISTS audio_lessons (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  material_id UUID NOT NULL REFERENCES study_materials(id) ON DELETE CASCADE,
  course_id UUID NOT NULL REFERENCES study_courses(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  audio_url TEXT NOT NULL,
  duration_seconds INTEGER DEFAULT 0,
  transcription TEXT,
  voice_style VARCHAR(50) DEFAULT 'balanced', -- casual|formal|balanced
  speed FLOAT DEFAULT 1.0, -- 0.75|1.0|1.25|1.5
  is_generated BOOLEAN DEFAULT FALSE,
  generated_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_audio_lessons_material_id ON audio_lessons(material_id);
CREATE INDEX IF NOT EXISTS idx_audio_lessons_course_id ON audio_lessons(course_id);
CREATE INDEX IF NOT EXISTS idx_audio_lessons_generated_at ON audio_lessons(generated_at);

COMMENT ON TABLE audio_lessons IS 'Tabla de lecciones de audio generadas con IA para modo podcast';
COMMENT ON COLUMN audio_lessons.voice_style IS 'Estilo de voz: casual (conversacional), formal (académico), balanced (equilibrado)';

-- 2.4 Study Questions & Quiz Attempts
CREATE TABLE IF NOT EXISTS study_questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id UUID REFERENCES study_courses(id) ON DELETE CASCADE,
    user_id INTEGER REFERENCES usuarios(id) ON DELETE CASCADE,
    question_text TEXT NOT NULL,
    options JSONB NOT NULL,
    correct_option VARCHAR(10) NOT NULL,
    explanation TEXT,
    difficulty_level VARCHAR(20) DEFAULT 'medium',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_study_questions_course ON study_questions(course_id);
CREATE INDEX IF NOT EXISTS idx_study_questions_user ON study_questions(user_id);

CREATE TABLE IF NOT EXISTS quiz_attempts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id INTEGER REFERENCES usuarios(id) ON DELETE CASCADE,
    course_id UUID REFERENCES study_courses(id) ON DELETE CASCADE,
    answers JSONB NOT NULL,
    time_seconds INTEGER,
    score INTEGER,
    total_questions INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_quiz_attempts_user ON quiz_attempts(user_id);
CREATE INDEX IF NOT EXISTS idx_quiz_attempts_course ON quiz_attempts(course_id);

-- 2.5 AI Responses Cache
CREATE TABLE IF NOT EXISTS ai_responses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id INTEGER REFERENCES usuarios(id) ON DELETE CASCADE,
    material_id UUID REFERENCES study_materials(id) ON DELETE CASCADE,
    course_id UUID REFERENCES study_courses(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL, -- 'summary', 'answer', 'explanation'
    content TEXT NOT NULL,
    prompt TEXT,
    from_cache BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_ai_responses_user ON ai_responses(user_id);
CREATE INDEX IF NOT EXISTS idx_ai_responses_material ON ai_responses(material_id);
CREATE INDEX IF NOT EXISTS idx_ai_responses_course ON ai_responses(course_id);
CREATE INDEX IF NOT EXISTS idx_ai_responses_type ON ai_responses(type);

-- ============================================================
-- 3. COMMUNITY ENGAGEMENT TABLES
-- ============================================================

-- 3.1 Reactions (Love, Fire, Laugh, Wow, Sad)
CREATE TABLE IF NOT EXISTS reacciones (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    publicacion_id INTEGER NOT NULL REFERENCES publicaciones(id) ON DELETE CASCADE,
    tipo VARCHAR(20) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(usuario_id, publicacion_id)
);

CREATE INDEX IF NOT EXISTS idx_reacciones_usuario_id ON reacciones(usuario_id);
CREATE INDEX IF NOT EXISTS idx_reacciones_publicacion_id ON reacciones(publicacion_id);
CREATE INDEX IF NOT EXISTS idx_reacciones_tipo ON reacciones(tipo);

-- 3.2 Mentions (En posts y comentarios)
CREATE TABLE IF NOT EXISTS menciones (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    publicacion_id INTEGER REFERENCES publicaciones(id) ON DELETE CASCADE,
    comentario_id INTEGER REFERENCES comentarios(id) ON DELETE CASCADE,
    mencionado_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    leida BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_menciones_usuario_id ON menciones(usuario_id);
CREATE INDEX IF NOT EXISTS idx_menciones_publicacion_id ON menciones(publicacion_id);
CREATE INDEX IF NOT EXISTS idx_menciones_comentario_id ON menciones(comentario_id);
CREATE INDEX IF NOT EXISTS idx_menciones_mencionado_id ON menciones(mencionado_id);

-- 3.3 Hashtags
CREATE TABLE IF NOT EXISTS hashtags (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) UNIQUE NOT NULL,
    contador INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS post_hashtags (
    id SERIAL PRIMARY KEY,
    post_id INTEGER NOT NULL REFERENCES publicaciones(id) ON DELETE CASCADE,
    hashtag_id INTEGER NOT NULL REFERENCES hashtags(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(post_id, hashtag_id)
);

CREATE INDEX IF NOT EXISTS idx_hashtags_nombre ON hashtags(nombre);
CREATE INDEX IF NOT EXISTS idx_post_hashtags_post_id ON post_hashtags(post_id);
CREATE INDEX IF NOT EXISTS idx_post_hashtags_hashtag_id ON post_hashtags(hashtag_id);

-- 3.4 Saved Posts & Collections
CREATE TABLE IF NOT EXISTS posts_guardados (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    post_id INTEGER NOT NULL REFERENCES publicaciones(id) ON DELETE CASCADE,
    coleccion_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(usuario_id, post_id)
);

CREATE TABLE IF NOT EXISTS colecciones (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    privada BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_posts_guardados_usuario_id ON posts_guardados(usuario_id);
CREATE INDEX IF NOT EXISTS idx_posts_guardados_post_id ON posts_guardados(post_id);
CREATE INDEX IF NOT EXISTS idx_colecciones_usuario_id ON colecciones(usuario_id);

-- ============================================================
-- 4. MESSAGING SYSTEM
-- ============================================================

-- 4.1 Conversations & Messages
CREATE TABLE IF NOT EXISTS conversaciones (
    id SERIAL PRIMARY KEY,
    usuario1_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    usuario2_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_conversation UNIQUE (usuario1_id, usuario2_id)
);

CREATE TABLE IF NOT EXISTS mensajes (
    id SERIAL PRIMARY KEY,
    conversacion_id INTEGER NOT NULL REFERENCES conversaciones(id) ON DELETE CASCADE,
    remitente_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    contenido TEXT NOT NULL,
    leido BOOLEAN DEFAULT FALSE,
    fecha_envio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_mensajes_conversacion_id ON mensajes(conversacion_id);
CREATE INDEX IF NOT EXISTS idx_mensajes_remitente_id ON mensajes(remitente_id);
CREATE INDEX IF NOT EXISTS idx_mensajes_fecha_envio ON mensajes(fecha_envio DESC);
CREATE INDEX IF NOT EXISTS idx_conversaciones_usuario1_id ON conversaciones(usuario1_id);
CREATE INDEX IF NOT EXISTS idx_conversaciones_usuario2_id ON conversaciones(usuario2_id);

-- 4.2 Trigger: Update conversation timestamp on new message
CREATE OR REPLACE FUNCTION update_conversaciones_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE conversaciones SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.conversacion_id;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER IF NOT EXISTS trigger_update_conversaciones_updated_at
    AFTER INSERT ON mensajes
    FOR EACH ROW
    EXECUTE FUNCTION update_conversaciones_updated_at();

-- ============================================================
-- 5. EVENTS & SURVEYS
-- ============================================================

-- 5.1 Events
CREATE TABLE IF NOT EXISTS eventos (
    id SERIAL PRIMARY KEY,
    comunidad_id INTEGER REFERENCES comunidades(id) ON DELETE CASCADE,
    usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    titulo VARCHAR(200) NOT NULL,
    descripcion TEXT,
    fecha_evento TIMESTAMP NOT NULL,
    ubicacion VARCHAR(200),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS evento_rsvp (
    id SERIAL PRIMARY KEY,
    evento_id INTEGER NOT NULL REFERENCES eventos(id) ON DELETE CASCADE,
    usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    estado VARCHAR(20) DEFAULT 'pendiente',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(evento_id, usuario_id)
);

CREATE INDEX IF NOT EXISTS idx_eventos_comunidad_id ON eventos(comunidad_id);
CREATE INDEX IF NOT EXISTS idx_eventos_usuario_id ON eventos(usuario_id);
CREATE INDEX IF NOT EXISTS idx_eventos_fecha_evento ON eventos(fecha_evento);
CREATE INDEX IF NOT EXISTS idx_evento_rsvp_evento_id ON evento_rsvp(evento_id);
CREATE INDEX IF NOT EXISTS idx_evento_rsvp_usuario_id ON evento_rsvp(usuario_id);

-- 5.2 Surveys & Polls
CREATE TABLE IF NOT EXISTS encuestas (
    id SERIAL PRIMARY KEY,
    publicacion_id INTEGER NOT NULL REFERENCES publicaciones(id) ON DELETE CASCADE,
    pregunta TEXT NOT NULL,
    expiracion TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS encuesta_opciones (
    id SERIAL PRIMARY KEY,
    encuesta_id INTEGER NOT NULL REFERENCES encuestas(id) ON DELETE CASCADE,
    opcion TEXT NOT NULL,
    orden INTEGER DEFAULT 0
);

CREATE TABLE IF NOT EXISTS encuesta_votos (
    id SERIAL PRIMARY KEY,
    encuesta_id INTEGER NOT NULL REFERENCES encuestas(id) ON DELETE CASCADE,
    opcion_id INTEGER NOT NULL REFERENCES encuesta_opciones(id) ON DELETE CASCADE,
    usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(encuesta_id, usuario_id)
);

CREATE INDEX IF NOT EXISTS idx_encuestas_publicacion_id ON encuestas(publicacion_id);
CREATE INDEX IF NOT EXISTS idx_encuesta_opciones_encuesta_id ON encuesta_opciones(encuesta_id);
CREATE INDEX IF NOT EXISTS idx_encuesta_votos_encuesta_id ON encuesta_votos(encuesta_id);
CREATE INDEX IF NOT EXISTS idx_encuesta_votos_usuario_id ON encuesta_votos(usuario_id);

-- ============================================================
-- 6. CORE INDEXING FOR PERFORMANCE
-- ============================================================

-- Community performance
CREATE INDEX IF NOT EXISTS idx_comunidades_creador ON comunidades(usuario_creador_id);
CREATE INDEX IF NOT EXISTS idx_publicaciones_fecha ON publicaciones(fecha);
CREATE INDEX IF NOT EXISTS idx_publicaciones_comunidad ON publicaciones(comunidad_id);
CREATE INDEX IF NOT EXISTS idx_miembros_comunidad_usuario ON miembros_comunidad(usuario_id);
CREATE INDEX IF NOT EXISTS idx_miembros_comunidad_comunidad ON miembros_comunidad(comunidad_id);

-- ============================================================
-- 7. TRIGGERS FOR AUTOMATIC UPDATES
-- ============================================================

-- Update usuarios.updated_at on profile changes
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER IF NOT EXISTS update_usuarios_updated_at 
    BEFORE UPDATE ON usuarios 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- INITIALIZATION COMPLETE
-- ============================================================

SELECT 'DATABASE SCHEMA SUCCESSFULLY INITIALIZED!' as status;
SELECT COUNT(*) as table_count FROM information_schema.tables WHERE table_schema = 'public';
