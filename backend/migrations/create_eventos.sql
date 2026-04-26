-- Crear tabla de eventos
CREATE TABLE IF NOT EXISTS eventos (
    id SERIAL PRIMARY KEY,
    comunidad_id INTEGER REFERENCES comunidades(id) ON DELETE CASCADE,
    usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    titulo VARCHAR(200) NOT NULL,
    descripcion TEXT,
    fecha_evento TIMESTAMP NOT NULL,
    ubicacion VARCHAR(200),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Crear tabla de RSVP a eventos
CREATE TABLE IF NOT EXISTS evento_rsvp (
    id SERIAL PRIMARY KEY,
    evento_id INTEGER NOT NULL REFERENCES eventos(id) ON DELETE CASCADE,
    usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    estado VARCHAR(20) DEFAULT 'pendiente', -- 'pendiente', 'confirmado', 'rechazado'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(evento_id, usuario_id)
);

-- Índices para mejorar el rendimiento
CREATE INDEX IF NOT EXISTS idx_eventos_comunidad_id ON eventos(comunidad_id);
CREATE INDEX IF NOT EXISTS idx_eventos_usuario_id ON eventos(usuario_id);
CREATE INDEX IF NOT EXISTS idx_eventos_fecha_evento ON eventos(fecha_evento);
CREATE INDEX IF NOT EXISTS idx_evento_rsvp_evento_id ON evento_rsvp(evento_id);
CREATE INDEX IF NOT EXISTS idx_evento_rsvp_usuario_id ON evento_rsvp(usuario_id);
