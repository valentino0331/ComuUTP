-- Crear tabla de conversaciones
CREATE TABLE IF NOT EXISTS conversaciones (
    id SERIAL PRIMARY KEY,
    usuario1_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    usuario2_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(LEAST(usuario1_id, usuario2_id), GREATEST(usuario1_id, usuario2_id))
);

-- Crear tabla de mensajes
CREATE TABLE IF NOT EXISTS mensajes (
    id SERIAL PRIMARY KEY,
    conversacion_id INTEGER NOT NULL REFERENCES conversaciones(id) ON DELETE CASCADE,
    remitente_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    contenido TEXT NOT NULL,
    leido BOOLEAN DEFAULT FALSE,
    fecha_envio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índices para mejorar el rendimiento
CREATE INDEX IF NOT EXISTS idx_mensajes_conversacion_id ON mensajes(conversacion_id);
CREATE INDEX IF NOT EXISTS idx_mensajes_remitente_id ON mensajes(remitente_id);
CREATE INDEX IF NOT EXISTS idx_mensajes_fecha_envio ON mensajes(fecha_envio DESC);
CREATE INDEX IF NOT EXISTS idx_conversaciones_usuario1_id ON conversaciones(usuario1_id);
CREATE INDEX IF NOT EXISTS idx_conversaciones_usuario2_id ON conversaciones(usuario2_id);

-- Trigger para actualizar updated_at en conversaciones
CREATE OR REPLACE FUNCTION update_conversaciones_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE conversaciones SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.conversacion_id;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER trigger_update_conversaciones_updated_at
    AFTER INSERT ON mensajes
    FOR EACH ROW
    EXECUTE FUNCTION update_conversaciones_updated_at();
