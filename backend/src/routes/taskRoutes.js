const { Router } = require('express');
const { body } = require('express-validator');
const validate = require('../middleware/validate');
const requireAuth = require('../middleware/auth');
const taskController = require('../controllers/taskController');

const router = Router();
router.use(requireAuth);

router.get('/', taskController.list);
router.post(
  '/',
  [
    body('title').trim().notEmpty().withMessage('Task title is required'),
    body('dueDate').optional().isISO8601(),
    body('priority').optional().isIn(['low', 'medium', 'high']),
  ],
  validate,
  taskController.create
);
router.get('/:id', taskController.getOne);
router.patch('/:id', taskController.update);
router.delete('/:id', taskController.remove);

module.exports = router;
