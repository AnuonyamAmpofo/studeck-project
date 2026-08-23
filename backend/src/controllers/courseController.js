const asyncHandler = require('../utils/asyncHandler');
const ApiError = require('../utils/ApiError');
const courseModel = require('../models/courseModel');

const list = asyncHandler(async (req, res) => {
  const courses = await courseModel.listForUser(req.userId);
  res.json({ courses });
});

const create = asyncHandler(async (req, res) => {
  const { name, code, colorHex, emoji, courseType } = req.body;
  const course = await courseModel.create({ userId: req.userId, name, code, colorHex, emoji, courseType });
  res.status(201).json({ course });
});

const getOne = asyncHandler(async (req, res) => {
  const course = await courseModel.findByIdForUser(req.params.id, req.userId);
  if (!course) throw new ApiError(404, 'Course not found');
  res.json({ course });
});

const update = asyncHandler(async (req, res) => {
  const { name, code, colorHex, emoji, courseType } = req.body;
  const course = await courseModel.updateForUser(req.params.id, req.userId, { name, code, colorHex, emoji, courseType });
  if (!course) throw new ApiError(404, 'Course not found');
  res.json({ course });
});

const remove = asyncHandler(async (req, res) => {
  const deleted = await courseModel.deleteForUser(req.params.id, req.userId);
  if (!deleted) throw new ApiError(404, 'Course not found');
  res.status(204).send();
});

module.exports = { list, create, getOne, update, remove };
