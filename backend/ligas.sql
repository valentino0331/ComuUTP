-- ========================================
-- SISTEMA DE LIGAS Y BATALLAS DE CONOCIMIENTO
-- ========================================

-- 1. TABLA LIGAS (Competencias generales o por comunidad)
CREATE TABLE IF NOT EXISTS ligas (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(255) NOT NULL,
  descripcion TEXT,
  comunidad_id INTEGER REFERENCES comunidades(id) ON DELETE CASCADE,
  tipo VARCHAR(50) NOT NULL DEFAULT 'general', -- 'general', 'por_comunidad', 'tematica'
  estado VARCHAR(50) NOT NULL DEFAULT 'activa', -- 'activa', 'pausada', 'finalizada'
  fecha_inicio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  fecha_fin TIMESTAMP,
  icono_url VARCHAR(500),
  premio_descripcion TEXT,
  creador_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE SET NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. TABLA DUELOS (Batallas entre dos usuarios)
CREATE TABLE IF NOT EXISTS duelos (
  id SERIAL PRIMARY KEY,
  liga_id INTEGER NOT NULL REFERENCES ligas(id) ON DELETE CASCADE,
  usuario1_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  usuario2_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  tema VARCHAR(500), -- Tema de la batalla (ej: "Cálculo Integral")
  material_id INTEGER REFERENCES materiales(id) ON DELETE SET NULL,
  estado VARCHAR(50) NOT NULL DEFAULT 'pendiente', -- 'pendiente', 'en_progreso', 'finalizado', 'cancelado'
  ganador_id INTEGER REFERENCES usuarios(id) ON DELETE SET NULL,
  puntos_usuario1 INTEGER DEFAULT 0,
  puntos_usuario2 INTEGER DEFAULT 0,
  rondas_totales INTEGER DEFAULT 5,
  ronda_actual INTEGER DEFAULT 0,
  fecha_inicio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  fecha_fin TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. TABLA PREGUNTAS DEL DUELO (Preguntas generadas por IA para cada ronda)
CREATE TABLE IF NOT EXISTS duelo_preguntas (
  id SERIAL PRIMARY KEY,
  duelo_id INTEGER NOT NULL REFERENCES duelos(id) ON DELETE CASCADE,
  ronda INTEGER NOT NULL,
  pregunta TEXT NOT NULL,
  opciones JSON, -- Array de opciones: [{"id": 0, "texto": "..."}, ...]
  respuesta_correcta INTEGER, -- ID de la opción correcta
  dificultad VARCHAR(50) DEFAULT 'media', -- 'facil', 'media', 'dificil'
  tiempo_limite INTEGER DEFAULT 30, -- segundos
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. TABLA RESPUESTAS DE USUARIOS EN DUELOS
CREATE TABLE IF NOT EXISTS duelo_respuestas (
  id SERIAL PRIMARY KEY,
  duelo_pregunta_id INTEGER NOT NULL REFERENCES duelo_preguntas(id) ON DELETE CASCADE,
  usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  respuesta_seleccionada INTEGER,
  es_correcta BOOLEAN DEFAULT FALSE,
  tiempo_respuesta INTEGER, -- segundos
  puntos_obtenidos INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. TABLA RANKING POR LIGA (Puntos y posición de cada usuario)
CREATE TABLE IF NOT EXISTS ranking_ligas (
  id SERIAL PRIMARY KEY,
  liga_id INTEGER NOT NULL REFERENCES ligas(id) ON DELETE CASCADE,
  usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  puntos_totales INTEGER DEFAULT 0,
  duelos_jugados INTEGER DEFAULT 0,
  duelos_ganados INTEGER DEFAULT 0,
  tasa_victoria DECIMAL(5, 2) DEFAULT 0,
  posicion INTEGER,
  insignias JSON, -- Array de insignias obtenidas
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(liga_id, usuario_id)
);

-- 6. TABLA INSIGNIAS/LOGROS
CREATE TABLE IF NOT EXISTS insignias (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(255) NOT NULL,
  descripcion TEXT,
  icono_url VARCHAR(500),
  tipo VARCHAR(50), -- 'victoria', 'racha', 'experto', 'participacion'
  condicion_descripcion TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 7. TABLA INSIGNIAS GANADAS POR USUARIOS
CREATE TABLE IF NOT EXISTS usuario_insignias (
  id SERIAL PRIMARY KEY,
  usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  insignia_id INTEGER NOT NULL REFERENCES insignias(id) ON DELETE CASCADE,
  fecha_obtenida TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(usuario_id, insignia_id)
);

-- 8. TABLA DE DESAFÍOS COLECTIVOS (Retos semanales)
CREATE TABLE IF NOT EXISTS desafios_colectivos (
  id SERIAL PRIMARY KEY,
  liga_id INTEGER NOT NULL REFERENCES ligas(id) ON DELETE CASCADE,
  titulo VARCHAR(255) NOT NULL,
  descripcion TEXT,
  tema VARCHAR(500),
  material_id INTEGER REFERENCES materiales(id),
  estado VARCHAR(50) DEFAULT 'activo', -- 'activo', 'finalizado'
  fecha_inicio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  fecha_fin TIMESTAMP NOT NULL,
  puntos_participacion INTEGER DEFAULT 10,
  puntos_completacion INTEGER DEFAULT 50,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 9. TABLA PARTICIPACIÓN EN DESAFÍOS
CREATE TABLE IF NOT EXISTS desafio_participantes (
  id SERIAL PRIMARY KEY,
  desafio_id INTEGER NOT NULL REFERENCES desafios_colectivos(id) ON DELETE CASCADE,
  usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  completo BOOLEAN DEFAULT FALSE,
  puntos_obtenidos INTEGER DEFAULT 0,
  fecha_participacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(desafio_id, usuario_id)
);

-- INDICES PARA RENDIMIENTO
CREATE INDEX IF NOT EXISTS idx_duelos_liga ON duelos(liga_id);
CREATE INDEX IF NOT EXISTS idx_duelos_usuario1 ON duelos(usuario1_id);
CREATE INDEX IF NOT EXISTS idx_duelos_usuario2 ON duelos(usuario2_id);
CREATE INDEX IF NOT EXISTS idx_ranking_liga ON ranking_ligas(liga_id);
CREATE INDEX IF NOT EXISTS idx_ranking_usuario ON ranking_ligas(usuario_id);
CREATE INDEX IF NOT EXISTS idx_desafio_participantes ON desafio_participantes(desafio_id);

-- VISTA: RANKING GENERAL (Top 10 de todas las ligas)
CREATE OR REPLACE VIEW ranking_general AS
SELECT 
  rl.usuario_id,
  u.nombre,
  u.foto_perfil,
  SUM(rl.puntos_totales) as puntos_totales,
  SUM(rl.duelos_jugados) as duelos_jugados,
  SUM(rl.duelos_ganados) as duelos_ganados,
  ROUND(AVG(rl.tasa_victoria)::NUMERIC, 2) as tasa_victoria_promedio
FROM ranking_ligas rl
JOIN usuarios u ON rl.usuario_id = u.id
GROUP BY rl.usuario_id, u.nombre, u.foto_perfil
ORDER BY puntos_totales DESC
LIMIT 100;

-- VISTA: RANKING POR COMUNIDAD
CREATE OR REPLACE VIEW ranking_por_comunidad AS
SELECT 
  l.comunidad_id,
  c.nombre as comunidad_nombre,
  rl.usuario_id,
  u.nombre,
  u.foto_perfil,
  rl.puntos_totales,
  rl.duelos_jugados,
  rl.duelos_ganados,
  rl.tasa_victoria,
  ROW_NUMBER() OVER (PARTITION BY l.comunidad_id ORDER BY rl.puntos_totales DESC) as posicion
FROM ranking_ligas rl
JOIN ligas l ON rl.liga_id = l.id
JOIN usuarios u ON rl.usuario_id = u.id
JOIN comunidades c ON l.comunidad_id = c.id
WHERE l.comunidad_id IS NOT NULL;
