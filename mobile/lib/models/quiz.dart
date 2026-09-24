class Quiz {
  const Quiz({required this.id, required this.title, this.courseId});

  final String id;
  final String title;
  final String? courseId;

  factory Quiz.fromJson(Map<String, dynamic> json) => Quiz(
        id: json['id'] as String,
        title: json['title'] as String,
        courseId: json['course_id'] as String?,
      );
}

class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.questionText,
    required this.options,
    required this.position,
  });

  final String id;
  final String questionText;
  final Map<String, dynamic> options; // { "A": "...", "B": "...", ... }
  final int position;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
        id: json['id'] as String,
        questionText: json['questionText'] as String,
        options: Map<String, dynamic>.from(json['options'] as Map),
        position: json['position'] as int,
      );
}

class QuizAttempt {
  const QuizAttempt({required this.id, required this.quizId, this.score, this.completedAt});

  final String id;
  final String quizId;
  final num? score;
  final DateTime? completedAt;

  factory QuizAttempt.fromJson(Map<String, dynamic> json) => QuizAttempt(
        id: json['id'] as String,
        quizId: json['quiz_id'] as String,
        score: json['score'] as num?,
        completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at'] as String) : null,
      );
}
