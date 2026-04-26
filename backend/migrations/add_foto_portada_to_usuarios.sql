-- Agregar campo foto_portada a la tabla usuarios
ALTER TABLE usuarios ADD COLUMN IF NOT EXISTS foto_portada TEXT;
