-- Agregar columna created_at si no existe en amistades
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'amistades' AND column_name = 'created_at'
    ) THEN
        ALTER TABLE amistades ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
    END IF;
END $$;

-- Agregar columna updated_at si no existe en amistades
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'amistades' AND column_name = 'updated_at'
    ) THEN
        ALTER TABLE amistades ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
    END IF;
END $$;
