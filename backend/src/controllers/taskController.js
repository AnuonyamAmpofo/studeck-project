const asyncHandler = require('../utils/asyncHandler');
const ApiError = require('../utils/ApiError');
const taskModel = require('../models/taskModel');

const list = asyncHandler(async (req, res) => {
  const tasks = await taskModel.listForUser(req.userId, { status: req.query.status });
  res.json({ tasks });
});

const create = asyncHandler(async (req, res) => {
  const { title, description, dueDate, priority, courseId } = req.body;
  const task = await taskModel.create({ userId: req.userId, courseId, title, description, dueDate, priority });
  res.status(201).json({ task });
});

const getOne = asyncHandler(async (req, res) => {
  const task = await taskModel.findByIdForUser(req.params.id, req.userId);
  if (!task) throw new ApiError(404, 'Task not found');
  res.json({ task });
});

const update = asyncHandler(async (req, res) => {
  const { title, description, dueDate, status, priority, courseId } = req.body;
  const task = await taskModel.updateForUser(req.params.id, req.userId, {
    title, description, dueDate, status, priority, courseId,
  });
  if (!task) throw new ApiError(404, 'Task not found');
  res.json({ task });
});

const remove = asyncHandler(async (req, res) => {
  const deleted = await taskModel.deleteForUser(req.params.id, req.userId);
  if (!deleted) throw new ApiError(404, 'Task not found');
  res.status(204).send();
});

module.exports = { list, create, getOne, update, remove };
