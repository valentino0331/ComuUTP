# 🚀 COMANDOS COPY/PASTE - Ligas de Conocimiento

> Simplemente copia y pega cada bloque en tu terminal
> Tiempo total: ~15 minutos

---

## PASO 1️⃣: MIGRACIÓN DE BASE DE DATOS (5 min)

### Opción A: Direct psql (RECOMENDADO)
```bash
psql "postgresql://[user]:[password]@[host]:5432/[dbname]" < backend/ligas_migration.sql
```

### Opción B: Desde Railway CLI
```bash
railway run psql < backend/ligas_migration.sql
```

### Opción C: Export DATABASE_URL y ejecutar
```bash
export DATABASE_URL="tu_url_completa_aqui"
psql "$DATABASE_URL" < backend/ligas_migration.sql
```

### ✅ Verificar éxito
```bash
psql "$DATABASE_URL" -c "SELECT COUNT(*) FROM ligas;"
# Debe retornar: 1

psql "$DATABASE_URL" -c "\dt"
# Debe mostrar todas las tablas nuevas
```

---

## PASO 2️⃣: PUSH A RAILWAY (3 min)

### Commit changes
```bash
cd /path/to/utp-comunidades
git add .
git commit -m "feat: Sistema Ligas de Conocimiento - Duelos 1v1 + Ranking"
```

### Push to main
```bash
git push origin main
```

### Verificar deployment
```bash
# Opción A: Ver logs en vivo
railway logs --follow

# Opción B: Ver status
railway status

# Opción C: Esperar y testear
sleep 120  # Esperar 2 minutos
curl https://<tu-railway-app>.railway.app/api/ligas
```

---

## PASO 3️⃣: VERIFICAR FLUTTER (3 min)

### Limpiar y obtener dependencias
```bash
cd utp_comunidades_app
flutter clean
flutter pub get
```

### Verificar que compila sin errores
```bash
flutter pub pub upgrade  # Opcional
flutter build --analyze-size
```

### Correr en emulador/device
```bash
flutter run -v
```

### En la app
```
1. Navegar a tab "Competir" (o "Ligas")
2. Verificar que carga lista de ligas
3. Ver que colores son Indigo/Cyan/Amber (no rojo)
4. Intentar seleccionar rival
```

---

## PASO 4️⃣: VALIDACIÓN (4 min)

### Test API endpoint 1: Ligas
```bash
curl -X GET https://<tu-app>.railway.app/api/ligas \
  -H "Content-Type: application/json"
```
Esperado: `{"ligas": [...]}`

### Test API endpoint 2: Ranking
```bash
curl -X GET https://<tu-app>.railway.app/api/ranking \
  -H "Content-Type: application/json"
```
Esperado: `{"ranking": [...]}`

### Test API endpoint 3: Crear Liga (con token)
```bash
curl -X POST https://<tu-app>.railway.app/api/ligas \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <tu_token_jwt>" \
  -d '{
    "nombre": "Liga Test",
    "descripcion": "Prueba",
    "tipo": "general"
  }'
```
Esperado: `201 Created`

### Database check
```bash
# Ver ligas creadas
psql "$DATABASE_URL" -c "SELECT id, nombre, estado FROM ligas LIMIT 5;"

# Ver tablas creadas
psql "$DATABASE_URL" -c "\dt"

# Ver vistas creadas
psql "$DATABASE_URL" -c "\dv"
```

---

## 🔧 TROUBLESHOOTING - Comandos Útiles

### Si API no responde
```bash
# Ver logs
railway logs --follow

# Revisar status del servicio
railway status

# Reiniciar si es necesario
railway down
railway up
```

### Si Flutter falla
```bash
# Deep clean
flutter clean
rm -rf pubspec.lock
flutter pub get

# Verificar no hay imports rotos
flutter analyze

# Build fresco
flutter pub upgrade
flutter run
```

### Si BD no conecta
```bash
# Verificar variable de entorno
echo $DATABASE_URL

# Test conexión
psql "$DATABASE_URL" -c "SELECT NOW();"

# Ver status de Neon
# Ir a https://console.neon.tech
```

### Ver que providers están loadings
```bash
# En Flutter, agregar logging
flutter run -v | grep "LigaProvider\|DueloProvider\|RankingProvider"
```

---

## 🎯 CHECKLIST DE VALIDACIÓN

### ✅ Backend
```bash
# 1. Controllers existen
ls -la backend/src/controllers/liga.controller.js
ls -la backend/src/controllers/duelo.controller.js
ls -la backend/src/controllers/ranking.controller.js

# 2. Routes existen
ls -la backend/src/routes/liga.routes.js
ls -la backend/src/routes/duelo.routes.js
ls -la backend/src/routes/ranking.routes.js

# 3. Migraciones existen
ls -la backend/ligas_migration.sql

# 4. BD tiene tablas
psql "$DATABASE_URL" -c "\dt" | grep ligas
psql "$DATABASE_URL" -c "\dt" | grep duelos
psql "$DATABASE_URL" -c "\dt" | grep ranking_ligas
```

### ✅ Frontend
```bash
# 1. Providers existen
ls -la lib/providers/liga_provider.dart
ls -la lib/providers/duelo_provider.dart
ls -la lib/providers/ranking_provider.dart

# 2. Modelos existen
ls -la lib/models/liga.dart

# 3. Screens existen
ls -la lib/screens/duelo_screen.dart
ls -la lib/screens/ligas_screen.dart
ls -la lib/screens/ranking_screen.dart

# 4. Theme actualizado
grep "colorPrimary = Color(0xFF1F3A93)" lib/theme/app_theme.dart

# 5. Main.dart actualizado
grep "LigaProvider\|DueloProvider\|RankingProvider" lib/main.dart
```

