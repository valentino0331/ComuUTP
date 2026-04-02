# UTP Comunidades App (Flutter)

Una aplicación móvil completa para estudiantes de la Universidad Tecnológica del Perú (UTP) para conectarse, formar comunidades y compartir contenido académico y social.

## ✨ Características principales

✅ **Autenticación**: Registro e inicio de sesión con correo institucional (@utp.edu.pe)  
✅ **Comunidades**: Crear, listar y unirse a comunidades universitarias  
✅ **Publicaciones**: Crear y compartir posts en tus comunidades  
✅ **Comentarios**: Interactuar comentando en publicaciones  
✅ **Likes**: Dar like a publicaciones  
✅ **Notificaciones**: Recibir notificaciones de actividad  
✅ **Reportes**: Reportar contenido inapropiado  
✅ **Perfil**: Ver información de usuario  
✅ **Chat básico**: Comunicarte en comunidades  
✅ **State Management**: Sistema global con Provider  

## 📁 Estructura del proyecto

```
lib/
├── main.dart                       # Punto de entrada
├── models/                         # Modelos de datos
│   ├── user.dart
│   ├── community.dart
│   ├── post.dart
│   ├── comment.dart
│   └── message.dart
├── services/
│   └── api_service.dart           # Cliente HTTP para la API
├── providers/                      # State management con Provider
│   ├── auth_provider.dart
│   ├── community_provider.dart
│   ├── post_provider.dart
│   ├── comment_provider.dart
│   ├── notification_provider.dart
│   ├── like_provider.dart
│   └── report_provider.dart
├── screens/                        # Pantallas principales
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── main_scaffold.dart
│   ├── home_screen.dart
│   ├── communities_screen.dart
│   ├── community_detail_screen.dart
│   ├── create_post_screen.dart
│   ├── post_detail_screen.dart
│   ├── profile_screen.dart
│   └── notifications_screen.dart
├── widgets/                        # Widgets reutilizables
│   ├── post_card.dart
│   ├── community_card.dart
│   └── bottom_nav.dart
└── utils/                          # Utilidades
    ├── dialogs.dart
    └── constants.dart
```

## 🚀 Guía de instalación

### Requisitos
- Flutter SDK 3.0+
- Dart SDK 3.0+
- Android Studio o VS Code
- Emulador o dispositivo físico
- Backend Node.js corriendo en puerto 3000

### Pasos

1. **Entra a la carpeta del proyecto**
   ```bash
   cd utp_comunidades_app
   ```

2. **Instala las dependencias**
   ```bash
   flutter pub get
   ```

3. **Configura la API**
   - Abre `lib/utils/constants.dart`
   - Actualiza `apiBaseUrl`:
     - **Emulador Android**: `http://10.0.2.2:3000/api`
     - **Dispositivo físico**: `http://TU_IP_LOCAL:3000/api`

4. **Ejecuta la app**
   ```bash
   flutter run
   ```

## 📱 Flujo de la aplicación

### 1️⃣ Login & Registro
- Inicia sesión con tu correo @utp.edu.pe
- Registra una nueva cuenta si no tienes
- Los tokens se guardan de manera segura

### 2️⃣ Home (Feed)
- Ve publicaciones de todas tus comunidades
- Crea nuevas publicaciones
- Comenta, da like y reporta contenido

### 3️⃣ Comunidades
- Explora todas las comunidades disponibles
- Crea nuevas comunidades
- Únete a comunidades que te interesen

### 4️⃣ Notificaciones
- Recibe notificaciones de actividad
- Manténte actualizado sobre tu comunidad

### 5️⃣ Perfil
- Ve tu información de usuario
- Cierra sesión

## 🔌 Endpoints de la API utilizados

```
POST   /auth/register              - Crear nueva cuenta
POST   /auth/login                 - Iniciar sesión
GET    /auth/me                    - Datos del usuario actual
GET    /users/profile              - Perfil del usuario
POST   /communities                - Crear comunidad
GET    /communities                - Listar todas las comunidades
POST   /communities/join           - Unirse a comunidad
POST   /posts                      - Crear publicación
GET    /posts/community/:id        - Ver posts de una comunidad
POST   /comments                   - Agregar comentario
POST   /likes                      - Dar like a post
POST   /reports                    - Reportar contenido
GET    /notifications              - Ver notificaciones
```

## 📦 Dependencias principales

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.1                      # Peticiones HTTP
  provider: ^6.1.2                  # State management
  flutter_secure_storage: ^9.0.0    # Almacenamiento seguro
  cupertino_icons: ^1.0.6           # Iconos iOS
```

## 🔐 Seguridad

- ✅ Tokens JWT almacenados en almacenamiento seguro
- ✅ Validación de correos UTP en cliente y servidor
- ✅ Contraseñas encriptadas con bcrypt
- ✅ Middleware de autenticación en todas las rutas

## 🛠️ Desarrollo

Para agregar nuevas características:

1. **Crear modelo** → `lib/models/new_model.dart`
2. **Crear provider** → `lib/providers/new_provider.dart`
3. **Crear pantalla** → `lib/screens/new_screen.dart`
4. **Añadir rutas** → Actualizar `main.dart`
5. **Conectar API** → Usar `ApiService` desde el provider

## 🐛 Troubleshooting

| Problema | Solución |
|----------|----------|
| "Connection refused" | Verifica que backend corra en puerto 3000 |
| API no responde | Usa IP correcta en `constants.dart` |
| Token inválido | Vuelve a iniciar sesión |
| Correo rechazado | Usa un correo que termine en @utp.edu.pe |

## 📝 Ejemplos de uso

### Iniciar sesión
```dart
final authProvider = Provider.of<AuthProvider>(context);
await authProvider.login('user@utp.edu.pe', 'password123');
```

### Crear comunidad
```dart
final communityProvider = Provider.of<CommunityProvider>(context);
await communityProvider.createCommunity('Mi comunidad', 'Descripción');
```

### Crear post
```dart
final postProvider = Provider.of<PostProvider>(context);
await postProvider.createPost(1, 'Mi contenido');
```

## 🚀 Features por implementar

- [ ] Chat en tiempo real con WebSockets
- [ ] Búsqueda de comunidades y usuarios
- [ ] Editar y eliminar posts
- [ ] Cargar imágenes
- [ ] Modo offline
- [ ] Integración de redes sociales

## 📄 Licencia

Proyecto educativo para UTP - 2024

## 👨‍💻 Desenvolvimiento

La app está completamente lista para usar con tu backend Node.js/Express/PostgreSQL. Solo asegúrate de:

1. ✅ Tener el backend corriendo
2. ✅ Configurar la URL base de la API
3. ✅ Tener la base de datos PostgreSQL creada
4. ✅ Ejecutar `flutter pub get` e `flutter run`

¡Disfruta tu app de comunidades! 🎉
