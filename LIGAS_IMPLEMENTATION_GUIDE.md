# 🏆 SISTEMA DE LIGAS Y BATALLAS DE CONOCIMIENTO
## Guía de Implementación y API

---

## 📋 Tabla de Contenidos
1. [Concepto General](#concepto-general)
2. [Arquitectura](#arquitectura)
3. [Endpoints API](#endpoints-api)
4. [Flujo de Usuario](#flujo-de-usuario)
5. [Implementación en Flutter](#implementación-en-flutter)

---

## Concepto General

El sistema de **Ligas de Conocimiento** permite a los estudiantes:

- ✅ **Competir en duelos 1v1** contra otros estudiantes sobre temas específicos
- ✅ **Acumular puntos** en rankings por comunidad
- ✅ **Ganar insignias** por logros (racha de victorias, experto en tema, etc.)
- ✅ **Participar en desafíos colectivos** semanales
- ✅ **Posicionarse como "expertos"** en su comunidad

**Diferencial vs ChatGPT:**
- No es solo resumir, es **competir y demostrar conocimiento real**
- Genera un sentido de **comunidad y pertenencia**
- Incentiva el **aprendizaje progresivo** (racha de victorias)
- Crea **prestigio social** (ser experto en la comunidad)

---

## Arquitectura

### Tablas Principales (en ligas.sql)

```
ligas                    → Competencias
  ├─ duelos            → Batallas 1v1
  │  ├─ duelo_preguntas      → Preguntas generadas por IA
  │  └─ duelo_respuestas     → Respuestas del usuario
  ├─ ranking_ligas           → Puntos y posición de cada usuario
  ├─ insignias               → Logros disponibles
  └─ desafios_colectivos     → Retos semanales
```

### Estados de un Duelo
```
pendiente    → El otro usuario debe aceptar
en_progreso  → Rondas en progreso
finalizado   → Duelo completado (ganador determinado)
cancelado    → Duelo cancelado
```

---

## Endpoints API

### 🏅 LIGAS

#### GET `/api/ligas`
Obtener todas las ligas activas (con filtro opcional por comunidad)

**Query Parameters:**
- `comunidad_id` (opcional): ID de la comunidad

**Response:**
```json
{
  "ligas": [
    {
      "id": 1,
      "nombre": "Liga de Cálculo I",
      "descripcion": "Competencia semanal de Cálculo",
      "comunidad_id": 5,
      "tipo": "por_comunidad",
      "estado": "activa",
      "fecha_inicio": "2026-05-20T10:00:00Z",
      "fecha_fin": "2026-06-20T23:59:59Z",
      "premio_descripcion": "Insignia de Experto en Cálculo"
    }
  ]
}
```

#### POST `/api/ligas`
Crear una nueva liga (requiere autenticación + admin o creador de comunidad)

**Body:**
```json
{
  "nombre": "Liga de Física II",
  "descripcion": "Batallas semanales de física",
  "comunidad_id": 8,
  "tipo": "por_comunidad",
  "fecha_fin": "2026-06-30T23:59:59Z",
  "premio_descripcion": "Insignia + puntos extras"
}
```

#### GET `/api/ligas/:id/participantes`
Obtener ranking de una liga

**Query Parameters:**
- `limit`: 100 (default)
- `offset`: 0 (default)

**Response:**
```json
{
  "participantes": [
    {
      "usuario_id": 42,
      "nombre": "Juan Pérez",
      "foto_perfil": "https://...",
      "puntos_totales": 850,
      "duelos_jugados": 15,
      "duelos_ganados": 10,
      "tasa_victoria": 66.67,
      "posicion": 1
    }
  ],
  "total": 45
}
```

---

### ⚔️ DUELOS (Batallas)

#### POST `/api/duelos/iniciar`
Iniciar un duelo contra otro usuario

**Body:**
```json
{
  "liga_id": 1,
  "opponent_id": 42,
  "tema": "Derivadas y Límites",
  "material_id": 15
}
```

**Response:**
```json
{
  "duelo": {
    "id": 100,
    "liga_id": 1,
    "usuario1_id": 7,
    "usuario2_id": 42,
    "tema": "Derivadas y Límites",
    "estado": "pendiente",
    "puntos_usuario1": 0,
    "puntos_usuario2": 0
  },
  "mensaje": "Duelo iniciado"
}
```

#### GET `/api/duelos/:id`
Obtener datos del duelo + preguntas de la ronda actual

**Response:**
```json
{
  "duelo": { ... },
  "preguntas": [
    {
      "id": 1,
      "ronda": 1,
      "pregunta": "¿Cuál es la derivada de x²?",
      "opciones": [
        { "id": 0, "texto": "2x" },
        { "id": 1, "texto": "x" },
        { "id": 2, "texto": "2" },
        { "id": 3, "texto": "x²" }
      ],
      "dificultad": "facil",
      "tiempo_limite": 30
    }
  ]
}
```

#### POST `/api/duelos/responder`
Enviar respuesta a una pregunta

**Body:**
```json
{
  "duelo_id": 100,
  "duelo_pregunta_id": 1,
  "respuesta_seleccionada": 0,
  "tiempo_respuesta": 12
}
```

**Response:**
```json
{
  "respuesta": { ... },
  "es_correcta": true,
  "puntos": 10
}
```

#### POST `/api/duelos/:duelo_id/finalizar`
Finalizar duelo y determinar ganador

**Response:**
```json
{
  "duelo": { ... },
  "ganador_id": 7
}
```

#### GET `/api/duelos/usuario/mis-duelos`
Obtener mis duelos (con filtros)

**Query Parameters:**
- `liga_id` (opcional)
- `estado` (opcional): 'pendiente', 'en_progreso', 'finalizado'

---

### 🏆 RANKING

#### GET `/api/ranking`
Obtener ranking general (top 100)

**Query Parameters:**
- `limit`: 100 (default)
- `offset`: 0 (default)

#### GET `/api/ranking/liga/:liga_id`
Obtener ranking de una liga específica

**Response:**
```json
{
  "ranking": [
    {
      "usuario_id": 42,
      "posicion": 1,
      "nombre": "Juan Pérez",
      "foto_perfil": "https://...",
      "puntos_totales": 850,
      "duelos_jugados": 15,
      "duelos_ganados": 10,
      "tasa_victoria": 66.67
    }
  ],
  "total": 45
}
```

#### GET `/api/ranking/liga/:liga_id/mi-posicion`
Obtener mi posición en una liga

#### GET `/api/ranking/usuario/insignias`
Obtener mis insignias ganadas

#### GET `/api/ranking/usuario/estadisticas`
Obtener mis estadísticas generales

---

## Flujo de Usuario

### 1. **Descubrimiento de Ligas**
```
Home → Pestaña "Competir"
  └─ Ver ligas disponibles por comunidad
     └─ Ver ranking actual
        └─ Desafiar a otro usuario
```

### 2. **Iniciar Duelo**
```
Usuario A: Selecciona usuario B + tema
         └─ Se genera duelo + 5 preguntas por IA
            └─ Usuario B recibe notificación
               └─ Usuario B acepta/rechaza
                  └─ Duelo en progreso
```

### 3. **Durante el Duelo**
```
Ronda 1: Pregunta → Usuario responde → Puntos (0 o 10)
Ronda 2: Pregunta → Usuario responde → Puntos (0 o 10)
...
Ronda 5: Pregunta → Usuario responde → Puntos (0 o 10)
         └─ Duelo finaliza
            └─ Se actualiza ranking
               └─ Se verifica insignias
```

### 4. **Después del Duelo**
```
Resultados:
  ├─ Ganador/Perdedor
  ├─ Puntos obtenidos
  ├─ Posición en ranking
  └─ Insignias ganadas (si aplica)
```

---

## Implementación en Flutter

### 1. **Crear Provider para Ligas**

```dart
class LigaProvider with ChangeNotifier {
  List<Liga> _ligas = [];
  Liga? _ligaActual;
  
  Future<void> fetchLigas({int? comunidadId}) async {
    final res = await ApiService.get('/ligas', auth: true);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      _ligas = (data['ligas'] as List)
          .map((l) => Liga.fromJson(l))
          .toList();
      notifyListeners();
    }
  }
  
  Future<void> crearLiga(String nombre, String descripcion, int? comunidadId) async {
    final res = await ApiService.post('/ligas', {
      'nombre': nombre,
      'descripcion': descripcion,
      'comunidad_id': comunidadId,
    }, auth: true);
    
    if (res.statusCode == 201) {
      await fetchLigas();
    }
  }
}
```

### 2. **Provider de Duelos**

```dart
class DueloProvider with ChangeNotifier {
  Duelo? _dueloActual;
  List<Pregunta> _preguntas = [];
  
  Future<void> iniciarDuelo(int ligaId, int opponentId, String tema) async {
    final res = await ApiService.post('/duelos/iniciar', {
      'liga_id': ligaId,
      'opponent_id': opponentId,
      'tema': tema,
    }, auth: true);
    
    if (res.statusCode == 201) {
      final data = jsonDecode(res.body);
      _dueloActual = Duelo.fromJson(data['duelo']);
      await obtenerDuelo(_dueloActual!.id);
      notifyListeners();
    }
  }
  
  Future<bool> enviarRespuesta(int dueloId, int preguntaId, int respuesta) async {
    final res = await ApiService.post('/duelos/responder', {
      'duelo_id': dueloId,
      'duelo_pregunta_id': preguntaId,
      'respuesta_seleccionada': respuesta,
      'tiempo_respuesta': 15, // segundos
    }, auth: true);
    
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['es_correcta'];
    }
    return false;
  }
}
```

### 3. **UI Pantalla de Competición**

```dart
class CompetirScreen extends StatefulWidget {
  @override
  State<CompetirScreen> createState() => _CompetirScreenState();
}

class _CompetirScreenState extends State<CompetirScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Competir')),
      body: TabBarView(
        children: [
          // Pestaña 1: Mis Ligas
          _buildLigasTab(),
          // Pestaña 2: Ranking
          _buildRankingTab(),
          // Pestaña 3: Mis Duelos
          _buildDuelosTab(),
        ],
      ),
    );
  }
  
  Widget _buildLigasTab() {
    return Consumer<LigaProvider>(
      builder: (context, ligaProvider, _) {
        return ListView.builder(
          itemCount: ligaProvider.ligas.length,
          itemBuilder: (context, index) {
            final liga = ligaProvider.ligas[index];
            return Card(
              child: ListTile(
                title: Text(liga.nombre),
                subtitle: Text('${liga.participantes} participantes'),
                trailing: ElevatedButton(
                  onPressed: () => _mostrarDialogDesafiar(liga),
                  child: Text('Desafiar'),
                ),
              ),
            );
          },
        );
      },
    );
  }
  
  void _mostrarDialogDesafiar(Liga liga) {
    // Dialog para seleccionar tema y usuario
  }
}
```

---

## 📊 Dashboard de Competición

**Elementos clave que mostrar:**

1. **Mi Posición** (en cada liga)
   - Posición actual
   - Puntos totales
   - Tasa de victoria
   - Insignias ganadas

2. **Duelos Pendientes**
   - Invitaciones recibidas
   - Botón para aceptar/rechazar

3. **Últimos Duelos**
   - Resultado (ganado/perdido)
   - Oponente
   - Puntos obtenidos

4. **Ranking de Comunidad**
   - Top 10 en tu comunidad
   - Tu posición destacada

---

## 🎯 Roadmap Futuro

- [ ] Sistema de "streaks" (rachas de victorias)
- [ ] Insignias dinámicas (mejora según progress)
- [ ] Desafíos colectivos por comunidad (próxima versión)
- [ ] Integración de IA para generar preguntas reales
- [ ] Espectadores en duelos en vivo
- [ ] Torneos mensuales

---

## ⚙️ Consideraciones Técnicas

1. **IA para Preguntas**: Actualmente simuladas, integrar con Claude API
2. **WebSockets**: Para duelos en tiempo real (futuro)
3. **Notificaciones**: Cuando alguien te desafía
4. **Caché**: Guardar ranking localmente (actualizar cada 5 min)