### ✅ API
```bash
# 1. GET ligas
curl -s https://<tu-app>.railway.app/api/ligas | jq '.ligas | length'

# 2. GET ranking
curl -s https://<tu-app>.railway.app/api/ranking | jq '.ranking | length'

# 3. Endpoints están en logs
railway logs | grep "GET /api/ligas"
```

---

## 📊 MONITOREO CONTINUO

### Ver logs en tiempo real
```bash
railway logs --follow
```

### Ver errores solo
```bash
railway logs --follow | grep -i error
```

### Monitorear base de datos
```bash
watch -n 5 "psql \"\$DATABASE_URL\" -c 'SELECT COUNT(*) as duelos_jugados FROM duelos;'"
```

### Monitorear usuarios conectados
```bash
watch -n 5 "psql \"\$DATABASE_URL\" -c 'SELECT COUNT(DISTINCT usuario_id) as usuarios_activos FROM ranking_ligas;'"
```

---

## 🔑 VARIABLES DE ENTORNO A VERIFICAR

```bash
# Railway
echo "DATABASE_URL: $DATABASE_URL"
echo "NODE_ENV: $NODE_ENV"
echo "PORT: $PORT"

# Neon
railway variables | grep DATABASE
railway variables | grep JWT_SECRET
railway variables | grep CLOUDINARY
```

---

## 🎮 QUICK TEST - Flujo Completo

### 1. Crear liga (desde Postman/Insomnia)
```bash
POST https://<tu-app>.railway.app/api/ligas
Authorization: Bearer <tu_jwt_token>
Content-Type: application/json

{
  "nombre": "Liga Test Rápida",
  "descripcion": "Para validar el sistema",
  "tipo": "general",
  "estado": "activa"
}
```

### 2. Obtener ID de la liga
```bash
curl -s https://<tu-app>.railway.app/api/ligas | jq '.ligas[0].id'
# Nota el ID (ej: 1)
```

### 3. Obtener ranking de esa liga
```bash
curl -s https://<tu-app>.railway.app/api/ranking/liga/1 | jq '.'
```

### 4. En la app Flutter
```
1. Abre app
2. Navega a "Competir"
3. Debería ver "Liga Test Rápida"
4. Selecciona
5. Ve el ranking (probablemente vacío)
6. Intenta "Desafiar Rival"
```

---

## 📝 COMANDOS PARA LIMPIEZA (Si necesitas resetear)

### ⚠️ CUIDADO: Borra todas las ligas/duelos
```bash
# Eliminar todos los duelos
psql "$DATABASE_URL" -c "DELETE FROM duelo_respuestas; DELETE FROM duelo_preguntas; DELETE FROM duelos;"

# Eliminar todos los rankings
psql "$DATABASE_URL" -c "DELETE FROM ranking_ligas;"

# Verificar que quedó limpio
psql "$DATABASE_URL" -c "SELECT COUNT(*) FROM duelos; SELECT COUNT(*) FROM ranking_ligas;"
```

### Resetear secuencias (IDs)
```bash
psql "$DATABASE_URL" -c "
ALTER SEQUENCE ligas_id_seq RESTART WITH 1;
ALTER SEQUENCE duelos_id_seq RESTART WITH 1;
ALTER SEQUENCE ranking_ligas_id_seq RESTART WITH 1;
"
```

---

## 🆘 AYUDA RÁPIDA

### Si todo falla, resetear todo
```bash
# 1. Clean backend
git reset --hard HEAD
git pull origin main

# 2. Re-migrar BD
psql "$DATABASE_URL" -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"
psql "$DATABASE_URL" < backend/ligas_migration.sql

# 3. Clean Flutter
flutter clean
rm -rf pubspec.lock

# 4. Re-deploy
git add . && git commit -m "fix: reset" && git push
```

---

## 📞 STATUS CHECK (Cópialo y ejecútalo)

```bash
#!/bin/bash
echo "═══════════════════════════════════════"
echo "🔍 STATUS CHECK - LIGAS"
echo "═══════════════════════════════════════"

echo ""
echo "🗄️  DATABASE"
psql "$DATABASE_URL" -c "SELECT COUNT(*) as ligas FROM ligas; SELECT COUNT(*) as duelos FROM duelos; SELECT COUNT(*) as usuarios FROM ranking_ligas;" 2>/dev/null || echo "❌ BD no conecta"

echo ""
echo "🔧 BACKEND"
curl -s https://<tu-app>.railway.app/api/ligas > /dev/null && echo "✅ API activa" || echo "❌ API no responde"

echo ""
echo "📱 FLUTTER"
flutter doctor 2>/dev/null | grep -E "Flutter|Dart" || echo "⚠️  Verifica Flutter"

echo ""
echo "═══════════════════════════════════════"
```

---

## 📚 ARCHIVOS IMPORTANTES

```bash
# Ver qué se generó
ls -lah backend/ligas_migration.sql
ls -lah backend/src/controllers/
ls -lah backend/src/routes/
ls -lah utp_comunidades_app/lib/providers/
ls -lah utp_comunidades_app/lib/screens/duelo_screen.dart

# Copiar si necesitas respaldo
cp backend/ligas_migration.sql /tmp/backup_migracion.sql
cp -r backend/src/controllers /tmp/backup_controllers
```

---

## ✨ TODO LISTO

```
Si completaste todos los pasos:
✅ BD migrada
✅ Backend pusheado
✅ Flutter compilado
✅ API respondiendo
✅ App carga sin crashes

ENTONCES: 🎉 ¡LIGAS EN PRODUCCIÓN!
```

---

**¡Cópialo, pégalo, y a disfrutar!** 🚀
