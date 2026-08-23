-- Studeck initial schema
-- Target: PostgreSQL 15+ (Supabase)

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TYPE course_type AS ENUM ('calculation', 'concept', 'skill', 'mixed');
CREATE TYPE task_status AS ENUM ('pending', 'in_progress', 'done', 'overdue');
CREATE TYPE task_priority AS ENUM ('low', 'medium', 'high');
CREATE TYPE quiz_source AS ENUM ('ai_generated', 'manual');

-- ── Users ────────────────────────────────────────────────────────────────
CREATE TABLE users (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email           TEXT NOT NULL UNIQUE,
    password_hash   TEXT NOT NULL,
    full_name       TEXT NOT NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE refresh_tokens (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash      TEXT NOT NULL UNIQUE,
    expires_at      TIMESTAMPTZ NOT NULL,
    revoked_at      TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_refresh_tokens_user_id ON refresh_tokens(user_id);

-- ── Courses ──────────────────────────────────────────────────────────────
-- course_type drives the cold-start default recommendations (see
-- cold_start_defaults below) until a student has enough personal session
-- history for real per-individual pattern detection.
CREATE TABLE courses (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name            TEXT NOT NULL,
    code            TEXT,
    color_hex       TEXT DEFAULT '#4F46E5',
    emoji           TEXT DEFAULT '📘',
    course_type     course_type NOT NULL DEFAULT 'mixed',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_courses_user_id ON courses(user_id);

-- ── Study sessions ───────────────────────────────────────────────────────
-- The core unit of data collection per the thesis: method, planned vs.
-- actual duration, environment, focus mode, self-rating, and outcome score
-- all captured in one logging interaction. self_rating vs. the derived
-- outcome percentage (problems_correct / problems_attempted) is what the
-- self-rating cross-validation module compares.
CREATE TABLE study_sessions (
    id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id               UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    course_id             UUID REFERENCES courses(id) ON DELETE SET NULL,
    started_at            TIMESTAMPTZ NOT NULL,
    ended_at              TIMESTAMPTZ,
    planned_duration_seconds INTEGER,
    duration_seconds      INTEGER,
    technique             TEXT,
    methods               TEXT[] NOT NULL DEFAULT '{}',
    environment           TEXT,
    focus_mode_on         BOOLEAN NOT NULL DEFAULT false,
    self_rating           SMALLINT CHECK (self_rating BETWEEN 1 AND 5),
    problems_attempted    SMALLINT,
    problems_correct      SMALLINT,
    pages_total           SMALLINT,
    pages_covered         SMALLINT,
    created_at            TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_study_sessions_user_id ON study_sessions(user_id);
CREATE INDEX idx_study_sessions_course_id ON study_sessions(course_id);
CREATE INDEX idx_study_sessions_started_at ON study_sessions(started_at);

-- ── Tasks ────────────────────────────────────────────────────────────────
CREATE TABLE tasks (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    course_id       UUID REFERENCES courses(id) ON DELETE SET NULL,
    title           TEXT NOT NULL,
    description     TEXT,
    due_date        TIMESTAMPTZ,
    status          task_status NOT NULL DEFAULT 'pending',
    priority        task_priority NOT NULL DEFAULT 'medium',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_tasks_user_id ON tasks(user_id);

-- ── Grades ───────────────────────────────────────────────────────────────
CREATE TABLE grades (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    course_id       UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    assessment_name TEXT NOT NULL,
    score           NUMERIC(6,2) NOT NULL,
    max_score       NUMERIC(6,2) NOT NULL,
    taken_at        DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_grades_user_id ON grades(user_id);
CREATE INDEX idx_grades_course_id ON grades(course_id);

-- ── AI-generated quizzes ─────────────────────────────────────────────────
-- Generated from a student's uploaded lecture slides, scoped to the pages
-- actually covered in that session (see study_sessions.pages_covered).
CREATE TABLE quizzes (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    course_id       UUID REFERENCES courses(id) ON DELETE SET NULL,
    title           TEXT NOT NULL,
    source          quiz_source NOT NULL DEFAULT 'ai_generated',
    source_material TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_quizzes_user_id ON quizzes(user_id);

CREATE TABLE quiz_questions (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    quiz_id         UUID NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
    question_text   TEXT NOT NULL,
    options         JSONB NOT NULL,
    correct_option  TEXT NOT NULL,
    explanation     TEXT,
    position        SMALLINT NOT NULL DEFAULT 0
);

CREATE INDEX idx_quiz_questions_quiz_id ON quiz_questions(quiz_id);

CREATE TABLE quiz_attempts (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    quiz_id         UUID NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    score           NUMERIC(5,2),
    total_questions SMALLINT NOT NULL,
    started_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    completed_at    TIMESTAMPTZ
);

CREATE INDEX idx_quiz_attempts_user_id ON quiz_attempts(user_id);

CREATE TABLE quiz_answers (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    attempt_id      UUID NOT NULL REFERENCES quiz_attempts(id) ON DELETE CASCADE,
    question_id     UUID NOT NULL REFERENCES quiz_questions(id) ON DELETE CASCADE,
    selected_option TEXT,
    is_correct      BOOLEAN NOT NULL
);

CREATE INDEX idx_quiz_answers_attempt_id ON quiz_answers(attempt_id);

-- ── Cold-start defaults ──────────────────────────────────────────────────
-- Reference data, not user-specific. Shown to a student for a given course
-- until they've logged enough sessions for real per-individual insights.
-- Addresses the "cold start problem" named in the thesis objectives.
CREATE TABLE cold_start_defaults (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_type     course_type NOT NULL,
    title           TEXT NOT NULL,
    body            TEXT NOT NULL,
    position        SMALLINT NOT NULL DEFAULT 0
);

INSERT INTO cold_start_defaults (course_type, title, body, position) VALUES
    ('calculation', 'Practice over rereading', 'For calculation-heavy courses, working problems from scratch beats reviewing worked examples — active recall of the steps is what builds transfer.', 0),
    ('calculation', 'Space out problem sets', 'Spacing practice across several shorter sessions produces better retention than one long problem-solving block.', 1),
    ('concept', 'Explain it without notes', 'For concept-heavy material, try explaining the idea out loud from memory before checking your notes — this surfaces gaps rereading hides.', 0),
    ('concept', 'Interleave related topics', 'Mixing related concepts in one session (rather than mastering one before moving on) improves your ability to tell them apart on exams.', 1),
    ('skill', 'Repetition with feedback', 'Skill-based courses benefit most from repeated practice with immediate feedback on what went wrong, not passive review.', 0),
    ('mixed', 'Match the method to the material', 'Mixed courses benefit from switching technique within a session — practice problems for the calculation parts, self-explanation for the conceptual parts.', 0);

-- ── updated_at auto-touch trigger ────────────────────────────────────────
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_courses_updated_at BEFORE UPDATE ON courses
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_tasks_updated_at BEFORE UPDATE ON tasks
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
