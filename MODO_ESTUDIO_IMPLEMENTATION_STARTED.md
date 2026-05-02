# 🎓 Modo Estudio + IA - Guía de Implementación

## ✅ Estado de Implementación

### Backend (Completado ✅)
- ✅ Servicios de negocio (3 archivos)
  - `study.service.js` - Gestión de cursos
  - `material.service.js` - Manejo de materiales
  - `ai.service.js` - Integración con OpenAI

- ✅ Controladores HTTP (3 archivos)
  - `study.controller.js` - Endpoints de cursos
  - `material.controller.js` - Endpoints de materiales
  - `ai.controller.js` - Endpoints de IA

- ✅ Rutas API (3 archivos)
  - `study.routes.js` - `/api/study/*`
  - `materials.routes.js` - `/api/materials/*`
  - `ai.routes.js` - `/api/ai/*`

- ✅ Base de datos
  - 7 tablas creadas en PostgreSQL (Neon)
  - Índices optimizados
  - Foreign keys validadas

### Frontend (Completado ✅)
- ✅ Modelos Flutter
  - `study_models.dart` - StudyCourse, StudyMaterial, AIResponse, StudyQuestion

- ✅ State Management
  - `study_provider.dart` - Provider con métodos para todas operaciones

- ✅ Interfaces de Usuario
  - `study_hub_screen.dart` - Pantalla principal con tabs
  - `course_card.dart` - Widget de tarjeta de curso

---

## 🚀 Cómo Comenzar

### 1. Configurar Variables de Entorno

En `backend/.env`:
```bash
# Existentes
DATABASE_URL=postgresql://usuario:contraseña@neon.db.com/base_datos
JWT_SECRET=tu_secreto_jwt

# Nuevas para Modo Estudio
OPENAI_API_KEY=sk-xxx (de https://platform.openai.com/api-keys)
CLOUDINARY_NAME=tu_nombre_cloudinary
CLOUDINARY_API_KEY=tu_api_key
CLOUDINARY_API_SECRET=tu_api_secret
```

### 2. Instalar Dependencias Necesarias

```bash
# Backend (si no está instalado)
npm install openai cloudinary multer --save

# Frontend (pubspec.yaml)
dependencies:
  provider: ^6.0.0
  http: ^1.1.0
```

### 3. Verificar Integración en Express

El archivo `backend/src/routes/index.js` ya contiene:
```javascript
router.use('/study', require('../../routes/study.routes'));
router.use('/materials', require('../../routes/materials.routes'));
router.use('/ai', require('../../routes/ai.routes'));
```

### 4. Testear con Postman

Importar colección: `STUDY_MODE_POSTMAN.json`

**Endpoints disponibles:**

#### Cursos
```
GET    /api/study/courses              - Listar cursos del usuario
POST   /api/study/courses              - Crear nuevo curso
GET    /api/study/courses/:id          - Detalles del curso
PUT    /api/study/courses/:id          - Actualizar curso
DELETE /api/study/courses/:id          - Archivar curso
```

#### Materiales
```
POST   /api/materials/upload           - Subir PDF/documento
GET    /api/materials/:id              - Obtener material
GET    /api/materials/course/:courseId - Listar materiales por curso
DELETE /api/materials/:id              - Eliminar material
```

#### IA
```
POST   /api/ai/summarize               - Resumir material
POST   /api/ai/explain                 - Explicar concepto
POST   /api/ai/generate-quiz           - Generar cuestionario
POST   /api/ai/ask-question            - Hacer pregunta
GET    /api/ai/responses/:materialId   - Respuestas cacheadas
GET    /api/ai/questions/:courseId     - Preguntas del curso
POST   /api/ai/quiz-attempt            - Enviar intento de quiz
```

---

## 🧪 Ejemplo de Flujo Completo

### 1. Crear Curso
```bash
curl -X POST http://localhost:3000/api/study/courses \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Bases de Datos",
    "course_code": "CS-2024-001",
    "professor_name": "Dr. García",
    "semester": 1,
    "year": 2024
  }'
```

Respuesta:
```json
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "Bases de Datos",
    "course_code": "CS-2024-001",
    ...
  }
}
```

### 2. Subir Material
```bash
curl -X POST http://localhost:3000/api/materials/upload \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -F "courseId=550e8400-e29b-41d4-a716-446655440000" \
  -F "file=@apuntes.pdf"
```

### 3. Resumir Material
```bash
curl -X POST http://localhost:3000/api/ai/summarize \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "materialId": "material-id-here",
    "forceRefresh": false
  }'
```

Respuesta:
```json
{
  "success": true,
  "data": {
    "type": "summary",
    "content": "El documento trata sobre... [resumen de hasta 500 tokens]",
    "tokensUsed": 245,
    "generatedAt": "2024-01-15T10:30:00Z"
  },
  "fromCache": false
}
```

