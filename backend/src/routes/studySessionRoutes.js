const { Router } = require('express');
const { body } = require('express-validator');
const validate = require('../middleware/validate');
const requireAuth = require('../middleware/auth');
const studySessionController = require('../controllers/studySessionController');

const router = Router();
router.use(requireAuth);

router.get('/', studySessionController.list);
router.post(
  '/',
  [
    body('startedAt').isISO8601().withMessage('startedAt must be an ISO date'),
    body('endedAt').optional().isISO8601(),
    body('selfRating').optional().isInt({ min: 1, max: 5 }),
    body('methods').optional().isArray(),
    body('focusModeOn').optional().isBoolean(),
    body('problemsAttempted').optional().isInt({ min: 0 }),
    body('problemsCorrect').optional().isInt({ min: 0 }),
    body('pagesTotal').optional().isInt({ min: 0 }),
    body('pagesCovered').optional().isInt({ min: 0 }),
    body('plannedDurationSeconds').optional().isInt({ min: 0 }),
  ],
  validate,
  studySessionController.create
);

module.exports = router;
