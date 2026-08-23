const { Router } = require('express');
const requireAuth = require('../middleware/auth');
const coldStartController = require('../controllers/coldStartController');

const router = Router();
router.use(requireAuth);

router.get('/:courseType', coldStartController.listForCourseType);

module.exports = router;
