# 🧪 Modo Estudio + IA - TESTING GUIDE

## Pre-Testing Checklist

- [ ] `.env` file configurado con credenciales reales
- [ ] OpenAI API key activo y con crédito
- [ ] Cloudinary account activo
- [ ] PostgreSQL Neon database con todas las 7 tablas
- [ ] JWT_SECRET válido
- [ ] Backend corriendo en `http://localhost:3000`
- [ ] Postman instalado

---

## ⚡ Quick Start (5 minutos)

### 1. Verificar que Backend está corriendo

```bash
# Terminal 1
cd backend
npm install  # si es necesario
npm start
# Debe mostrar: "✅ Servidor conectado a puerto 3000"
```

### 2. Verificar Base de Datos

```bash
# En Neon Console > SQL Editor, ejecuta:
SELECT COUNT(*) FROM study_courses;
SELECT COUNT(*) FROM study_materials;
SELECT COUNT(*) FROM ai_responses_cache;
SELECT COUNT(*) FROM study_questions;
SELECT COUNT(*) FROM quiz_attempts;
SELECT COUNT(*) FROM study_history;
SELECT COUNT(*) FROM user_streaks;

# Debe retornar 7 resultados (posiblemente 0 si es la primera vez)
```

### 3. Obtener JWT Token

```bash
# 1. Login con usuario existente en /api/auth/login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "password123"
  }'

# Respuesta esperada:
# {
#   "success": true,
#   "data": {
#     "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
#     "user": {...}
#   }
# }

# 2. Copiar el token y usarlo en todos los requests
export JWT_TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

---

## 🧪 Test 1: Crear Curso

### 1A. Con cURL

```bash
curl -X POST http://localhost:3000/api/study/courses \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Bases de Datos - 2024",
    "course_code": "CS-2024-001",
    "professor_name": "Dr. García López",
    "description": "Curso avanzado de SQL y normalización",
    "semester": 1,
    "year": 2024
  }'
```

### Respuesta Esperada (201 Created)

```json
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "Bases de Datos - 2024",
    "course_code": "CS-2024-001",
    "professor_name": "Dr. García López",
    "description": "Curso avanzado de SQL y normalización",
    "semester": 1,
    "year": 2024,
    "is_archived": false,
    "created_at": "2024-01-15T10:30:00Z"
  },
  "message": "Curso creado exitosamente"
}
```

### Guardar el COURSE_ID para próximos tests

```bash
export COURSE_ID="550e8400-e29b-41d4-a716-446655440000"
```

---

## 🧪 Test 2: Listar Cursos

```bash
curl -X GET http://localhost:3000/api/study/courses \
  -H "Authorization: Bearer $JWT_TOKEN"
```

### Respuesta Esperada (200 OK)

```json
{
  "success": true,
  "data": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "name": "Bases de Datos - 2024",
      ...
    }
  ],
  "count": 1
}
```

---

## 🧪 Test 3: Obtener Detalles del Curso

```bash
curl -X GET http://localhost:3000/api/study/courses/$COURSE_ID \
  -H "Authorization: Bearer $JWT_TOKEN"
```

### Respuesta Esperada (200 OK)

```json
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "Bases de Datos - 2024",
    "materials": []  // Aún sin materiales
  }
}
```

---

## 🧪 Test 4: Subir Material (PDF)

### 4A. Crear archivo de prueba

```bash
# En terminal, crear PDF de prueba
cat > /tmp/test.pdf << 'EOF'
%PDF-1.4
1 0 obj
<< /Type /Catalog /Pages 2 0 R >>
endobj
2 0 obj
<< /Type /Pages /Kids [3 0 R] /Count 1 >>
endobj
3 0 obj
<< /Type /Page /Parent 2 0 R /Resources 4 0 R /MediaBox [0 0 612 792] /Contents 5 0 R >>
endobj
4 0 obj
<< /Font << /F1 << /Type /Font /Subtype /Type1 /BaseFont /Helvetica >> >> >>
endobj
5 0 obj
<< /Length 44 >>
stream
BT /F1 12 Tf 100 700 Td (Test PDF Content) Tj ET
endstream
endobj
xref
0 6
0000000000 65535 f 
0000000009 00000 n 
0000000058 00000 n 
0000000115 00000 n 
0000000214 00000 n 
0000000333 00000 n 
trailer
<< /Size 6 /Root 1 0 R >>
startxref
427
%%EOF
```

### 4B. Subir con Multipart

```bash
curl -X POST http://localhost:3000/api/materials/upload \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -F "courseId=$COURSE_ID" \
  -F "file=@/tmp/test.pdf"
