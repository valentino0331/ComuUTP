# Database Migrations - UTP Comunidades

## Overview

This directory contains the **consolidated master migration script** for the UTP Comunidades database schema.

### File Structure

- **`000-master-init.sql`** - **MAIN FILE** - Complete database initialization script (consolidated from 20 individual migration files)

## How to Use

### Local Development

```bash
# Connect to PostgreSQL and run the master script
psql -U postgres -d utp_comunidades -f migrations/000-master-init.sql

# Or use PostgreSQL CLI from database connection
\i migrations/000-master-init.sql
```

### Production (Neon Cloud)

1. Go to [Neon Console](https://console.neon.tech)
2. Select your project → **SQL Editor**
3. Create a new query
4. Copy entire content of `000-master-init.sql`
5. Paste and execute (Ctrl+Enter)
6. Wait for confirmation: "DATABASE SCHEMA SUCCESSFULLY INITIALIZED!"

## What's Included

The master initialization script includes:

### 1. Schema Modifications
- Core columns for `usuarios`, `publicaciones`, `comunidades`
- Profile settings and user preferences
- Media/image URL fields
- Timestamps for audit trails

### 2. Study Mode Tables
- `study_courses` - User courses/classes
- `study_materials` - PDFs, apuntes, resources
- `audio_lessons` - AI-generated audio lectures (NEW)
- `study_questions` - Quiz questions
- `quiz_attempts` - User quiz results
- `ai_responses` - IA response cache

### 3. Community Features
- `reacciones` - Post reactions (love, fire, laugh, wow, sad)
- `menciones` - User mentions notifications
- `hashtags` - Post hashtags
- `posts_guardados` - Saved posts/bookmarks
- `colecciones` - Post collections

### 4. Messaging System
- `conversaciones` - Direct message conversations
- `mensajes` - Messages between users
- Automatic timestamp updates via triggers

### 5. Events & Surveys
- `eventos` - Community events
- `evento_rsvp` - Event RSVPs
- `encuestas` - Polls/surveys
- `encuesta_opciones` - Poll options
- `encuesta_votos` - Poll votes

### 6. Performance Optimization
- 30+ indexes for common queries
- Proper foreign key relationships
- Cascade delete rules
- Triggers for automatic timestamp management

## Idempotency

All operations use `IF NOT EXISTS` or `IF NOT EXISTS` with conditional blocks to ensure:
- ✅ Safe re-runs (no errors if tables exist)
- ✅ Partial failures don't break the script
- ✅ Can be executed multiple times safely

## Key Features

| Feature | Included |
|---------|----------|
| 📚 Study Mode | ✅ Full schema |
| 🎙️ Audio Lessons | ✅ Complete tables + indexes |
| 🤖 AI Responses | ✅ Caching tables |
| 💬 Messaging | ✅ With automatic triggers |
| 📸 Media Support | ✅ TEXT fields for base64 |
| 🔍 Full Text Search | ✅ Via indexes |
| ⏰ Audit Trails | ✅ created_at, updated_at |
| 🔗 Relationships | ✅ All foreign keys |

## Migration History

Previously, migrations were split across 20 individual files:
- `001-add-usuario-creador-id.sql`
- `002-create-study-mode-tables.sql`
- `003-create-audio-lessons-table.sql`
- `create_amistades.sql`
- `create_ai_responses.sql`
- And 15 more...

**As of 2024**, all migrations are **consolidated into `000-master-init.sql`** for:
- ✅ Easier deployment
- ✅ Faster setup
- ✅ No dependency management
- ✅ Single source of truth

## Troubleshooting

### Error: "relation already exists"
- Safe to ignore - `CREATE TABLE IF NOT EXISTS` handles this
- Script will skip existing tables

### Error: "column already exists"
- Safe to ignore - `ADD COLUMN IF NOT EXISTS` handles this
- Script will skip existing columns

### Error: "duplicate key value"
- This means the constraint name already exists
- Script already handles this with `IF NOT EXISTS`

### Need to reset database?
```sql
-- WARNING: This will delete all data!
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
-- Then re-run the migration script
```

## Verification

After running the migration, verify with:

```sql
-- Count total tables
SELECT COUNT(*) as table_count 
FROM information_schema.tables 
WHERE table_schema = 'public';

-- Should return approximately 20+ tables

-- List all tables
\dt public.*

-- Check specific table structure
\d study_courses
\d audio_lessons
```

## Support

- 📖 See [README.md](../../README.md) for deployment instructions
- 🐛 Report migration issues in GitHub issues
- 💡 For schema modifications, update `000-master-init.sql` and document changes
