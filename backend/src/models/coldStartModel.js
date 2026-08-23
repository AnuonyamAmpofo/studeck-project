const db = require('../config/db');

// Reference data — no user_id filter, these are the same for every student
// with a given course_type.
async function listForCourseType(courseType) {
  const { rows } = await db.query(
    'SELECT * FROM cold_start_defaults WHERE course_type = $1 ORDER BY position ASC',
    [courseType]
  );
  return rows;
}

module.exports = { listForCourseType };
