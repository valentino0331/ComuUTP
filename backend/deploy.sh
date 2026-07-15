#!/bin/bash
# Deploy script para Railway - Ejecuta migraciones y inicia el servidor
# Uso: bash backend/deploy.sh

echo "🚀 Iniciando deployment a Railway..."
echo "================================="

# 1. Verificar variables de entorno
echo "✓ Verificando variables de entorno..."
if [ -z "$DATABASE_URL" ]; then
  echo "❌ ERROR: DATABASE_URL no está configurada"
  exit 1
fi

# 2. Instalar dependencias (si es necesario)
echo "✓ Instalando dependencias..."
npm install

# 3. Ejecutar migraciones SQL
echo "✓ Ejecutando migraciones de Ligas..."
psql $DATABASE_URL < backend/ligas_migration.sql
if [ $? -eq 0 ]; then
  echo "✅ Migraciones completadas exitosamente"
else
  echo "⚠️  Advertencia: Las migraciones pueden ya estar aplicadas"
fi

# 4. Iniciar servidor
echo "✓ Iniciando servidor Node.js..."
node backend/server.js

echo "✅ Deployment completado"
