import '../models/course.dart';
import '../models/grade.dart';
import '../models/quiz.dart';
import '../models/study_session.dart';
import '../models/user.dart';

/// In-memory data backing kDemoMode. Pre-seeded with enough history that
/// the dashboard insights, course-detail breakdowns, and grade trend chart
/// all have something real to render the moment the app opens.
class DemoDataStore {
  DemoDataStore._internal() {
    _seed();
  }

  static final DemoDataStore instance = DemoDataStore._internal();

  AppUser? currentUser;
  final List<Course> courses = [];
  final List<StudySession> sessions = [];
  final List<Grade> grades = [];
  final List<Quiz> quizzes = [];
  final Map<String, List<QuizQuestion>> quizQuestions = {};
  final Map<String, Map<String, Map<String, String>>> quizAnswerKeys = {}; // quizId -> questionId -> {correctOption, explanation}
  final List<QuizAttempt> attempts = [];

  int _idCounter = 1000;
  String nextId() => 'demo-${_idCounter++}';

  void _seed() {
    final calc = Course(
      id: nextId(),
      name: 'Calculus II',
      code: 'MATH 202',
      colorHex: '#6C5CE7',
      emoji: '📐',
      courseType: 'calculation',
    );
    final chem = Course(
      id: nextId(),
      name: 'Organic Chemistry',
      code: 'CHEM 210',
      colorHex: '#22C55E',
      emoji: '🧪',
      courseType: 'concept',
    );
    courses.addAll([calc, chem]);

    final now = DateTime.now();
    sessions.addAll([
      StudySession(
        id: nextId(),
        courseId: calc.id,
        startedAt: now.subtract(const Duration(days: 1, hours: 15)),
        endedAt: now.subtract(const Duration(days: 1, hours: 14, minutes: 15)),
        durationSeconds: 2700,
        technique: 'Pomodoro',
        selfRating: 4,
        methods: const ['practice', 'active_recall'],
      ),
      StudySession(
        id: nextId(),
        courseId: calc.id,
        startedAt: now.subtract(const Duration(days: 2, hours: 16)),
        endedAt: now.subtract(const Duration(days: 2, hours: 15, minutes: 20)),
        durationSeconds: 2400,
        technique: 'Deep work',
        selfRating: 3,
        methods: const ['reading', 'flashcards'],
      ),
      StudySession(
        id: nextId(),
        courseId: chem.id,
        startedAt: now.subtract(const Duration(days: 1, hours: 9)),
        endedAt: now.subtract(const Duration(days: 1, hours: 8, minutes: 10)),
        durationSeconds: 3000,
        technique: 'Pomodoro',
        selfRating: 5,
        methods: const ['active_recall'],
      ),
      StudySession(
        id: nextId(),
        courseId: chem.id,
        startedAt: now.subtract(const Duration(days: 3, hours: 20)),
        endedAt: now.subtract(const Duration(days: 3, hours: 19, minutes: 30)),
        durationSeconds: 1800,
        technique: 'Quick review',
        selfRating: 2,
        methods: const ['reading'],
      ),
      StudySession(
        id: nextId(),
        courseId: chem.id,
        startedAt: now.subtract(const Duration(hours: 9)),
        endedAt: now.subtract(const Duration(hours: 8, minutes: 20)),
        durationSeconds: 2400,
        technique: 'Pomodoro',
        selfRating: 3,
        methods: const ['active_recall', 'practice'],
      ),
      StudySession(
        id: nextId(),
        courseId: chem.id,
        startedAt: now.subtract(const Duration(hours: 3)),
        endedAt: now.subtract(const Duration(hours: 2, minutes: 25)),
        durationSeconds: 2100,
        technique: 'Pomodoro',
        selfRating: 2,
        methods: const ['reading'],
      ),
    ]);
    sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));

    grades.addAll([
      Grade(id: nextId(), courseId: calc.id, assessmentName: 'Quiz 1', score: 78, maxScore: 100, takenAt: now.subtract(const Duration(days: 20))),
      Grade(id: nextId(), courseId: calc.id, assessmentName: 'Quiz 2', score: 81, maxScore: 100, takenAt: now.subtract(const Duration(days: 12))),
      Grade(id: nextId(), courseId: calc.id, assessmentName: 'Midterm', score: 84, maxScore: 100, takenAt: now.subtract(const Duration(days: 5))),
      Grade(id: nextId(), courseId: chem.id, assessmentName: 'Lab Report 1', score: 88, maxScore: 100, takenAt: now.subtract(const Duration(days: 15))),
      Grade(id: nextId(), courseId: chem.id, assessmentName: 'Quiz 1', score: 70, maxScore: 100, takenAt: now.subtract(const Duration(days: 6))),
    ]);
  }
}