```

### Respuesta Esperada (201 Created)

```json
{
  "success": true,
  "data": {
    "id": "660e8400-e29b-41d4-a716-446655440111",
    "course_id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "test.pdf",
    "file_url": "https://res.cloudinary.com/your-cloud/...",
    "file_size_bytes": 427,
    "file_type": "application/pdf",
    "created_at": "2024-01-15T10:35:00Z"
  },
  "message": "Material subido exitosamente"
}
```

### Guardar MATERIAL_ID

```bash
export MATERIAL_ID="660e8400-e29b-41d4-a716-446655440111"
```

---

## 🧪 Test 5: Resumir Material (con IA)

### Prerequisito: Verificar OpenAI API

```bash
# Comprobar que OPENAI_API_KEY está configurado
echo $OPENAI_API_KEY  # Debe mostrar sk-xxx...

# Si no, agregar a .env:
# OPENAI_API_KEY=sk-your-real-key-here
```

### Request

```bash
curl -X POST http://localhost:3000/api/ai/summarize \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "materialId": "'$MATERIAL_ID'",
    "forceRefresh": false
  }'
```

### Respuesta Esperada (200 OK) ⚠️ Primera llamada tardará

```json
{
  "success": true,
  "data": {
    "type": "summary",
    "content": "El archivo PDF contiene contenido de prueba...",
    "tokensUsed": 47,
    "generatedAt": "2024-01-15T10:36:00Z"
  },
  "fromCache": false
}
```

### Segunda llamada (desde cache - más rápida)

```bash
# Ejecutar el mismo request de nuevo
curl -X POST http://localhost:3000/api/ai/summarize \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "materialId": "'$MATERIAL_ID'",
    "forceRefresh": false
  }'

# Respuesta debe tener:
# "fromCache": true  ✅
```

---

## 🧪 Test 6: Explicar Concepto

```bash
curl -X POST http://localhost:3000/api/ai/explain \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "materialId": "'$MATERIAL_ID'",
    "concept": "Normalización de bases de datos",
    "level": "intermediate"
  }'
```

### Respuesta Esperada (200 OK)

```json
{
  "success": true,
  "data": {
    "type": "explanation",
    "content": "La normalización es el proceso de organizar datos...",
    "generatedAt": "2024-01-15T10:37:00Z"
  }
}
```

---

## 🧪 Test 7: Generar Quiz

```bash
curl -X POST http://localhost:3000/api/ai/generate-quiz \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "courseId": "'$COURSE_ID'",
    "count": 3,
    "difficulty": "medium"
  }'
```

### Respuesta Esperada (200 OK)

```json
{
  "success": true,
  "data": {
    "quizId": "quiz_1705315020000",
    "questionIds": [
      "770e8400-e29b-41d4-a716-446655440000",
      "770e8400-e29b-41d4-a716-446655440001",
      "770e8400-e29b-41d4-a716-446655440002"
    ],
    "count": 3,
    "difficulty": "medium"
  }
}
```

### Guardar primer QUESTION_ID

```bash
export QUESTION_ID="770e8400-e29b-41d4-a716-446655440000"
```

---

## 🧪 Test 8: Obtener Preguntas del Curso

```bash
curl -X GET http://localhost:3000/api/ai/questions/$COURSE_ID \
  -H "Authorization: Bearer $JWT_TOKEN"
```

### Respuesta Esperada (200 OK)

```json
{
  "success": true,
  "data": [
    {
      "id": "770e8400-e29b-41d4-a716-446655440000",
      "question_text": "¿Qué es la normalización?",
      "options": {
        "a": "Opción A",
        "b": "Opción B",
        "c": "Opción C",
        "d": "Opción D"
      },
      "correct_option": "a",
      "explanation": "La respuesta correcta es A porque...",
      "difficulty_level": "medium"
    }
  ],
  "count": 3
}
```

---

## 🧪 Test 9: Hacer Pregunta (Q&A con IA)

```bash
curl -X POST http://localhost:3000/api/ai/ask-question \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "courseId": "'$COURSE_ID'",
    "question": "¿Cuál es la diferencia entre 1NF y 2NF?"
  }'
```

### Respuesta Esperada (200 OK)

```json
{
  "success": true,
  "data": {
    "type": "qa",
    "question": "¿Cuál es la diferencia entre 1NF y 2NF?",
    "answer": "La Primera Forma Normal (1NF) requiere que... La Segunda Forma Normal (2NF) además requiere...",
    "generatedAt": "2024-01-15T10:38:00Z"
  }
}
```

---

## 🧪 Test 10: Enviar Intento de Quiz

```bash
curl -X POST http://localhost:3000/api/ai/quiz-attempt \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "courseId": "'$COURSE_ID'",
    "answers": {
      "770e8400-e29b-41d4-a716-446655440000": "a",
      "770e8400-e29b-41d4-a716-446655440001": "b",
      "770e8400-e29b-41d4-a716-446655440002": "c"
    },
    "timeSpent": 180
  }'
```

### Respuesta Esperada (200 OK)

```json
{
  "success": true,
  "data": {
    "score": 67,
    "correctCount": 2,
    "totalQuestions": 3,
    "percentage": "67%"
  }
}
```

---

## ❌ Manejo de Errores

### Error: Token Inválido (401)

```bash
# Error response
{
  "error": "Token inválido"
}

