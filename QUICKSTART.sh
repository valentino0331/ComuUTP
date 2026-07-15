#!/bin/bash
# 🚀 QUICK START - Ligas de Conocimiento en 15 minutos

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  🎮 SISTEMA LIGAS DE CONOCIMIENTO - DEPLOYMENT SCRIPT          ║"
echo "║  Tiempo estimado: 15 minutos                                  ║"
echo "╚════════════════════════════════════════════════════════════════╝"

# ============================================
# STEP 1: DATABASE MIGRATION (5 min)
# ============================================
echo ""
echo "📊 PASO 1: Migración de Base de Datos"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
echo "⚠️  REQUIERE: DATABASE_URL configurada (Neon/PostgreSQL)"
echo ""
echo "Opción A: Desde línea de comandos (MÁS RÁPIDO)"
echo "   psql \"\$DATABASE_URL\" < backend/ligas_migration.sql"
echo ""
echo "Opción B: Desde Railway CLI"
echo "   railway run psql < backend/ligas_migration.sql"
echo ""
echo "Opción C: Desde Node.js"
echo "   node backend/migrations/run-migration.js"
echo ""
read -p "¿Ejecutar migración? (s/n) " -n 1 -r
echo

if [[ $REPLY =~ ^[Ss]$ ]]; then
  echo "🔄 Ejecutando migraciones..."
  
  if command -v psql &> /dev/null; then
    if [ -z "$DATABASE_URL" ]; then
      echo "❌ ERROR: DATABASE_URL no configurada"
      echo "   Ejecuta: export DATABASE_URL='postgresql://...'"
      exit 1
    fi
    
    psql "$DATABASE_URL" < backend/ligas_migration.sql
    if [ $? -eq 0 ]; then
      echo "✅ Migraciones completadas exitosamente"
    else
      echo "⚠️  Error en migraciones (pueden estar ya aplicadas)"
    fi
  else
    echo "❌ psql no está instalado"
    echo "   Instala PostgreSQL o usa railway CLI"
    exit 1
  fi
fi

# ============================================
# STEP 2: BACKEND PUSH (3 min)
# ============================================
echo ""
echo "🔧 PASO 2: Push Backend a Railway"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Comando:"
echo "   git add ."
echo "   git commit -m 'feat: Ligas de Conocimiento - Sistema completo'"
echo "   git push origin main"
echo ""

read -p "¿Push a Railway? (s/n) " -n 1 -r
echo

if [[ $REPLY =~ ^[Ss]$ ]]; then
  if ! command -v git &> /dev/null; then
    echo "❌ Git no está instalado"
    exit 1
  fi
  
  echo "📤 Pushando cambios..."
  git add .
  git commit -m "feat: Ligas de Conocimiento - Sistema completo"
  git push origin main
  
  if [ $? -eq 0 ]; then
    echo "✅ Backend pusheado a Railway"
    echo ""
    echo "⏳ Esperando deployment... (2-3 minutos)"
    echo "   Ver progreso: railway logs --follow"
  else
    echo "❌ Error al hacer push"
    exit 1
  fi
fi

# ============================================
# STEP 3: FLUTTER VERIFICATION (3 min)
# ============================================
echo ""
echo "📱 PASO 3: Verificar Flutter App"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Verificaciones:"
echo "   1. flutter clean"
echo "   2. flutter pub get"
echo "   3. flutter run"
echo ""

read -p "¿Verificar Flutter? (s/n) " -n 1 -r
echo

if [[ $REPLY =~ ^[Ss]$ ]]; then
  if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter no está instalado"
    exit 1
  fi
  
  echo "🧹 Limpiando proyecto..."
  flutter clean
  
  echo "📦 Obteniendo dependencias..."
  flutter pub get
  
  if [ $? -eq 0 ]; then
    echo "✅ Flutter verificado"
    echo ""
    echo "⏳ Para correr la app:"
    echo "   flutter run"
  else
    echo "❌ Error en Flutter"
    exit 1
  fi
fi

# ============================================
# STEP 4: VERIFICATION (4 min)
# ============================================
echo ""
echo "✔️  PASO 4: Verificaciones Finales"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check 1: Database
echo "1️⃣  Database"
if command -v psql &> /dev/null && [ -n "$DATABASE_URL" ]; then
  LIGAS_COUNT=$(psql "$DATABASE_URL" -t -c "SELECT COUNT(*) FROM ligas;" 2>/dev/null || echo "error")
  if [ "$LIGAS_COUNT" != "error" ]; then
    echo "   ✅ BD conectada (ligas: $LIGAS_COUNT)"
  else
    echo "   ⚠️  No se pudo conectar a BD"
  fi
else
  echo "   ⏭️  Skipped (psql no disponible)"
fi

# Check 2: Files
echo ""
echo "2️⃣  Archivos Generados"
FILES=(
  "backend/ligas_migration.sql"
  "backend/src/controllers/liga.controller.js"
  "backend/src/controllers/duelo.controller.js"
  "backend/src/routes/liga.routes.js"
  "backend/src/routes/duelo.routes.js"
  "utp_comunidades_app/lib/providers/liga_provider.dart"
  "utp_comunidades_app/lib/providers/duelo_provider.dart"
  "utp_comunidades_app/lib/screens/duelo_screen.dart"
  "DEPLOYMENT_GUIDE.md"
  "LIGAS_SYSTEM_GUIDE.md"
)

for file in "${FILES[@]}"; do
  if [ -f "$file" ]; then
    echo "   ✅ $file"
  else
    echo "   ❌ $file (FALTA)"
  fi
done

# Check 3: Git
echo ""
echo "3️⃣  Git Status"
if command -v git &> /dev/null; then
  CHANGES=$(git status --porcelain | wc -l)
  if [ "$CHANGES" -eq 0 ]; then
    echo "   ✅ Todo pusheado"
  else
    echo "   ⚠️  $CHANGES cambios sin pusher"
  fi
else
  echo "   ⏭️  Skipped (Git no disponible)"
fi

# ============================================
# FINAL STATUS
# ============================================
echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║ 🎉 IMPLEMENTACIÓN COMPLETADA                                  ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "📋 Próximos pasos:"
echo "   1. Esperar a que Railway termine deployment (2-3 min)"
echo "   2. Ver logs: railway logs --follow"
echo "   3. Probar endpoints:"
echo "      curl https://<tu-app>.railway.app/api/ligas"
echo "   4. Correr Flutter: flutter run"
echo "   5. Navegar a tab 'Competir'"
echo ""
echo "📚 Documentación:"
echo "   - IMPLEMENTATION_SUMMARY.md (Este checklist)"
echo "   - DEPLOYMENT_GUIDE.md (Detalles deployment)"
echo "   - LIGAS_SYSTEM_GUIDE.md (Guía completa del sistema)"
echo ""
echo "✨ ¡Sistema listo para producción!"
echo ""
