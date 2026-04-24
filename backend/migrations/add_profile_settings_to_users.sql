-- Agregar columnas de configuración de perfil y preferencias a usuarios
ALTER TABLE usuarios 
ADD COLUMN IF NOT EXISTS bio TEXT,
ADD COLUMN IF NOT EXISTS gustos TEXT,
ADD COLUMN IF NOT EXISTS notificaciones_activas BOOLEAN DEFAULT TRUE,
ADD COLUMN IF NOT EXISTS email_notificaciones BOOLEAN DEFAULT TRUE,
ADD COLUMN IF NOT EXISTS notificaciones_menciones BOOLEAN DEFAULT TRUE,
ADD COLUMN IF NOT EXISTS modo_oscuro BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS privacidad_perfil_publico BOOLEAN DEFAULT TRUE,
ADD COLUMN IF NOT EXISTS privacidad_mostrar_email BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS idioma VARCHAR(10) DEFAULT 'es',
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- Crear trigger para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_usuarios_updated_at 
    BEFORE UPDATE ON usuarios 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

SELECT 'Profile settings columns added successfully!' as status;
