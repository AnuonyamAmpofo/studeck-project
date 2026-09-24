import '../models/study_session.dart';
import '../widgets/insight_card.dart';
import 'quiz_service.dart';
import 'study_session_service.dart';

class DashboardInsight {
  const DashboardInsight({required this.title, required this.body, required this.tone});
  final String title;
  final String body;
  final InsightTone tone;
}

class DashboardSummary {
  const DashboardSummary({
    required this.sessionCount,
    required this.avgRating,
    required this.quizAverage,
    required this.insight,
    required this.suggestion,
  });

  final int sessionCount;
  final double? avgRating;
  final double? quizAverage;
  final DashboardInsight? insight;
  final DashboardInsight? suggestion;
}

/// Turns raw session/quiz history into the "Insights" and "Suggestions" cards
/// shown on the dashboard — computed from real data rather than canned copy.
class DashboardService {
  DashboardService(this._sessions, this._quizzes);

  final StudySessionService _sessions;
  final QuizService _quizzes;

  Future<DashboardSummary> loadSummary() async {
    final sessions = await _sessions.list();
    final attempts = await _quizzes.listAttempts();

    final rated = sessions.where((s) => s.selfRating != null).toList();
    final avgRating = rated.isEmpty
        ? null
        : rated.map((s) => s.selfRating!).reduce((a, b) => a + b) / rated.length;

    final scored = attempts.where((a) => a.score != null).toList();
    final quizAverage = scored.isEmpty
        ? null
        : scored.map((a) => a.score!.toDouble()).reduce((a, b) => a + b) / scored.length;

    return DashboardSummary(
      sessionCount: sessions.length,
      avgRating: avgRating,
      quizAverage: quizAverage,
      insight: _buildTimeOfDayInsight(sessions),
      suggestion: _buildTechniqueSuggestion(sessions),
    );
  }

  DashboardInsight? _buildTimeOfDayInsight(List<StudySession> sessions) {
    final rated = sessions.where((s) => s.selfRating != null).toList();
    if (rated.length < 4) return null;

    final morning = rated.where((s) => s.startedAt.hour < 12).toList();
    final afternoon = rated.where((s) => s.startedAt.hour >= 12).toList();
    if (morning.isEmpty || afternoon.isEmpty) return null;

    double avg(List<StudySession> list) =>
        list.map((s) => s.selfRating!).reduce((a, b) => a + b) / list.length;

    final morningAvg = avg(morning);
    final afternoonAvg = avg(afternoon);
    final better = morningAvg >= afternoonAvg ? 'Morning' : 'Afternoon';
    final diffPercent = ((morningAvg - afternoonAvg).abs() / afternoonAvg.clamp(0.01, 5) * 100).round();

    if (diffPercent < 10) return null;

    return DashboardInsight(
      title: '$better sessions work best',
      body: '$diffPercent% higher avg. rating in your $better sessions recently.',
      tone: InsightTone.positive,
    );
  }

  DashboardInsight? _buildTechniqueSuggestion(List<StudySession> sessions) {
    final rated = sessions.where((s) => s.selfRating != null && s.technique != null).toList();
    if (rated.length < 3) return null;

    final recent = rated.take(3).toList();
    final isDeclining = recent[0].selfRating! < recent[1].selfRating! &&
        recent[1].selfRating! < recent[2].selfRating!;

    if (!isDeclining) return null;

    final byTechnique = <String, List<int>>{};
    for (final s in rated) {
      byTechnique.putIfAbsent(s.technique!, () => []).add(s.selfRating!);
    }
    final bestTechnique = byTechnique.entries
        .map((e) => MapEntry(e.key, e.value.reduce((a, b) => a + b) / e.value.length))
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;

    return DashboardInsight(
      title: 'Struggle pattern detected',
      body: 'Ratings declining over your last 3 sessions. Try switching to $bestTechnique.',
      tone: InsightTone.warning,
    );
  }
}
