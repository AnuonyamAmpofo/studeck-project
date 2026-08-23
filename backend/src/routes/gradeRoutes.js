const { Router } = require('express');
const { body } = require('express-validator');
const validate = require('../middleware/validate');
const requireAuth = require('../middleware/auth');
const gradeController = require('../controllers/gradeController');

const router = Router();
router.use(requireAuth);

router.get('/', gradeController.list);
router.post(
  '/',
  [
    body('courseId').isUUID().withMessage('courseId must be a valid UUID'),
    body('assessmentName').trim().notEmpty(),
    body('score').isFloat({ min: 0 }),
    body('maxScore').isFloat({ min: 0 }),
  ],
  validate,
  gradeController.create
);
router.delete('/:id', gradeController.remove);

module.exports = router;
