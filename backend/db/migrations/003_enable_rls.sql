-- Supabase auto-exposes every public-schema table via its own REST API
-- (using the public "anon" key), entirely separate from our Express
-- backend. With RLS disabled, that API can read/write any row in any
-- table, bypassing our JWT auth completely.
--
-- Enabling RLS with zero policies blocks that public API outright, while
-- leaving our own backend unaffected: DATABASE_URL connects as the table
-- owner, and table owners bypass RLS by default in Postgres. Access
-- control keeps happening exactly where it already does — in our
-- controllers/models, scoped by req.userId.

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE refresh_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE study_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE grades ENABLE ROW LEVEL SECURITY;
ALTER TABLE quizzes ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_answers ENABLE ROW LEVEL SECURITY;
ALTER TABLE cold_start_defaults ENABLE ROW LEVEL SECURITY;
ALTER TABLE schema_migrations ENABLE ROW LEVEL SECURITY;

-- Also fixes the "Function Search Path Mutable" advisory: pinning
-- search_path stops a maliciously-created schema from shadowing objects
-- this function references.
ALTER FUNCTION set_updated_at() SET search_path = public;
