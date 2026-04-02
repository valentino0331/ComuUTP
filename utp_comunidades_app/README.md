# UTP Comunidades App (Flutter)

## Estructura

- `lib/main.dart`: Punto de entrada
- `lib/screens/`: Pantallas principales (login, home, etc.)
- `lib/models/`: Modelos de datos (User, Community, Post, etc.)
- `lib/services/`: Servicios para consumir la API
- `lib/widgets/`: Widgets reutilizables
- `lib/utils/`: Utilidades

## Dependencias principales
- http
- provider
- flutter_secure_storage

## Primeros pasos

1. Abre esta carpeta en VS Code o Android Studio
2. Ejecuta:
   ```
   flutter pub get
   flutter run
   ```
3. Asegúrate de que el backend esté corriendo y accesible desde el emulador/dispositivo

## Personalización
- Cambia la URL base de la API en `api_service.dart` si usas dispositivo físico
- Agrega el logo de UTP en `assets/utp_logo.png` y registra la carpeta en `pubspec.yaml`

## Pantallas incluidas
- Login (con validación de correo UTP)
- Home/feed (estructura base, lista para personalizar)

## Siguiente paso
- Agrega más pantallas y lógica según el diseño de la imagen y tus necesidades
