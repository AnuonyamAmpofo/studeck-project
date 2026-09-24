const { Router } = require('express');
const { body } = require('express-validator');
const validate = require('../middleware/validate');
const requireAuth = require('../middleware/auth');
const quizController = require('../controllers/quizController');

const router = Router();
router.use(requireAuth);

router.post(
  '/generate',
  [
    body('numQuestions').optional().isInt({ min: 1, max: 20 }),
    body('topic').optional().isString(),
    body('sourceMaterial').optional().isString(),
  ],
  validate,
  quizController.generate
);
router.get('/attempts', quizController.listAttempts);
router.get('/:id', quizController.getOne);
router.post('/:id/attempts', quizController.startAttempt);
router.post('/attempts/:attemptId/submit', quizController.submitAttempt);

module.exports = router;
