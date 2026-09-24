class Grade {
  const Grade({
    required this.id,
    required this.courseId,
    required this.assessmentName,
    required this.score,
    required this.maxScore,
    required this.takenAt,
  });

  final String id;
  final String courseId;
  final String assessmentName;
  final num score;
  final num maxScore;
  final DateTime takenAt;

  double get percentage => (score / maxScore) * 100;

  factory Grade.fromJson(Map<String, dynamic> json) => Grade(
        id: json['id'] as String,
        courseId: json['course_id'] as String,
        assessmentName: json['assessment_name'] as String,
        score: json['score'] as num,
        maxScore: json['max_score'] as num,
        takenAt: DateTime.parse(json['taken_at'] as String),
      );
}
