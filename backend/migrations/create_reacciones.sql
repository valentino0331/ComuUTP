-- Crear tabla de reacciones
CREATE TABLE IF NOT EXISTS reacciones (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    publicacion_id INTEGER NOT NULL REFERENCES publicaciones(id) ON DELETE CASCADE,
    tipo VARCHAR(20) NOT NULL, -- 'love', 'fire', 'laugh', 'wow', 'sad'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(usuario_id, publicacion_id)
);

-- Índices para mejorar el rendimiento
CREATE INDEX IF NOT EXISTS idx_reacciones_usuario_id ON reacciones(usuario_id);
CREATE INDEX IF NOT EXISTS idx_reacciones_publicacion_id ON reacciones(publicacion_id);
CREATE INDEX IF NOT EXISTS idx_reacciones_tipo ON reacciones(tipo);
