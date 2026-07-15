# ⚔️ Ligas de Conocimiento - Guía Completa

## 🎮 ¿Qué es?

**Ligas de Conocimiento** es un sistema competitivo **1v1** integrado en UTP Comunidades que permite a los estudiantes demostrar sus conocimientos a través de duelos educativos, **diferenciándose completamente de ChatGPT** al crear una experiencia social y competitiva.

### Diferencia con ChatGPT:
| Aspecto | ChatGPT | Ligas |
|--------|---------|-------|
| **Interacción** | Monólogo con IA | 1v1 Competitivo |
| **Motivación** | Curiosidad | Ranking, Insignias, Racha |
| **Prueba** | Generada por AI | Contra adversario real |
| **Comunidad** | Individual | Social (Leaderboard) |
| **Permanencia** | Conversación temporal | Puntos persistentes |

---

## 🏗️ Arquitectura

### Base de Datos (9 Tablas + 2 Vistas)

```
ligas (Competencias)
├── duelos (Batallas 1v1)
│   ├── duelo_preguntas (Preguntas por duelo)
│   │   └── duelo_respuestas (Respuestas de usuarios)
│   └── ranking_ligas (Posición en liga)
│       └── usuario_insignias (Badges obtenidos)
├── insignias (Definición de badges)
├── desafios_colectivos (Retos comunitarios)
│   └── desafio_participantes (Usuarios participando)
└── Vistas:
    ├── ranking_general (Global)
    └── ranking_por_comunidad (Por comunidad)
```

### API Endpoints

#### 🏆 Ligas
```
GET    /api/ligas                 → Obtener todas
GET    /api/ligas/:id             → Detalle de liga
POST   /api/ligas                 → Crear nueva (admin)
PUT    /api/ligas/:id             → Actualizar
GET    /api/ligas/:id/participantes → Usuarios en liga
```

#### ⚔️ Duelos
```
POST   /api/duelos/iniciar           → Empezar duelo
GET    /api/duelos/:id               → Detalle actual
POST   /api/duelos/responder         → Enviar respuesta
POST   /api/duelos/:id/finalizar     → Terminar duelo
GET    /api/duelos/usuario/mis-duelos → Historial personal
```

#### 📊 Ranking
```
GET    /api/ranking                    → Global
GET    /api/ranking/liga/:id           → Por liga
GET    /api/ranking/comunidad/:id      → Por comunidad
GET    /api/ranking/liga/:id/mi-posicion → Mi posición
GET    /api/ranking/usuario/insignias  → Mis badges
GET    /api/ranking/usuario/estadisticas → Mis stats
```

---

## 🎮 Flujo de Juego

### 1. **Seleccionar Liga**
```
Usuario abre app → Tab "Ligas" → Selecciona "Liga de Matemáticas"
```

### 2. **Buscar Oponente**
```
Usuario ve ranking de liga → Busca rival → "Desafiar"
```

### 3. **Batalla (5 preguntas)**
```
┌─────────────────────────────────┐
│ PREGUNTA 1/5                    │
├─────────────────────────────────┤
│ ¿Cuál es la derivada de x²?    │
│                                 │
│ ⊕ A) 2x                        │
│ ⊕ B) 2x + 1                    │
│ ⊕ C) x²/2                      │
│ ⊕ D) 2                         │
│                                 │
│ [Confirmar Respuesta] 30s ⏱️   │
└─────────────────────────────────┘
```

Puntuación:
- ✅ Correcto rápido (< 15s): +15 pts
- ✅ Correcto medio (15-25s): +10 pts
- ✅ Correcto lento (> 25s): +5 pts
- ❌ Incorrecto: 0 pts

### 4. **Resultados**
```
┌──────────────────────────┐
│  DUELO FINALIZADO        │
├──────────────────────────┤
│ Tú:         45 pts  ✅   │
│ Rival:      30 pts  ❌   │
│                          │
│ +20 puntos en ranking    │
│ Racha: 3 victorias 🔥    │
│ Insignia: "Racha de 3"   │
└──────────────────────────┘
```

---

## 🏅 Sistema de Insignias

Automáticas por logro:

| Insignia | Requisito | Bonus |
|----------|-----------|-------|
| 🎮 Primer Duelo | Completar 1 duelo | +10 pts |
| 🔥 Racha de 3 | 3 victorias consecutivas | +25 pts |
| 🔥 Racha de 5 | 5 victorias consecutivas | +50 pts |
| 👑 Campeón de Liga | #1 en ranking de liga | +100 pts |
| 🧠 Experto Conocimiento | 50 duelos ganados | +50 pts |
| 🎓 Maestro del Saber | 100 duelos ganados | +100 pts |

---

## 📱 UI/UX Components

### Pantalla Principal de Ligas
```
[HEADER: Ligas de Conocimiento]

🎯 Liga General
   Descripción: Competencia global
   Estado: ACTIVA
   [Jugar Ahora] →

🏫 Liga de Matemáticas
   Descripción: Cálculo, Álgebra
   Estado: ACTIVA
   [Jugar Ahora] →

📚 Liga de Programación
   Estado: PRÓXIMO
```

### Pantalla de Ranking
```
[YOUR POSITION]
┌──────────────────┐
│ ⭐ Tu Posición    │
│ #45 • 1,250 pts  │
│ 12 Victorias 🏆  │
└──────────────────┘

TOP 10:
🥇 #1  Juan (5,000 pts)
🥈 #2  María (4,200 pts)
🥉 #3  Carlos (3,800 pts)
   #4  Ana (3,500 pts)
   #5  Pedro (3,200 pts)
   ...
```

### Pantalla de Duelo (Durante)
```
═════════════════════════════════════
        TÚ  VS  RIVAL
      [50 pts] ⚔️ [45 pts]
═════════════════════════════════════

Pregunta 4/5
████████░░ Progress

"¿Cuál es el capital de Perú?"

A) Lima      C) Arequipa
B) Cusco     D) Trujillo

[30s] ⏱️

[Confirmar]
```

---

## 🛠️ Backend Implementation

### Estructura de Carpetas
```
backend/
├── src/
│   ├── controllers/
│   │   ├── liga.controller.js
│   │   ├── duelo.controller.js
│   │   └── ranking.controller.js
│   ├── routes/
│   │   ├── liga.routes.js
│   │   ├── duelo.routes.js
│   │   └── ranking.routes.js
│   └── middlewares/
│       └── auth.middleware.js
├── ligas_migration.sql
├── deploy.sh
└── server.js
```

### Controllers Base

**liga.controller.js**
```javascript
exports.crearLiga = async (req, res) => {
  // POST /ligas - Crear nueva liga
}

exports.fetchLigaDetalle = async (req, res) => {
  // GET /ligas/:id - Obtener detalle
}
```

**duelo.controller.js**
```javascript
exports.iniciarDuelo = async (req, res) => {
  // POST /duelos/iniciar
  // 1. Validar usuarios
  // 2. Crear registro duelo
  // 3. Generar 5 preguntas
  // 4. Retornar datos
}

exports.enviarRespuesta = async (req, res) => {
  // POST /duelos/responder
  // 1. Validar respuesta
  // 2. Calcular puntos
  // 3. Actualizar ranking
  // 4. Retornar resultado
}
```

---

## 📦 Flutter Implementation

### Providers (State Management)

```dart
// lib/providers/liga_provider.dart
class LigaProvider with ChangeNotifier {
  List<Liga> ligas;
  fetchLigas() → GET /api/ligas
  crearLiga() → POST /api/ligas
}

// lib/providers/duelo_provider.dart
class DueloProvider with ChangeNotifier {
  Duelo? dueloActual;
  List<Pregunta> preguntas;
  iniciarDuelo() → POST /api/duelos/iniciar
  enviarRespuesta() → POST /api/duelos/responder
}

// lib/providers/ranking_provider.dart
class RankingProvider with ChangeNotifier {
  List<RankingUsuario> ranking;
  fetchRankingLiga(ligaId) → GET /api/ranking/liga/:id
  fetchMiPosicion(ligaId) → GET /api/ranking/liga/:id/mi-posicion
}
```

### Pantallas

```dart
// lib/screens/ligas_screen.dart
- Tab 1: Lista de ligas disponibles
- Tab 2: Mi ranking personal

// lib/screens/duelo_screen.dart
- Pantalla principal del duelo
- Pregunta con 4 opciones
- Temporizador de 30s
- Contador VS en tiempo real

// lib/screens/ranking_screen.dart
- Mi posición destacada
- Leaderboard top 10-50
- Estadísticas personales
- Insignias obtenidas
```

