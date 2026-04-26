-- Crear tabla de menciones
CREATE TABLE IF NOT EXISTS menciones (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    publicacion_id INTEGER REFERENCES publicaciones(id) ON DELETE CASCADE,
    comentario_id INTEGER REFERENCES comentarios(id) ON DELETE CASCADE,
    mencionado_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    leida BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índices para mejorar el rendimiento
CREATE INDEX IF NOT EXISTS idx_menciones_usuario_id ON menciones(usuario_id);
CREATE INDEX IF NOT EXISTS idx_menciones_publicacion_id ON menciones(publicacion_id);
CREATE INDEX IF NOT EXISTS idx_menciones_comentario_id ON menciones(comentario_id);
CREATE INDEX IF NOT EXISTS idx_menciones_mencionado_id ON menciones(mencionado_id);
