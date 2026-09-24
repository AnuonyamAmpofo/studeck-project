import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/course.dart';
import '../../services/course_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/course_card.dart';
import 'add_courses_screen.dart';
import 'course_detail_screen.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  late Future<List<Course>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<CourseService>().list();
  }

  void _refresh() => setState(() => _future = context.read<CourseService>().list());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Courses')),
      body: SafeArea(
        child: FutureBuilder<List<Course>>(
          future: _future,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final courses = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${courses.length} course${courses.length == 1 ? '' : 's'}',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: courses.isEmpty
                        ? const Center(
                            child: Text('No courses yet', style: TextStyle(color: AppColors.textMuted)),
                          )
                        : ListView.separated(
                            itemCount: courses.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, i) => CourseCard(
                              course: courses[i],
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => CourseDetailScreen(course: courses[i])),
                              ),
                            ),
                          ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AddCoursesScreen()),
                      );
                      _refresh();
                    },
                    child: const Text('Add another course'),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
