# 🔐 Política de Seguridad - UTP Comunidades

## 1. Versión y Control

**Versión**: 1.0.0  
**Fecha de emisión**: 2024-01-15  
**Responsable**: Equipo de Seguridad  
**Próxima revisión**: 2024-07-15

---

## 2. Principios de Seguridad

### 2.1 Confidencialidad
- Datos sensibles encriptados en tránsito (HTTPS/TLS)
- Datos sensibles encriptados en reposo
- Acceso limitado por rol
- Tokens con expiración

### 2.2 Integridad
- Contraseñas hasheadas (bcrypt, no reversibles)
- Validación de datos en cada capa
- Firma de tokens JWT
- Logs de auditoría

### 2.3 Disponibilidad
- Manejo de errores sin exposición de información
- Rate limiting en endpoints críticos
- Validación de tamaño de payloads
- Backups y recuperación

---

## 3. Gestión de Credenciales

### 3.1 Contraseñas
```
Requisitos mínimos:
✅ Longitud: 8+ caracteres
✅ Contiene mayúscula, minúscula, número, símbolo
✅ Hash: bcrypt con salt rounds=10
✅ Nunca: Plain-text, en logs, en email
```

### 3.2 Tokens JWT
```
Configuración:
✅ Expiración: 24 horas
✅ Algoritmo: HS256
✅ Firma: JWT_SECRET (mínimo 32 caracteres)
✅ Almacenamiento: HttpOnly cookie o localStorage
```

### 3.3 Variables de Entorno
```
DEBE estar en .env (NUNCA en .env.example):
- JWT_SECRET
- DB_PASSWORD
- API_KEYS (si aplica)
- OTROS_SECRETOS

NUNCA hardcodear secretos en el código
```

---

## 4. Autenticación y Autorización

### 4.1 Flujo de Autenticación
```
1. Usuario ingresa email + contraseña
2. Validar formato de email
3. Buscar usuario en BD
4. Comparar contraseña con hash bcrypt
5. Si válido: generar JWT con exp=24h
6. Responder con token
7. Cliente almacena token
8. Incluir en header Authorization: Bearer <token>
```

### 4.2 Validación de Token
```
Cada request protegido debe:
1. Extraer token del header
2. Verificar presencia del token
3. Verificar firma JWT
4. Verificar expiración
5. Extraer user_id del payload
6. Validar que usuario exista
7. Proceder con operación
```

### 4.3 Control de Acceso
```
Por rol (si implementar):
- ADMIN: todos los permisos
- MODERATOR: gestionar reportes, baneos
- USER: operaciones básicas
- GUEST: solo lectura

Validación:
✅ usuario.role >= requerido.role
```

---

## 5. Validación de Datos

### 5.1 Email
```javascript
✅ Formato: regex o librería
✅ Dominio válido: MX record check (opcional)
✅ Único en BD: consulta antes de crear
✅ Sanitizado: trim(), lowercase()
```

### 5.2 Contraseña
```javascript
✅ Longitud: 8-128 caracteres
✅ Complejidad: mayús + minús + número + símbolo
✅ No: espacios al inicio/fin
✅ Verificar contra lista de contraseñas comunes
```

### 5.3 Nombres y Strings
```javascript
✅ Longitud válida: 1-200 caracteres
✅ Caracteres permitidos: alfanuméricos + espacios + básicos
✅ Sin: <<<, >>>>, scripts, comandos SQL
✅ Trim y normalización Unicode
```

### 5.4 IDs y números
```javascript
✅ Tipo: integer, positivo
✅ Rango: validar que tenga sentido
✅ Formato: número puro, sin caracteres especiales
```

### 5.5 Payloads
```
✅ Tamaño máximo: 10MB
✅ Content-Type correcto
✅ Body presente para POST/PUT
✅ Estructura esperada
```

---

## 6. Protección contra Ataques

### 6.1 SQL Injection
```javascript
✅ NUNCA: concatenar strings en queries
❌ NUNCA: SELECT * FROM users WHERE id = ' + id
✅ SIEMPRE: Usar prepared statements
✅ SIEMPRE: Validar tipos de datos
```

### 6.2 Cross-Site Scripting (XSS)
```javascript
✅ Sanitizar inputs en frontend
✅ Escapar outputs en HTML
✅ Usar Content Security Policy headers
✅ Validar y filtrar en backend
```

### 6.3 Cross-Site Request Forgery (CSRF)
```javascript
✅ CSRF tokens en formularios
✅ SameSite cookies
✅ Validar Origin header
✅ POST para operaciones sensibles
```

### 6.4 Brute Force
```
✅ Rate limiting:
  - Login: máx 5 intentos por 15 minutos
  - API: máx 100 requests por minuto
✅ Lockout temporal después de intentos fallidos
✅ Alertar sobre intentos sospechosos
```

### 6.5 Archivo Uploads (si aplica)
```javascript
✅ Validar tipo de archivo
✅ Validar tamaño (máx 50MB)
✅ Verificar magic bytes
✅ Almacenar en carpeta protegida
✅ Generar nombre aleatorio
✅ Servir con headers de seguridad
```

---

## 7. Logging de Seguridad

### 7.1 Eventos a Registrar
```
✅ Login exitoso: [usuario, IP, timestamp]
✅ Login fallido: [email, IP, timestamp, razón]
✅ Cambio de contraseña: [usuario, timestamp]
✅ Cambio de email: [usuario, antiguo, nuevo]
✅ Creación/eliminación de usuario: [actor, target, timestamp]
✅ Cambios de rol: [usuario, antiguo rol, nuevo rol]
✅ Acceso denegado: [usuario/IP, recurso, motivo]
✅ Errores de validación: [tipo, usuario, IP]
```

