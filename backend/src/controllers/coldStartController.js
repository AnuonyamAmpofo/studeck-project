const asyncHandler = require('../utils/asyncHandler');
const ApiError = require('../utils/ApiError');
const coldStartModel = require('../models/coldStartModel');

const VALID_TYPES = ['calculation', 'concept', 'skill', 'mixed'];

const listForCourseType = asyncHandler(async (req, res) => {
  const { courseType } = req.params;
  if (!VALID_TYPES.includes(courseType)) {
    throw new ApiError(422, `courseType must be one of: ${VALID_TYPES.join(', ')}`);
  }
  const defaults = await coldStartModel.listForCourseType(courseType);
  res.json({ defaults });
});

module.exports = { listForCourseType };
