const db = require('../config/db');

async function create({ userId, courseId, assessmentName, score, maxScore, takenAt }) {
  const { rows } = await db.query(
    `INSERT INTO grades (user_id, course_id, assessment_name, score, max_score, taken_at)
     VALUES ($1, $2, $3, $4, $5, COALESCE($6, CURRENT_DATE))
     RETURNING *`,
    [userId, courseId, assessmentName, score, maxScore, takenAt || null]
  );
  return rows[0];
}

async function listForUser(userId, { courseId } = {}) {
  const params = [userId];
  let where = 'user_id = $1';
  if (courseId) {
    params.push(courseId);
    where += ` AND course_id = $${params.length}`;
  }
  const { rows } = await db.query(`SELECT * FROM grades WHERE ${where} ORDER BY taken_at DESC`, params);
  return rows;
}

async function deleteForUser(id, userId) {
  const { rowCount } = await db.query('DELETE FROM grades WHERE id = $1 AND user_id = $2', [id, userId]);
  return rowCount > 0;
}

module.exports = { create, listForUser, deleteForUser };
