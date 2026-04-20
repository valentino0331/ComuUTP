-- Migración: Agregar columnas faltantes y corregir esquema
-- Esta migración agrega todas las columnas faltantes en las tablas

-- 1. Agregar columna usuario_creador_id a tabla comunidades
ALTER TABLE comunidades
ADD COLUMN IF NOT EXISTS usuario_creador_id INTEGER REFERENCES usuarios(id) ON DELETE SET NULL;

-- 2. Asegurar que la columna fecha existe en publicaciones (puede estar como "fecha" o "fecha_creacion")
ALTER TABLE publicaciones
ADD COLUMN IF NOT EXISTS fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- 3. Si existe "creado_en" pero no "fecha", renombrarla
DO $$ 
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='publicaciones' AND column_name='creado_en' AND NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='publicaciones' AND column_name='fecha')) THEN
    ALTER TABLE publicaciones RENAME COLUMN creado_en TO fecha;
  END IF;
END $$;

-- 4. Crear índices para mejor performance
CREATE INDEX IF NOT EXISTS idx_comunidades_creador ON comunidades(usuario_creador_id);
CREATE INDEX IF NOT EXISTS idx_publicaciones_fecha ON publicaciones(fecha);
CREATE INDEX IF NOT EXISTS idx_publicaciones_comunidad ON publicaciones(comunidad_id);
CREATE INDEX IF NOT EXISTS idx_miembros_comunidad_usuario ON miembros_comunidad(usuario_id);
CREATE INDEX IF NOT EXISTS idx_miembros_comunidad_comunidad ON miembros_comunidad(comunidad_id);
