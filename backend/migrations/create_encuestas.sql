-- Crear tabla de encuestas
CREATE TABLE IF NOT EXISTS encuestas (
    id SERIAL PRIMARY KEY,
    publicacion_id INTEGER NOT NULL REFERENCES publicaciones(id) ON DELETE CASCADE,
    pregunta TEXT NOT NULL,
    expiracion TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Crear tabla de opciones de encuesta
CREATE TABLE IF NOT EXISTS encuesta_opciones (
    id SERIAL PRIMARY KEY,
    encuesta_id INTEGER NOT NULL REFERENCES encuestas(id) ON DELETE CASCADE,
    opcion TEXT NOT NULL,
    orden INTEGER DEFAULT 0
);

-- Crear tabla de votos de encuesta
CREATE TABLE IF NOT EXISTS encuesta_votos (
    id SERIAL PRIMARY KEY,
    encuesta_id INTEGER NOT NULL REFERENCES encuestas(id) ON DELETE CASCADE,
    opcion_id INTEGER NOT NULL REFERENCES encuesta_opciones(id) ON DELETE CASCADE,
    usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(encuesta_id, usuario_id)
);

-- Índices para mejorar el rendimiento
CREATE INDEX IF NOT EXISTS idx_encuestas_publicacion_id ON encuestas(publicacion_id);
CREATE INDEX IF NOT EXISTS idx_encuesta_opciones_encuesta_id ON encuesta_opciones(encuesta_id);
CREATE INDEX IF NOT EXISTS idx_encuesta_votos_encuesta_id ON encuesta_votos(encuesta_id);
CREATE INDEX IF NOT EXISTS idx_encuesta_votos_usuario_id ON encuesta_votos(usuario_id);
