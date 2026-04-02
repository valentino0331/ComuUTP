# Integración Backend-Frontend - UTP Comunidades

## 📋 Resumen de la integración completa

La aplicación UTP Comunidades está completamente integrada entre:
- **Backend**: Node.js + Express + PostgreSQL (puerto 3000)
- **Frontend**: Flutter (móvil iOS/Android)

## 🔄 Flujo de comunicación

```
┌─────────────────────────────────┐
│      Flutter App (Frontend)     │
│                                 │
│  ├─ Screens (Interfaz)         │
│  ├─ Providers (Estado)         │
│  └─ Services (API Client)      │
└────────────┬────────────────────┘
             │
             │ HTTP(S)
             │
    ┌────────▼────────┐
    │ API Node.js :3000
    │                 │
    ├─ Controllers    │
    ├─ Models         │
    ├─ Routes         │
    └────────┬────────┘
             │
             │ SQL
             │
    ┌────────▼────────┐
    │ PostgreSQL      │
    │ (Base de datos) │
    └─────────────────┘
```

## 📱 Pantallas implementadas

| Pantalla | Archivo | Funcionalidad |
|----------|---------|---------------|
| Login | `login_screen.dart` | Autenticación con JWT |
| Registro | `register_screen.dart` | Crear cuenta con validación @utp.edu.pe |
| Home/Feed | `home_screen.dart` | Ver publicaciones de comunidades |
| Comunidades | `communities_screen.dart` | Listar, crear y unirse a comunidades |
| Detalle Comunidad | `community_detail_screen.dart` | Chat básico de comunidad |
| Crear Post | `create_post_screen.dart` | Publicar en comunidad |
| Detalle Post | `post_detail_screen.dart` | Ver, comentar, like, reportar |
| Perfil | `profile_screen.dart` | Info de usuario y logout |
| Notificaciones | `notifications_screen.dart` | Ver notificaciones |

## 🔑 Providers (State Management)

| Provider | Función |
|----------|---------|
| `AuthProvider` | Manage login, register, logout, user data |
| `CommunityProvider` | Fetch, create, join communities |
| `PostProvider` | Fetch, create posts |
| `CommentProvider` | Fetch, create comments |
| `NotificationProvider` | Fetch notifications |
| `LikeProvider` | Like posts |
| `ReportProvider` | Report content |

## 🔐 Autenticación

```dart
// Flujo de login
1. Usuario ingresa email y contraseña
2. ApiService.post('/auth/login', credentials)
3. Backend valida y retorna JWT token
4. Token se guarda en flutter_secure_storage
5. Se realiza GET /auth/me para obtener datos del usuario
6. AuthProvider actualiza el estado global
7. App navega a pantalla principal
```

## 🌐 Ejemplo de llamada API

```dart
// En user.ts
import 'package:provider/provider.dart';

Future<void> loginUser(String email, String password) async {
  final res = await ApiService.post('/auth/login', {
    'email': email,
    'password': password,
  });
  
  if (res.statusCode == 200) {
    final data = jsonDecode(res.body);
    final token = data['token'];
    await ApiService.saveToken(token);
    // ... navegar a home
  }
}
```

## 📊 Modelo de datos

### User (Usuario)
```dart
{
  "id": 1,
  "email": "student@utp.edu.pe",
  "nombre": "Juan Pérez"
}
```

### Community (Comunidad)
```dart
{
  "id": 1,
  "nombre": "Programadores",
  "descripcion": "Comunidad de desarrollo"
}
```

### Post (Publicación)
```dart
{
  "id": 1,
  "usuario_id": 1,
  "comunidad_id": 1,
  "contenido": "Hola a todos!",
  "fecha": "2024-01-01T12:00:00Z"
}
```

### Comment (Comentario)
```dart
{
  "id": 1,
  "usuario_id": 2,
  "publicacion_id": 1,
  "contenido": "Excelente post!",
  "fecha": "2024-01-01T12:30:00Z"
}
```

## 🔄 Flujos principales

### 1. Registro
```
RegisterScreen
    ↓
AuthProvider.register()
    ↓
POST /auth/register
    ↓
Backend: bcrypt hash password + INSERT usuarios
    ↓
Respuesta: 201 Created
    ↓
Navegar a Login
```

### 2. Timeline de comunidades
```
HomeScreen
    ↓
PostProvider.fetchPostsByCommunity(1)
    ↓
GET /posts/community/1
    ↓
Mostrar lista de posts en ListView
```

### 3. Crear publicación
```
CreatePostScreen
    ↓
PostProvider.createPost(comunidadId, contenido)
    ↓
POST /posts (con JWT auth)
    ↓
Backend: INSERT publicaciones + INSERT logs_sistema
    ↓
Actualizar feed automáticamente
```

### 4. Comentar en post
```
PostDetailScreen
    ↓
CommentProvider.createComment(postId, contenido)
    ↓
POST /comments (con JWT auth)
    ↓
Backend: INSERT comentarios + INSERT logs_sistema
    ↓
Refrescar lista de comentarios
```

## 🚀 Cómo ejecutar

### Paso 1: Inicia el backend
```bash
cd backend
npm run dev
# Verás: "Servidor escuchando en el puerto 3000"
```

### Paso 2: Inicia la app Flutter
```bash
cd utp_comunidades_app
flutter run
```

### Paso 3: Usa la app
- Registrate con un email @utp.edu.pe
- Crea una comunidad
- Crea publicaciones
- Únete a otras comunidades
- Comenta, da like, reporta

## 🔒 Tokens JWT

La app maneja tokens JWT automáticamente:

```dart
// En api_service.dart
static Future<http.Response> post(String endpoint, Map<String, dynamic> data, {bool auth = false}) {
  final headers = {'Content-Type': 'application/json'};
  if (auth) {
    final token = await getToken();
    if (token != null) headers['Authorization'] = 'Bearer $token';
  }
  return http.post(Uri.parse('$baseUrl$endpoint'), headers: headers, body: jsonEncode(data));
}
```

## 📝 Logs del sistema

El backend registra automáticamente:
- Creación de comunidades
- Creación de publicaciones
- Creación de comentarios
- Reportes de usuarios

Verifica `logs_sistema` en la base de datos para auditoría.

## ✅ Checklist de funcionalidad

- [x] Login e inicio de sesión
- [x] Registro con validación @utp.edu.pe
- [x] Ver comunidades
- [x] Crear comunidades
- [x] Unirse a comunidades
- [x] Ver publicaciones del feed
- [x] Crear publicaciones
- [x] Ver detalles de publicación
- [x] Comentar
- [x] Dar like
- [x] Reportar contenido
- [x] Ver notificaciones
- [x] Perfil de usuario
- [x] Cerrar sesión
- [x] Chat básico en comunidades

## 🎯 Próx pasos para mejorar

1. **Chat en tiempo real**: Implementar WebSockets con Socket.io
2. **Búsqueda**: Agregar búsqueda de comunidades y usuarios
3. **Media**: Permitir compartir imágenes y videos
4. **Roles**: Sistema de moderadores y administradores
5. **Push Notifications**: Notificaciones en tiempo real
6. **Offline Mode**: Funcionalidad offline básica

## 📞 Soporte

Para problemas de conexión:
1. Verifica que backend corre en Puerto 3000
2. Usa la IP correcta en `constants.dart`
3. Para emulador: `http://10.0.2.2:3000/api`
4. Para dispositivo: `http://192.168.x.x:3000/api`

---

✅ **La app está lista para usar completamente funcional!**
