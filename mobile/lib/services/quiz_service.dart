import '../models/quiz.dart';
import 'api_client.dart';
import 'demo_data_store.dart';
import 'demo_mode.dart';

class QuizService {
  QuizService(this._client);

  final ApiClient _client;

  Future<({Quiz quiz, List<QuizQuestion> questions})> generate({
    String? topic,
    String? sourceMaterial,
    String? courseId,
    int numQuestions = 5,
  }) async {
    if (kDemoMode) {
      await Future.delayed(const Duration(milliseconds: 900));
      final store = DemoDataStore.instance;
      final quizId = store.nextId();
      final subject = topic ?? 'this topic';
      final quiz = Quiz(id: quizId, title: '$subject quiz', courseId: courseId);

      final questions = <QuizQuestion>[];
      final answerKey = <String, Map<String, String>>{};
      for (var i = 0; i < numQuestions; i++) {
        final questionId = store.nextId();
        final correct = ['A', 'B', 'C', 'D'][i % 4];
        questions.add(QuizQuestion(
          id: questionId,
          questionText: 'Practice question ${i + 1}: which statement best applies to $subject?',
          options: {
            'A': 'Option A for question ${i + 1}',
            'B': 'Option B for question ${i + 1}',
            'C': 'Option C for question ${i + 1}',
            'D': 'Option D for question ${i + 1}',
          },
          position: i,
        ));
        answerKey[questionId] = {
          'correctOption': correct,
          'explanation': 'Option $correct is correct because it most directly reflects a core idea in $subject.',
        };
      }

      store.quizzes.add(quiz);
      store.quizQuestions[quizId] = questions;
      store.quizAnswerKeys[quizId] = answerKey;
      return (quiz: quiz, questions: questions);
    }

    final res = await _client.dio.post('/quizzes/generate', data: {
      if (topic != null) 'topic': topic,
      if (sourceMaterial != null) 'sourceMaterial': sourceMaterial,
      if (courseId != null) 'courseId': courseId,
      'numQuestions': numQuestions,
    });
    final quiz = Quiz.fromJson(res.data['quiz'] as Map<String, dynamic>);
    final questions = (res.data['questions'] as List)
        .map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
        .toList();
    return (quiz: quiz, questions: questions);
  }

  Future<List<QuizAttempt>> listAttempts() async {
    if (kDemoMode) {
      return DemoDataStore.instance.attempts.where((a) => a.completedAt != null).toList();
    }
    final res = await _client.dio.get('/quizzes/attempts');
    return (res.data['attempts'] as List)
        .map((a) => QuizAttempt.fromJson(a as Map<String, dynamic>))
        .toList();
  }

  Future<String> startAttempt(String quizId) async {
    if (kDemoMode) {
      final store = DemoDataStore.instance;
      final attempt = QuizAttempt(id: store.nextId(), quizId: quizId);
      store.attempts.add(attempt);
      return attempt.id;
    }
    final res = await _client.dio.post('/quizzes/$quizId/attempts');
    return res.data['attempt']['id'] as String;
  }

  Future<Map<String, dynamic>> submitAttempt(
    String attemptId,
    List<Map<String, String>> answers,
  ) async {
    if (kDemoMode) {
      final store = DemoDataStore.instance;
      final attemptIndex = store.attempts.indexWhere((a) => a.id == attemptId);
      final attempt = store.attempts[attemptIndex];
      final answerKey = store.quizAnswerKeys[attempt.quizId] ?? {};

      var correctCount = 0;
      final results = <Map<String, dynamic>>[];
      for (final answer in answers) {
        final questionId = answer['questionId']!;
        final selected = answer['selectedOption'];
        final key = answerKey[questionId];
        final isCorrect = key != null && key['correctOption'] == selected;
        if (isCorrect) correctCount++;
        results.add({
          'questionId': questionId,
          'selectedOption': selected,
          'correctOption': key?['correctOption'],
          'isCorrect': isCorrect,
          'explanation': key?['explanation'],
        });
      }
      final score = answers.isEmpty ? 0 : (correctCount / answers.length * 100).round();
      store.attempts[attemptIndex] = QuizAttempt(
        id: attempt.id,
        quizId: attempt.quizId,
        score: score,
        completedAt: DateTime.now(),
      );

      return {
        'attempt': {'id': attempt.id, 'score': score},
        'results': results,
      };
    }

    final res = await _client.dio.post('/quizzes/attempts/$attemptId/submit', data: {
      'answers': answers,
    });
    return res.data as Map<String, dynamic>;
  }
}
