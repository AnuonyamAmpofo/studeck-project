import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/course.dart';
import '../../models/grade.dart';
import '../../models/study_session.dart';
import '../../services/course_insights.dart';
import '../../services/grade_service.dart';
import '../../services/study_session_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_panel.dart';
import '../../widgets/insight_card.dart';
import '../../widgets/performance_bar_row.dart';
import '../../widgets/section_label.dart';
import '../../widgets/stat_card.dart';

class CourseDetailScreen extends StatefulWidget {
  const CourseDetailScreen({super.key, required this.course});

  final Course course;

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  late Future<(List<Grade>, List<StudySession>)> _future;
  final Set<String> _dismissedInsights = {};

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<(List<Grade>, List<StudySession>)> _load() async {
    final gradeService = context.read<GradeService>();
    final sessionService = context.read<StudySessionService>();
    final grades = await gradeService.list(courseId: widget.course.id);
    final sessions = await sessionService.list(courseId: widget.course.id);
    return (grades, sessions);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.course.name)),
      body: SafeArea(
        child: FutureBuilder<(List<Grade>, List<StudySession>)>(
          future: _future,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final (grades, sessions) = snapshot.data!;
            final rated = sessions.where((s) => s.selfRating != null).toList();
            final avgRating = rated.isEmpty
                ? null
                : rated.map((s) => s.selfRating!).reduce((a, b) => a + b) / rated.length;
            final avgGrade = grades.isEmpty
                ? null
                : grades.map((g) => g.percentage).reduce((a, b) => a + b) / grades.length;

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              children: [
                Row(
                  children: [
                    Expanded(child: StatCard(value: '${sessions.length}', label: 'Sessions')),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatCard(
                        value: avgRating?.toStringAsFixed(1) ?? '—',
                        label: 'Avg. Rating',
                        valueColor: AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatCard(
                        value: avgGrade != null ? '${avgGrade.round()}%' : '—',
                        label: 'Grade Avg.',
                        valueColor: AppColors.warning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (grades.length >= 2) ...[
                  const SectionLabel('Performance over time'),
                  const SizedBox(height: 10),
                  SizedBox(height: 160, child: _GradeTrendChart(grades: grades)),
                  const SizedBox(height: 24),
                ],
                Builder(builder: (context) {
                  final timeOfDay = timeOfDayBreakdown(sessions);
                  if (timeOfDay.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionLabel('Performance by time of day'),
                        const SizedBox(height: 12),
                        ...timeOfDay.map((bar) => PerformanceBarRow(bar: bar)),
                      ],
                    ),
                  );
                }),
                Builder(builder: (context) {
                  final byMethod = methodBreakdown(sessions);
                  if (byMethod.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionLabel('Performance by method'),
                        const SizedBox(height: 12),
                        ...byMethod.map((bar) => PerformanceBarRow(bar: bar, color: AppColors.success)),
                      ],
                    ),
                  );
                }),
                Builder(builder: (context) {
                  final insights = buildCourseInsights(sessions)
                      .where((i) => !_dismissedInsights.contains(i.key))
                      .toList();
                  final review = nextReviewDate(sessions);
                  if (insights.isEmpty && review == null) return const SizedBox.shrink();

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionLabel('Insights for this course'),
                        const SizedBox(height: 10),
                        for (final insight in insights) ...[
                          GlassPanel(
                            borderRadius: 14,
                            tintColor: insight.tone == InsightTone.positive
                                ? AppColors.successSurface
                                : AppColors.warningSurface,
                            tintOpacity: 0.3,
                            borderColor: (insight.tone == InsightTone.positive
                                    ? AppColors.successSurface
                                    : AppColors.warningSurface)
                                .withOpacity(0.55),
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(insight.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                const SizedBox(height: 6),
                                Text(insight.body, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4)),
                                if (insight.suggestedMethod != null) ...[
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          setState(() => _dismissedInsights.add(insight.key));
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text("We'll suggest ${insight.suggestedMethod} next time")),
                                          );
                                        },
                                        child: const Text('Yes'),
                                      ),
                                      TextButton(
                                        onPressed: () => setState(() => _dismissedInsights.add(insight.key)),
                                        child: const Text('Dismiss', style: TextStyle(color: AppColors.textMuted)),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                        if (review != null) _ReviewDueCard(reviewDate: review),
                      ],
                    ),
                  );
                }),
                const SectionLabel('Recent sessions'),
                const SizedBox(height: 10),
                if (sessions.isEmpty)
                  const Text('No sessions yet for this course.', style: TextStyle(color: AppColors.textMuted))
                else
                  ...sessions.take(5).map(
                        (s) => Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.surfaceBorder),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(s.technique ?? 'Study session', style: const TextStyle(fontWeight: FontWeight.w600)),
                              if (s.durationSeconds != null)
                                Text(
                                  '${(s.durationSeconds! / 60).round()} min',
                                  style: const TextStyle(color: AppColors.textSecondary),
                                ),
                            ],
                          ),
                        ),
                      ),
                const SizedBox(height: 20),
                const SectionLabel('Grades'),
                const SizedBox(height: 10),
                if (grades.isEmpty)
                  const Text('No grades logged yet.', style: TextStyle(color: AppColors.textMuted))
                else
                  ...grades.map(
                    (g) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(g.assessmentName, style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text('${g.percentage.round()}%', style: const TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ReviewDueCard extends StatelessWidget {
  const _ReviewDueCard({required this.reviewDate});
  final DateTime reviewDate;

  @override
  Widget build(BuildContext context) {
    final days = reviewDate.difference(DateTime.now()).inDays;
    final label = days > 0 ? 'Review due in $days day${days == 1 ? '' : 's'}' : 'Review overdue';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.refresh_rounded, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
                const Text(
                  'Based on your last reviewed session',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GradeTrendChart extends StatelessWidget {
  const _GradeTrendChart({required this.grades});
  final List<Grade> grades;

  @override
  Widget build(BuildContext context) {
    final sorted = [...grades]..sort((a, b) => a.takenAt.compareTo(b.takenAt));
    final spots = [
      for (var i = 0; i < sorted.length; i++) FlSpot(i.toDouble(), sorted[i].percentage),
    ];

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 100,
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: true, color: AppColors.primary.withOpacity(0.12)),
          ),
        ],
      ),
    );
  }
}