---

## 🔄 Preguntas Dinámicas

### Opción 1: Preguntas Predefinidas
```sql
CREATE TABLE banco_preguntas (
  id SERIAL PRIMARY KEY,
  categoria VARCHAR(255),
  dificultad VARCHAR(50),
  pregunta TEXT,
  opciones JSONB,
  respuesta_correcta INT
);
```

### Opción 2: Integración Claude API (Recomendado)
```javascript
// backend/services/ai.service.js
async function generarPregunta(tema, dificultad) {
  const response = await claude.messages.create({
    model: "claude-3-sonnet-20240229",
    max_tokens: 500,
    messages: [{
      role: "user",
      content: `Genera una pregunta de múltiple choice sobre ${tema}
               Dificultad: ${dificultad}
               Formato JSON con opciones`
    }]
  });
  return parseQuestion(response.content);
}
```

---

## ✅ Testing

### API Tests
```bash
# Test Ligas
curl -X POST http://localhost:3000/api/ligas \
  -H "Authorization: Bearer token" \
  -d '{"nombre":"Test","tipo":"general"}'

# Test Duelo
curl -X POST http://localhost:3000/api/duelos/iniciar \
  -H "Authorization: Bearer token" \
  -d '{"liga_id":1,"opponent_id":2,"tema":"Prueba"}'

# Test Ranking
curl http://localhost:3000/api/ranking/1
```

### Flutter Tests
```dart
test('LigaProvider fetchLigas', () async {
  final provider = LigaProvider();
  await provider.fetchLigas();
  expect(provider.ligas, isNotEmpty);
});
```

---

## 🚀 Roadmap Futuro

### v1.0 (Actual)
- [x] Sistema de duelos 1v1
- [x] Ranking por liga
- [x] Insignias básicas
- [x] UI Material 3

### v1.1 (Próximo)
- [ ] Chat en tiempo real durante duelos
- [ ] Desafíos colectivos (equipo vs equipo)
- [ ] Preguntas generadas con Claude API
- [ ] Sistema de moderación de preguntas

### v1.2
- [ ] Torneos semanales/mensuales
- [ ] Rewards (puntos, regalos)
- [ ] Integración con badges de comunidad
- [ ] Streaming en vivo de duelos épicos

### v2.0
- [ ] Ligas por especialización (carreras)
- [ ] Coaching automatizado basado en errores
- [ ] Análisis de aprendizaje con IA
- [ ] Marketplace de certificados

---

## 📊 Métricas de Éxito

Objetivo: **Diferenciarse de ChatGPT**
- 📈 +60% engagement vs modo estudio actual
- 👥 +40% usuarios activos semanales
- 🏆 +50% tiempo en app
- 💬 +30% recomendaciones boca a boca

---

## 🤝 Integración con Comunidades

Cada comunidad puede:
1. Crear sus propias ligas
2. Configurar temas específicos
3. Ver leaderboard interno
4. Premiar a campeones

Ejemplo: Comunidad de Ingeniería Civil
```
Liga: Estructuras Metálicas
Liga: Diseño Hidráulico
Liga: CAD Avanzado
```

---

## 📝 Cheatsheet API Rápido

```bash
# Crear liga
POST /api/ligas
{"nombre":"Liga Test","tipo":"general"}

# Listar ligas
GET /api/ligas

# Iniciar duelo
POST /api/duelos/iniciar
{"liga_id":1,"opponent_id":2,"tema":"Math"}

# Responder pregunta
POST /api/duelos/responder
{"duelo_id":1,"duelo_pregunta_id":1,"respuesta_seleccionada":1}

# Ver mi ranking
GET /api/ranking/liga/1/mi-posicion

# Ver top 10
GET /api/ranking/liga/1?limit=10

# Mis insignias
GET /api/ranking/usuario/insignias
```

---

## 💡 Mejores Prácticas

1. **Validación rigurosa** de respuestas
2. **Caché de preguntas** para performance
3. **Anti-cheat**: Timeout automático por sesión
4. **Rate limiting** en duelos
5. **Logging** de todas las acciones

---

## 📞 Soporte

Para problemas o sugerencias:
- Revisar logs: `railway logs`
- Conectar DB: `railway run psql -c "SELECT * FROM ligas"`
- Verificar requests: Network tab en DevTools
