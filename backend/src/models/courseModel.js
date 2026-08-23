const db = require('../config/db');

async function create({ userId, name, code, colorHex, emoji, courseType }) {
  const { rows } = await db.query(
    `INSERT INTO courses (user_id, name, code, color_hex, emoji, course_type)
     VALUES ($1, $2, $3, COALESCE($4, '#4F46E5'), COALESCE($5, '📘'), COALESCE($6, 'mixed')::course_type)
     RETURNING *`,
    [userId, name, code || null, colorHex || null, emoji || null, courseType || null]
  );
  return rows[0];
}

async function listForUser(userId) {
  const { rows } = await db.query('SELECT * FROM courses WHERE user_id = $1 ORDER BY created_at DESC', [userId]);
  return rows;
}

async function findByIdForUser(id, userId) {
  const { rows } = await db.query('SELECT * FROM courses WHERE id = $1 AND user_id = $2', [id, userId]);
  return rows[0] || null;
}

async function updateForUser(id, userId, { name, code, colorHex, emoji, courseType }) {
  const { rows } = await db.query(
    `UPDATE courses
     SET name = COALESCE($3, name),
         code = COALESCE($4, code),
         color_hex = COALESCE($5, color_hex),
         emoji = COALESCE($6, emoji),
         course_type = COALESCE($7, course_type)
     WHERE id = $1 AND user_id = $2
     RETURNING *`,
    [id, userId, name, code, colorHex, emoji, courseType]
  );
  return rows[0] || null;
}

async function deleteForUser(id, userId) {
  const { rowCount } = await db.query('DELETE FROM courses WHERE id = $1 AND user_id = $2', [id, userId]);
  return rowCount > 0;
}

module.exports = { create, listForUser, findByIdForUser, updateForUser, deleteForUser };
