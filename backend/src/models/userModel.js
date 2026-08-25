const db = require('../config/db');

const PUBLIC_COLUMNS = 'id, email, full_name, auth_provider, created_at';

async function createUser({ email, passwordHash, fullName }) {
  const { rows } = await db.query(
    `INSERT INTO users (email, password_hash, full_name, auth_provider)
     VALUES ($1, $2, $3, 'password')
     RETURNING ${PUBLIC_COLUMNS}`,
    [email, passwordHash, fullName]
  );
  return rows[0];
}

async function createGoogleUser({ email, fullName, googleId }) {
  const { rows } = await db.query(
    `INSERT INTO users (email, full_name, google_id, auth_provider)
     VALUES ($1, $2, $3, 'google')
     RETURNING ${PUBLIC_COLUMNS}`,
    [email, fullName, googleId]
  );
  return rows[0];
}

async function linkGoogleId(userId, googleId) {
  await db.query('UPDATE users SET google_id = $2 WHERE id = $1', [userId, googleId]);
}

async function findByEmail(email) {
  const { rows } = await db.query('SELECT * FROM users WHERE email = $1', [email]);
  return rows[0] || null;
}

async function findByGoogleId(googleId) {
  const { rows } = await db.query('SELECT * FROM users WHERE google_id = $1', [googleId]);
  return rows[0] || null;
}

async function findById(id) {
  const { rows } = await db.query(`SELECT ${PUBLIC_COLUMNS} FROM users WHERE id = $1`, [id]);
  return rows[0] || null;
}

module.exports = { createUser, createGoogleUser, linkGoogleId, findByEmail, findByGoogleId, findById };
