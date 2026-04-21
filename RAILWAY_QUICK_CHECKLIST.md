# 🚀 DEPLOYMENT RAILWAY - CHECKLIST RÁPIDO

## 📋 ANTES DE EMPEZAR
- [ ] Tienes cuenta GitHub
- [ ] Tienes una cuenta Railway (o vas a crearla)
- [ ] Tienes Firebase Console accesible
- [ ] Los cambios están pushed a GitHub (`main` branch)

---

## 🎯 PASO 1: CREAR PROYECTO EN RAILWAY
```
railway.app → Dashboard
→ "+ New Project"
→ "Deploy from GitHub repo"
→ Busca "ComuUTP" o "valentino0331/ComuUTP"
→ Click "Deploy"
```
✅ **Railway creará automáticamente:**
- Contenedor para tu app
- Detectará `railway.json`
- URL del proyecto

---

## 🎯 PASO 2: CREAR BASE DE DATOS POSTGRESQL
```
Tu proyecto en Railway
→ "+ New"
→ "Database" → "PostgreSQL"
→ Espera a que se cree
```
✅ **Railway hará:**
- Crea BD automáticamente
- Genera DATABASE_URL
- La añade a las variables

---

## 🎯 PASO 3: AÑADIR VARIABLES DE ENTORNO

### En Railway Dashboard:
```
Tu proyecto → Variables → "+ New Variable"
```

### Copia y pega estas variables UNA POR UNA:

**Variable 1: NODE_ENV**
```
KEY: NODE_ENV
VALUE: production
```

**Variable 2: PORT**
```
KEY: PORT
VALUE: 3000
```

**Variable 3: FRONTEND_URL**
```
KEY: FRONTEND_URL
VALUE: http://localhost:5173
(o tu URL frontend de producción)
```

**Variables 4-11: FIREBASE** (obtén de tu Firebase Console)
```
FIREBASE_API_KEY: AIzaSy...
FIREBASE_AUTH_DOMAIN: comuutp-xxx.firebaseapp.com
FIREBASE_PROJECT_ID: comuutp-xxx
FIREBASE_STORAGE_BUCKET: comuutp-xxx.appspot.com
FIREBASE_MESSAGING_SENDER_ID: 123456789
FIREBASE_APP_ID: 1:123456789:web:abc...
FIREBASE_PRIVATE_KEY: "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL: firebase-adminsdk@...iam.gserviceaccount.com
```

✅ **DATABASE_URL ya está automático de PostgreSQL**

---

## 🎯 PASO 4: ESPERAR DEPLOYMENT

```
Tu proyecto en Railway
→ "Deployments"
→ Espera el estado ✅ "Success"
```

🔄 **Status posibles:**
- 🟡 Building... (compilando)
- 🟡 Deploying... (desplegando)
- ✅ Success (¡listo!)
- ❌ Failed (revisar logs)

---

## 🎯 PASO 5: OBTENER URL DEL BACKEND

```
Tu proyecto → Backend Service
→ "Environment" o "Settings"
→ Busca la URL: https://comuutp-production.up.railway.app
```

📌 **Copia esta URL, la necesitarás después**

---

## 🎯 PASO 6: LIMPIAR DATA FALSA

### En Railway Console:
```
Tu proyecto → Backend → "Command Palette" o "Shell"
```

### Ejecuta:
```bash
cd backend
npm install
node clean-data.js
```

📊 **Salida esperada:**
```
✓ Tabla 'logs' limpiada
✓ Tabla 'reportes' limpiada
✓ Tabla 'notificaciones' limpiada
✓ Tabla 'historias' limpiada
✓ Tabla 'likes' limpiada
✓ Tabla 'comentarios' limpiada
✓ Tabla 'publicaciones' limpiada
✓ Tabla 'miembros_comunidad' limpiada
✓ Tabla 'bloqueos' limpiada
✓ Tabla 'comunidades' limpiada
✓ Tabla 'usuarios' limpiada

✅ Base de datos limpiada completamente!
```

---

## 🎯 PASO 7: VERIFICAR QUE FUNCIONA

### Test 1: Health Check
```bash
curl https://[TU-URL-AQUI].up.railway.app/health
```

📍 **Deberías ver:**
```json
{"status": "ok"}
```

### Test 2: En tu app Flutter
```dart
// Intenta:
1. Registrar nuevo usuario
2. Crear una comunidad
3. Hacer un post
4. Ver que aparecen en tiempo real
```

---

## 🎯 PASO 8: CONFIGURAR FRONTEND (opcional)

Si necesitas cambiar la URL en tu frontend:

**En `lib/main.dart` o `services/api.dart`:**
```dart
const String BACKEND_URL = 'https://[TU-URL-RAILWAY].up.railway.app';
```

Luego:
```bash
cd utp_comunidades_app
flutter pub get
flutter run
```

---

## ✅ DESPUÉS: PRODUCCIÓN LISTA

Ahora tu app tiene:
- ✅ Backend en la nube (Railway)
- ✅ BD PostgreSQL en la nube
- ✅ Firebase para autenticación
- ✅ Data 100% real (limpia)
- ✅ Solo usuarios logeados pueden crear contenido
- ✅ Deploy automático con cada push a `main`

---

## 🚨 PROBLEMAS COMUNES

### 1. "Deployment Failed"
```
Verifica:
- Está el railway.json en la raíz? ✓
- Las variables de entorno están todas? ✓
- DATABASE_URL existe? ✓
```

### 2. "Can't connect to database"
```
Verifica:
- PostgreSQL service está running? ✓
- DATABASE_URL es correcto? ✓
- Firewall permite conexión? ✓
```

### 3. "Firebase auth failing"
```
Verifica:
- Todos los FIREBASE_* están correctos? ✓
- FIREBASE_PRIVATE_KEY tiene \n correctos? ✓
```

### 4. Ver logs
```
Railway Dashboard
→ Tu proyecto
→ "Logs"
→ Busca el error exacto
```

---

## 📞 LINKS ÚTILES

- [Railway Dashboard](https://railway.app/dashboard)
- [Firebase Console](https://console.firebase.google.com)
- [Documentación Railway](https://docs.railway.app)
- [Documentación Firebase](https://firebase.google.com/docs)

---

## 🎉 ¡LISTO!

Si todo está verde:
- 🟢 Backend corriendo
- 🟢 BD funcionando
- 🟢 Data limpia
- 🟢 Usuarios reales solo

**Tu app está en PRODUCCIÓN** 🚀
