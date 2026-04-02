# ⚙️ Guía de Configuración - UTP Comunidades

## Paso 1: Configurar la Base de Datos PostgreSQL

### Crear la base de datos

```sql
-- Conéctate a PostgreSQL
psql -U postgres

-- Crear base de datos
CREATE DATABASE UTP;

-- Conectarse a la BD
\c UTP

-- Crear tablas
CREATE TABLE usuarios (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  nombre VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE comunidades (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(255) NOT NULL,
  descripcion TEXT,
  creador_id INTEGER NOT NULL REFERENCES usuarios(id),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE miembros_comunidad (
  usuario_id INTEGER NOT NULL REFERENCES usuarios(id),
  comunidad_id INTEGER NOT NULL REFERENCES comunidades(id),
  PRIMARY KEY (usuario_id, comunidad_id)
);

CREATE TABLE publicaciones (
  id SERIAL PRIMARY KEY,
  usuario_id INTEGER NOT NULL REFERENCES usuarios(id),
  comunidad_id INTEGER NOT NULL REFERENCES comunidades(id),
  contenido TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE comentarios (
  id SERIAL PRIMARY KEY,
  usuario_id INTEGER NOT NULL REFERENCES usuarios(id),
  publicacion_id INTEGER NOT NULL REFERENCES publicaciones(id),
  contenido TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE likes_publicaciones (
  usuario_id INTEGER NOT NULL REFERENCES usuarios(id),
  publicacion_id INTEGER NOT NULL REFERENCES publicaciones(id),
  PRIMARY KEY (usuario_id, publicacion_id)
);

CREATE TABLE reportes (
  id SERIAL PRIMARY KEY,
  usuario_id INTEGER NOT NULL REFERENCES usuarios(id),
  tipo VARCHAR(50) NOT NULL,
  referencia_id INTEGER NOT NULL,
  motivo TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE baneos (
  id SERIAL PRIMARY KEY,
  usuario_id INTEGER NOT NULL REFERENCES usuarios(id),
  comunidad_id INTEGER REFERENCES comunidades(id),
  motivo TEXT NOT NULL,
  moderador_id INTEGER REFERENCES usuarios(id),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE notificaciones (
  id SERIAL PRIMARY KEY,
  usuario_id INTEGER NOT NULL REFERENCES usuarios(id),
  mensaje TEXT NOT NULL,
  leido BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE logs_sistema (
  id SERIAL PRIMARY KEY,
  usuario_id INTEGER REFERENCES usuarios(id),
  accion VARCHAR(255) NOT NULL,
  descripcion TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## Paso 2: Configurar Backend

### Archivo .env del backend

```bash
# backend/.env

DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=1234
DB_NAME=UTP
JWT_SECRET=supersecretkey-cambiar-en-produccion
PORT=3000
NODE_ENV=development
```

### Instalar y ejecutar

```bash
cd backend

# Instalar dependencias
npm install

# Ejecutar en desarrollo
npm run dev

# Verás:
# Servidor escuchando en el puerto 3000
```

## Paso 3: Configurar Frontend Flutter

### Archivo constants.dart

```dart
// lib/utils/constants.dart

class AppConstants {
  // Para emulador Android
  static const String apiBaseUrl = 'http://10.0.2.2:3000/api';
  
  // Para dispositivo físico (reemplaza con tu IP)
  // static const String apiBaseUrl = 'http://192.168.1.100:3000/api';
  
  // Para otro framework (reemplaza localhost)
  // static const String apiBaseUrl = 'http://localhost:3000/api';
  
  static const String appName = 'UTP Comunidades';
}
```

### Instalar y ejecutar

```bash
cd utp_comunidades_app

# Instalar dependencias
flutter pub get

