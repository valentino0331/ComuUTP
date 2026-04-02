# 🎓 UTP Comunidades - Aplicación Completa

Una aplicación de comunidades universitarias full-stack para estudiantes de la Universidad Tecnológica del Perú.

## 📦 Estructura del proyecto

```
utp-comunidades/
│
├── backend/                    # API REST con Node.js, Express, PostgreSQL
│   ├── src/
│   │   ├── config/            # Configuración de BD
│   │   ├── controllers/       # Lógica de aplicación
│   │   ├── models/            # Estructuras de datos
│   │   ├── routes/            # Rutas API
│   │   ├── middlewares/       # Validación, autenticación
│   │   ├── services/          # Servicios auxiliares
│   │   └── utils/             # Utilidades
│   ├── app.js                 # Configuración de Express
│   ├── server.js              # Punto de entrada
│   ├── package.json           # Dependencias Node
│   ├── .env                   # Configuración (BD, JWT)
│   └── README.md              # Instrucciones
│
├── utp_comunidades_app/       # App Flutter (Móvil)
│   ├── lib/
│   │   ├── main.dart          # Punto de entrada
│   │   ├── models/            # Modelos de datos
│   │   ├── services/          # Cliente HTTP
│   │   ├── providers/         # State management
│   │   ├── screens/           # Pantallas UI
│   │   ├── widgets/           # Componentes reutilizables
│   │   └── utils/             # Utilidades
│   ├── pubspec.yaml           # Dependencias Flutter
│   ├── android/               # Configuración Android
│   ├── ios/                   # Configuración iOS
│   ├── README.md              # Instrucciones
│   └── GUIA_COMPLETA.md       # Guía detallada
│
├── diseño/                    # Mockups e imágenes de diseño
│
├── .gitignore
├── README.md                  # Este archivo
└── INTEGRACION_COMPLETA.md    # Documentación técnica
```

## 🚀 Inicio rápido

### Backend (5 minutos)

```bash
cd backend

# 1. Instalar dependencias
npm install

# 2. Configurar .env
# DB_HOST=localhost
# DB_PORT=5432
# DB_USER=postgres
# DB_PASSWORD=1234
# DB_NAME=UTP
# JWT_SECRET=supersecretkey

# 3. Iniciar servidor
npm run dev
# Verás: "Servidor escuchando en el puerto 3000"
```

### Frontend (5 minutos)

```bash
cd utp_comunidades_app

# 1. Instalar dependencias
flutter pub get

# 2. Configurar conexión a backend
# Edita: lib/utils/constants.dart
# apiBaseUrl = 'http://10.0.2.2:3000/api' (emulador)
# apiBaseUrl = 'http://192.168.x.x:3000/api' (dispositivo físico)

# 3. Iniciar app
flutter run
```

## 🎯 Funcionalidades principales

### 1. Autenticación 🔐
- ✅ Registro con validación @utp.edu.pe
- ✅ Login con JWT
- ✅ Almacenamiento seguro de tokens
- ✅ Logout

### 2. Comunidades 👥
- ✅ Crear nuevas comunidades
- ✅ Listar todas las comunidades
- ✅ Unirse a comunidades
- ✅ Chat básico en comunidades

### 3. Publicaciones 📝
- ✅ Crear posts en comunidades
- ✅ Ver feed de publicaciones
- ✅ Comentar en posts
- ✅ Dar like a posts
- ✅ Reportar contenido inapropiado

### 4. Notificaciones 🔔
- ✅ Recibir notificaciones en tiempo real
- ✅ Ver historial de notificaciones

### 5. Perfil 👤
- ✅ Ver información de usuario
- ✅ Cerrar sesión

## 🗄️ Base de Datos

La app usa PostgreSQL con las siguientes tablas:

```sql
-- Usuarios
usuarios (id, email, password, nombre)

-- Comunidades
comunidades (id, nombre, descripcion, creador_id)

-- Membresía
miembros_comunidad (usuario_id, comunidad_id)

-- Publicaciones
publicaciones (id, usuario_id, comunidad_id, contenido, fecha)

-- Comentarios
comentarios (id, usuario_id, publicacion_id, contenido, fecha)

-- Likes
likes_publicaciones (usuario_id, publicacion_id)

-- Reportes
reportes (id, usuario_id, tipo, referencia_id, motivo)

-- Baneos
baneos (id, usuario_id, comunidad_id, motivo, moderador_id)

-- Notificaciones
notificaciones (id, usuario_id, mensaje, leido)

-- Logs
logs_sistema (id, usuario_id, accion, descripcion, fecha)
```

## 🔌 Endpoints principales

