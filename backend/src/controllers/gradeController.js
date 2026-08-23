const asyncHandler = require('../utils/asyncHandler');
const gradeModel = require('../models/gradeModel');

const list = asyncHandler(async (req, res) => {
  const grades = await gradeModel.listForUser(req.userId, { courseId: req.query.courseId });
  res.json({ grades });
});

const create = asyncHandler(async (req, res) => {
  const { courseId, assessmentName, score, maxScore, takenAt } = req.body;
  const grade = await gradeModel.create({ userId: req.userId, courseId, assessmentName, score, maxScore, takenAt });
  res.status(201).json({ grade });
});

const remove = asyncHandler(async (req, res) => {
  const deleted = await gradeModel.deleteForUser(req.params.id, req.userId);
  res.status(deleted ? 204 : 404).send();
});

module.exports = { list, create, remove };
