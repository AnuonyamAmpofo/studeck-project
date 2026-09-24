import '../models/study_method.dart';
import '../models/study_session.dart';
import '../widgets/insight_card.dart';

class PerformanceBar {
  const PerformanceBar(this.label, this.percent);
  final String label;
  final double percent; // 0-100
}

class CourseInsight {
  const CourseInsight({
    required this.key,
    required this.title,
    required this.body,
    required this.tone,
    this.suggestedMethod,
  });

  final String key;
  final String title;
  final String body;
  final InsightTone tone;
  final String? suggestedMethod;
}

/// [1..5] self-ratings converted to a 0-100 scale so they read alongside
/// grade percentages on the same bar charts.
double _ratingToPercent(Iterable<StudySession> sessions) {
  final rated = sessions.where((s) => s.selfRating != null).toList();
  if (rated.isEmpty) return 0;
  final avg = rated.map((s) => s.selfRating!).reduce((a, b) => a + b) / rated.length;
  return avg / 5 * 100;
}

List<PerformanceBar> timeOfDayBreakdown(List<StudySession> sessions) {
  final buckets = {
    'Morning': sessions.where((s) => s.startedAt.hour < 12),
    'Afternoon': sessions.where((s) => s.startedAt.hour >= 12 && s.startedAt.hour < 17),
    'Evening': sessions.where((s) => s.startedAt.hour >= 17),
  };
  return buckets.entries
      .where((e) => e.value.any((s) => s.selfRating != null))
      .map((e) => PerformanceBar(e.key, _ratingToPercent(e.value)))
      .toList();
}

List<PerformanceBar> methodBreakdown(List<StudySession> sessions) {
  final bars = <PerformanceBar>[];
  for (final method in kStudyMethods) {
    final withMethod = sessions.where((s) => s.methods.contains(method.value));
    if (withMethod.any((s) => s.selfRating != null)) {
      bars.add(PerformanceBar(method.label, _ratingToPercent(withMethod)));
    }
  }
  bars.sort((a, b) => b.percent.compareTo(a.percent));
  return bars;
}

List<CourseInsight> buildCourseInsights(List<StudySession> sessions) {
  final insights = <CourseInsight>[];

  final timeOfDay = timeOfDayBreakdown(sessions);
  if (timeOfDay.length >= 2) {
    final best = timeOfDay.reduce((a, b) => a.percent >= b.percent ? a : b);
    final worst = timeOfDay.reduce((a, b) => a.percent <= b.percent ? a : b);
    if (best.percent - worst.percent >= 15) {
      insights.add(CourseInsight(
        key: 'time_of_day',
        title: '${best.label} sessions work best',
        body: '${(best.percent - worst.percent).round()}% higher avg. rating than your ${worst.label.toLowerCase()} sessions.',
        tone: InsightTone.positive,
      ));
    }
  }

  final byMethod = methodBreakdown(sessions);
  final recentMethod = sessions.isNotEmpty && sessions.first.methods.isNotEmpty
      ? sessions.first.methods.first
      : null;
  if (byMethod.length >= 2 && recentMethod != null) {
    final best = byMethod.first;
    final recentLabel = studyMethodLabel(recentMethod);
    if (best.label != recentLabel && best.percent - byMethod.last.percent >= 15) {
      insights.add(CourseInsight(
        key: 'method_switch',
        title: 'Switch to ${best.label.toLowerCase()}',
        body: '${best.label} sessions rate higher than ${recentLabel.toLowerCase()} for this course.',
        tone: InsightTone.warning,
        suggestedMethod: best.label,
      ));
    }
  }

  return insights;
}

/// Simple spaced-repetition estimate: better-understood sessions push the
/// next review further out (rating * 2 days, clamped to a 1-10 day window).
DateTime? nextReviewDate(List<StudySession> sessions) {
  if (sessions.isEmpty) return null;
  final last = sessions.first; // sessions are sorted most-recent-first
  final rating = last.selfRating ?? 3;
  final gapDays = (rating * 2).clamp(1, 10);
  return last.startedAt.add(Duration(days: gapDays));
}
