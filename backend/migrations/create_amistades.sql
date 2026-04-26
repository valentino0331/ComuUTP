-- Crear tabla de amistades
CREATE TABLE IF NOT EXISTS amistades (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    amigo_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    estado VARCHAR(20) DEFAULT 'pendiente', -- 'pendiente', 'aceptada', 'rechazada'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(usuario_id, amigo_id)
);

-- Índices para mejorar el rendimiento
CREATE INDEX IF NOT EXISTS idx_amistades_usuario_id ON amistades(usuario_id);
CREATE INDEX IF NOT EXISTS idx_amistades_amigo_id ON amistades(amigo_id);
CREATE INDEX IF NOT EXISTS idx_amistades_estado ON amistades(estado);

-- Trigger para actualizar updated_at
CREATE OR REPLACE FUNCTION update_amistades_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER trigger_update_amistades_updated_at
    BEFORE UPDATE ON amistades
    FOR EACH ROW
    EXECUTE FUNCTION update_amistades_updated_at();
