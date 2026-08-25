const { Router } = require('express');
const authRoutes = require('./authRoutes');
const courseRoutes = require('./courseRoutes');
const taskRoutes = require('./taskRoutes');
const gradeRoutes = require('./gradeRoutes');
const studySessionRoutes = require('./studySessionRoutes');
const quizRoutes = require('./quizRoutes');
const coldStartRoutes = require('./coldStartRoutes');

const router = Router();

router.get('/health', (req, res) => res.json({ status: 'ok' }));
router.use('/auth', authRoutes);
router.use('/courses', courseRoutes);
router.use('/tasks', taskRoutes);
router.use('/grades', gradeRoutes);
router.use('/study-sessions', studySessionRoutes);
router.use('/quizzes', quizRoutes);
router.use('/cold-start-defaults', coldStartRoutes);

module.exports = router;

