-- Tablas para sistema de batallas comunitarias

-- 1. Batallas
CREATE TABLE IF NOT EXISTS battles (
  id SERIAL PRIMARY KEY,
  challenger_community_id INT NOT NULL REFERENCES communities(id) ON DELETE CASCADE,
  challenged_community_id INT NOT NULL REFERENCES communities(id) ON DELETE CASCADE,
  leader_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  opponent_leader_id INT REFERENCES users(id) ON DELETE SET NULL,
  difficulty VARCHAR(50) NOT NULL, -- 'basico', 'intermedio', 'avanzado'
  career VARCHAR(100),
  status VARCHAR(50) DEFAULT 'pending', -- pending, waiting_start, active, completed, cancelled, rejected
  start_time TIMESTAMP,
  end_time TIMESTAMP,
  winner_team VARCHAR(50), -- 'challenger', 'challenged', NULL si empate
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- 2. Miembros de batalla (representantes)
CREATE TABLE IF NOT EXISTS battle_members (
  id SERIAL PRIMARY KEY,
  battle_id INT NOT NULL REFERENCES battles(id) ON DELETE CASCADE,
  member_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  team VARCHAR(50) NOT NULL, -- 'challenger', 'challenged'
  locked_until TIMESTAMP, -- Exclusividad temporal
  excluded_until TIMESTAMP, -- Exclusión temporal si falla
  status VARCHAR(50) DEFAULT 'pending', -- pending, accepted, rejected, active, finished
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(battle_id, member_id)
);

-- 3. Rondas de batalla
CREATE TABLE IF NOT EXISTS battle_rounds (
  id SERIAL PRIMARY KEY,
  battle_id INT NOT NULL REFERENCES battles(id) ON DELETE CASCADE,
  round_number INT NOT NULL,
  status VARCHAR(50) DEFAULT 'active', -- active, completed
  start_time TIMESTAMP,
  end_time TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW()
);

-- 4. Preguntas por ronda
CREATE TABLE IF NOT EXISTS round_questions (
  id SERIAL PRIMARY KEY,
  round_id INT NOT NULL REFERENCES battle_rounds(id) ON DELETE CASCADE,
  question_id INT NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
  question_order INT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- 5. Respuestas durante batalla
CREATE TABLE IF NOT EXISTS round_answers (
  id SERIAL PRIMARY KEY,
  member_id INT NOT NULL REFERENCES battle_members(id) ON DELETE CASCADE,
  question_id INT NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
  selected_option VARCHAR(500),
  is_correct BOOLEAN DEFAULT FALSE,
  time_taken INT, -- segundos
  created_at TIMESTAMP DEFAULT NOW()
);

-- 6. Puntuación final
CREATE TABLE IF NOT EXISTS battle_scores (
  id SERIAL PRIMARY KEY,
  battle_id INT NOT NULL REFERENCES battles(id) ON DELETE CASCADE,
  member_id INT NOT NULL REFERENCES battle_members(id) ON DELETE CASCADE,
  correct_answers INT DEFAULT 0,
  total_questions INT DEFAULT 0,
  score DECIMAL(5,2) DEFAULT 0,
  ranking_points INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_battles_status ON battles(status);
CREATE INDEX idx_battles_community ON battles(challenger_community_id, challenged_community_id);
CREATE INDEX idx_battle_members_user ON battle_members(member_id);
CREATE INDEX idx_battle_members_locked ON battle_members(locked_until);
CREATE INDEX idx_round_answers_member ON round_answers(member_id);
CREATE INDEX idx_round_answers_correct ON round_answers(is_correct);
