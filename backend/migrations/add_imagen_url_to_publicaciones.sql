-- Agregar campo imagen_url a la tabla publicaciones
ALTER TABLE publicaciones ADD COLUMN IF NOT EXISTS imagen_url TEXT;
