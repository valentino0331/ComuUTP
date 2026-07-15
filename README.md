# 🎓 UTP Comunidades - Plataforma de Aprendizaje Colaborativo

**Aplicación web y móvil de comunidades para estudiantes de UTP con funcionalidades IA: resúmenes automáticos, quizzes inteligentes y lecciones de audio generadas.**

---

## 📋 Contenido

- [Descripción](#descripción)
- [Quick Start (3 pasos)](#quick-start-3-pasos)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Instalación Local](#instalación-local)
- [Deployment a Railway](#deployment-a-railway)
- [Testing](#testing)
- [Seguridad](#seguridad)
- [Troubleshooting](#troubleshooting)

---

## Descripción

**UTP Comunidades** es una plataforma que permite:

✨ **Funcionalidades Principales:**
- 👥 Comunidades de estudiantes por carrera
- 📚 Compartir materiales y recursos
- 🤖 Resúmenes automáticos de PDFs con IA
- 🎙️ Generación de lecciones de audio
- 📝 Quizzes inteligentes basados en contenido
- 💬 Sistema de mensajería en tiempo real
- 🔐 Autenticación con JWT + Firebase
- 📱 App móvil con Flutter

**Stack Tecnológico:**
- **Backend:** Node.js + Express + PostgreSQL
- **Frontend:** Flutter (iOS/Android)
- **Base de Datos:** PostgreSQL (Neon Cloud)
- **Deployment:** Railway
- **Autenticación:** Firebase Auth + JWT
- **IA:** OpenAI/ElevenLabs para resúmenes y audio

---

## 🚀 Quick Start (3 Pasos)

### ⏱️ Tiempo total: ~20 minutos

### PASO 1: Migración de Base de Datos (5 min)

1. Abre [Neon Console](https://console.neon.tech)
2. Selecciona tu proyecto → SQL Editor
3. Copia el script maestro:

```bash
cd backend
cat migrations/000-master-init.sql
```

4. Pega **TODO** en Neon SQL Editor y ejecuta (Ctrl+Enter)
5. Debe mostrar: ✅ `DATABASE SCHEMA SUCCESSFULLY INITIALIZED!`

### PASO 2: Deploy en Railway (10 min)

**Opción A: Desde Dashboard**
1. Ve a [Railway Dashboard](https://railway.app/dashboard)
2. Selecciona tu proyecto → backend
3. Settings → Redeploy (botón azul)
4. Espera 2 minutos (~3MB upload)
5. Estado debe cambiar a: ✅ **Active**

**Opción B: Desde Terminal**
```bash
cd backend
railway up
# Espera hasta ver "listening on port 3000"
```

### PASO 3: Verificar que Funciona (5 min)

```bash
# Configura tus variables
TOKEN="tu_token_jwt_aqui"
MATERIAL_ID="uuid_del_material"
COURSE_ID="uuid_del_curso"
APP_URL="https://tu-app.railway.app"

# Test 1: Resumen de PDF
curl -X POST $APP_URL/api/study/ai/summarize \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"materialId": "'$MATERIAL_ID'"}'

# Deberías ver: "success": true ✅

# Test 2: Generar audio-lección
curl -X POST $APP_URL/api/study/ai/generate-audio-lesson \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "materialId": "'$MATERIAL_ID'",
    "courseId": "'$COURSE_ID'",
    "voiceStyle": "balanced",
    "speed": 1.0
  }'

# Deberías ver: "success": true ✅
```

---

## 📁 Estructura del Proyecto

```
utp-comunidades/
├── backend/                      # API Node.js + Express
│   ├── routes/                   # Rutas de API
│   │   ├── ai.routes.js         # Endpoints IA (resúmenes, audio)
│   │   └── ...
│   ├── migrations/              # Scripts SQL
│   │   ├── 001-*.sql
│   │   ├── 002-*.sql
│   │   └── 003-create-audio-lessons-table.sql
│   ├── app.js                   # Configuración Express
│   ├── server.js                # Servidor principal
│   ├── package.json             # Dependencias Node
│   └── .env                     # Variables de entorno
│
├── utp_comunidades_app/         # App Flutter
│   ├── lib/
│   │   ├── main.dart            # Entry point
│   │   ├── screens/
│   │   ├── widgets/
│   │   └── models/
│   ├── android/                 # Config Android
│   ├── ios/                     # Config iOS
│   └── pubspec.yaml             # Dependencias Flutter
│
└── README.md                    # Este archivo
```

---

## 💻 Instalación Local

### Requisitos Previos
- Node.js 18+ (backend)
- Flutter SDK 3.0+ (app móvil)
- PostgreSQL 14+ (local) O Neon account (cloud)
- Firebase account configurada
- OpenAI / ElevenLabs API keys

### Backend Setup

```bash
# 1. Ir al directorio backend
cd backend

# 2. Instalar dependencias
npm install

# 3. Crear archivo .env con:
# BASE DE DATOS
DATABASE_URL=postgresql://user:password@localhost:5432/utp_comunidades

# FIREBASE
FIREBASE_API_KEY=xxx
FIREBASE_AUTH_DOMAIN=xxx
FIREBASE_PROJECT_ID=xxx
FIREBASE_STORAGE_BUCKET=xxx
FIREBASE_MESSAGING_SENDER_ID=xxx
FIREBASE_APP_ID=xxx

# IA
OPENAI_API_KEY=xxx
ELEVENLABS_API_KEY=xxx

# JWT
JWT_SECRET=tu_super_secret_key

# 4. Ejecutar migraciones
psql -U postgres -d utp_comunidades -f migrations/000-master-init.sql

# 5. Iniciar servidor
npm start
# Debe mostrar: "Server running on port 3000"
```

### App Flutter Setup

```bash
# 1. Ir al directorio de la app
cd utp_comunidades_app

# 2. Obtener dependencias
flutter pub get

# 3. Generar archivos (si es necesario)
flutter pub run build_runner build

# 4. Ejecutar en emulador o dispositivo
flutter run
```

---

## 🚂 Deployment a Railway

### Configuración Inicial (primera vez)

1. **Conectar repositorio a Railway:**
   - Ir a [Railway.app](https://railway.app)
   - New Project → Import from GitHub
   - Seleccionar este repositorio

2. **Configurar BD en Railway:**
   - Agregar servicio PostgreSQL
   - Copiar `DATABASE_URL` a variables de entorno

3. **Variables de Entorno en Railway:**
   ```env
   # Base de datos (auto-generada)
   DATABASE_URL=postgresql://...

   # APIs externas
   OPENAI_API_KEY=xxx
   ELEVENLABS_API_KEY=xxx
   FIREBASE_*=xxx

   # Seguridad
   JWT_SECRET=random_secure_key_here
   NODE_ENV=production
   ```

4. **Ejecutar migraciones en producción:**
   - Railway Console → Copiar contenido de `migrations/000-master-init.sql`
   - Pegar en Neon SQL Editor y ejecutar

### Redeploy después de cambios

```bash
# Opción 1: Desde terminal
cd backend
railway up

# Opción 2: Dashboard
# Settings → Redeploy (botón azul)
```

### Monitorear Deployment

- **Dashboard:** Railway → tu proyecto → Logs
- **En tiempo real:** `railway logs --follow`
- **Errores:** Revisar sección "Deployments"

---

## 🧪 Testing

### Test con cURL

```bash
# 1. Obtener token (login)
curl -X POST https://tu-app.railway.app/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "usuario@utp.edu.pe",
    "password": "password123"
  }'
# Guardar el token del response

# 2. Test: Resumen de PDF
curl -X POST https://tu-app.railway.app/api/study/ai/summarize \
  -H "Authorization: Bearer TOKEN_AQUI" \
  -H "Content-Type: application/json" \
  -d '{"materialId": "uuid-del-material"}'

# 3. Test: Quiz Inteligente
curl -X POST https://tu-app.railway.app/api/study/ai/generate-quiz \
  -H "Authorization: Bearer TOKEN_AQUI" \
  -H "Content-Type: application/json" \
  -d '{"materialId": "uuid-del-material"}'

# 4. Test: Audio-Lección
curl -X POST https://tu-app.railway.app/api/study/ai/generate-audio-lesson \
  -H "Authorization: Bearer TOKEN_AQUI" \
  -H "Content-Type: application/json" \
  -d '{
    "materialId": "uuid",
    "courseId": "uuid",
    "voiceStyle": "balanced",
    "speed": 1.0
  }'
```

### Verificar Status

```bash
# Endpoint de health check
curl https://tu-app.railway.app/api/health

# Debe responder:
# {"status": "ok", "timestamp": "2024-..."}
```

---

## 🔐 Seguridad

### Variables de Entorno Críticas
- ⚠️ **Nunca** commitear `.env` a Git
- ⚠️ **JWT_SECRET** debe ser fuerte (mínimo 32 caracteres)
- ⚠️ Rotar **API keys** regularmente
- ⚠️ Usar HTTPS siempre en producción

### Políticas de Acceso
- Firebase Auth para autenticación
- JWT con expiración de 24 horas
- Rate limiting en endpoints IA
- CORS configurado solo para dominios autorizados

### Data Privacy
- Contraseñas hasheadas con bcryptjs
- Datos sensibles encriptados en BD
- GDPR compliance para datos de usuarios
- Backups automáticos en PostgreSQL

Ver [SECURITY_POLICY.md](./backend/SECURITY_POLICY.md) para detalles completos.

---

## 🆘 Troubleshooting

### "Connection refused: 5432"
```bash
# BD local no está corriendo
# Solución: Iniciar PostgreSQL
pg_ctl -D /usr/local/var/postgres start
# O si usas Neon, verificar DATABASE_URL
```

### "CORS error"
```
# Los headers no están configurados correctamente
# Verifica en backend/app.js:
const cors = require('cors');
app.use(cors({
  origin: ['http://localhost:3000', 'https://tu-app.railway.app'],
  credentials: true
}));
```

### "401 Unauthorized"
```bash
# Token inválido o expirado
# Soluciones:
# 1. Verificar que incluyas "Authorization: Bearer TOKEN"
# 2. Verificar que JWT_SECRET sea el mismo en prod y dev
# 3. Regenerar token haciendo login nuevamente
```

### "500 Error en /api/study/ai/*"
```bash
# API key de IA no configurada
# Verifica:
echo $OPENAI_API_KEY      # Debe tener valor
echo $ELEVENLABS_API_KEY  # Debe tener valor

# En Railway: Settings → Variables → Verificar que estén presentes
```

### "Database migration failed"
```bash
# Script SQL con error
# Pasos:
# 1. Revisar syntax del SQL
# 2. Conectar a Neon directamente
# 3. Ejecutar línea por línea
# 4. Buscar errores de constraint o type
```

### App Flutter no conecta
```bash
# API_BASE_URL incorrea
# Editar en: lib/config/api_config.dart
const String API_BASE_URL = 'https://tu-app.railway.app';
# No olvidar rebuild: flutter clean && flutter run
```

---

## 📞 Soporte

- **Bug reports:** Crear issue en GitHub
- **Documentación técnica:** Ver carpeta `/backend/migrations/`
- **Testing completo:** Ejecutar script de test en `/testing/`
- **Logs en tiempo real:** `railway logs --follow`

---

## 📝 Cambios Recientes

✅ **Última actualización:** Audio-lecciones implementadas
- Tabla `audio_lessons` creada
- Endpoint `/api/study/ai/generate-audio-lesson` funcionando
- Integración con ElevenLabs API
- Tests ejecutando correctamente

---

## 📄 Licencia

Todos los derechos reservados © 2024 UTP Comunidades
