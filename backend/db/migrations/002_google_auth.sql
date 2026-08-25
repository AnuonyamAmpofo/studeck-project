-- Adds Google Sign-In support. A user can now exist with no password at all
-- (Google-only account), so password_hash must become nullable. google_id
-- is Google's stable per-account identifier ("sub" claim in the ID token),
-- used to look up returning Google users without depending on their email
-- staying the same.

ALTER TABLE users ALTER COLUMN password_hash DROP NOT NULL;
ALTER TABLE users ADD COLUMN google_id TEXT UNIQUE;
ALTER TABLE users ADD COLUMN auth_provider TEXT NOT NULL DEFAULT 'password';
-- auth_provider is one of: 'password', 'google'
