-- Cambiar foto_perfil y foto_portada a TEXT para soportar imágenes en base64
ALTER TABLE usuarios ALTER COLUMN foto_perfil TYPE TEXT;
ALTER TABLE usuarios ALTER COLUMN foto_portada TYPE TEXT;
