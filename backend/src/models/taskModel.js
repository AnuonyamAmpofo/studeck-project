const db = require('../config/db');

async function create({ userId, courseId, title, description, dueDate, priority }) {
  const { rows } = await db.query(
    `INSERT INTO tasks (user_id, course_id, title, description, due_date, priority)
     VALUES ($1, $2, $3, $4, $5, COALESCE($6, 'medium')::task_priority)
     RETURNING *`,
    [userId, courseId || null, title, description || null, dueDate || null, priority || null]
  );
  return rows[0];
}

async function listForUser(userId, { status } = {}) {
  const params = [userId];
  let where = 'user_id = $1';
  if (status) {
    params.push(status);
    where += ` AND status = $${params.length}`;
  }
  const { rows } = await db.query(`SELECT * FROM tasks WHERE ${where} ORDER BY due_date ASC NULLS LAST`, params);
  return rows;
}

async function findByIdForUser(id, userId) {
  const { rows } = await db.query('SELECT * FROM tasks WHERE id = $1 AND user_id = $2', [id, userId]);
  return rows[0] || null;
}

async function updateForUser(id, userId, { title, description, dueDate, status, priority, courseId }) {
  const { rows } = await db.query(
    `UPDATE tasks
     SET title = COALESCE($3, title),
         description = COALESCE($4, description),
         due_date = COALESCE($5, due_date),
         status = COALESCE($6, status),
         priority = COALESCE($7, priority),
         course_id = COALESCE($8, course_id)
     WHERE id = $1 AND user_id = $2
     RETURNING *`,
    [id, userId, title, description, dueDate, status, priority, courseId]
  );
  return rows[0] || null;
}

async function deleteForUser(id, userId) {
  const { rowCount } = await db.query('DELETE FROM tasks WHERE id = $1 AND user_id = $2', [id, userId]);
  return rowCount > 0;
}

module.exports = { create, listForUser, findByIdForUser, updateForUser, deleteForUser };
