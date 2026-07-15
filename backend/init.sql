que las personas usaurios normales solo puedan 1 comiunidada para evitar el exceso de comunidades, si quieren mas tiene que acceden al plan premiun 


vip=10 soles 

-- ============================================
-- SCRIPT INICIALIZADOR - UTP Comunidades
-- ============================================

-- Crear tabla USUARIOS (con Firebase Auth support)
CREATE TABLE IF NOT EXISTS usuarios (
  id SERIAL PRIMARY KEY,
  firebase_uid VARCHAR(128) UNIQUE, -- UID de Firebase Auth
  email VARCHAR(120) UNIQUE NOT NULL,
  password VARCHAR(500), -- Opcional, solo para compatibilidad legacy
  nombre VARCHAR(120) NOT NULL,
  apellido VARCHAR(120),
  carrera VARCHAR(100),
  ciclo INTEGER,
  email_verificado BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Crear tabla COMUNIDADES
CREATE TABLE IF NOT EXISTS comunidades (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(120) NOT NULL,
  descripcion TEXT,
  usuario_creador_id INTEGER REFERENCES usuarios(id) ON DELETE SET NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Crear tabla PUBLICACIONES
CREATE TABLE IF NOT EXISTS publicaciones (
  id SERIAL PRIMARY KEY,
  usuario_id INTEGER REFERENCES usuarios(id) ON DELETE CASCADE,
  comunidad_id INTEGER REFERENCES comunidades(id) ON DELETE CASCADE,
  contenido TEXT NOT NULL,
  fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Crear tabla COMENTARIOS
CREATE TABLE IF NOT EXISTS comentarios (
  id SERIAL PRIMARY KEY,
  usuario_id INTEGER REFERENCES usuarios(id) ON DELETE CASCADE,
  publicacion_id INTEGER REFERENCES publicaciones(id) ON DELETE CASCADE,
  contenido TEXT NOT NULL,
  fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Crear tabla LIKES
CREATE TABLE IF NOT EXISTS likes (
  id SERIAL PRIMARY KEY,
  usuario_id INTEGER REFERENCES usuarios(id) ON DELETE CASCADE,
  publicacion_id INTEGER REFERENCES publicaciones(id) ON DELETE CASCADE,
  fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(usuario_id, publicacion_id)
);

-- Crear tabla NOTIFICACIONES
CREATE TABLE IF NOT EXISTS notificaciones (
  id SERIAL PRIMARY KEY,
  usuario_id INTEGER REFERENCES usuarios(id) ON DELETE CASCADE,
  tipo VARCHAR(50) NOT NULL,
  contenido TEXT,
  leida BOOLEAN DEFAULT FALSE,
  fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Crear tabla MIEMBROS_COMUNIDAD
CREATE TABLE IF NOT EXISTS miembros_comunidad (
  id SERIAL PRIMARY KEY,
  usuario_id INTEGER REFERENCES usuarios(id) ON DELETE CASCADE,
  comunidad_id INTEGER REFERENCES comunidades(id) ON DELETE CASCADE,
  fecha_union TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(usuario_id, comunidad_id)
);

-- Crear tabla REPORTES
CREATE TABLE IF NOT EXISTS reportes (
  id SERIAL PRIMARY KEY,
  usuario_id INTEGER REFERENCES usuarios(id) ON DELETE SET NULL,
  contenido_tipo VARCHAR(50) NOT NULL,
  contenido_id INTEGER,
  razon TEXT,
  estado VARCHAR(20) DEFAULT 'pendiente',
  fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Crear tabla LOGS_SISTEMA
CREATE TABLE IF NOT EXISTS logs_sistema (
  id SERIAL PRIMARY KEY,
  usuario_id INTEGER REFERENCES usuarios(id) ON DELETE SET NULL,
  accion VARCHAR(100) NOT NULL,
  descripcion TEXT,
  fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Crear índices para mejor performance
CREATE INDEX IF NOT EXISTS idx_usuarios_email ON usuarios(email);
CREATE INDEX IF NOT EXISTS idx_publicaciones_comunidad ON publicaciones(comunidad_id);
CREATE INDEX IF NOT EXISTS idx_publicaciones_usuario ON publicaciones(usuario_id);
CREATE INDEX IF NOT EXISTS idx_comentarios_publicacion ON comentarios(publicacion_id);
CREATE INDEX IF NOT EXISTS idx_likes_publicacion ON likes(publicacion_id);
CREATE INDEX IF NOT EXISTS idx_miembros_comunidad ON miembros_comunidad(comunidad_id);

-- Insertar datos de prueba (opcional)
INSERT INTO usuarios (email, nombre, password) VALUES 
  ('u20221234@utp.edu.pe', 'Carlos Rodríguez', '$2b$10$dXJ3SW6G7P50eS3BxZ0R2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUm'), -- password: password123
  ('u20234567@utp.edu.pe', 'Ana Martínez', '$2b$10$dXJ3SW6G7P50eS3BxZ0R2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUm'),
  ('u20245678@utp.edu.pe', 'Luis Fernández', '$2b$10$dXJ3SW6G7P50eS3BxZ0R2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUm'),
  ('u22247388@utp.edu.pe', 'María López', '$2b$10$dXJ3SW6G7P50eS3BxZ0R2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUm'),
  ('u20238901@utp.edu.pe', 'Pedro Gómez', '$2b$10$dXJ3SW6G7P50eS3BxZ0R2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUm'),
  ('u20247890@utp.edu.pe', 'Sofía Ramírez', '$2b$10$dXJ3SW6G7P50eS3BxZ0R2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUm'),
  ('u20236789@utp.edu.pe', 'Diego Torres', '$2b$10$dXJ3SW6G7P50eS3BxZ0R2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUm'),
  ('u20245612@utp.edu.pe', 'Lucía Vargas', '$2b$10$dXJ3SW6G7P50eS3BxZ0R2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUm')
ON CONFLICT (email) DO NOTHING;

INSERT INTO comunidades (nombre, descripcion, usuario_creador_id) VALUES
  ('Ing. Sistemas UTP', 'Comunidad de Ingeniería de Sistemas', 1),
  ('Fútbol UTP', 'Para los amantes del fútbol', 2),
  ('Hacks Académicos', 'Tips y trucos académicos', 3),
  ('UTP Arequipa Of.', 'Oficial de UTP Arequipa', 1)
ON CONFLICT DO NOTHING;

INSERT INTO publicaciones (usuario_id, comunidad_id, contenido) VALUES
  (1, 1, '¿Alguien sabe si abrieron la biblioteca de Piura hoy?'),
  (2, 2, 'Partida de fútbol mañana a las 5 PM en la cancha'),
  (3, 3, 'Tip: Usa la técnica Pomodoro para estudiar mejor')
ON CONFLICT DO NOTHING;

-- Verificar que todo está bien
SELECT 'Database initialized successfully!' as status;

-- Agregar campos adicionales a usuarios
ALTER TABLE usuarios 
ADD COLUMN IF NOT EXISTS foto_perfil VARCHAR(500),
ADD COLUMN IF NOT EXISTS biografia TEXT,
ADD COLUMN IF NOT EXISTS es_premium BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS premium_hasta TIMESTAMP,
ADD COLUMN IF NOT EXISTS puede_crear_comunidad BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS asistencias_verificadas INTEGER DEFAULT 0;

-- Crear tabla de ASISTENCIAS (para trackear asistencias a clases)
CREATE TABLE IF NOT EXISTS asistencias (
  id SERIAL PRIMARY KEY,
  usuario_id INTEGER REFERENCES usuarios(id) ON DELETE CASCADE,
  curso_nombre VARCHAR(120) NOT NULL,
  fecha_asistencia TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  metodo_verificacion VARCHAR(50) DEFAULT 'evidencia', -- 'evidencia' o 'premium'
  estado VARCHAR(20) DEFAULT 'pendiente', -- 'pendiente', 'aprobada', 'rechazada'
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Crear tabla de EVIDENCIAS DE ASISTENCIA (fotos/evidencias subidas)
CREATE TABLE IF NOT EXISTS evidencias_asistencia (
  id SERIAL PRIMARY KEY,
  asistencia_id INTEGER REFERENCES asistencias(id) ON DELETE CASCADE,
  usuario_id INTEGER REFERENCES usuarios(id) ON DELETE CASCADE,
  tipo_evidencia VARCHAR(50) NOT NULL, -- 'foto_clase', 'captura_aula', 'selfie_profesor', etc.
  url_evidencia VARCHAR(500) NOT NULL,
  descripcion TEXT,
  estado VARCHAR(20) DEFAULT 'pendiente', -- 'pendiente', 'aprobada', 'rechazada'
  revisado_por INTEGER REFERENCES usuarios(id) ON DELETE SET NULL,
  fecha_revision TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Crear tabla de SUSCRIPCIONES PREMIUM
CREATE TABLE IF NOT EXISTS suscripciones_premium (
  id SERIAL PRIMARY KEY,
  usuario_id INTEGER REFERENCES usuarios(id) ON DELETE CASCADE,
  monto DECIMAL(10,2) NOT NULL DEFAULT 50.00,
  metodo_pago VARCHAR(50) NOT NULL, -- 'tarjeta', 'yape', 'plin', 'transferencia'
  estado VARCHAR(20) DEFAULT 'activa', -- 'activa', 'vencida', 'cancelada'
  fecha_inicio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  fecha_fin TIMESTAMP NOT NULL,
  comprobante_pago_url VARCHAR(500),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Crear tabla de HISTORIAS (Instagram style - expiran en 24h)
CREATE TABLE IF NOT EXISTS historias (
  id SERIAL PRIMARY KEY,
  usuario_id INTEGER REFERENCES usuarios(id) ON DELETE CASCADE,
  tipo_contenido VARCHAR(20) NOT NULL DEFAULT 'imagen', -- 'imagen', 'video', 'texto'
  url_contenido VARCHAR(500),
  texto_contenido TEXT,
  color_fondo VARCHAR(20),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  expira_at TIMESTAMP NOT NULL DEFAULT (CURRENT_TIMESTAMP + INTERVAL '24 hours'),
  view_count INTEGER DEFAULT 0
);

-- Crear tabla de VISTAS DE HISTORIAS
CREATE TABLE IF NOT EXISTS historias_vistas (
  id SERIAL PRIMARY KEY,
  historia_id INTEGER REFERENCES historias(id) ON DELETE CASCADE,
  usuario_id INTEGER REFERENCES usuarios(id) ON DELETE CASCADE,
  visto_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(historia_id, usuario_id)
);

-- Crear tabla de FOLLOWERS/SEGUIDORES
CREATE TABLE IF NOT EXISTS seguidores (
  id SERIAL PRIMARY KEY,
  seguidor_id INTEGER REFERENCES usuarios(id) ON DELETE CASCADE,
  seguido_id INTEGER REFERENCES usuarios(id) ON DELETE CASCADE,
  estado VARCHAR(20) DEFAULT 'pendiente', -- 'pendiente', 'aceptado', 'rechazado'
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(seguidor_id, seguido_id)
);

-- Crear tabla de POSTS COMPARTIDOS (shares/reposts)
CREATE TABLE IF NOT EXISTS publicaciones_compartidas (
  id SERIAL PRIMARY KEY,
  usuario_id INTEGER REFERENCES usuarios(id) ON DELETE CASCADE,
  publicacion_original_id INTEGER REFERENCES publicaciones(id) ON DELETE CASCADE,
  comunidad_origen_id INTEGER REFERENCES comunidades(id) ON DELETE CASCADE,
  comentario_compartido TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Crear tabla de TOKENS DE VERIFICACIÓN DE EMAIL
CREATE TABLE IF NOT EXISTS verification_tokens (
  id SERIAL PRIMARY KEY,
  usuario_id INTEGER REFERENCES usuarios(id) ON DELETE CASCADE,
  token VARCHAR(255) UNIQUE NOT NULL,
  expira_at TIMESTAMP NOT NULL DEFAULT (CURRENT_TIMESTAMP + INTERVAL '24 hours'),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(usuario_id)
);
CREATE INDEX IF NOT EXISTS idx_verification_tokens_token ON verification_tokens(token);

-- Crear tabla de INTERESES del usuario (para el perfil)
CREATE TABLE IF NOT EXISTS intereses_usuario (
  id SERIAL PRIMARY KEY,
  usuario_id INTEGER REFERENCES usuarios(id) ON DELETE CASCADE,
  interes VARCHAR(50) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(usuario_id, interes)
);

-- Índices adicionales para las nuevas tablas
CREATE INDEX IF NOT EXISTS idx_asistencias_usuario ON asistencias(usuario_id);
CREATE INDEX IF NOT EXISTS idx_asistencias_estado ON asistencias(estado);
CREATE INDEX IF NOT EXISTS idx_evidencias_asistencia ON evidencias_asistencia(asistencia_id);
CREATE INDEX IF NOT EXISTS idx_suscripciones_usuario ON suscripciones_premium(usuario_id);
CREATE INDEX IF NOT EXISTS idx_suscripciones_estado ON suscripciones_premium(estado);
CREATE INDEX IF NOT EXISTS idx_historias_usuario ON historias(usuario_id);
CREATE INDEX IF NOT EXISTS idx_historias_expira ON historias(expira_at);
CREATE INDEX IF NOT EXISTS idx_seguidores_seguidor ON seguidores(seguidor_id);
CREATE INDEX IF NOT EXISTS idx_seguidores_seguido ON seguidores(seguido_id);
CREATE INDEX IF NOT EXISTS idx_publicaciones_compartidas_usuario ON publicaciones_compartidas(usuario_id);
CREATE INDEX IF NOT EXISTS idx_intereses_usuario ON intereses_usuario(usuario_id);

-- Función para limpiar historias expiradas automáticamente
CREATE OR REPLACE FUNCTION limpiar_historias_expiradas()
RETURNS void AS $$
BEGIN
  DELETE FROM historias WHERE expira_at < CURRENT_TIMESTAMP;
END;
$$ LANGUAGE plpgsql;

-- Función para verificar si usuario puede crear comunidad
CREATE OR REPLACE FUNCTION verificar_permiso_crear_comunidad(p_user_id INTEGER)
RETURNS BOOLEAN AS $$
DECLARE
  v_asistencias_count INTEGER;
  v_es_premium BOOLEAN;
  v_premium_activo BOOLEAN;
BEGIN
  -- Verificar asistencias aprobadas
  SELECT COUNT(*) INTO v_asistencias_count
  FROM asistencias 
  WHERE usuario_id = p_user_id AND estado = 'aprobada';
  
  -- Verificar si es premium y está activo
  SELECT es_premium, (premium_hasta > CURRENT_TIMESTAMP) 
  INTO v_es_premium, v_premium_activo
  FROM usuarios 
  WHERE id = p_user_id;
  
  -- Puede crear si tiene 8+ asistencias O tiene premium activo
  RETURN (v_asistencias_count >= 8) OR (v_es_premium AND v_premium_activo);
END;
$$ LANGUAGE plpgsql;

SELECT 'Nuevas tablas y funciones creadas exitosamente!' as status;
