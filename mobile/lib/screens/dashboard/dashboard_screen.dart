import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/dashboard_service.dart';
import '../../state/auth_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/insight_card.dart';
import '../../widgets/section_label.dart';
import '../../widgets/stat_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<DashboardSummary> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<DashboardService>().loadSummary();
  }

  Future<void> _refresh() async {
    final future = context.read<DashboardService>().loadSummary();
    setState(() => _future = future);
    await future;
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthState>().user;
    final greeting = _greeting();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(greeting, style: const TextStyle(color: AppColors.textSecondary)),
                      Text(user?.fullName ?? '', style: AppFonts.heading(fontSize: 22)),
                    ],
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: const Icon(Icons.person_outline, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FutureBuilder<DashboardSummary>(
                future: _future,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final summary = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: StatCard(value: '${summary.sessionCount}', label: 'Sessions'),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: StatCard(
                              value: summary.avgRating?.toStringAsFixed(1) ?? '—',
                              label: 'Avg. Rating',
                              valueColor: AppColors.warning,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: StatCard(
                              value: summary.quizAverage != null
                                  ? '${summary.quizAverage!.round()}%'
                                  : '—',
                              label: 'Quiz Avg.',
                              valueColor: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      if (summary.insight != null) ...[
                        const SectionLabel('Insights'),
                        const SizedBox(height: 10),
                        InsightCard(
                          title: summary.insight!.title,
                          body: summary.insight!.body,
                          tone: summary.insight!.tone,
                        ),
                        const SizedBox(height: 24),
                      ],
                      if (summary.suggestion != null) ...[
                        const SectionLabel('Suggestions'),
                        const SizedBox(height: 10),
                        InsightCard(
                          title: summary.suggestion!.title,
                          body: summary.suggestion!.body,
                          tone: summary.suggestion!.tone,
                        ),
                      ],
                      if (summary.insight == null && summary.suggestion == null)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            'Log a few more study sessions and Studeck will start '
                            'surfacing patterns here.',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }
}
