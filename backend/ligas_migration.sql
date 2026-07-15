-- Ligas de Conocimiento - Database Schema Migration
-- Para ejecutar: psql $DATABASE_URL < backend/ligas_migration.sql

-- ============================================
-- TABLA: ligas
-- Descripción: Ligas de competencia entre usuarios
-- ============================================
CREATE TABLE IF NOT EXISTS ligas (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(255) NOT NULL UNIQUE,
  descripcion TEXT,
  comunidad_id INTEGER,
  tipo VARCHAR(50) DEFAULT 'general',
  estado VARCHAR(50) DEFAULT 'activa',
  fecha_inicio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  fecha_fin TIMESTAMP,
  premios_disponibles BOOLEAN DEFAULT true,
  premio_descripcion TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (comunidad_id) REFERENCES comunidades(id) ON DELETE SET NULL
);

-- ============================================
-- TABLA: duelos
-- Descripción: Batallas 1v1 entre usuarios
-- ============================================
CREATE TABLE IF NOT EXISTS duelos (
  id SERIAL PRIMARY KEY,
  liga_id INTEGER NOT NULL,
  usuario1_id INTEGER NOT NULL,
  usuario2_id INTEGER NOT NULL,
  tema VARCHAR(255),
  estado VARCHAR(50) DEFAULT 'pendiente',
  puntos_usuario1 INTEGER DEFAULT 0,
  puntos_usuario2 INTEGER DEFAULT 0,
  ganador_id INTEGER,
  fecha_inicio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  fecha_fin TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (liga_id) REFERENCES ligas(id) ON DELETE CASCADE,
  FOREIGN KEY (usuario1_id) REFERENCES usuarios(id) ON DELETE CASCADE,
  FOREIGN KEY (usuario2_id) REFERENCES usuarios(id) ON DELETE CASCADE,
  FOREIGN KEY (ganador_id) REFERENCES usuarios(id) ON DELETE SET NULL
);

-- ============================================
-- TABLA: duelo_preguntas
-- Descripción: Preguntas de cada duelo (max 5 preguntas)
-- ============================================
CREATE TABLE IF NOT EXISTS duelo_preguntas (
  id SERIAL PRIMARY KEY,
  duelo_id INTEGER NOT NULL,
  ronda INTEGER NOT NULL,
  pregunta TEXT NOT NULL,
  opciones JSONB NOT NULL, -- Array JSON: [{"id": 1, "texto": "opcion"}, ...]
  respuesta_correcta INTEGER NOT NULL,
  dificultad VARCHAR(50) DEFAULT 'media',
  tiempo_limite INTEGER DEFAULT 30,
  tema_material VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (duelo_id) REFERENCES duelos(id) ON DELETE CASCADE
);

-- ============================================
-- TABLA: duelo_respuestas
-- Descripción: Respuestas de cada usuario por pregunta
-- ============================================
CREATE TABLE IF NOT EXISTS duelo_respuestas (
  id SERIAL PRIMARY KEY,
  duelo_pregunta_id INTEGER NOT NULL,
  usuario_id INTEGER NOT NULL,
  respuesta_seleccionada INTEGER,
  es_correcta BOOLEAN DEFAULT false,
  tiempo_respuesta INTEGER, -- segundos
  puntos_obtenidos INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (duelo_pregunta_id) REFERENCES duelo_preguntas(id) ON DELETE CASCADE,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);

-- ============================================
-- TABLA: ranking_ligas
-- Descripción: Puntuación y posición de usuarios por liga
-- ============================================
CREATE TABLE IF NOT EXISTS ranking_ligas (
  id SERIAL PRIMARY KEY,
  usuario_id INTEGER NOT NULL,
  liga_id INTEGER NOT NULL,
  puntos_totales INTEGER DEFAULT 0,
  duelos_jugados INTEGER DEFAULT 0,
  duelos_ganados INTEGER DEFAULT 0,
  posicion INTEGER,
  racha_actual INTEGER DEFAULT 0,
  mejor_racha INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(usuario_id, liga_id),
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
  FOREIGN KEY (liga_id) REFERENCES ligas(id) ON DELETE CASCADE
);