# Correr en emulador o dispositivo
flutter run
```

## Paso 4: Probar la aplicación

### Test de registro

1. Abre la app Flutter
2. Haz clic en "Regístrate aquí"
3. Ingresa:
   - **Nombre**: Juan Pérez
   - **Email**: juan@utp.edu.pe
   - **Contraseña**: password123
4. Haz clic en "Registrarse"

### Test de login

1. Ingresa el correo: juan@utp.edu.pe
2. Ingresa la contraseña: password123
3. Haz clic en "Entrar"
4. Deberías ver el home con el feed

### Test de comunidades

1. Toca "Comunidades" en la barra inferior
2. Haz clic en el botón + de la esquina superior derecha
3. Crea una comunidad:
   - **Nombre**: Programadores
   - **Descripción**: Para desarrolladores
4. Haz clic en "Crear"

### Test de publicación

1. Vuelve a "Inicio"
2. Haz clic en el botón + flotante
3. Selecciona la comunidad creada
4. Escribe: "¡Hola a todos!"
5. Haz clic en "Publicar"

## Configuración avanzada

### Para dispositivo físico

1. **Obtén tu IP local**:
   ```bash
   # Windows
   ipconfig
   # Busca "IPv4 Address"
   
   # Mac/Linux
   ifconfig
   # Busca "inet"
   ```

2. **Actualiza constants.dart**:
   ```dart
   static const String apiBaseUrl = 'http://192.168.1.100:3000/api';
   ```

3. **Asegúrate que estén en la misma red**:
   - Backend en tu computadora
   - Dispositivo conectado a WiFi local

### Para producción

```dart
// Usa HTTPS en producción
static const String apiBaseUrl = 'https://api.utp-comunidades.com/api';
```

```bash
# Backend en servidor
JWT_SECRET=cambiar-secret-seguro
NODE_ENV=production
DB_HOST=ip-servidor-bd
```

## Troubleshooting

### "Connection refused" 10.0.2.2:3000

**Solución**: 
- Verifica que backend corra en puerto 3000
- En Windows: `netstat -ano | findstr :3000`
- En Mac/Linux: `lsof -i :3000`

### "Network error" en dispositivo físico

**Solución**:
- Asegúrate de usar IP correcta en constants.dart
- Ambos dispositivos en la misma red WiFi
- Firewall no bloquea puerto 3000

### "Correo UTP inválido"

**Solución**:
- El email debe terminar en @utp.edu.pe
- SOLO se aceptan correos institucionales

### Contraseña rechazada

**Solución**:
- Mínimo 6 caracteres
- Sin espacios en blanco al inicio/final

### Base de datos vacía

**Solución**:
- Ejecuta los comandos CREATE TABLE arriba
- Verifica que estés usando BD "UTP"

## Variables de entorno importantes

### .env Backend

```bash
# Básicos
DB_HOST=localhost                  # Servidor PostgreSQL
DB_PORT=5432                       # Puerto PostgreSQL
DB_USER=postgres                   # Usuario BD
DB_PASSWORD=1234                   # Contraseña BD
DB_NAME=UTP                        # Nombre BD
JWT_SECRET=supersecretkey          # Secreto JWT
PORT=3000                          # Puerto servidor

# Opcionales
NODE_ENV=development               # development/production
LOG_LEVEL=info                     # debug/info/warn/error
CORS_ORIGIN=*                      # CORS para produción
```

### Constantes Flutter

```dart
// lib/utils/constants.dart

class AppConstants {
  static const String apiBaseUrl = 'http://10.0.2.2:3000/api';
  static const String appName = 'UTP Comunidades';
  
  // Puedes agregar más constantes según necesites
  static const int requestTimeout = 30; // segundos
  static const int retryAttempts = 3;
  
  // Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  // ... más endpoints
}
```

## Estructura de carpetas final

```
utp-comunidades/
├── backend/                        ✅ Completado
│   └── .env                        ✅ Configurado
├── utp_comunidades_app/
│   └── lib/utils/constants.dart    ✅ URL API configurada
├── diseño/
├── README.md                       ✅ Esta carpeta
└── INTEGRACION_COMPLETA.md         ✅ Documentación
```

## Checklist final

- [ ] PostgreSQL instalado y corriendo
- [ ] Base de datos UTP creada y tablas inicializadas
- [ ] Backend configurado con .env correcto
- [ ] Backend ejecutándose en puerto 3000
- [ ] Flutter SDK instalado
- [ ] constants.dart con URL API correcta
- [ ] App Flutter compilando sin errores
- [ ] Prueba de registro exitosa
- [ ] Prueba de login exitosa
- [ ] Prueba de crear comunidad exitosa
- [ ] Prueba de crear post exitosa

## ✅ Listo para usar

Cuando todos los checks estén marcados, tu aplicación está **100% funcional** y lista para usar en producción (con pequeños ajustes de seguridad).

---

**¡Disfruta tu app de comunidades UTP!** 🎉