# Solución: Obtener nuevo token
curl -X POST http://localhost:3000/api/auth/login ...
```

### Error: No tienes acceso a este curso (403)

```bash
# Error response
{
  "error": "No tienes acceso a este curso"
}

# Solución: Verificar que USER_ID coincide con quien creó el curso
# SELECT * FROM study_courses WHERE id = 'COURSE_ID';
```

### Error: Tipo de archivo no permitido (400)

```bash
# Error response
{
  "error": "Tipo de archivo no permitido. Solo PDF, TXT y DOCX."
}

# Solución: Subir solo PDF, TXT o DOCX
```

### Error: OpenAI API Key no configurado (500)

```bash
# Error response
{
  "error": "Error al resumir"
}

# En logs: "OpenAI API key not found"

# Solución: Verificar .env tiene OPENAI_API_KEY
# cat backend/.env | grep OPENAI_API_KEY
```

### Error: Cloudinary credential invalid (500)

```bash
# Error response
{
  "error": "Error al subir archivo"
}

# Solución: Verificar credenciales en .env
# cat backend/.env | grep CLOUDINARY
```

---

## 📊 Base de Datos Checks

### Ver todos los cursos creados

```sql
SELECT id, user_id, name, course_code, created_at 
FROM study_courses 
WHERE NOT is_archived 
ORDER BY created_at DESC;
```

### Ver todos los materiales

```sql
SELECT id, course_id, name, file_url, file_size_bytes, created_at
FROM study_materials
ORDER BY created_at DESC;
```

### Ver cache de respuestas IA

```sql
SELECT id, material_id, user_id, response_type, tokens_used, created_at
FROM ai_responses_cache
ORDER BY created_at DESC;
```

### Ver preguntas generadas

```sql
SELECT id, course_id, question_text, difficulty_level, ai_generated, created_at
FROM study_questions
ORDER BY created_at DESC;
```

### Ver intentos de quiz

```sql
SELECT id, user_id, course_id, score, total_questions, time_spent_seconds, completed_at
FROM quiz_attempts
ORDER BY completed_at DESC;
```

---

## 📊 Performance Checks

### Tiempo de respuesta esperado

| Operación | Tiempo | Nota |
|-----------|--------|------|
| GET /courses | <100ms | Muy rápido |
| POST /courses | <200ms | Insertar BD |
| POST /materials/upload | 1-3s | Cloudinary upload |
| POST /ai/summarize (1era) | 2-5s | OpenAI API call |
| POST /ai/summarize (cache) | <100ms | ✅ Desde cache |
| POST /ai/explain | 2-4s | OpenAI API call |
| POST /ai/generate-quiz | 3-8s | OpenAI + INSERT |
| POST /ai/ask-question | 2-5s | OpenAI API call |
| POST /quiz-attempt | <200ms | Scoring + INSERT |

---

## 🐛 Troubleshooting

### Backend no inicia

```bash
# Verificar que puerto 3000 no está en uso
lsof -i :3000

# Limpiar puerto
kill -9 <PID>

# Reiniciar
npm start
```

### Error: Database connection failed

```bash
# Verificar .env tiene DATABASE_URL
cat backend/.env | grep DATABASE

# Verificar conexión a Neon
psql $DATABASE_URL -c "SELECT 1;"
```

### IA no genera respuestas

```bash
# Verificar OpenAI API key
echo $OPENAI_API_KEY

# Verificar crédito en https://platform.openai.com/account/billing/overview

# Verificar logs
tail -f backend/logs/error.log
```

### Archivo no se sube a Cloudinary

```bash
# Verificar credenciales
echo $CLOUDINARY_NAME
echo $CLOUDINARY_API_KEY

# Verificar consola de Cloudinary
# https://cloudinary.com/console/media_library

# Ver logs
curl -X POST http://localhost:3000/api/materials/upload ... 2>&1 | grep -i error
```

---

## ✅ Checklist Final

- [ ] Test 1: Crear curso ✅
- [ ] Test 2: Listar cursos ✅
- [ ] Test 3: Obtener detalles ✅
- [ ] Test 4: Subir material ✅
- [ ] Test 5: Resumir (con IA) ✅
- [ ] Test 6: Explicar concepto ✅
- [ ] Test 7: Generar quiz ✅
- [ ] Test 8: Obtener preguntas ✅
- [ ] Test 9: Q&A con IA ✅
- [ ] Test 10: Enviar intento quiz ✅
- [ ] Error handling validado ✅
- [ ] Performance aceptable ✅
- [ ] Base de datos consistente ✅
- [ ] Logs claros en caso de error ✅

---

**¡Listo para ir a producción!** 🚀

Si encuentras algún error, revisa los logs:
```bash
tail -f backend/logs/error.log
```