### 7.2 Información NUNCA a Registrar
```
❌ Contraseñas (ni hasheadas)
❌ Tokens JWT completos
❌ Números de tarjeta
❌ Datos personales sensibles
❌ Request bodies completos
```

### 7.3 Formato de Log de Seguridad
```
[TIMESTAMP] [LEVEL] [MÓDULO] [EVENTO] [DETALLES]

Ejemplo:
[2024-01-15 10:30:45] [WARN] [AuthController] LOGIN_FAILED email=user@example.com IP=192.168.1.1 reason=invalid_credentials
[2024-01-15 10:30:46] [INFO] [UserController] USER_CREATED user_id=123 creator_id=1 timestamp=2024-01-15T10:30:46Z
[2024-01-15 10:30:47] [ERROR] [ReportController] INVALID_REPORT_DATA user_id=456 IP=192.168.1.2 reason=missing_field type
```

---

## 8. Headers de Seguridad HTTP

```
Todos los responses deben incluir:

✅ Content-Security-Policy: "default-src 'self'"
✅ X-Content-Type-Options: nosniff
✅ X-Frame-Options: DENY
✅ X-XSS-Protection: 1; mode=block
✅ Strict-Transport-Security: max-age=31536000
✅ Referrer-Policy: strict-origin-when-cross-origin
```

---

## 9. HTTPS/TLS

```
✅ SIEMPRE usar HTTPS en producción
✅ Redirigir HTTP → HTTPS
✅ TLS 1.2 mínimo (1.3 preferible)
✅ Certificados válidos y actualizados
✅ HSTS enabled
✅ Verificación de certificado en cliente
```

---

## 10. CORS (Cross-Origin Resource Sharing)

```javascript
Configuración:
✅ Origen permitido: dominio de frontend
✅ Métodos: GET, POST, PUT, DELETE, OPTIONS
✅ Headers: Content-Type, Authorization
✅ Credenciales: allow credentials si necesario
✅ NUNCA: origen *

Código esperado:
app.use(cors({
  origin: process.env.FRONTEND_URL,
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
```

---

## 11. Acceso a BD

### 11.1 Credenciales
```
✅ Usuario de BD con permisos mínimos requeridos
✅ Contraseña fuerte (32+ caracteres, aleatoria)
✅ Almacenar en variables de entorno
✅ No compartir entre ambientes
```

### 11.2 Conexiones
```
✅ Pool de conexiones configurado
✅ Timeout de conexión: 5000ms
✅ Máximo de conexiones: 20
✅ SSL/TLS para conexiones remotas
```

### 11.3 Operaciones
```
✅ Backup automático diario
✅ Verificar integridad referencial
✅ Índices en columnas críticas
✅ Monitorear crecimiento de BD
```

---

## 12. Procedimientos de Seguridad

### 12.1 Incidente de Seguridad
1. Identificar: ¿Qué pasó?
2. Contener: Limitar el daño
3. Investigar: ¿Cómo pasó? ¿Cuándo?
4. Remediar: Corregir la vulnerabilidad
5. Documentar: Registro del incidente
6. Prevenir: Mecanismos para evitar repetir

### 12.2 Cambio de Credenciales de Producción
1. Generar credencial nueva
2. Probar en staging
3. Actualizar en producción
4. Verificar funcionamiento
5. Eliminar credencial vieja
6. Documentar cambio
7. Notificar al equipo

### 12.3 Auditoría de Seguridad
```
Trimestral:
✅ Revisar logs de seguridad
✅ Validar configuraciones
✅ Pruebas de penetración simuladas
✅ Verificar cumplimiento de políticas

Anual:
✅ Auditoría de seguridad completa
✅ Actualización de políticas
✅ Capacitación de equipo
✅ Pentest externo recomendado
```

---

## 13. Cumplimiento Legal

### 13.1 Privacidad (GDPR, CCPA si aplica)
```
✅ Recolectar solo datos necesarios
✅ Consentimiento documentado
✅ Derecho a acceso a datos
✅ Derecho a eliminación ("right to be forgotten")
✅ Portabilidad de datos
```

### 13.2 Retención de Datos
```
✅ Logs de acceso: 90 días
✅ Logs de error: 30 días
✅ Datos de usuario: hasta solicitud de eliminación
✅ Backups: 6 meses
✅ Documentar política
```

---

## 14. Plan de Respuesta a Incidentes

### 14.1 Contactos de Emergencia
```
Responsable de Seguridad: [Info de contacto]
DevOps Lead: [Info de contacto]
Project Manager: [Info de contacto]
```

### 14.2 Escalación
```
Crítico (P1): Inmediato, notificar a todos
Alto (P2): Dentro de 1 hora
Medio (P3): Dentro de 24 horas
Bajo (P4): En próximo sprint
```

---

## 15. Capacitación y Conciencia

### 15.1 Obligatorio para todo el equipo
```
✅ Fundamentos de seguridad
✅ OWASP Top 10
✅ Prácticas de codificación segura
✅ Manejo de secretos
✅ Respuesta a incidentes
```

### 15.2 Revisión Anual
```
✅ Actualización de políticas
✅ Nuevas vulnerabilidades
✅ Casos de estudio
✅ Mejores prácticas actuales
```

---

## Contacto y Preguntas

Para preguntas de seguridad, contactar al equipo de seguridad.

**Nota importante**: Esta política debe ser revisada y actualizada regularmente. Cualquier incidencia de seguridad debe ser reportada inmediatamente.

---

**Aprobado por**: Equipo de Desarrollo  
**Fecha de aprobación**: 2024-01-15
