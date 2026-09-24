const asyncHandler = require('../utils/asyncHandler');
const ApiError = require('../utils/ApiError');
const quizModel = require('../models/quizModel');
const claudeService = require('../services/claudeService');

// Strip answer-revealing fields so a quiz can be safely sent to the client before it's taken.
const toSafeQuestion = (q) => ({ id: q.id, questionText: q.question_text, options: q.options, position: q.position });

const generate = asyncHandler(async (req, res) => {
  const { title, topic, sourceMaterial, numQuestions, courseId } = req.body;
  if (!topic && !sourceMaterial) {
    throw new ApiError(422, 'Provide a topic or sourceMaterial (e.g. text extracted from uploaded slides)');
  }

  const questions = await claudeService.generateQuizQuestions({ topic, sourceMaterial, numQuestions });
  const quiz = await quizModel.createQuiz({
    userId: req.userId,
    courseId,
    title: title || topic || 'AI-generated quiz',
    sourceMaterial,
  });
  const savedQuestions = await quizModel.addQuestions(quiz.id, questions);

  res.status(201).json({ quiz, questions: savedQuestions.map(toSafeQuestion) });
});

const getOne = asyncHandler(async (req, res) => {
  const quiz = await quizModel.findByIdForUser(req.params.id, req.userId);
  if (!quiz) throw new ApiError(404, 'Quiz not found');
  const questions = await quizModel.getQuestions(quiz.id);
  res.json({ quiz, questions: questions.map(toSafeQuestion) });
});

const listAttempts = asyncHandler(async (req, res) => {
  const attempts = await quizModel.listAttemptsForUser(req.userId);
  res.json({ attempts });
});

const startAttempt = asyncHandler(async (req, res) => {
  const quiz = await quizModel.findByIdForUser(req.params.id, req.userId);
  if (!quiz) throw new ApiError(404, 'Quiz not found');
  const questions = await quizModel.getQuestions(quiz.id);
  const attempt = await quizModel.createAttempt({ quizId: quiz.id, userId: req.userId, totalQuestions: questions.length });
  res.status(201).json({ attempt });
});

// body: { answers: [{ questionId, selectedOption }] }
const submitAttempt = asyncHandler(async (req, res) => {
  const attempt = await quizModel.findAttemptForUser(req.params.attemptId, req.userId);
  if (!attempt) throw new ApiError(404, 'Attempt not found');
  if (attempt.completed_at) throw new ApiError(409, 'Attempt already submitted');

  const questions = await quizModel.getQuestions(attempt.quiz_id);
  const questionById = new Map(questions.map((q) => [q.id, q]));

  const { answers } = req.body;
  if (!Array.isArray(answers)) throw new ApiError(422, 'answers must be an array');

  let correctCount = 0;
  const results = [];
  for (const { questionId, selectedOption } of answers) {
    const question = questionById.get(questionId);
    if (!question) continue;
    const isCorrect = question.correct_option === selectedOption;
    if (isCorrect) correctCount += 1;
    await quizModel.recordAnswer({ attemptId: attempt.id, questionId, selectedOption, isCorrect });
    results.push({
      questionId, selectedOption, correctOption: question.correct_option, isCorrect, explanation: question.explanation,
    });
  }

  const score = questions.length > 0 ? Math.round((correctCount / questions.length) * 100) : 0;
  const completedAttempt = await quizModel.completeAttempt(attempt.id, score);

  res.json({ attempt: completedAttempt, results });
});

module.exports = { generate, listAttempts, getOne, startAttempt, submitAttempt };