-- ============================================
-- TABLA: insignias
-- Descripción: Badges que se pueden obtener
-- ============================================
CREATE TABLE IF NOT EXISTS insignias (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(255) NOT NULL UNIQUE,
  descripcion TEXT,
  icono VARCHAR(255),
  tipo VARCHAR(50), -- 'victoria', 'racha', 'milestone', 'special'
  requisito_descripcion TEXT,
  puntos_bonus INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLA: usuario_insignias
-- Descripción: Insignias obtenidas por usuarios
-- ============================================
CREATE TABLE IF NOT EXISTS usuario_insignias (
  id SERIAL PRIMARY KEY,
  usuario_id INTEGER NOT NULL,
  insignia_id INTEGER NOT NULL,
  fecha_obtenida TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(usuario_id, insignia_id),
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
  FOREIGN KEY (insignia_id) REFERENCES insignias(id) ON DELETE CASCADE
);

-- ============================================
-- TABLA: desafios_colectivos
-- Descripción: Desafíos comunitarios para grupos
-- ============================================
CREATE TABLE IF NOT EXISTS desafios_colectivos (
  id SERIAL PRIMARY KEY,
  liga_id INTEGER NOT NULL,
  titulo VARCHAR(255) NOT NULL,
  descripcion TEXT,
  objetivo_preguntas INTEGER,
  estado VARCHAR(50) DEFAULT 'activo',
  fecha_inicio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  fecha_fin TIMESTAMP,
  premio_descripcion TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (liga_id) REFERENCES ligas(id) ON DELETE CASCADE
);

-- ============================================
-- TABLA: desafio_participantes
-- Descripción: Participación en desafíos colectivos
-- ============================================
CREATE TABLE IF NOT EXISTS desafio_participantes (
  id SERIAL PRIMARY KEY,
  desafio_id INTEGER NOT NULL,
  usuario_id INTEGER NOT NULL,
  preguntas_respondidas INTEGER DEFAULT 0,
  preguntas_correctas INTEGER DEFAULT 0,
  puntos_contribuidos INTEGER DEFAULT 0,
  posicion_equipo INTEGER,
  fecha_inicio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(desafio_id, usuario_id),
  FOREIGN KEY (desafio_id) REFERENCES desafios_colectivos(id) ON DELETE CASCADE,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);

-- ============================================
-- VISTA: ranking_general
-- Descripción: Ranking global de todos los usuarios
-- ============================================
CREATE OR REPLACE VIEW ranking_general AS
SELECT 
  rl.usuario_id,
  u.nombre,
  u.foto_perfil,
  ROW_NUMBER() OVER (ORDER BY rl.puntos_totales DESC) as posicion,
  rl.puntos_totales,
  rl.duelos_jugados,
  rl.duelos_ganados,
  CASE 
    WHEN rl.duelos_jugados > 0 
    THEN ROUND((rl.duelos_ganados::decimal / rl.duelos_jugados) * 100, 2)
    ELSE 0 
  END as tasa_victoria,
  (
    SELECT array_agg(i.nombre) 
    FROM usuario_insignias ui
    JOIN insignias i ON ui.insignia_id = i.id
    WHERE ui.usuario_id = rl.usuario_id
    LIMIT 5
  ) as insignias
FROM ranking_ligas rl
JOIN usuarios u ON rl.usuario_id = u.id
ORDER BY rl.puntos_totales DESC;

-- ============================================
-- VISTA: ranking_por_comunidad
-- Descripción: Ranking de usuarios por comunidad
-- ============================================
CREATE OR REPLACE VIEW ranking_por_comunidad AS
SELECT 
  rl.usuario_id,
  u.nombre,
  u.foto_perfil,
  l.comunidad_id,
  l.id as liga_id,
  l.nombre as liga_nombre,
  ROW_NUMBER() OVER (PARTITION BY l.comunidad_id ORDER BY rl.puntos_totales DESC) as posicion,
  rl.puntos_totales,
  rl.duelos_jugados,
  rl.duelos_ganados,
  CASE 
    WHEN rl.duelos_jugados > 0 
    THEN ROUND((rl.duelos_ganados::decimal / rl.duelos_jugados) * 100, 2)
    ELSE 0 
  END as tasa_victoria
FROM ranking_ligas rl
JOIN usuarios u ON rl.usuario_id = u.id
JOIN ligas l ON rl.liga_id = l.id
WHERE l.comunidad_id IS NOT NULL
ORDER BY l.comunidad_id, rl.puntos_totales DESC;

-- ============================================
-- ÍNDICES PARA PERFORMANCE
-- ============================================
CREATE INDEX IF NOT EXISTS idx_duelos_liga ON duelos(liga_id);
CREATE INDEX IF NOT EXISTS idx_duelos_usuarios ON duelos(usuario1_id, usuario2_id);
CREATE INDEX IF NOT EXISTS idx_duelos_estado ON duelos(estado);
CREATE INDEX IF NOT EXISTS idx_ranking_liga ON ranking_ligas(liga_id);
CREATE INDEX IF NOT EXISTS idx_ranking_usuario ON ranking_ligas(usuario_id);
CREATE INDEX IF NOT EXISTS idx_usuario_insignias ON usuario_insignias(usuario_id);
CREATE INDEX IF NOT EXISTS idx_duelo_respuestas_usuario ON duelo_respuestas(usuario_id);
CREATE INDEX IF NOT EXISTS idx_desafio_participantes ON desafio_participantes(desafio_id);

-- ============================================
-- INSERTS INICIALES
-- ============================================
-- Insignias predefinidas
INSERT INTO insignias (nombre, descripcion, tipo, puntos_bonus) VALUES
('Primer Duelo', 'Completaste tu primer duelo', 'special', 10),
('Racha de 3', 'Ganaste 3 duelos consecutivos', 'racha', 25),
('Racha de 5', 'Ganaste 5 duelos consecutivos', 'racha', 50),
('Campeón de Liga', 'Alcanzaste el #1 en una liga', 'milestone', 100),
('Experto Conocimiento', 'Ganaste 50 duelos', 'victoria', 50),
('Maestro del Saber', 'Ganaste 100 duelos', 'victoria', 100)
ON CONFLICT (nombre) DO NOTHING;

-- Liga General (predeterminada)
INSERT INTO ligas (nombre, descripcion, tipo, estado) VALUES
('Liga General', 'Competencia global entre todos los usuarios', 'general', 'activa')
ON CONFLICT (nombre) DO NOTHING;

COMMIT;
