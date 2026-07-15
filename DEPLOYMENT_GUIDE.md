# 🚀 Guía de Deployment - Ligas de Conocimiento

## Requisitos Previos
- Cuenta en [Railway.app](https://railway.app)
- Cuenta en [Neon](https://neon.tech) (PostgreSQL)
- Railway CLI instalado: `npm install -g @railway/cli`
- Git configurado

---

## 1️⃣ Preparar Base de Datos (Neon)

### Paso 1: Conectar Neon a Railway
```bash
# En Railway, ir a Project → New → Add Service
# Seleccionar PostgreSQL (o conectar a Neon existente)
# Copiar la CONNECTION STRING
```

### Paso 2: Ejecutar Migraciones
```bash
# Opción A: Usando psql directamente
psql "<tu_database_url_de_neon>" < backend/ligas_migration.sql

# Opción B: Desde Railway CLI
railway run psql < backend/ligas_migration.sql

# Opción C: Desde Node.js
node -e "
const { Pool } = require('pg');
const fs = require('fs');
const pool = new Pool({
  connectionString: process.env.DATABASE_URL
});
const sql = fs.readFileSync('./backend/ligas_migration.sql', 'utf8');
pool.query(sql).then(() => {
  console.log('✅ Migraciones completadas');
  process.exit(0);
}).catch(err => {
  console.error('❌ Error:', err);
  process.exit(1);
});
"
```

### Verificar Migraciones
```sql
-- Conectar a tu DB en Neon
psql <url_de_neon>

-- Verificar tablas creadas
\dt ligas
\dt duelos
\dt ranking_ligas

-- Ver vistas
SELECT * FROM ranking_general LIMIT 5;
```

---

## 2️⃣ Deployar Backend a Railway

### Paso 1: Configurar en Railway
```bash
# 1. Iniciar sesión en Railway
railway login

# 2. Conectar proyecto
railway connect  # Seleccionar tu proyecto

# 3. Ver variables de entorno
railway variables
```

### Paso 2: Actualizar package.json (si es necesario)
```json
{
  "scripts": {
    "start": "node backend/server.js",
    "deploy": "bash backend/deploy.sh"
  }
}
```

### Paso 3: Push a Railway
```bash
# Con Railway CLI
railway up

# O con Git
git add .
git commit -m "feat: Ligas de Conocimiento sistema completo"
git push origin main
```

### Verificar Deployment
```bash
# Ver logs
railway logs

# Probar API
curl https://<tu-app>.railway.app/ligas
```

---

## 3️⃣ Actualizar Flutter App

### Paso 1: Configurar API Base URL
En `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'https://<tu-app>.railway.app/api';
```

### Paso 2: Actualizar pubspec.yaml
```yaml
dependencies:
  flutter:
    sdk: flutter
  # ... existentes ...
  phosphor_flutter: ^1.0.0
  provider: ^6.0.0
```

### Paso 3: Build & Deploy Flutter
```bash
# iOS
flutter build ios --release

# Android
flutter build apk --release
```

---

## 4️⃣ Variables de Entorno en Railway

### Backend (.env)
```env
DATABASE_URL=postgresql://user:password@host:5432/dbname
NODE_ENV=production
PORT=8000
JWT_SECRET=<tu_jwt_secret>
CLOUDINARY_API_KEY=<tu_cloudinary_key>
FIREBASE_SERVICE_ACCOUNT=<tu_firebase_json>
```

### En Railway Dashboard:
1. Ir a Project → Settings → Environment
2. Agregar cada variable
3. Re-deploy después de cambios

---

## 5️⃣ Verificar Sistema Completo

### Test Backend APIs

```bash
# 1. Crear Liga
curl -X POST https://<tu-app>.railway.app/api/ligas \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <tu_token>" \
  -d '{
    "nombre": "Liga Test",
    "descripcion": "Liga de prueba",
    "tipo": "general"
  }'

# 2. Obtener Ligas
curl https://<tu-app>.railway.app/api/ligas

# 3. Obtener Ranking
curl https://<tu-app>.railway.app/api/ranking

# 4. Iniciar Duelo
curl -X POST https://<tu-app>.railway.app/api/duelos/iniciar \
  -H "Authorization: Bearer <tu_token>" \
  -d '{
    "liga_id": 1,
    "opponent_id": 2,
    "tema": "Matemáticas"
  }'
```

### Test Flutter App
1. En Xcode/Android Studio: Run → Select device
2. Navegar a tab "Ligas"
3. Verificar que carga el listado
4. Intentar iniciar duelo

---

## 6️⃣ Troubleshooting

### ❌ Error: "Connection refused"
```bash
# Verificar DATABASE_URL
railway variables | grep DATABASE

# Reiniciar servicio
railway down
railway up
```

### ❌ Error 404 en /ligas
```bash
# Verificar que routes están importados en server.js
grep -n "app.use.*require" backend/server.js | grep ligas

# Verificar archivos existen
ls -la backend/src/routes/liga.routes.js
ls -la backend/src/controllers/liga.controller.js
```

### ❌ CORS errors en Flutter
En `backend/server.js`:
```javascript
const cors = require('cors');
app.use(cors({
  origin: ['https://tu-railway-app.railway.app', 'http://localhost:*'],
  credentials: true
}));
```

### ❌ JWT authentication failures
```bash
# Regenerar JWT_SECRET
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
# Actualizar en Railway variables
railway variables JWT_SECRET=<nuevo_valor>
```

---

## 7️⃣ Monitoreo en Producción

### Logs
```bash
railway logs --follow  # Ver logs en tiempo real
```

### Métricas
- RAM usage
- CPU usage
- Request count
- Error rate

### Database Backups
```bash
# En Neon Dashboard → Backups
# Crear backup manual antes de cambios importantes
```

---

## ✅ Checklist Final

- [ ] Base de datos Neon creada con migraciones
- [ ] Backend deployado en Railway
- [ ] Variables de entorno configuradas
- [ ] Flutter app actualizada con nueva URL
- [ ] API endpoints respondiendo correctamente
- [ ] Flutter app conecta a backend (verificado en logs)
- [ ] Duelos funcionan sin errores
- [ ] Ranking actualiza correctamente
- [ ] SSL/HTTPS habilitado

---

## 🎉 ¡Listo!

Tu sistema de Ligas de Conocimiento está en vivo. Los estudiantes pueden ahora:
- 🏆 Participar en duelos 1v1
- 📊 Ver su ranking en vivo
- 🎖️ Obtener insignias por logros
- 🔥 Mantener rachas de victorias

**Próximos pasos opcionales:**
- Integrar Claude API para preguntas dinámicas
- Agregar chat en tiempo real durante duelos
- Crear leaderboard global por semana/mes
- Implementar sistema de rewards

---

## 📞 Soporte

Para problemas:
1. Revisar logs: `railway logs`
2. Conectar a base de datos: `railway run psql`
3. Verificar configuración: `railway variables`
