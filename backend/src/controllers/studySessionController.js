const asyncHandler = require('../utils/asyncHandler');
const studySessionModel = require('../models/studySessionModel');

const list = asyncHandler(async (req, res) => {
  const { courseId, from, to } = req.query;
  const sessions = await studySessionModel.listForUser(req.userId, { courseId, from, to });
  res.json({ sessions });
});

const create = asyncHandler(async (req, res) => {
  const {
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
  } = req.body;

  const session = await studySessionModel.create({
    userId: req.userId,
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
  });
  res.status(201).json({ session });
});

module.exports = { list, create };
