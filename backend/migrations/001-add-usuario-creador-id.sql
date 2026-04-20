-- Migración: Agregar columna usuario_creador_id a tabla comunidades
-- Esta columna guarda el ID del usuario que creó la comunidad

-- Verificar si la columna no existe antes de crearla
ALTER TABLE comunidades
ADD COLUMN IF NOT EXISTS usuario_creador_id INTEGER REFERENCES usuarios(id) ON DELETE SET NULL;

-- Crear índice para mejor performance
CREATE INDEX IF NOT EXISTS idx_comunidades_creador ON comunidades(usuario_creador_id);
