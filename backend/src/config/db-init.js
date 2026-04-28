const pool = require('./db');
const fs = require('fs');
const path = require('path');

const initDatabase = async () => {
  try {
    console.log('🔧 Verificando base de datos...');

    // Probar conexión simple
    await pool.query('SELECT NOW()');
    console.log('✅ Conexión a BD exitosa');

    // Ejecutar migraciones
    console.log('🔄 Ejecutando migraciones de esquema...');
    
    // Migración 1: Agregar columna usuario_creador_id si no existe
    try {
      await pool.query(`
        ALTER TABLE comunidades
        ADD COLUMN IF NOT EXISTS usuario_creador_id INTEGER REFERENCES usuarios(id) ON DELETE SET NULL;
      `);
      console.log('✅ Columna usuario_creador_id verificada');
    } catch (err) {
      console.log('ℹ️ Columna usuario_creador_id:', err.message.substring(0, 100));
    }

    // Migración 2: Agregar columna fecha a publicaciones
    try {
      await pool.query(`
        ALTER TABLE publicaciones
        ADD COLUMN IF NOT EXISTS fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
      `);
      console.log('✅ Columna fecha en publicaciones verificada');
    } catch (err) {
      console.log('ℹ️ Columna fecha:', err.message.substring(0, 100));
    }

    // Migración 3: Verificar que comentarios tiene fecha
    try {
      await pool.query(`
        ALTER TABLE comentarios
        ADD COLUMN IF NOT EXISTS fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
      `);
      console.log('✅ Columna fecha en comentarios verificada');
    } catch (err) {
      console.log('ℹ️ Columna fecha comentarios:', err.message.substring(0, 100));
    }

    // Migración 4: Verificar que historias tiene las columnas necesarias
    try {
      await pool.query(`
        ALTER TABLE historias
        ADD COLUMN IF NOT EXISTS imagen_url TEXT;
      `);
      console.log('✅ Columnas en historias verificadas');
    } catch (err) {
      console.log('ℹ️ Columnas historias:', err.message.substring(0, 100));
    }

    // Migración 5: Agregar columna imagen_url a publicaciones
    try {
      await pool.query(`
        ALTER TABLE publicaciones
        ADD COLUMN IF NOT EXISTS imagen_url TEXT;
      `);
      console.log('✅ Columna imagen_url en publicaciones verificada');
    } catch (err) {
      console.log('ℹ️ Columna imagen_url:', err.message.substring(0, 100));
    }

    // Crear índices de performance
    try {
      await pool.query(`
        CREATE INDEX IF NOT EXISTS idx_comunidades_creador ON comunidades(usuario_creador_id);
        CREATE INDEX IF NOT EXISTS idx_publicaciones_fecha ON publicaciones(fecha);
        CREATE INDEX IF NOT EXISTS idx_publicaciones_comunidad ON publicaciones(comunidad_id);
        CREATE INDEX IF NOT EXISTS idx_miembros_comunidad_usuario ON miembros_comunidad(usuario_id);
        CREATE INDEX IF NOT EXISTS idx_miembros_comunidad_comunidad ON miembros_comunidad(comunidad_id);
      `);
      console.log('✅ Índices creados/verificados');
    } catch (err) {
      console.log('ℹ️ Índices:', err.message.substring(0, 100));
    }

    // Migración 6: Crear tablas de Modo Estudio + IA
    try {
      // Tabla study_courses
      await pool.query(`
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
      `);
      console.log('✅ Tabla study_courses creada/verificada');
    } catch (err) {
      console.log('ℹ️ Tabla study_courses:', err.message.substring(0, 100));
    }

    try {
      // Tabla study_materials
      await pool.query(`
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
      `);
      console.log('✅ Tabla study_materials creada/verificada');
    } catch (err) {
      console.log('ℹ️ Tabla study_materials:', err.message.substring(0, 100));
    }

    try {
      // Tabla ai_responses
      await pool.query(`
        CREATE TABLE IF NOT EXISTS ai_responses (
          id VARCHAR(36) PRIMARY KEY,
          user_id INTEGER REFERENCES usuarios(id) ON DELETE CASCADE,
          material_id VARCHAR(36) REFERENCES study_materials(id) ON DELETE CASCADE,
          course_id VARCHAR(36) REFERENCES study_courses(id) ON DELETE CASCADE,
          type VARCHAR(50) NOT NULL,
          content TEXT NOT NULL,
          prompt TEXT,
          from_cache BOOLEAN DEFAULT FALSE,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
      `);
      console.log('✅ Tabla ai_responses creada/verificada');
    } catch (err) {
      console.log('ℹ️ Tabla ai_responses:', err.message.substring(0, 100));
    }

    try {
      // Tabla study_questions
      await pool.query(`
        CREATE TABLE IF NOT EXISTS study_questions (
          id VARCHAR(36) PRIMARY KEY,
          course_id VARCHAR(36) REFERENCES study_courses(id) ON DELETE CASCADE,
          user_id INTEGER REFERENCES usuarios(id) ON DELETE CASCADE,
          question_text TEXT NOT NULL,
          options JSONB NOT NULL,
          correct_option VARCHAR(10) NOT NULL,
          explanation TEXT,
          difficulty_level VARCHAR(20) DEFAULT 'medium',
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
      `);
      console.log('✅ Tabla study_questions creada/verificada');
    } catch (err) {
      console.log('ℹ️ Tabla study_questions:', err.message.substring(0, 100));
    }

    try {
      // Tabla quiz_attempts
      await pool.query(`
        CREATE TABLE IF NOT EXISTS quiz_attempts (
          id VARCHAR(36) PRIMARY KEY,
          user_id INTEGER REFERENCES usuarios(id) ON DELETE CASCADE,
          course_id VARCHAR(36) REFERENCES study_courses(id) ON DELETE CASCADE,
          answers JSONB NOT NULL,
          time_seconds INTEGER,
          score INTEGER,
          total_questions INTEGER,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
      `);
      console.log('✅ Tabla quiz_attempts creada/verificada');
    } catch (err) {
      console.log('ℹ️ Tabla quiz_attempts:', err.message.substring(0, 100));
    }

    try {
      // Crear índices de study
      await pool.query(`
        CREATE INDEX IF NOT EXISTS idx_study_courses_user ON study_courses(user_id);
        CREATE INDEX IF NOT EXISTS idx_study_courses_code ON study_courses(course_code);
        CREATE INDEX IF NOT EXISTS idx_study_materials_course ON study_materials(course_id);
        CREATE INDEX IF NOT EXISTS idx_study_materials_user ON study_materials(user_id);
        CREATE INDEX IF NOT EXISTS idx_ai_responses_user ON ai_responses(user_id);
        CREATE INDEX IF NOT EXISTS idx_ai_responses_material ON ai_responses(material_id);
        CREATE INDEX IF NOT EXISTS idx_ai_responses_course ON ai_responses(course_id);
        CREATE INDEX IF NOT EXISTS idx_ai_responses_type ON ai_responses(type);
        CREATE INDEX IF NOT EXISTS idx_study_questions_course ON study_questions(course_id);
        CREATE INDEX IF NOT EXISTS idx_study_questions_user ON study_questions(user_id);
        CREATE INDEX IF NOT EXISTS idx_quiz_attempts_user ON quiz_attempts(user_id);
        CREATE INDEX IF NOT EXISTS idx_quiz_attempts_course ON quiz_attempts(course_id);
      `);
      console.log('✅ Índices de study creados/verificados');
    } catch (err) {
      console.log('ℹ️ Índices de study:', err.message.substring(0, 100));
    }

    // NO insertar usuarios de prueba - base de datos limpia para datos reales
    console.log('📊 Base de datos lista para usuarios reales');

    console.log('\n✅ ✅ ✅ BASE DE DATOS VERIFICADA CORRECTAMENTE ✅ ✅ ✅\n');
    return true;
  } catch (error) {
    console.error('\n❌ Error al verificar la base de datos:', error.message);
    console.error('Detalles:', error);
    return false;
  }
};

module.exports = initDatabase;
