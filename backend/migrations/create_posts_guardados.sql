-- Crear tabla de posts guardados
CREATE TABLE IF NOT EXISTS posts_guardados (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    post_id INTEGER NOT NULL REFERENCES publicaciones(id) ON DELETE CASCADE,
    coleccion_id INTEGER, -- Opcional: para organizar en colecciones
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(usuario_id, post_id)
);

-- Crear tabla de colecciones
CREATE TABLE IF NOT EXISTS colecciones (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    privada BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índices para mejorar el rendimiento
CREATE INDEX IF NOT EXISTS idx_posts_guardados_usuario_id ON posts_guardados(usuario_id);
CREATE INDEX IF NOT EXISTS idx_posts_guardados_post_id ON posts_guardados(post_id);
CREATE INDEX IF NOT EXISTS idx_colecciones_usuario_id ON colecciones(usuario_id);
