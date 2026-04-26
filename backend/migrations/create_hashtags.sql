-- Crear tabla de hashtags
CREATE TABLE IF NOT EXISTS hashtags (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) UNIQUE NOT NULL,
    contador INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Crear tabla de relación post-hashtag
CREATE TABLE IF NOT EXISTS post_hashtags (
    id SERIAL PRIMARY KEY,
    post_id INTEGER NOT NULL REFERENCES publicaciones(id) ON DELETE CASCADE,
    hashtag_id INTEGER NOT NULL REFERENCES hashtags(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(post_id, hashtag_id)
);

-- Índices para mejorar el rendimiento
CREATE INDEX IF NOT EXISTS idx_hashtags_nombre ON hashtags(nombre);
CREATE INDEX IF NOT EXISTS idx_post_hashtags_post_id ON post_hashtags(post_id);
CREATE INDEX IF NOT EXISTS idx_post_hashtags_hashtag_id ON post_hashtags(hashtag_id);
