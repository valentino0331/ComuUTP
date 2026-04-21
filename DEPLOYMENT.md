# 🚀 Guía de Deployment a Railway - UTP Comunidades

## Resumen Rápido
1. Limpiar toda la data falsa de la BD
2. Deployar el backend a Railway
3. Empezar con data 100% real de usuarios logeados

---

## 1️⃣ Limpiar Toda la Data Falsa

### Opción A: Limpiar en Local (para pruebas)
```bash
cd backend
npm install
node clean-data.js
```

### Opción B: Limpiar en Railway (en producción)
Una vez deployado en Railway, puedes ejecutar el script directamente en la consola de Railway:

```bash
npm install
node clean-data.js
```

**Esto eliminará:**
- ❌ Todos los usuarios de prueba
- ❌ Todas las comunidades falsas
- ❌ Todos los posts, comentarios, likes
- ❌ Toda data de prueba

**Pero mantiene:**
- ✅ La estructura de las tablas
- ✅ Las configuraciones de roles
- ✅ Las columnas y tipos de datos

---

## 2️⃣ Variables de Entorno Requeridas

Asegúrate de tener estas en Railway:

```env
# Base de datos
DATABASE_URL=postgresql://user:pass@host:port/dbname

# Firebase
FIREBASE_API_KEY=your_api_key
FIREBASE_AUTH_DOMAIN=your_auth_domain
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_STORAGE_BUCKET=your_storage_bucket
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_APP_ID=your_app_id
FIREBASE_PRIVATE_KEY=your_private_key
FIREBASE_CLIENT_EMAIL=your_client_email
FIREBASE_CLIENT_ID=your_client_id

# Frontend URL
FRONTEND_URL=https://tu-frontend.vercel.app

# Email (opcional)
SENDGRID_API_KEY=your_sendgrid_key (opcional)
SENDGRID_FROM_EMAIL=noreply@tuapp.com (opcional)

# Puerto
PORT=3000
NODE_ENV=production
```

---

## 3️⃣ Steps para Deployar en Railway

### Paso 1: Preparar el repositorio
```bash
# Asegúrate de estar en la rama main
git status
git add .
git commit -m "Clean data for production deployment"
git push origin main
```

### Paso 2: Conectar Railway a tu repositorio GitHub
1. Ve a [railway.app](https://railway.app)
2. Click en "New Project"
3. Selecciona "Deploy from GitHub"
4. Conecta tu cuenta de GitHub
5. Selecciona el repositorio `utp-comunidades`

### Paso 3: Configurar Railway
1. Railway detectará el `railway.json` automáticamente
2. Añade las variables de entorno (DATABASE_URL, FIREBASE_* etc.)
3. Crea una nueva base de datos PostgreSQL en Railway
4. Copia la DATABASE_URL a las variables de entorno

### Paso 4: Deploy automático
```bash
# Cada push a main disparará un nuevo deploy automáticamente
git push origin main
```

Railway verá el `railway.json` y ejecutará:
```
cd backend && npm install && node server.js
```

---

## 4️⃣ Después del Deployment

### Limpiar Data en Producción
Una vez deployado, en la consola de Railway:

```bash
npm install
node clean-data.js
```

### Verificar que todo funciona
```bash
# En local, prueba conectar al backend en producción
curl https://tu-app-production.up.railway.app/health
```

---

## 5️⃣ Flujo de Usuarios Reales

Ahora que está limpio, el flujo será:

1. **Usuario se registra** en la app con Firebase
2. **Usuario se loguea** con sus credenciales reales
3. **Usuario crea comunidades** (si tiene permisos)
4. **Usuario hace posts** en sus comunidades
5. **Todo queda guardado** 100% real en la BD

---

## 6️⃣ Monitoreo en Railway

### Ver logs en tiempo real
```bash
railway logs --follow
```

### Ver estado de la app
```bash
railway status
```

### Variables de entorno
```bash
railway env ls
```

---

## 7️⃣ Rollback si algo sale mal

```bash
# Ver historial de deployments
railway deployments

# Rollback a una versión anterior
railway deploy [deployment-id]
```

---

## ✅ Checklist antes de deployar

- [ ] Script `clean-data.js` creado
- [ ] Variables de entorno configuradas en Railway
- [ ] Base de datos PostgreSQL creada en Railway
- [ ] Firebase configurado correctamente
- [ ] FRONTEND_URL apunta a tu app frontend
- [ ] Git repository sincronizado

---

## 🎯 Después: Datos 100% Reales

Una vez limpio y deployado:
- ✅ Solo usuarios logeados pueden crear contenido
- ✅ Cada usuario debe tener credenciales reales en Firebase
- ✅ Todos los posts, comentarios, likes son 100% autentificados
- ✅ La data es persistente y real en la BD de production

---

## 📞 Soporte

Si hay problemas:
1. Revisa los logs de Railway: `railway logs`
2. Verifica las variables de entorno
3. Asegúrate de que DATABASE_URL es válido
4. Verifica que Firebase está configurado correctamente
