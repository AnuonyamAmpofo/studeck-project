const { Router } = require('express');
const { body } = require('express-validator');
const validate = require('../middleware/validate');
const requireAuth = require('../middleware/auth');
const courseController = require('../controllers/courseController');

const router = Router();
router.use(requireAuth);

router.get('/', courseController.list);
router.post(
  '/',
  [
    body('name').trim().notEmpty().withMessage('Course name is required'),
    body('courseType').optional().isIn(['calculation', 'concept', 'skill', 'mixed']),
  ],
  validate,
  courseController.create
);
router.get('/:id', courseController.getOne);
router.patch('/:id', courseController.update);
router.delete('/:id', courseController.remove);

module.exports = router;
