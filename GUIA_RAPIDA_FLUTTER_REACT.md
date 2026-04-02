# 🚀 Guía Rápida - Flutter + React

## 📱 FLUTTER (Móvil)

### ✅ Que se implementó:

1. **AppTheme** (`lib/theme/app_theme.dart`)
   - Color rojo UTP (#ED1C24)
   - Tema Material 3 completo
   - Tipografía profesional
   - Botones y inputs personalizados

2. **PantallaInicio** (Splash Screen)
   - Logo animado con FadeTransition
   - Duración 4 segundos
   - Indicador de carga circular
   - Navegación automática a login

3. **PantallaLogin** (Login mejorado)
   - Validación de @utp.edu.pe
   - Mostrar/ocultar contraseña
   - Indicador visual de email válido
   - Integración con AuthProvider
   - Manejo de errores completo

4. **PantallaFeed** (Feed mejorado)
   - Grid de publicaciones con tarjetas
   - Avatar de usuario
   - Nombre, comunidad y timestamp
   - Botones: Like, Comentarios, Compartir
   - Pull-to-refresh
   - Estados: cargando, error, vacío

### 🔧 Cómo usar:

```bash
cd utp_comunidades_app

# 1. Actualizar main.dart:
# Reemplaza el código antiguo con:
# - Importar: import 'theme/app_theme.dart';
# - Importar: import 'screens/splash_screen.dart';
# - Theme: theme: AppTheme.temaClaro(),
# - Route inicial: initialRoute: '/splash',

# 2. Instalar/actualizar dependencias
flutter pub get

# 3. Ejecutar
flutter run
```

### 📂 Archivos creados:
- `lib/theme/app_theme.dart` - Tema global
- `lib/screens/splash_screen.dart` - Splash animado
- `lib/screens/login_screen_new.dart` - Login mejorado
- `lib/screens/home_screen_new.dart` - Feed mejorado

### 🎯 Qué se ve:
```
[Splash Screen 4s]  →  [Login @utp.edu.pe]  →  [Feed de Posts]
```

---

## 🌐 REACT (Web)

### ✅ Que se implementó:

1. **CSS Completo** (global.css + components.css)
   - Colores UTP idénticos a Flutter
   - Flexbox y CSS Grid
   - Animaciones suaves
   - Responsive (móvil → escritorio)
   - Variables CSS normalizadas

2. **SplashScreen.js**
   - Logo animado (fade + scale)
   - Spinner de carga
   - Duración 4 segundos
   - Transiciones fluidas

3. **Login.js**
   - Validación @utp.edu.pe en tiempo real
   - Toggle de mostrar contraseña
   - Integración con API backend
   - Almacenamiento de token en localStorage
   - Manejo de errores visual

4. **Feed.js**
   - Lista de posts con tarjetas
   - Avatar con letra de usuario
   - Información del autor y comunidad
   - Contador de likes y comentarios
   - Botones de acción interactivos
   - Estados: cargando, error, vacío

5. **API Service** (apiService.js)
   - Cliente HTTP centralizado
   - Manejo automático de tokens JWT
   - Timeouts de 5 segundos
   - Funciones para: Auth, Posts, Likes, Comentarios, etc.

### 🔧 Cómo usar:

```bash
cd web

# 1. Instalar dependencias
npm install

# 2. Crear archivo .env
cp .env.example .env

# 3. Editar .env (si backend no está en localhost:3000)
REACT_APP_API_URL=http://localhost:3000/api

# 4. Iniciar
npm start
```

Abrirá automáticamente en `http://localhost:3000`

### 📂 Estructura:
```
web/
├── src/
│   ├── components/          # SplashScreen, Login, Feed
│   ├── services/            # apiService.js
│   ├── styles/              # global.css, components.css
│   ├── App.js               # Enrutador principal
│   └── index.js             # Punto de entrada
├── public/
│   └── index.html
└── package.json
```

### 🎯 Qué se ve:
```
[Splash 4s]  →  [Login Web]  →  [Feed Responsivo]
```

---

## 🎨 Identidad Visual Idéntica

Ambas versiones comparten:

| Aspecto | Valor |
|---------|-------|
| Color Primario | #ED1C24 (Rojo UTP) |
| Color Oscuro | #b3151b |
| Fondo Claro | #F5F5F5 |
| Border Radius | 16px (cards) / 30px (botones) |
| Sombra | 4px 12px rgba(0,0,0,0.08) |
| Tipografía | Roboto (Flutter) / System (React) |
| Animaciones | Smooth 0.3s |

---

## 🔌 Integración Backend

### Endpoints principales que se usan:

**Autenticación:**
```
POST /api/auth/register    { email, nombre, password }
POST /api/auth/login       { email, password }
GET  /api/auth/me          (Bearer token)
```

**Publicaciones:**
```
GET  /api/posts/feed       (feed del usuario)
POST /api/posts            { comunidad_id, contenido }
```

**Interacción:**
```
POST /api/likes            { publicacion_id }
POST /api/comments         { publicacion_id, contenido }
```

### Headers automáticos en React:
```javascript
{
  'Content-Type': 'application/json',
  'Authorization': 'Bearer {token}'
}
```

---

## 📋 Checklist de Instalación

### Flutter: ✅
- [x] AppTheme con colores UTP
- [x] SplashScreen animado
- [x] LoginScreen con validación @utp.edu.pe
- [x] FeedScreen con posts
- [x] Material 3 integrado
- [x] Comentarios en español

### React: ✅
- [x] CSS puro (NO Tailwind, NO Bootstrap)
- [x] SplashScreen.js animado
- [x] Login.js con validación
- [x] Feed.js responsivo
- [x] apiService.js centralizado
- [x] LocalStorage para tokens
- [x] Responsive (móvil + escritorio)

---

## 🚀 Deploy

### Flutter:
```bash
# Android
flutter build apk

# iOS
flutter build ios

# Web Flutter (opcional)
flutter build web
```

### React:
```bash
# Build para producción
npm run build

# Deploy en:
# - Vercel (recomendado): vercel deploy
# - Netlify: netlify deploy --prod
# - Firebase: firebase deploy --only hosting
```

---

## 🐛 Troubleshooting

**Flutter no inicia:**
- Verifica: `flutter doctor`
- Reinstala dependencias: `flutter pub get`

**React muestra error de conexión:**
- Backend debe estar en `localhost:3000`
- Verifica: `npm run start`

**Estilos no cargan en React:**
- Limpia caché: `npm cache clean --force`
- Reinstala: `rm -rf node_modules && npm install`

---

## 📞 Soporte rápido

**Para ambas versiones:**
```bash
# Ver estructura
tree -L 3

# Ver logs
# Flutter: Ver output de flutter run
# React: Ver console del navegador (F12)

# Limpiar
# Flutter: flutter clean && flutter pub get
# React: npm cache clean && npm install
```

---

**Desarrollo completado**: ✅ Abril 1, 2026

- ✅ Flutter app idéntica
- ✅ React web identical design
- ✅ CSS puro (Flexbox + Grid)
- ✅ Validación completa
- ✅ Integración API

¡Disfruta tu plataforma de comunidades! 🎉
