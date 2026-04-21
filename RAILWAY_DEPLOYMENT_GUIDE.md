# 🚀 DEPLOYMENT A RAILWAY - PASO A PASO

## STEP 1: Crear cuenta en Railway (si no tienes)
1. Ve a **railway.app**
2. Click en **"Sign Up"**
3. Conecta con GitHub
4. Autoriza Railway a acceder a tus repositorios

---

## STEP 2: Crear nuevo proyecto en Railway

1. Ve a **https://railway.app/dashboard**
2. Click en **"+ New Project"**
3. Selecciona **"Deploy from GitHub repo"**
4. Busca **"ComuUTP"** o **"valentino0331/ComuUTP"**
5. Click en **"Deploy"**

Railway detectará automáticamente:
- El archivo `railway.json` en la raíz
- El comando a ejecutar: `cd backend && npm install && node server.js`

---

## STEP 3: Configurar Base de Datos PostgreSQL

1. En tu proyecto de Railway, click en **"+ New"**
2. Selecciona **"Database"** → **"PostgreSQL"**
3. Railway creará automáticamente:
   - Una base de datos nueva
   - Usuario y contraseña
   - Generará la `DATABASE_URL` automáticamente

**La DATABASE_URL se añadirá automáticamente a las variables de entorno** ✅

---

## STEP 4: Añadir Variables de Entorno

En Railway Dashboard:

1. Click en tu proyecto
2. Ve a la pestaña **"Variables"**
3. Haz click en **"+ New Variable"**
4. Añade estas variables una por una:

```env
# Firebase (obtén estos valores de tu consola de Firebase)
FIREBASE_API_KEY=AIzaSy...
FIREBASE_AUTH_DOMAIN=comuutp-xxx.firebaseapp.com
FIREBASE_PROJECT_ID=comuutp-xxx
FIREBASE_STORAGE_BUCKET=comuutp-xxx.appspot.com
FIREBASE_MESSAGING_SENDER_ID=123456789
FIREBASE_APP_ID=1:123456789:web:abc...
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk@comuutp-xxx.iam.gserviceaccount.com
FIREBASE_CLIENT_ID=123456789

# Frontend URL
FRONTEND_URL=http://localhost:5173

# Otros
NODE_ENV=production
PORT=3000
```

**⚠️ IMPORTANTE:** 
- DATABASE_URL se crea automáticamente con PostgreSQL
- No necesitas crear manualmente DATABASE_URL
- Los valores de Firebase están en tu **Firebase Console**

---

## STEP 5: Deploy Automático

Una vez configuradas las variables:

1. Railway detectará cambios en tu GitHub
2. Cada push a `main` dispara un deploy automático
3. Puedes ver los logs en tiempo real

**El comando que ejecutará será:**
```
cd backend && npm install && node server.js
```

---

## STEP 6: Obtener URL de tu Backend

Después del deploy:

1. En Railway Dashboard, ve a tu proyecto
2. Click en el servicio del backend
3. Ve a la pestaña **"Deployments"**
4. Verás una URL como: `https://comuutp-production.up.railway.app`

**Esta URL es tu BACKEND_URL** 🎯

---

## STEP 7: Limpiar Data Falsa

Una vez deployado:

1. En Railway Dashboard, click en tu backend
2. Ve a **"Command Palette"** o **"Shell"**
3. Ejecuta:

```bash
cd backend
npm install
node clean-data.js
```

**Esto eliminará:**
- ❌ Usuarios de prueba
- ❌ Comunidades falsas
- ❌ Todos los posts, comentarios, likes de prueba

**Pero mantiene:**
- ✅ Estructura de BD intacta
- ✅ Tablas y columnas
- ✅ Configuraciones

---

## STEP 8: Configurar Frontend para Production

En `lib/main.dart` o en tu `firebase_options.dart`, asegúrate de:

1. Apuntar a la BD de production (ya hecho con Firebase)
2. Backend URL correcta:

```dart
const String BACKEND_URL = 'https://comuutp-production.up.railway.app';
```

---

## ✅ VERIFICACIÓN FINAL

Prueba que todo funciona:

```bash
# Test del backend
curl https://comuutp-production.up.railway.app/health

# O en tu app Flutter
# Intenta registrarte como usuario nuevo
# Crea una comunidad
# Haz un post
```

---

## 🎯 Conclusión

Si todo está bien:
- ✅ Backend deployado en Railway
- ✅ PostgreSQL funcionando
- ✅ Data limpia (solo usuarios reales)
- ✅ Firebase integrado
- ✅ Deploy automático con cada push

---

## 📞 Si algo falla:

### Ver logs en tiempo real
```
Railway Dashboard → Tu proyecto → "Logs"
```

### Verificar variables de entorno
```
Railway Dashboard → Tu proyecto → "Variables"
```

### Rollback a versión anterior
```
Railway Dashboard → "Deployments" → Selecciona una versión anterior
```

---

## 🎉 ¡LISTO PARA PRODUCCIÓN!

Ahora solo usuarios reales logeados pueden:
- ✅ Crear comunidades
- ✅ Hacer posts
- ✅ Comentar
- ✅ Dar likes

**100% data auténtica** 🎯