```
POST   /api/auth/register              Registro
POST   /api/auth/login                 Login
GET    /api/auth/me                    Datos usuario
++++

GET    /api/communities                Listar comunidades
POST   /api/communities                Crear comunidad
POST   /api/communities/join           Unirse
++++

POST   /api/posts                      Crear post
GET    /api/posts/community/:id        Posts de comunidad
++++

POST   /api/comments                   Crear comentario
POST   /api/likes                      Dar like
POST   /api/reports                    Reportar
++++

GET    /api/notifications              Ver notificaciones
```

## 🛠️ Tecnologías

### Backend
- **Node.js** - Runtime JavaScript
- **Express** - Framework web
- **PostgreSQL** - Base de datos
- **JWT** - Autenticación
- **bcrypt** - Encriptación de contraseñas

### Frontend
- **Flutter** - SDK móvil
- **Dart** - Lenguaje
- **Provider** - State management
- **HTTP** - Cliente para API
- **flutter_secure_storage** - Almacenamiento seguro

## 📋 Requisitos del sistema

- Node.js 18+
- Flutter 3.0+
- PostgreSQL 12+
- Android Studio o VS Code
- Emulador o dispositivo físico

## 🔍 Pruebas rápidas

### 1. Prueba de registro
```bash
Email: student@utp.edu.pe
Password: password123
Nombre: Juan Pérez
```

### 2. Prueba de comunidades
- Crea una comunidad: "Programadores"
- Únete a ella
- Crea un post

### 3. Prueba de interacción
- Comenta en el post
- Agrega un like
- Reporta un contenido

## 🐛 Troubleshooting

| Problema | Solución |
|----------|----------|
| Backend no inicia | Verifica que PostgreSQL esté corriendo |
| Conexión rechazada | Verifica PORT 3000 y URL base de API |
| Token inválido | Vuelve a iniciar sesión |
| Email rechazado | Debe terminar en @utp.edu.pe |
| Emulador lento | Prueba con dispositivo físico |

## 📖 Documentación completa

- `backend/README.md` - Guía del backend
- `utp_comunidades_app/README.md` - Guía del frontend
- `utp_comunidades_app/GUIA_COMPLETA.md` - Guía detallada de Flutter
- `INTEGRACION_COMPLETA.md` - Documentación técnica de integración

## 🎓 Arquitectura

```
┌─────────────────────────────────────────────────────────┐
│                   Flutter App Mobile                    │
│                                                         │
│  ┌────────────┐  ┌──────────┐  ┌────────────────────┐ │
│  │   Screens  │→ │Providers │→ │   API Service      │ │
│  │ (UI/Views) │  │ (State)  │  │ (HTTP Requests)    │ │
│  └────────────┘  └──────────┘  └────────┬───────────┘ │
└───────────────────────────────────┬──────────────────────┘
                                    │ HTTP
                    ┌───────────────▼────────────────┐
                    │   Node.js + Express Server     │
                    │   (Port 3000)                  │
                    │                                │
                    │  ┌──────────────────────────┐  │
                    │  │   API Routes             │  │
                    │  │   - Auth                 │  │
                    │  │   - Communities          │  │
                    │  │   - Posts                │  │
                    │  │   - Comments             │  │
                    │  │   - Notifications        │  │
                    │  └───────────┬──────────────┘  │
                    └──────────────┼─────────────────┘
                                   │ SQL
                    ┌──────────────▼──────────────┐
                    │   PostgreSQL Database       │
                    │                            │
                    │   - usuarios               │
                    │   - comunidades            │
                    │   - publicaciones          │
                    │   - comentarios            │
                    │   - notificaciones         │
                    └────────────────────────────┘
```

## ✅ Checklist de implementación

- [x] Backend con todas las rutas
- [x] Autenticación con JWT
- [x] Validación de emails UTP
- [x] Encriptación de contraseñas
- [x] Frontend Flutter completo
- [x] State management con Provider
- [x] Pantallas principales
- [x] Conexión API backend-frontend
- [x] Logs del sistema
- [x] Validaciones en cliente y servidor
- [x] Manejo de errores
- [x] UI moderna y responsive

## 🚀 Próximas mejoras

- [ ] Chat en tiempo real (WebSockets)
- [ ] Búsqueda de usuarios y comunidades
- [ ] Cargar imágenes en posts
- [ ] Sistema de roles (moderador, admin)
- [ ] Push notifications
- [ ] Modo offline básico
- [ ] Integración con redes sociales

## 📄 Licencia

Proyecto educativo - UTP 2024

## 👨‍💻 Desarrollo

La aplicación está **100% funcional y lista para usar**. Solo necesitas:

1. ✅ Ejecutar `npm run dev` en backend
2. ✅ Ejecutar `flutter run` en frontend
3. ✅ ¡Comenzar a usar la app!

---

**Disfruta tu app de comunidades universitarias!** 🎉