### 4. Generar Cuestionario
```bash
curl -X POST http://localhost:3000/api/ai/generate-quiz \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "courseId": "550e8400-e29b-41d4-a716-446655440000",
    "count": 5,
    "difficulty": "medium"
  }'
```

---

## 📱 Integración en Flutter

### 1. Agregar Provider en main.dart

```dart
import 'package:provider/provider.dart';
import 'providers/study_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StudyModeProvider()),
        // ... otros providers
      ],
      child: MaterialApp(
        home: MainScaffold(),
      ),
    );
  }
}
```

### 2. Agregar Tab en main_scaffold.dart

```dart
class MainScaffold extends StatefulWidget {
  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.groups), label: 'Comunidades'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Estudio'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Mensajes'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
      body: [
        HomePage(),
        CommunitiesPage(),
        StudyHubScreen(),  // 👈 NUEVO
        MessagesPage(),
        ProfilePage(),
      ][_selectedIndex],
    );
  }
}
```

### 3. Usar el Provider en Pantallas

```dart
// En cualquier pantalla
final courses = context.watch<StudyModeProvider>().courses;

// Para cargar datos
Future<void> _loadCourses() async {
  await context.read<StudyModeProvider>().fetchCourses();
}
```

---

## 🗂️ Estructura de Archivos Implementados

```
backend/
├── src/
│   ├── services/
│   │   ├── study.service.js      ✅
│   │   ├── material.service.js   ✅
│   │   └── ai.service.js         ✅
│   ├── controllers/
│   │   ├── study.controller.js   ✅
│   │   ├── material.controller.js ✅
│   │   └── ai.controller.js      ✅
│   └── routes/
│       └── index.js              ✅ (Actualizado)
├── routes/
│   ├── study.routes.js           ✅
│   ├── materials.routes.js       ✅
│   └── ai.routes.js              ✅
└── migrations/
    └── 002-create-study-mode-tables.sql ✅

utp_comunidades_app/
└── lib/
    ├── models/
    │   └── study_models.dart         ✅
    ├── providers/
    │   └── study_provider.dart       ✅
    ├── screens/
    │   └── study_hub_screen.dart     ✅
    └── widgets/
        └── course_card.dart          ✅
```

---

## 🔧 Checklist de Implementación

### Backend
- [x] Servicios de negocio
- [x] Controladores HTTP
- [x] Rutas API
- [x] Integración en index.js
- [ ] **TODO**: Testear todos los endpoints
- [ ] **TODO**: Validación de entrada (sanitization)
- [ ] **TODO**: Manejo de errores mejorado
- [ ] **TODO**: Rate limiting por endpoint

### Frontend
- [x] Modelos de datos
- [x] Provider con state management
- [x] Pantalla principal de Estudio
- [x] Widget de tarjeta de curso
- [ ] **TODO**: Pantalla de detalles del curso
- [ ] **TODO**: Visor de PDF
- [ ] **TODO**: Pantalla de cuestionario
- [ ] **TODO**: Pantalla de chat con IA
- [ ] **TODO**: Integrar en main_scaffold.dart

### Testing & Deployment
- [ ] **TODO**: Pruebas unitarias (backend)
- [ ] **TODO**: Pruebas de integración (backend)
- [ ] **TODO**: Pruebas en Flutter
- [ ] **TODO**: Load testing
- [ ] **TODO**: Seguridad: Rate limiting
- [ ] **TODO**: Seguridad: Validación de permisos

---

## ⚠️ Notas Importantes

1. **Autenticación**: Todos los endpoints requieren JWT Bearer token
2. **Rate Limiting**: Implementar límites para OpenAI API (costo)
3. **Cloudinary**: Configurar carpetas automáticas `/utp/study/{courseId}/`
4. **Base de Datos**: Índices creados para optimizar queries frecuentes
5. **Caché**: Las respuestas de IA se cachean por 24h

---

## 📞 Troubleshooting

### Error: "OpenAI API Key not found"
```
Solución: Verifica que OPENAI_API_KEY esté en .env
```

### Error: "Cloudinary configuration missing"
```
Solución: Configura CLOUDINARY_NAME, CLOUDINARY_API_KEY, CLOUDINARY_API_SECRET
```

### Error: "Database connection failed"
```
Solución: Verifica DATABASE_URL y que las 7 tablas estén creadas en Neon
```

### Error: "Token inválido" en Postman
```
Solución: Obtén un JWT token válido del login y úsalo en Authorization header
```

---

## 📊 KPIs a Monitorear

- **DAU (Daily Active Users)**: Usuarios que usan Modo Estudio
- **Tiempo promedio de sesión**: Objetivo 60+ minutos
- **Retención 30 días**: Objetivo 55%
- **Preguntas generadas por IA**: Métrica de engagement
- **Costo de API**: Monitorear uso de OpenAI

---

**¡Listo para comenzar!** 🎉

Próximos pasos recomendados:
1. Testear endpoints con Postman
2. Verificar autenticación JWT
3. Integrar en Flutter
4. Hacer deployment a Railway
