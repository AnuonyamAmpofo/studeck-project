import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/course_catalog.dart';
import '../../models/course.dart';
import '../../services/course_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/section_label.dart';
import '../shell/app_shell.dart';
import 'confirm_course_details_screen.dart';

class AddCoursesScreen extends StatefulWidget {
  const AddCoursesScreen({super.key});

  @override
  State<AddCoursesScreen> createState() => _AddCoursesScreenState();
}

class _AddCoursesScreenState extends State<AddCoursesScreen> {
  final _searchController = TextEditingController();
  final List<Course> _added = [];
  bool _isSaving = false;

  List<String> get _matches {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return const [];
    return kCourseCatalog.where((c) => c.toLowerCase().contains(query)).toList();
  }

  Future<void> _openConfirmDetails(String name) async {
    final draft = await Navigator.of(context).push<Course>(
      MaterialPageRoute(builder: (_) => ConfirmCourseDetailsScreen(initialName: name)),
    );
    if (draft != null) {
      setState(() {
        _added.add(draft);
        _searchController.clear();
      });
    }
  }

  Future<void> _proceed() async {
    setState(() => _isSaving = true);
    final courseService = context.read<CourseService>();
    try {
      for (final draft in _added) {
        await courseService.create(draft);
      }
      if (!mounted) return;
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true);
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AppShell()),
          (route) => false,
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save courses. Check your connection and try again.')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Courses', style: AppFonts.heading(fontSize: 24)),
              const SizedBox(height: 4),
              const Text('Search to add more courses', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 18),
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                onSubmitted: _openConfirmDetails,
                decoration: const InputDecoration(hintText: 'e.g. Data Structures'),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView(
                  children: [
                    if (_matches.isNotEmpty) ...[
                      const SectionLabel('Tap a course to confirm'),
                      const SizedBox(height: 10),
                      ..._matches.map(
                        (name) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => _openConfirmDetails(name),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.surfaceBorder),
                              ),
                              child: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ),
                      ),
                    ] else if (_searchController.text.trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => _openConfirmDetails(_searchController.text.trim()),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.surfaceBorder, style: BorderStyle.solid),
                            ),
                            child: Text('Add "${_searchController.text.trim()}" as a new course'),
                          ),
                        ),
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Center(
                          child: Text(
                            'Start typing to search\nover 500 university courses',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        ),
                      ),
                    if (_added.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const SectionLabel('Added courses'),
                      const SizedBox(height: 10),
                      ..._added.map(
                        (c) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.surfaceBorder),
                            ),
                            child: Row(
                              children: [
                                Text(c.emoji ?? '📘', style: const TextStyle(fontSize: 18)),
                                const SizedBox(width: 10),
                                Expanded(child: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: (_added.isEmpty || _isSaving) ? null : _proceed,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Proceed to Dashboard'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
