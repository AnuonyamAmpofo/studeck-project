class StudySession {
  const StudySession({
    required this.id,
    this.courseId,
    required this.startedAt,
    this.endedAt,
    this.plannedDurationSeconds,
    this.durationSeconds,
    this.technique,
    this.methods = const [],
    this.environment,
    this.focusModeOn = false,
    this.selfRating,
    this.problemsAttempted,
    this.problemsCorrect,
    this.pagesTotal,
    this.pagesCovered,
  });

  final String id;
  final String? courseId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int? plannedDurationSeconds;
  final int? durationSeconds;
  final String? technique;
  final List<String> methods;
  final String? environment;
  final bool focusModeOn;
  final int? selfRating;
  final int? problemsAttempted;
  final int? problemsCorrect;
  final int? pagesTotal;
  final int? pagesCovered;

  factory StudySession.fromJson(Map<String, dynamic> json) => StudySession(
        id: json['id'] as String,
        courseId: json['course_id'] as String?,
        startedAt: DateTime.parse(json['started_at'] as String),
        endedAt: json['ended_at'] != null ? DateTime.parse(json['ended_at'] as String) : null,
        plannedDurationSeconds: json['planned_duration_seconds'] as int?,
        durationSeconds: json['duration_seconds'] as int?,
        technique: json['technique'] as String?,
        methods: json['methods'] != null ? List<String>.from(json['methods'] as List) : const [],
        environment: json['environment'] as String?,
        focusModeOn: json['focus_mode_on'] as bool? ?? false,
        selfRating: json['self_rating'] as int?,
        problemsAttempted: json['problems_attempted'] as int?,
        problemsCorrect: json['problems_correct'] as int?,
        pagesTotal: json['pages_total'] as int?,
        pagesCovered: json['pages_covered'] as int?,
      );
}
