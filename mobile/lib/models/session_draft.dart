import '../models/course.dart';
import '../models/quiz.dart';

/// Accumulates everything captured across the post-timer screens
/// (audit → practice → optional quiz → ready-to-save) before a single
/// POST /study-sessions call persists it all at once. Field set matches
/// the thesis's session record description: planned vs. actual duration,
/// method, environment, focus mode, self-rating, and outcome score,
/// captured in one logging interaction.
class SessionDraft {
  SessionDraft({
    required this.course,
    required this.technique,
    required this.startedAt,
    required this.endedAt,
    required this.plannedDurationSeconds,
    required this.cyclesCompleted,
    required this.focusSeconds,
    required this.focusModeOn,
    this.uploadedFileName,
    this.pagesTotal,
    this.extractedText,
  });

  final Course course;
  final String technique;
  final DateTime startedAt;
  final DateTime endedAt;
  final int plannedDurationSeconds;
  final int cyclesCompleted;
  final int focusSeconds;
  final bool focusModeOn;
  final String? uploadedFileName;
  final int? pagesTotal;
  /// Raw text pulled from the uploaded file (currently only .txt is read
  /// directly) — fed to Claude as sourceMaterial when generating a quiz.
  final String? extractedText;

  bool get hasSlides => uploadedFileName != null;
  int get minutes => (focusSeconds / 60).round();

  // Filled in by SessionAuditScreen.
  Set<String> methods = {};
  int? understandingRating;
  String? environment;

  // Filled in by PracticeScreen.
  int? problemsAttempted;
  int? problemsCorrect;
  int? pagesCovered;

  // Filled in by the quiz flow, if the student generates + takes one.
  Quiz? quiz;
  num? quizScore;

  double? get practiceAccuracy {
    if (problemsAttempted == null || problemsAttempted == 0 || problemsCorrect == null) return null;
    return problemsCorrect! / problemsAttempted! * 100;
  }
}
