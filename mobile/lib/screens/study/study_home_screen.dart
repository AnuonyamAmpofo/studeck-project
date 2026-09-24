import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/course.dart';
import '../../models/study_session.dart';
import '../../services/course_service.dart';
import '../../services/study_session_service.dart';
import '../../widgets/course_card.dart';
import '../../widgets/section_label.dart';
import '../../theme/app_colors.dart';
import 'session_setup_screen.dart';

class StudyHomeScreen extends StatefulWidget {
  const StudyHomeScreen({super.key});

  @override
  State<StudyHomeScreen> createState() => _StudyHomeScreenState();
}

class _StudyHomeScreenState extends State<StudyHomeScreen> {
  late Future<(List<Course>, List<StudySession>)> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<(List<Course>, List<StudySession>)> _load() async {
    final courseService = context.read<CourseService>();
    final sessionService = context.read<StudySessionService>();
    final courses = await courseService.list();
    final sessions = await sessionService.list();
    return (courses, sessions);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Study')),
      body: SafeArea(
        child: FutureBuilder<(List<Course>, List<StudySession>)>(
          future: _future,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final (courses, sessions) = snapshot.data!;
            final recent = sessions.take(3).toList();

            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 100),
              children: [
                const Text(
                  'What are you studying today?',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                if (courses.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text('Add a course first from the Courses tab.', style: TextStyle(color: AppColors.textMuted)),
                  )
                else
                  ...courses.map(
                    (course) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CourseCard(
                        course: course,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => SessionSetupScreen(course: course)),
                        ),
                      ),
                    ),
                  ),
                if (recent.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const SectionLabel('Recent sessions'),
                  const SizedBox(height: 10),
                  ...recent.map(
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
                          Text(
                            s.technique ?? 'Study session',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          if (s.selfRating != null)
                            Text('${s.selfRating}/5', style: const TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
