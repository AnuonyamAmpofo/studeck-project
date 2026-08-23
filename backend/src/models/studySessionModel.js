const db = require('../config/db');

async function create({
  userId,
  courseId,
  startedAt,
  endedAt,
  plannedDurationSeconds,
  technique,
  methods,
  environment,
  focusModeOn,
  selfRating,
  problemsAttempted,
  problemsCorrect,
  pagesTotal,
  pagesCovered,
}) {
  const durationSeconds =
    endedAt && startedAt
      ? Math.max(0, Math.round((new Date(endedAt) - new Date(startedAt)) / 1000))
      : null;

  const { rows } = await db.query(
    `INSERT INTO study_sessions
       (user_id, course_id, started_at, ended_at, planned_duration_seconds, duration_seconds,
        technique, methods, environment, focus_mode_on, self_rating,
        problems_attempted, problems_correct, pages_total, pages_covered)
     VALUES ($1, $2, $3, $4, $5, $6, $7, COALESCE($8, '{}')::text[], $9, COALESCE($10, false), $11, $12, $13, $14, $15)
     RETURNING *`,
    [
      userId,
      courseId || null,
      startedAt,
      endedAt || null,
      plannedDurationSeconds ?? null,
      durationSeconds,
      technique || null,
      methods || null,
      environment || null,
      focusModeOn ?? null,
      selfRating ?? null,
      problemsAttempted ?? null,
      problemsCorrect ?? null,
      pagesTotal ?? null,
      pagesCovered ?? null,
    ]
  );
  return rows[0];
}

async function listForUser(userId, { courseId, from, to } = {}) {
  const params = [userId];
  let where = 'user_id = $1';
  if (courseId) {
    params.push(courseId);
    where += ` AND course_id = $${params.length}`;
  }
  if (from) {
    params.push(from);
    where += ` AND started_at >= $${params.length}`;
  }
  if (to) {
    params.push(to);
    where += ` AND started_at <= $${params.length}`;
  }
  const { rows } = await db.query(`SELECT * FROM study_sessions WHERE ${where} ORDER BY started_at DESC`, params);
  return rows;
}

module.exports = { create, listForUser };
