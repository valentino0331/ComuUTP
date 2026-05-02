# 📚 MODO ESTUDIO + IA | Design & Implementation System

**Versión:** 1.0  
**Fecha:** Abril 2026  
**Estado:** Ready for Implementation  
**Nivel:** Senior Product Design + Full Stack Architecture

---

## 📋 TABLA DE CONTENIDOS

1. [Vision & Objetivos](#vision)
2. [Análisis de App Actual](#análisis)
3. [Flujo de Usuario Completo](#flujo)
4. [Arquitectura de Pantallas](#pantallas)
5. [Diseño UI/UX Detallado](#diseño)
6. [Arquitectura Técnica](#arquitectura)
7. [Integración IA](#integración-ia)
8. [Ejemplos de Interacción](#ejemplos)
9. [Plan de Implementación](#plan)
10. [Escalabilidad & Performance](#escalabilidad)

---

## 🎯 VISION & OBJETIVOS {#vision}

### Propósito
Convertir tu app de red social en una **plataforma educativa integral** que retenga estudiantes con valor real (no decorativo).

### Métricas de Éxito
- **DAU (Daily Active Users):** +40% con Modo Estudio
- **Session Duration:** +60 minutos promedio
- **User Retention (30d):** >65%
- **Feature Adoption:** >45% dentro de 3 meses

### Core Values del Feature
✅ **Útil**: Resuelve problemas reales de estudiantes  
✅ **Inteligente**: IA que aprende del usuario  
✅ **Minimalista**: Sin saturación visual  
✅ **Consistente**: Alineado con tu diseño actual  
✅ **Escalable**: Preparado para 100K+ usuarios

---

## 🔍 ANÁLISIS DE APP ACTUAL {#análisis}

### Stack Tecnológico Existente

```
FRONTEND (Flutter)
├── State: Provider
├── Auth: Firebase Auth
├── Design: Material 3 (Rojo principal)
└── Navegación: Bottom Nav (4 tabs)

BACKEND (Express.js)
├── DB: PostgreSQL (Neon)
├── Auth: JWT + Firebase UID
├── Upload: Cloudinary
├── Real-time: Socket.io
└── Email: SendGrid

INTEGRACIONES
├── Firebase Core & Auth
├── Cloudinary API
└── SendGrid Mail
```

### Navegación Actual (Bottom Nav)
```
[Home] [Communities] [Notifications] [Profile]
         + FAB (Create Post)
```

### Conclusión del Análisis
✅ **Fortalezas para escalar:**
- Firebase auth ya soporta múltiples providers
- Cloudinary ideal para PDFs + imágenes
- PostgreSQL puede manejar índices para búsqueda semantic
- Socket.io listo para real-time

⚠️ **Consideraciones:**
- No romper la navegación existente
- Agregar sin sobrecargar bottom nav
- IA debe ser asincrónica para no frenar UI

---

## 🚀 FLUJO DE USUARIO COMPLETO {#flujo}

### User Journey Map: Estudiante Promedio

```
DÍA 1: Descubrimiento
├─ Abre app → Ve "Nuevo: Modo Estudio" (badge)
├─ Toca para explorar (onboarding de 3 pasos)
├─ Ve lista de sus cursos (auto-sincronizados)
└─ Crea primer curso manualmente

DÍA 2: Primeras Acciones
├─ Sube PDF del primer parcial
├─ Toca "Resumir" → IA genera 5 puntos
├─ Guarda resumen en historial
└─ Invita amigos a compartir curso

SEMANA 1: Uso Regular
├─ Acumula 3-4 cursos
├─ Sube 8-10 PDFs
├─ Genera 20+ respuestas IA
├─ Intenta "Generar Quiz" (5 preguntas)
└─ Responde quiz, ve feedback

SEMANA 3: Hábito Formado
├─ Estudia 3-4 veces semana
├─ Usa IA para dudas específicas
├─ Colabora con 2-3 amigos en cursos
├─ Accede histórico para repasar examen anterior
└─ Modo Estudio es su 2° app más usada

MES 3: Power User
├─ 15+ PDFs en 5+ cursos
├─ Generó +100 respuestas IA
├─ Compartió 5+ recursos
└─ Modo Estudio es su razón principal usar app
```

### Paths de Entrada al Feature

```
1. DESDE HOME FEED
   Botón flotante o card "Modo Estudio"
   
2. DESDE NUEVA SECCIÓN EN BOTTOM NAV
   Reemplazar o agregar 5to tab
   
3. DESDE PERFIL/MENU
   Link secundario "Mi Estudio"
   
4. ONBOARDING POST-LOGIN
   "¿Usas la app para estudiar? Prueba Modo Estudio"
```

### Acciones Principales por Rol

**ESTUDIANTE**
- Ver cursos
- Subir materiales
- Hacer preguntas
- Responder quiz
- Guardar/Compartir

**ASISTENTE/DELEGADO CURSO**
- Crear curso
- Moderar materiales
- Ver progreso grupo
- Crear banco preguntas

**ADMIN**
- Auditar cursos
- Metrics & analytics
- Gestionar IA

---

## 🎨 ARQUITECTURA DE PANTALLAS {#pantallas}

### PANTALLA 1: Hub de Estudio (Landing)

```
┌─────────────────────────────────┐
│ 🎓 Modo Estudio                 │
├─────────────────────────────────┤
│  [Barra búsqueda de cursos]     │
│  [Filtro: Activos | Guardados]  │
├─────────────────────────────────┤
│ 📚 TUS CURSOS (3 activos)       │
│                                 │
│ ┌─────────────────────────────┐ │
│ │ [Foto] MATE 101             │ │
│ │ Prof: Dr. García    23 PDFs │ │
│ │ 💾 Último acceso: Hoy 3pm  │ │
│ │ ✨ IA disponible           │ │
│ └─────────────────────────────┘ │
│                                 │
│ ┌─────────────────────────────┐ │
│ │ [Foto] PROGRAMACIÓN I       │ │
│ │ Prof: Ing. López    15 PDFs │ │
│ │ 💾 Último acceso: Ayer     │ │
│ │ ✨ IA disponible           │ │
│ └─────────────────────────────┘ │
│                                 │
├─────────────────────────────────┤
│ [+ Crear curso] [+ Unirme]      │
└─────────────────────────────────┘
```

**Componentes:**
- **Header:** Logo Modo Estudio + icono de settings
- **Search Bar:** Buscar cursos por nombre/código
- **Filtros:** Tabs "Activos", "Archivados", "Favoritos"
- **Course Cards:** 
  - Thumbnail + nombre curso
  - Profesor + cantidad PDFs
  - Último acceso
  - Badge "✨ IA disponible"
  - Swipe actions: Abrir | Favorito | Más
- **CTA Bottom:** "+ Crear curso" y "+ Unirme a curso"

---

### PANTALLA 2: Detalle de Curso (Course View)

```
┌─────────────────────────────────┐
│ ◀ MATE 101 - Cálculo I       👤 │
├─────────────────────────────────┤
│ 📊 Progreso: [████░░░] 60%      │
│ 20 PDFs | 35 preguntas | 5 Quiz │
├─────────────────────────────────┤
│ 🔖 ORGANIZACION                 │
│ ├─ Ciclo 1      [→]             │
│ ├─ Parcial I    [→]             │
│ └─ Parcial II   [→]             │
├─────────────────────────────────┤
│ 📚 MATERIALES (20 docs)         │
│                                 │
│ ┌─────────────────────────────┐ │
│ │ 📄 Unidad_1_Basico.pdf      │ │
│ │ 2.3 MB · Hace 3 días        │ │
│ │ [Resumir] [Preguntas] [...]  │ │
│ └─────────────────────────────┘ │
│                                 │
│ ┌─────────────────────────────┐ │
│ │ 📄 Parcial_I_Ejemplos.pdf   │ │
│ │ 1.8 MB · Hace 1 semana      │ │
│ │ [Resumir] [Preguntas] [...]  │ │
│ └─────────────────────────────┘ │
│                                 │
│ ┌─────────────────────────────┐ │
│ │ 📝 Apuntes_Personales.pdf   │ │
│ │ 456 KB · Hace 5 horas       │ │
│ │ [Resumir] [Preguntas] [...]  │ │
│ └─────────────────────────────┘ │
├─────────────────────────────────┤
│ [+ Subir material]              │
└─────────────────────────────────┘
```

**Componentes:**
- **Header:** Curso actual con badge "Activo/Archivado"
- **Progress Bar:** % completado (visual motivador)
- **Stats Row:** PDFs, Preguntas, Quiz
- **Organization Tabs:** Ciclo/Tema/Fecha
- **Material List:**
  - Card por PDF con preview thumbnail
  - Metadata: Tamaño + fecha
  - 3 action buttons: Resumir | Generar Preguntas | Menú
- **Floating Action:** "+ Subir material"

---

### PANTALLA 3: Lector de PDF con IA (PDF Viewer + AI Overlay)

```
┌─────────────────────────────────┐
│ ◀ Unidad_1_Basico.pdf        ⚙️ │
├─────────────────────────────────┤
│                                 │
│ ┌───────────────────────────────┐
│ │ [PDF Render - Página 1]       │
│ │                               │
│ │                               │
│ │ ┌──────────────┐              │
│ │ │ TEXTO PDF    │              │
│ │ │ Con contenido│              │
│ │ │ del documento│              │
│ │ └──────────────┘              │
│ │                               │
│ └───────────────────────────────┘
│                                 │
│ ┌─────────────────────────────┐ │
│ │ ⚡ ¿Necesitas ayuda?        │ │
│ │ [Resumir en 5 puntos]        │ │
│ │ [Explicar simple]            │ │
│ │ [Generar preguntas]          │ │
│ │ [Haz una pregunta]           │ │
│ └─────────────────────────────┘ │
│                                 │
│ Página 1 / 25                   │
└─────────────────────────────────┘
```

**Componentes:**
- **PDF Viewer:** Usando `pdf` package Flutter
- **AI Quick Actions Panel:**
  - Botones contextuales: Resumir, Explicar, Quiz, Preguntar
  - Animación de aparición suave
  - Indicador de carga mientras genera
- **Page Counter:** Posición actual

---

### PANTALLA 4: Respuesta IA (Response Card)

```
┌─────────────────────────────────┐
│ ◀ Resumen: Unidad 1             │
├─────────────────────────────────┤
│ ⏱️ Generado hace 2 min          │
├─────────────────────────────────┤
│ 📋 RESUMEN EN 5 PUNTOS          │
│                                 │
│ 1️⃣  Los límites definen...     │
│     En matemáticas, los límites │
│     son... [más contexto]       │
│                                 │
│ 2️⃣  Propiedades fundamentales  │
│     [contenido]                 │
│                                 │
│ 3️⃣  Derivadas vs Límites       │
│     [contenido]                 │
│                                 │
│ 4️⃣  Aplicaciones prácticas     │
│     [contenido]                 │
│                                 │
│ 5️⃣  Ejercicios tipo examen     │
│     [contenido]                 │
│                                 │
├─────────────────────────────────┤
│ ⭐ [Útil] [⚠️ Revisar] [🗑️]   │
├─────────────────────────────────┤
│ [💾 Guardar] [📤 Compartir]     │
│ [🔗 Copiar link] [🎯 Seguir]    │
└─────────────────────────────────┘
```

**Componentes:**
- **Header:** Tipo de respuesta + timestamp
- **Content Area:** Numerado, con emojis visuales
- **Feedback Buttons:** Útil/Revisar/Borrar (datos para entrenar IA)
- **Action Row:** Guardar, Compartir, Copiar, Enviar como flashcard

---

### PANTALLA 5: Banco de Preguntas & Quiz

```
┌─────────────────────────────────┐
│ ◀ Quiz: Parcial I Simulado   ⏱️ │
├─────────────────────────────────┤
│ Pregunta 1 / 5                  │
│ ⏱️ Tiempo: 15:30                │
├─────────────────────────────────┤
│ ¿Cuál es el concepto clave      │
│ de derivada según la unidad 2?  │
│                                 │
│ ○ Opción A [Distractor]         │
│                                 │
│ ● Opción B [CORRECTA]           │
│                                 │
│ ○ Opción C [Distractor]         │
│                                 │
│ ○ Opción D [Distractor]         │
│                                 │
│ [Saltar] [Responder]            │
│                                 │
│ [████░░░░░] Progreso            │
└─────────────────────────────────┘

DESPUÉS DE RESPONDER:
┌─────────────────────────────────┐
│ ✅ ¡Correcto!                   │
│ Explicación:                    │
│ La derivada es... [contexto]    │
│                                 │
│ 📖 Leer más → Unidad 2          │
│                                 │
│ [Siguiente]                     │
└─────────────────────────────────┘

FINAL:
┌─────────────────────────────────┐
│ 📊 RESULTADO FINAL              │
│ ━━━━━━━━━━━━━━━━━━━━━━━━━━━    │
│ Puntuación: 4/5 (80%)           │
│                                 │
│ ✅ Bueno - Necesitas revisar:   │
│    • Derivadas de funciones     │
│    • Regla de la cadena         │
│                                 │
│ 📚 Materiales recomendados:     │
│    [Unidad 2] [Unidad 3]        │
│                                 │
│ [Reintentar] [Historial] [Home] │
└─────────────────────────────────┘
```

**Componentes:**
- **Quiz Header:** Título + timer + progreso
- **Question Card:** Pregunta + 4 opciones (A/B/C/D)
- **Navigation:** Saltar/Responder
- **Feedback Inmediato:** ✅/❌ + explicación
- **Results Screen:** Score + recomendaciones + links a materiales

---

### PANTALLA 6: Historial & Progreso

```
┌─────────────────────────────────┐
│ ◀ Historial: MATE 101        📊 │
├─────────────────────────────────┤
│ 📈 ESTADÍSTICAS                 │
│ • PDFs revisados: 18/20         │
│ • Resúmenes generados: 12       │
│ • Quiz completados: 7           │
│ • % Material cubierto: 85%      │
│                                 │
│ 🎯 PRÓXIMOS: Parcial II (24d)   │
├─────────────────────────────────┤
│ 📅 ÚLTIMAS ACCIONES             │
│                                 │
│ HOY                             │
│ • ✅ Generaste resumen: Unit_3  │
│ • ✅ Respondiste Quiz: 8/10     │
│                                 │
│ HACE 2 DÍAS                     │
│ • 📄 Subiste: Parcial_I_Sol.pdf │
│ • ❓ Hiciste 3 preguntas (IA)   │
│                                 │
│ HACE 1 SEMANA                   │
│ • 🎓 Generaste 15 flashcards    │
│                                 │
├─────────────────────────────────┤
│ [🔄 Repasar débiles] [📊 Detalle]
└─────────────────────────────────┘
```

---

### PANTALLA 7: Ajustes & Preferencias (Settings)

```
┌─────────────────────────────────┐
│ ◀ Configuración: Modo Estudio    │
├─────────────────────────────────┤
│ 🤖 PREFERENCIAS IA              │
│ • Nivel explicación: Básico ▼   │
│ • Idioma: Español ▼             │
│ • Tipo resumen: Numerado ▼      │
│                                 │
│ 📬 NOTIFICACIONES              │
│ ✓ Recordar estudiar            │
│   (Hora: 19:00)                 │
│ ✓ Nuevas preguntas disponibles  │
│ ○ Sugerencias de estudio       │
│                                 │
│ 💾 DATOS & PRIVACIDAD          │
│ • IA accede a: PDFs, respuestas │
│ • Datos anónimos compartidos    │
│ [Política de Privacidad]        │
│                                 │
│ 🔄 SINCRONIZACIÓN              │
│ Último sync: Hace 5 min         │
│ [Sincronizar ahora]             │
│                                 │
│ ⚙️ AVANZADO                     │
│ [Limpiar cache] [Exportar datos]│
│ [Eliminar curso] [Borrar todo]  │
└─────────────────────────────────┘
```

---

## 🎨 DISEÑO UI/UX DETALLADO {#diseño}

### Color Palette (Manteniendo Coherencia)

```
PRIMARY: #DC2626 (Rojo - Ya en tu app)
SECONDARY: #2563EB (Azul - Nuevo, para IA)
SUCCESS: #10B981 (Verde - Respuestas correctas)
WARNING: #F59E0B (Naranja - Alertas)

NEUTRALS:
- Background: #FAFAFA (Gris muy claro)
- Card: #FFFFFF (Blanco)
- Text Primary: #111827 (Casi negro)
- Text Secondary: #6B7280 (Gris medio)
- Borders: #E5E7EB (Gris claro)

GRADIENTS (Fondos suaves):
IA: Linear(#2563EB → #1E40AF)
Success: Linear(#10B981 → #059669)
```

### Tipografía
```
Headlines: Google Font "Geist" (Sans-serif moderno)
- H1: 32px Bold (0.5 scale)
- H2: 24px SemiBold (títulos pantallas)
- H3: 18px SemiBold (subtítulos)

Body: Google Font "Inter"
- Body Large: 16px Regular (contenido principal)
- Body Medium: 14px Regular (contenido secundario)
- Body Small: 12px Regular (metadata)

Code: "JetBrains Mono" (monoespaciada)
```

### Componentes Reutilizables

#### 1. Course Card
```dart
CustomCourseCard(
  title: 'MATE 101',
  professor: 'Dr. García',
  pdfCount: 23,
  lastAccess: DateTime.now(),
  hasAI: true,
  onTap: () {},
)
```

#### 2. Material Card
```dart
MaterialCard(
  title: 'Unidad_1.pdf',
  size: '2.3 MB',
  date: DateTime.now(),
  onSummarize: () {},
  onQuestions: () {},
  onMore: () {},
)
```

#### 3. AI Response Card
```dart
AIResponseCard(
  type: AIResponseType.summary,
  content: 'Lorem ipsum...',
  timestamp: DateTime.now(),
  onUseful: () {},
  onReview: () {},
  onSave: () {},
)
```

#### 4. Quiz Card
```dart
QuizCard(
  question: 'Pregunta?',
  options: ['A', 'B', 'C', 'D'],
  onSelect: (answer) {},
  showFeedback: true,
  isCorrect: true,
)
```

### Animaciones (Sutiles)
```
- Cards: FadeInUp (300ms) + Scale (0.95 → 1)
- Buttons: Ripple effect (200ms) + Scale on press
- Loading: Pulse suave (dots animados)
- Transitions: CupertinoPageRoute (slide suave)
- IA responses: TypeWriter effect (legible pero natural)
```

### Iconografía
```
Usar Phosphor Icons (ya en tu app):
- 📚 course.book.open
- 📄 doc.text
- 🤖 robot.fill
- ⭐ star.fill
- ✅ check.circle
- ❌ x.circle
- 💾 floppy.disk
- 📤 share.fill
```

---

## ⚙️ ARQUITECTURA TÉCNICA {#arquitectura}

### Diagrama de Componentes

```
┌─────────────────────────────────────────────┐
│            FLUTTER APP                      │
├─────────────────────────────────────────────┤
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │ StudyModeProvider (State)           │   │
│  │ ├─ courseController                 │   │
│  │ ├─ materialController               │   │
│  │ ├─ quizController                   │   │
│  │ └─ aiResponsesCache                 │   │
│  └─────────────────────────────────────┘   │
│           ↓ (HTTP/WebSocket)               │
├─────────────────────────────────────────────┤
│     EXPRESS.JS BACKEND (REST + RTC)        │
├─────────────────────────────────────────────┤
│                                             │
│  ┌──────────────────┐  ┌────────────────┐  │
│  │ Routes:          │  │ Controllers:   │  │
│  │ /study/*         │  │ study.ctrl.js  │  │
│  │ /ai/*            │  │ ai.ctrl.js     │  │
│  │ /quiz/*          │  │ quiz.ctrl.js   │  │
│  └──────────────────┘  └────────────────┘  │
│           ↓                  ↓              │
│  ┌──────────────────────────────────────┐  │
│  │      SERVICES LAYER                  │  │
│  ├──────────────────────────────────────┤  │
│  │ • courseService.js                   │  │
│  │ • materialService.js                 │  │
│  │ • aiService.js (OpenAI, Gemini)      │  │
│  │ • pdfService.js (PDF parsing)        │  │
│  │ • quizService.js                     │  │
│  │ • cacheService.js (Redis)            │  │
│  └──────────────────────────────────────┘  │
│           ↓                                 │
│  ┌──────────────────────────────────────┐  │
│  │      DATA LAYER (PostgreSQL)         │  │
│  ├──────────────────────────────────────┤  │
│  │ Tables:                              │  │
│  │ • study_courses                      │  │
│  │ • study_materials                    │  │
│  │ • study_questions                    │  │
│  │ • quiz_responses                     │  │
│  │ • ai_responses_cache                 │  │
│  │ • study_history                      │  │
│  └──────────────────────────────────────┘  │
│                                             │
└─────────────────────────────────────────────┘
           ↓ (External APIs)
┌─────────────────────────────────────────────┐
│   EXTERNAL SERVICES                         │
├─────────────────────────────────────────────┤
│ • Cloudinary (PDF uploads)                  │
│ • OpenAI / Google Gemini (IA)               │
│ • Pinecone / Weaviate (Vector DB - opcional)│
│ • S3 (Storage alternativo)                  │
└─────────────────────────────────────────────┘
```

### Schema de Base de Datos (Nueva Estructura)

```sql
-- Tabla: study_courses
CREATE TABLE study_courses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    course_code VARCHAR(50),
    professor_name VARCHAR(255),
    description TEXT,
    photo_url TEXT,
    created_by_user_id UUID NOT NULL REFERENCES usuarios(id),
    semester INT,
    year INT,
    is_archived BOOLEAN DEFAULT FALSE,
    metadata JSONB, -- {temas: [], ciclos: []}
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_course (user_id, created_at)
);

-- Tabla: study_materials
CREATE TABLE study_materials (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id UUID NOT NULL REFERENCES study_courses(id) ON DELETE CASCADE,
    uploaded_by_user_id UUID NOT NULL REFERENCES usuarios(id),
    name VARCHAR(255) NOT NULL,
    file_url TEXT NOT NULL,
    file_size_bytes INT,
    file_type VARCHAR(50), -- 'pdf', 'image', 'document'
    cloudinary_public_id VARCHAR(255),
    page_count INT, -- Si es PDF
    text_content TEXT, -- Contenido extraído (OCR/PDF)
    embeddings_generated BOOLEAN DEFAULT FALSE,
    pinecone_namespace VARCHAR(255), -- Para vector search
    category VARCHAR(100), -- 'apuntes', 'parciales', 'ejercicios'
    topic VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_course_created (course_id, created_at),
    INDEX idx_embeddings (embeddings_generated)
);

-- Tabla: ai_responses_cache
CREATE TABLE ai_responses_cache (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    material_id UUID REFERENCES study_materials(id) ON DELETE CASCADE,
    response_type VARCHAR(50), -- 'summary', 'explanation', 'quiz', 'answer'
    prompt TEXT,
    response_content TEXT NOT NULL,
    ai_model VARCHAR(50), -- 'gpt-4', 'gemini-pro'
    tokens_used INT,
    user_feedback VARCHAR(50), -- 'useful', 'needs_review', null
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_material_type (material_id, response_type)
);

-- Tabla: study_questions (Banco de preguntas)
CREATE TABLE study_questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id UUID NOT NULL REFERENCES study_courses(id) ON DELETE CASCADE,
    question_text TEXT NOT NULL,
    options JSONB NOT NULL, -- {a: '...', b: '...', c: '...', d: '...'}
    correct_option VARCHAR(1), -- 'a', 'b', 'c', 'd'
    explanation TEXT,
    difficulty_level VARCHAR(20), -- 'easy', 'medium', 'hard'
    source_material_id UUID REFERENCES study_materials(id),
    created_by_user_id UUID REFERENCES usuarios(id),
    ai_generated BOOLEAN DEFAULT FALSE,
    tags JSONB, -- ['derivadas', 'límites']
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_course_difficulty (course_id, difficulty_level)
);

-- Tabla: quiz_attempts
CREATE TABLE quiz_attempts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    quiz_id VARCHAR(255), -- ID del quiz (generated o manual)
    score INT,
    total_questions INT,
    time_spent_seconds INT,
    answers JSONB, -- {question_id: 'chosen_answer', ...}
    completed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_quiz (user_id, completed_at)
);

-- Tabla: study_history (Auditoría y análisis)
CREATE TABLE study_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    course_id UUID REFERENCES study_courses(id) ON DELETE SET NULL,
    material_id UUID REFERENCES study_materials(id) ON DELETE SET NULL,
    action_type VARCHAR(50), -- 'view', 'download', 'ai_used', 'quiz', 'share'
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_course_history (user_id, course_id, created_at)
);

-- Índices para performance
CREATE INDEX idx_study_courses_active ON study_courses(user_id) WHERE NOT is_archived;
CREATE INDEX idx_materials_embeddings ON study_materials(pinecone_namespace);
```

### Express Routes (Nueva estructura)

```javascript
// routes/study.routes.js
router.get('/courses', authMiddleware, courseController.getUserCourses);
router.post('/courses', authMiddleware, courseController.createCourse);
router.get('/courses/:courseId', authMiddleware, courseController.getCourseDetail);
router.put('/courses/:courseId', authMiddleware, courseController.updateCourse);
router.delete('/courses/:courseId', authMiddleware, courseController.archiveCourse);

// routes/materials.routes.js
router.post('/materials/upload', authMiddleware, upload.single('file'), materialController.uploadMaterial);
router.get('/materials/:materialId', authMiddleware, materialController.getMaterial);
router.delete('/materials/:materialId', authMiddleware, materialController.deleteMaterial);

// routes/ai.routes.js
router.post('/ai/summarize', authMiddleware, aiController.summarizePDF);
router.post('/ai/explain', authMiddleware, aiController.explainContent);
router.post('/ai/generate-quiz', authMiddleware, aiController.generateQuiz);
router.post('/ai/ask-question', authMiddleware, aiController.askQuestion);
router.get('/ai/responses/:materialId', authMiddleware, aiController.getResponses);

// routes/quiz.routes.js
router.post('/quiz/attempt', authMiddleware, quizController.submitAttempt);
router.get('/quiz/:courseId/history', authMiddleware, quizController.getHistory);
router.get('/quiz/:courseId/analytics', authMiddleware, quizController.getAnalytics);
```

### Flutter Provider Structure

```dart
// providers/study_provider.dart
class StudyModeProvider extends ChangeNotifier {
  
  List<StudyCourse> _courses = [];
  Map<String, List<StudyMaterial>> _materials = {};
  Map<String, AIResponse> _aiResponsesCache = {};
  
  // Getters
  List<StudyCourse> get courses => _courses;
  List<StudyMaterial> getMaterialsByCourse(String courseId) => _materials[courseId] ?? [];
  
  // Métodos principales
  Future<void> fetchCourses() async { ... }
  Future<void> createCourse(StudyCourse course) async { ... }
  Future<void> uploadMaterial(String courseId, File file) async { ... }
  
  // IA
  Future<AIResponse> summarizeMaterial(String materialId) async { ... }
  Future<AIResponse> explainContent(String materialId, String context) async { ... }
  Future<List<StudyQuestion>> generateQuiz(String courseId, int count) async { ... }
  Future<AIResponse> askQuestion(String courseId, String question) async { ... }
  
  // Cache management
  void cacheAIResponse(String key, AIResponse response) { ... }
  AIResponse? getCachedResponse(String key) { ... }
}

// Models
class StudyCourse {
  final String id;
  final String name;
  final String professorName;
  final int pdfCount;
  final DateTime lastAccess;
  final bool hasAI;
}

class AIResponse {
  final String id;
  final AIResponseType type;
  final String content;
  final DateTime generatedAt;
  final int tokensUsed;
}

enum AIResponseType { summary, explanation, quiz, answer }
```

---

## 🤖 INTEGRACIÓN IA {#integración-ia}

### Decisión: Qué IA Usar (Low-cost, High-performance)

#### OPCIÓN 1: OpenAI GPT-4 Mini (RECOMENDADO)
```
Pros:
✅ Mejor calidad de respuestas
✅ Context window grande (128K tokens)
✅ Excelente para educación
✅ Pricing: $0.00015 input, $0.0006 output per 1K tokens

Contras:
❌ Más caro que alternativas
❌ Requiere rate limiting cuidadoso

Casos de uso:
• Resúmenes detallados
• Explicaciones complejas
• Preguntas tipo examen
```

#### OPCIÓN 2: Google Gemini (BALANCE)
```
Pros:
✅ Pricing: $0.075/millón input, $0.3/millón output
✅ Muy económico
✅ Buenas explicaciones

Contras:
❌ Menos consistente en algunos temas

Casos de uso:
• Resúmenes rápidos
• Explicaciones básicas
```

#### OPCIÓN 3: Anthropic Claude 3 (PREMIUM)
```
Pros:
✅ Mejor razonamiento
✅ Excelente para código

Contras:
❌ Más caro ($3/$15 por millón tokens)

Casos de uso:
• Problemas complejos
• Código/ejercicios
```

**RECOMENDACIÓN:** Hybrid approach
- Resúmenes: Gemini (rápido, económico)
- Explicaciones: GPT-4 Mini
- Preguntas tipo examen: GPT-4 Mini
- Cache agresivo para reutilizar

### Prompt Engineering (Templates)

```javascript
// summarizeService.js

const SYSTEM_PROMPT_SUMMARY = `Eres un tutor experto universitario.
Tu tarea es crear resúmenes concisos y educativos.

Reglas:
1. Máximo 5 puntos numerados
2. Cada punto: 2-3 líneas
3. Lenguaje claro para estudiantes
4. Incluir conceptos clave en BOLD
5. Agregar 1 ejemplo práctico por punto`;

const summaryPrompt = (pdfContent) => `
Documento: ${pdfContent.substring(0, 2000)}...

Genera un resumen en 5 puntos clave de este material.
Sé conciso pero completo.
Formato:
1. [Punto] - [Explicación 2-3 líneas]
2. ...
`;

// explainService.js
const SYSTEM_PROMPT_EXPLAIN = `Eres un profesor que explica como si el estudiante fuera principiante.
Usa analogías del mundo real.
Evita jerga técnica innecesaria.
Sé empático y motivador.`;

const explainPrompt = (concept) => `
Concepto: ${concept}

Explica esto como si fuera para alguien en 1er año de universidad.
Usa 1-2 analogías del mundo real.
Después, da 1 ejemplo concreto.
`;

// quizService.js
const SYSTEM_PROMPT_QUIZ = `Eres un profesor experto creando preguntas de examen.
Las preguntas deben ser:
- Desafiantes pero justas
- Enfocadas en conceptos clave
- Tipo múltiple choice (A/B/C/D)
- Una respuesta claramente correcta`;

const quizPrompt = (materialContent) => `
Contenido: ${materialContent}

Genera 5 preguntas de examen tipo múltiple choice.
Formato JSON:
{
  "questions": [
    {
      "question": "...",
      "options": {
        "a": "Distractor realista",
        "b": "Respuesta correcta",
        "c": "Distractor realista",
        "d": "Distractor realista"
      },
      "correct_answer": "b",
      "explanation": "La respuesta correcta es B porque..."
    }
  ]
}
`;
```

### Flujo de Procesamiento PDF

```
1. UPLOAD
   └─ PDF enviado → Validar tamaño (<50MB)
      └─ Subir a Cloudinary
         └─ Generar thumbnail preview
            └─ Guardar en study_materials

2. PROCESSING
   └─ Extraer texto con pdfjs (frontend) O pdfparse (backend)
      └─ Dividir en chunks de 1500 tokens (context windows)
         └─ Generar embeddings (si usamos vector DB)
            └─ Guardar en Pinecone/Weaviate (opcional)

3. INDEXING
   └─ Almacenar en PostgreSQL (text_content)
      └─ Cache en Redis (últimos 100 accedidos)

4. QUERIES
   └─ Usuario solicita resumen
      └─ Query: "Resumen de X"
         └─ Enviar chunk relevante a IA
            └─ Cache resultado 24 horas
```

### Cost Estimation (1000 usuarios)

```
SCENARIO: 1000 estudiantes activos, 2 meses

AI API Costs:
- Resúmenes: 500 generados × $0.0015 = $0.75
- Explicaciones: 1000 × $0.005 = $5.00
- Quiz gen: 300 × $0.01 = $3.00
- Q&A: 2000 × $0.002 = $4.00
SUBTOTAL IA: ~$13/mes

Storage:
- PDFs (Cloudinary): 1000 × 5MB avg = 5GB = ~$50/mes
- Vector DB (Pinecone free tier): $0

Database:
- PostgreSQL Neon: ~$50/mes (starter plan)

TOTAL MONTHLY: ~$115/mes
COST PER USER: $0.115/mes (escala muy bien)

Optimizations para bajar costo:
✓ Cache agresivo (reutilizar respuestas 80%)
✓ Usar Gemini para respuestas simples
✓ Limitar frecuencia de generación
✓ Batch processing en off-peak hours
```

---

## 💡 EJEMPLOS DE INTERACCIÓN {#ejemplos}

### Flujo 1: Estudiante Sube PDF y Genera Resumen

```
PASO 1: Navegar a Modo Estudio
┌─────────────────────────────────┐
│ Toca "Modo Estudio" en nav      │
│ ↓ (Tab o menú según diseño)     │
└─────────────────────────────────┘

PASO 2: Seleccionar Curso
┌─────────────────────────────────┐
│ Ve lista de cursos              │
│ Toca "MATE 101"                 │
│ ↓ Abre detalle del curso        │
└─────────────────────────────────┘

PASO 3: Subir Material
┌─────────────────────────────────┐
│ Ve botón "+ Subir Material"     │
│ Toca → Abre file picker         │
│ Selecciona "Parcial_I.pdf"      │
│ ✓ Se sube a Cloudinary          │
│ ↓ Aparece en lista (loading)    │
└─────────────────────────────────┘

PASO 4: IA Action Panel
┌─────────────────────────────────┐
│ Se carga el PDF en viewer       │
│ Aparece overlay con acciones:   │
│ [Resumir] [Explicar] [Quiz] [?] │
│ Toca "Resumir"                  │
│ ↓ Muestra loading indicator     │
└─────────────────────────────────┘

PASO 5: IA Genera Resumen
Backend:
1. Extrae texto del PDF
2. Divide en chunks
3. Envía a OpenAI con prompt
4. Crea AIResponse en DB
5. Caches el resultado

Frontend (Real-time):
┌─────────────────────────────────┐
│ ⏳ Generando resumen...          │
│ (Animación de puntos)           │
│ ↓ (10-15 segundos)              │
└─────────────────────────────────┘

PASO 6: Mostrar Resultado
┌─────────────────────────────────┐
│ Animación: Fade + Slide Up      │
│                                 │
│ 📋 RESUMEN EN 5 PUNTOS          │
│                                 │
│ 1️⃣  Ecuaciones diferenciales   │
│     Son relaciones que conectan │
│     funciones con sus derivadas │
│                                 │
│ 2️⃣  Tipos principales...       │
│     ...                         │
│ ... (3-5 más)                   │
│                                 │
│ [💾 Guardar] [📤 Compartir]     │
└─────────────────────────────────┘

PASO 7: Interacción Post-Respuesta
Opciones:
• 💾 Guardar → Se añade a historial
• 📤 Compartir → Copia link o envía a amigos
• ⭐ Útil → Feedback para mejorar IA
• 🔄 Regenerar → Con prompt diferente
```

### Flujo 2: Estudiante Intenta Quiz y Ve Feedback

```
PASO 1: Desde Detalle Curso
┌─────────────────────────────────┐
│ Ve stats del curso              │
│ "5 Quiz disponibles"            │
│ Toca [Hacer Quiz]               │
└─────────────────────────────────┘

PASO 2: Inicio de Quiz
┌─────────────────────────────────┐
│ Pantalla pre-quiz:              │
│ "Quiz: Parcial I Simulado"      │
│ 5 preguntas | 15 minutos        │
│ Dificultad: Intermedia          │
│ [Comenzar] [Cancelar]           │
└─────────────────────────────────┘

PASO 3: Primera Pregunta
┌─────────────────────────────────┐
│ ⏱️ 15:00 (timer)                 │
│ Pregunta 1/5                    │
│                                 │
│ "¿Cuál es la derivada de x²?"   │
│                                 │
│ ○ 2x + 1                        │
│ ○ 2x          ← Correcta       │
│ ○ x² + 2x                       │
│ ○ 4x                            │
│                                 │
│ [Anterior] [Siguiente]          │
└─────────────────────────────────┘

PASO 4: Responder (Usuario elige ○ 2x)
┌─────────────────────────────────┐
│ ✅ ¡CORRECTO!                   │
│                                 │
│ La derivada de x² es 2x         │
│ Usamos la regla de potencia:    │
│ d/dx(x^n) = n·x^(n-1)          │
│                                 │
│ [Siguiente pregunta]            │
└─────────────────────────────────┘

PASO 5-9: Resto de Preguntas
(Similar, algunas correctas, algunas malas)

PASO 10: Resultados Finales
┌─────────────────────────────────┐
│ 🎉 QUIZ COMPLETADO             │
│                                 │
│ Puntuación: 4/5 (80%)           │
│ Tiempo usado: 12:45             │
│                                 │
│ ✅ 4 correctas                  │
│ ❌ 1 incorrecta                 │
│                                 │
│ 📊 ANÁLISIS:                    │
│ • Derivadas: Excelente (5/5)   │
│ • Integrales: Mejorable (1/2)  │
│                                 │
│ 💡 RECOMENDADO:                 │
│ [📖 Revisar: Integrales]        │
│ [🔄 Reintentar este tema]       │
│                                 │
│ [Historial] [Home]              │
└─────────────────────────────────┘

PASO 11: Guardar Respuestas
Backend:
1. Guardar en quiz_attempts
2. Calcular score
3. Analizar patrones débiles
4. Guardar en study_history para analytics
5. Trigger: Si score < 60%, sugerir material
```

### Flujo 3: Estudiante Hace Pregunta a IA

```
PASO 1: Desde PDF Viewer
┌─────────────────────────────────┐
│ Leyendo PDF de Cálculo          │
│ Tiene duda específica           │
│ Toca [?] (Hacer pregunta)       │
└─────────────────────────────────┘

PASO 2: Input de Pregunta
┌─────────────────────────────────┐
│ 💬 ¿Cuál es tu pregunta?        │
│                                 │
│ [Escribe aquí...]               │
│ "No entiendo por qué se aplica  │
│  la regla de la cadena en la    │
│  page 23"                       │
│                                 │
│ [Cancelar] [Enviar]             │
└─────────────────────────────────┘

PASO 3: IA Procesa
Backend:
1. Captura el contexto del PDF (última página vista)
2. Envía prompt contextualizado a OpenAI:
   "El usuario está leyendo página 23 sobre [tema].
    Su pregunta: [user_question]
    Contexto: [relevant_excerpt]"
3. Genera respuesta
4. Cache el resultado

PASO 4: Mostrar Respuesta
┌─────────────────────────────────┐
│ ◀ Respuesta: Regla de Cadena    │
├─────────────────────────────────┤
│ 🤖 Explicación:                 │
│                                 │
│ La regla de la cadena se aplica │
│ cuando tienes una función       │
│ compuesta: f(g(x))              │
│                                 │
│ En tu caso, en la página 23:    │
│ d/dx[sin(x²)] = cos(x²) · 2x   │
│                                 │
│ El "2x" viene de la derivada    │
│ interna, por eso necesitas      │
│ multiplicarla.                  │
│                                 │
│ 📚 Ejercicio práctico:          │
│ Intenta: d/dx[e^(3x²)]         │
│                                 │
│ ├─ [💾 Guardar]                │
│ ├─ [📤 Compartir]               │
│ └─ [🔗 Link al material]        │
└─────────────────────────────────┘

PASO 5: Interacción Continua
• Toca "Más detalles" para profundizar
• Toca "Siguiente ejercicio" para práctica
• Sistema aprende: "Este usuario tiene duda con regla cadena"
  → Próximos quiz enfatizará este tema
```

---

## 📊 PLAN DE IMPLEMENTACIÓN {#plan}

### Fase 1: MVP (2-3 semanas)

```
SEMANA 1:
┌─────────────────────────────────┐
├─ DB: Crear tablas study_courses,
│  study_materials, ai_responses
│
├─ Backend: CRUD básico cursos
│  POST /study/courses
│  GET /study/courses
│  DELETE /study/courses/:id
│
├─ Backend: Upload materiales
│  POST /materials/upload
│  GET /materials/:courseId
│
├─ Frontend: Pantalla Hub Estudio
│  ListCourses Widget
│  CourseCard Component
│
└─ Frontend: Pantalla Detalle Curso
   MaterialsList Widget
   Material Card Component
```

```
SEMANA 2:
┌─────────────────────────────────┐
├─ IA Integration: OpenAI setup
│  - API key management
│  - Service layer basics
│  - Summarize endpoint
│
├─ Frontend: PDF Viewer
│  pdf package integration
│  FloatingAction overlay
│
├─ Backend: AI Summarize
│  POST /ai/summarize
│  Cache layer (Redis/Memory)
│
├─ Frontend: AI Response Card
│  Display responses
│  Save/Share actions
│
└─ Testing: Basic E2E
```

```
SEMANA 3:
┌─────────────────────────────────┐
├─ IA: Explain feature
│  Prompt template
│  Service + endpoint
│
├─ Backend: Quiz generation
│  Quiz service
│  POST /ai/generate-quiz
│
├─ Frontend: Quiz Flow
│  Quiz Screen
│  Results Screen
│  Analytics
│
├─ Navigation: Bottom nav update
│  Add Study Mode tab
│
├─ Polish: UI refinements
│  Animations
│  Error handling
│
└─ Beta: Internal testing
```

### Fase 2: Expansion (3-4 semanas)

```
SEMANA 4-5:
├─ Advanced Features:
│  ├─ Q&A Feature (Ask anything)
│  ├─ Historial & Analytics
│  ├─ Flashcards
│  ├─ Study Groups (shared courses)
│  └─ Notifications & reminders
│
├─ Performance:
│  ├─ Lazy loading
│  ├─ Image optimization
│  ├─ Query optimization
│  └─ Cache strategy
│
├─ Analytics:
│  ├─ Track user behavior
│  ├─ Measure feature adoption
│  ├─ Identify weak spots
│  └─ A/B testing setup
│
└─ Security:
   ├─ Rate limiting per user
   ├─ Input validation
   ├─ Data encryption
   └─ Privacy policy update
```

### Fase 3: Optimization (Ongoing)

```
├─ Cost optimization:
│  ├─ Cache strategy refinement
│  ├─ Batch AI calls
│  ├─ Model switching (GPT-4 Mini vs Gemini)
│  └─ Token counting
│
├─ UX optimization:
│  ├─ User feedback sessions
│  ├─ Heatmaps & session recordings
│  ├─ Conversion funnel analysis
│  └─ Retention cohort analysis
│
├─ Scaling:
│  ├─ Load testing (5000 concurrent)
│  ├─ CDN for assets
│  ├─ Database replication
│  └─ Queue system (Kafka/RabbitMQ)
│
└─ New features:
   ├─ Video tutoring
   ├─ Peer-to-peer Q&A
   ├─ Study planner AI
   └─ Predictive analytics
```

### Roadmap Gantt (Visual)

```
                    S1  S2  S3  S4  S5  S6  S7  S8
MVP Phase           ▓▓▓ ▓▓▓ ▓▓▓
├─ Database         ▓▓▓
├─ Backend CRUD     ▓▓▓ ▓▓▓
├─ Frontend UI      ▓▓▓ ▓▓▓
├─ IA Integration       ▓▓▓ ▓▓▓
└─ Testing              ▓▓▓

Expansion Phase                 ▓▓▓ ▓▓▓
├─ Q&A + Analytics              ▓▓▓
├─ Groups + Social                  ▓▓▓
├─ Performance                   ▓▓▓ ▓▓▓
└─ Analytics Platform               ▓▓▓

Launch                              ▓▓▓
├─ Beta Users (100)                 ▓▓▓
├─ Feedback & Fixes                     ▓▓▓
└─ Public Release                           ▓▓▓
```

---

## 🚀 ESCALABILIDAD & PERFORMANCE {#escalabilidad}

### Benchmarks Target

```
Métrica                 Target      Técnica
─────────────────────────────────────────────
PDF Upload              < 3s        Chunked upload + Cloudinary
PDF Viewer              < 1s        Lazy load pages
AI Response Gen         < 15s       Streaming + cache
Quiz Load               < 500ms     Prefetch + indexing
List Courses            < 300ms     Pagination
Search                  < 500ms     PostgreSQL FTS
```

### Arquitectura de Escalabilidad

```
TIER 1: CDN & Load Balancer
┌─────────────────────────────────┐
│ CloudFlare / AWS CloudFront     │
│ (Caché assets, reduce latency)  │
└─────────────────────────────────┘
          ↓
TIER 2: API Gateway + Rate Limit
┌─────────────────────────────────┐
│ Express Rate Limit Middleware   │
│ Max 100 req/min per user        │
│ Max 1000 req/min per IP         │
└─────────────────────────────────┘
          ↓
TIER 3: App Servers (Horizontal scaling)
┌─────────────────────────────────┐
│ Multiple Express instances      │
│ Behind Load Balancer (HAProxy)  │
│ Auto-scale based on CPU > 70%   │
└─────────────────────────────────┘
          ↓
TIER 4: Cache Layer
┌─────────────────────────────────┐
│ Redis (AI responses, sessions)  │
│ TTL: 24h para resúmenes         │
│ Memory: 2-4GB                   │
└─────────────────────────────────┘
          ↓
TIER 5: Database Layer
┌─────────────────────────────────┐
│ PostgreSQL (Neon - Primary)     │
│ Read replicas si > 1M queries   │
│ Sharding si > 10M records       │
└─────────────────────────────────┘
          ↓
TIER 6: Background Jobs
┌─────────────────────────────────┐
│ Bull Queue / RabbitMQ           │
│ For: PDF processing, AI batches │
│ Workers: 2-4 por instancia      │
└─────────────────────────────────┘
```

### Cost Scaling Model

```
USERs      Monthly Cost    Cost/User   Infrastructure
─────────────────────────────────────────────────────
100        $150            $1.50       1 server + DB
1,000      $300            $0.30       2 servers + cache
10,000     $1,200          $0.12       4 servers + replica
100,000    $8,000          $0.08       Auto-scale + CDN
1,000,000  $50,000         $0.05       Multi-region

Cost Breakdown (100K users):
├─ Infrastructure (servers): $2,000
├─ Database (Neon): $300
├─ AI APIs: $1,500 (if heavy usage)
├─ Storage (Cloudinary): $500
├─ Cache (Redis): $200
├─ Monitoring/Tools: $500
└─ Buffer/Misc: $1,000
TOTAL: ~$6,500/mes (~$0.065 per user)
```

### Optimization Checklist

```
FRONTEND
├─ ☐ Lazy load screens with RepaintBoundary
├─ ☐ Image compression (WebP format)
├─ ☐ Pagination (max 20 items per request)
├─ ☐ Infinite scroll con lastScrollOffset
├─ ☐ Cache manager para PDFs
└─ ☐ Minify/Obfuscate Dart code

BACKEND
├─ ☐ Database indexing (idx_user_course, idx_embeddings)
├─ ☐ Query optimization (EXPLAIN ANALYZE)
├─ ☐ Connection pooling (max 10 per server)
├─ ☐ Gzip compression para responses
├─ ☐ HTTP caching headers (ETag, 304)
├─ ☐ API versioning (/v1/study/...)
└─ ☐ Monitoring (NewRelic, DataDog)

DATABASE
├─ ☐ Partitioning tables si > 100M rows
├─ ☐ Archival strategy (study_history > 6mo)
├─ ☐ Vacuum/Analyze nightly
├─ ☐ Slow query logs (> 1s)
└─ ☐ Backup strategy (daily)

AI/LLM
├─ ☐ Prompt caching (same prompt = cache hit)
├─ ☐ Response compression
├─ ☐ Batch processing en off-peak
├─ ☐ Token counting para budgets
└─ ☐ Model downgrading (GPT-4 Mini → Gemini)
```

---

## 🎯 DIFERENCIAL: Growth Hacks {#diferencial}

### Idea 1: "Streak de Estudio" (Daily Habit Loop)

```
Concepto:
Similar a Duolingo, trackear días consecutivos estudiando.

Mechanic:
┌─────────────────────────────────┐
│ 🔥 RACHA DE ESTUDIO             │
│ 23 días consecutivos 🎉         │
│                                 │
│ Hoy:                            │
│ ☐ Ver 1 material                │
│ ☑️  Generar resumen              │
│ ☐ Hacer 1 quiz                  │
│ ☐ 15 min de estudio             │
│                                 │
│ Mañana completarás... +25 días  │
│ 🏆 Desbloqueado: "Estudioso"    │
└─────────────────────────────────┘

Implementación:
├─ Tabla: user_streaks
│  (user_id, days, last_activity, badges)
│
├─ Daily check-in logic
│  "¿Has estudiado hoy?" → +1 streak
│
├─ Badges/Achievements (gamification)
│  - 7 días: "Constante"
│  - 30 días: "Dedicado"
│  - 100 días: "Legends"
│
├─ Social sharing
│  "¡Llevo 23 días estudiando en UTP Comunidades! 🔥"
│  (Pre-filled tweet/share)
│
└─ Notifications
   "¿Listos para mantener tu racha? Estudia hoy 🎓"
```

**Expected Impact:**
- +35% daily retention
- +50% session frequency
- Viral coefficient from sharing

---

### Idea 2: "Estudio en Grupo con IA" (Collab Learning)

```
Concepto:
Estudiantes pueden crear "Grupos de Estudio" privados
y compartir respuestas de IA, crear quiz juntos.

Mechanic:
1. Usuario crea grupo: "Grupo de Cálculo - Parcial I"
2. Invita 3-5 amigos via link/QR
3. Todos suben materiales al grupo
4. IA genera resúmenes compartidos
5. Quiz compartidos con leaderboard

UI:
┌─────────────────────────────────┐
│ 👥 Grupo: Cálculo Parcial I     │
│ 4 miembros | 12 archivos        │
├─────────────────────────────────┤
│ 🏆 LEADERBOARD DE QUIZ          │
│ 1. Juan: 95% (8 quizzes)        │
│ 2. María: 92% (7 quizzes)       │
│ 3. Carlos: 88% (6 quizzes)      │
│                                 │
│ 🔄 ÚLTIMAS ACTIVIDADES         │
│ • María subió Parcial_I_Sol.pdf │
│ • Sistema generó 5 preguntas    │
│ • Juan respondió quiz (95%)     │
│                                 │
│ [+ Invitar] [Crear Quiz] [+Sub] │
└─────────────────────────────────┘

Benefits:
- Motivación por competencia sana
- Peer learning
- Reducir sensación de aislamiento
- Higher engagement (2x+ actividad)

Métricas:
- Groups created: Target 30% de users
- Avg group size: 4-5 personas
- Retention en grupos: +60% (vs solo)
```

---

## 🔐 Consideraciones Finales

### Privacy & Security

```
✅ PDFs nunca se comparten públicamente
✅ IA responses asociadas a user
✅ Solo el propietario ve su historial
✅ Encryptado en tránsito (HTTPS)
✅ GDPR compliance (data deletion)
✅ Optional: Anonimizar datos para IA training

Política:
- "Usamos tus preguntas para mejorar nuestro sistema IA"
- Opt-in para contribuir datos
```

### Regulatory

```
✅ Verificar con UTP si hay políticas sobre:
  - IA en educación
  - Uso de materiales académicos
  - Plagio/Honor code

✅ Disclaimers:
  - "IA es asistente, no reemplaza profesor"
  - "Verifica siempre respuestas"
  - "Úsalo para aprender, no copiar"
```

### Monetización (Futuro, Opcional)

```
Modelo freemium:
┌─────────────────────────────────┐
│ FREE TIER                       │
│ • 5 AI responses/mes            │
│ • Basic courses                 │
│ • Limited storage               │
│                                 │
│ PREMIUM ($4.99/mes)             │
│ • Unlimited AI                  │
│ • Study groups                  │
│ • Advanced analytics            │
│ • Priority support              │
│                                 │
│ TEAM ($14.99/mes)               │
│ • Para profesores               │
│ • Crear quizzes masivos         │
│ • Ver analytics de clase        │
└─────────────────────────────────┘

NOT RECOMMENDED initially - Focus on adoption first
```

---

## 📝 RESUMEN EJECUTIVO

### What You're Building

Una **sección dentro de tu app** que transforma estudiantes en **power users diarios** con:
- ✅ Sistema de cursos inteligente (sin romper la app existente)
- ✅ IA contextual integrada de forma natural
- ✅ Gamificación sutil pero efectiva
- ✅ Escalable para millones de usuarios
- ✅ Bajo costo operativo (~$0.05 por usuario/mes)

### Why It Works

1. **Soluciona problema real:** Estudiantes NECESITAN estudiar → Herramienta reduce friction
2. **Retention killer:** Uso diario (racha + quiz + IA)
3. **Viral**: Compartir grupos de estudio, badges, streaks
4. **Defensible:** Competencia difícil sin dataset educativo

### Critical Success Factors

✅ **NO romper lo existente** → Agregar como sección nueva  
✅ **IA debe ser invisible** → Solo solve problems, no distracciones  
✅ **Performance obsesión** → Sub 1s para listas, <15s para IA  
✅ **Quality over quantity** → 5 features bien hechas > 20 rotas  

---

**LISTO PARA IMPLEMENTACIÓN.**

Siguiente paso: ¿Quieres que profundice en alguna sección específica o empezamos con el código?
