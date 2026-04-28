-- Agregar campo imagen_url a la tabla publicaciones
ALTER TABLE publicaciones ADD COLUMN IF NOT EXISTS imagen_url TEXT;

-- Cambiar tipo de dato de VARCHAR(500) a TEXT si ya existe
ALTER TABLE publicaciones ALTER COLUMN imagen_url TYPE TEXT;
