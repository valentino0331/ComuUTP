# 🌐 UTP Comunidades - Versión Web (React)

Versión web responsive de UTP Comunidades construida con **React** y **CSS puro**.

## 📋 Características

✅ Splash screen animado  
✅ Login con validación @utp.edu.pe  
✅ Feed de publicaciones en tiempo real  
✅ Dar likes y comentarios  
✅ Diseño responsive (móvil y escritorio)  
✅ Diseño idéntico a la versión Flutter  
✅ Integración completa con API Backend  

## 🚀 Inicio rápido

### 1. Instalar dependencias
```bash
cd web
npm install
```

### 2. Configurar variables de entorno
```bash
# Copiar archivo de ejemplo
cp .env.example .env

# Editar .env y ajustar la URL del backend si es necesario
# REACT_APP_API_URL=http://localhost:3000/api
```

### 3. Iniciar aplicación
```bash
npm start
```

La aplicación abrirá automáticamente en `http://localhost:3000`

## 📁 Estructura de carpetas

```
web/
├── public/
│   └── index.html          # HTML principal
├── src/
│   ├── components/
│   │   ├── SplashScreen.js # Pantalla de inicio
│   │   ├── Login.js        # Autenticación
│   │   └── Feed.js         # Feed de publicaciones
│   ├── services/
│   │   └── apiService.js   # Cliente HTTP centralizado
│   ├── styles/
│   │   ├── global.css      # Estilos globales
│   │   └── components.css  # Estilos de componentes
│   ├── App.js              # Componente principal
│   └── index.js            # Punto de entrada
├── package.json
└── README.md
```

## 🎨 Colores y Diseño

- **Primario**: #ED1C24 (Rojo UTP)
- **Secundario**: #b3151b (Rojo oscuro)
- **Fondos**: #FFFFFF y #F5F5F5
- **Border Radius**: 16px (estándar), 30px (botones)

Todos los estilos están en CSS puro usando **Flexbox** y **CSS Grid**.

## 🔌 API Integration

La aplicación se conecta con el backend mediante fetch API con:
- Autenticación por JWT
- Timeout de 5 segundos
- Manejo centralizado de errores
- Headers automáticos

### Endpoints principales

```
POST   /api/auth/register      Registro
POST   /api/auth/login         Login
GET    /api/auth/me            Datos usuario

GET    /api/posts/feed         Obtener feed
POST   /api/posts              Crear post

POST   /api/likes              Dar like
POST   /api/comments           Crear comentario
```

## 📱 Responsividad

La aplicación es **100% responsive**:
- ✅ Móviles (< 480px)
- ✅ Tablets (480px - 768px)
- ✅ Escritorio (> 768px)

## 🛠️ Scripts disponibles

```bash
npm start           # Iniciar servidor de desarrollo
npm run build       # Compilar para producción
npm test            # Ejecutar pruebas
npm run eject       # Configuración avanzada (⚠️ irreversible)
```

## 🔐 Autenticación

- Los tokens JWT se guardan en LocalStorage
- Los usuarios se validan con dominio @utp.edu.pe
- Las contraseñas deben tener mínimo 6 caracteres
- Token automático en headers de API

## 📦 Dependencias principales

- **react**: 18.2.0
- **react-dom**: 18.2.0
- **react-scripts**: 5.0.1

## 🐛 Troubleshooting

| Problema | Solución |
|----------|----------|
| Error de conexión a API | Verifica que el backend está corriendo en `localhost:3000` |
| Token inválido | Limpia caché del navegador y vuelve a iniciar sesión |
| Estilos no cargan | Verifica que los archivos CSS están en `src/styles/` |
| CORS error | Configura CORS en el backend |

## 📌 Notas importantes

1. **Variables de entorno**: Copia `.env.example` a `.env` antes de ejecutar
2. **Backend**: El backend debe estar corriendo en `http://localhost:3000`
3. **Navegador**: Compatible con navegadores modernos (Chrome, Firefox, Safari, Edge)
4. **LocalStorage**: La app usa LocalStorage para guardar tokens y sesión

## 🚀 Deployment (Producción)

```bash
# Compilar para producción
npm run build

# El resultado está en la carpeta 'build/'
# Puedes deployar en:
# - Vercel
# - Netlify
# - Firebase Hosting
# - AWS S3 + CloudFront
# - Azure Static Web Apps
```

## 📖 Documentación completa

Ver [INTEGRACION_COMPLETA.md](../INTEGRACION_COMPLETA.md) para arquitectura y documentación técnica.

---

**Desarrollado con ❤️ para UTP** 🏫

¡Disfruta tu plataforma de comunidades web!
