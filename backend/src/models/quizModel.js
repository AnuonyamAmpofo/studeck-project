const db = require('../config/db');

async function createQuiz({ userId, courseId, title, sourceMaterial }) {
  const { rows } = await db.query(
    `INSERT INTO quizzes (user_id, course_id, title, source_material)
     VALUES ($1, $2, $3, $4)
     RETURNING *`,
    [userId, courseId || null, title, sourceMaterial || null]
  );
  return rows[0];
}

async function addQuestions(quizId, questions) {
  const inserted = [];
  for (let i = 0; i < questions.length; i++) {
    const q = questions[i];
    const { rows } = await db.query(
      `INSERT INTO quiz_questions (quiz_id, question_text, options, correct_option, explanation, position)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING *`,
      [quizId, q.questionText, JSON.stringify(q.options), q.correctOption, q.explanation || null, i]
    );
    inserted.push(rows[0]);
  }
  return inserted;
}

async function getQuestions(quizId) {
  const { rows } = await db.query('SELECT * FROM quiz_questions WHERE quiz_id = $1 ORDER BY position ASC', [quizId]);
  return rows;
}

async function findByIdForUser(id, userId) {
  const { rows } = await db.query('SELECT * FROM quizzes WHERE id = $1 AND user_id = $2', [id, userId]);
  return rows[0] || null;
}

async function createAttempt({ quizId, userId, totalQuestions }) {
  const { rows } = await db.query(
    `INSERT INTO quiz_attempts (quiz_id, user_id, total_questions) VALUES ($1, $2, $3) RETURNING *`,
    [quizId, userId, totalQuestions]
  );
  return rows[0];
}

async function findAttemptForUser(attemptId, userId) {
  const { rows } = await db.query('SELECT * FROM quiz_attempts WHERE id = $1 AND user_id = $2', [attemptId, userId]);
  return rows[0] || null;
}

async function recordAnswer({ attemptId, questionId, selectedOption, isCorrect }) {
  await db.query(
    `INSERT INTO quiz_answers (attempt_id, question_id, selected_option, is_correct) VALUES ($1, $2, $3, $4)`,
    [attemptId, questionId, selectedOption || null, isCorrect]
  );
}

async function completeAttempt(attemptId, score) {
  const { rows } = await db.query(
    `UPDATE quiz_attempts SET score = $2, completed_at = now() WHERE id = $1 RETURNING *`,
    [attemptId, score]
  );
  return rows[0];
}

module.exports = {
  createQuiz,
  addQuestions,
  getQuestions,
  findByIdForUser,
  createAttempt,
  findAttemptForUser,
  recordAnswer,
  completeAttempt,
};
