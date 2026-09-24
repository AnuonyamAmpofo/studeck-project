import 'package:flutter/material.dart';
import '../../models/course.dart';
import '../../theme/app_colors.dart';
import '../../widgets/section_label.dart';
import 'choose_emoji_sheet.dart';

const _kCourseTypes = [
  {'value': 'calculation', 'title': 'Calculation', 'subtitle': 'Problem solving and equations'},
  {'value': 'concept', 'title': 'Concept', 'subtitle': 'Theory, proofs & understanding'},
  {'value': 'skill', 'title': 'Skill', 'subtitle': 'Practice and application'},
  {'value': 'mixed', 'title': 'Mixed', 'subtitle': 'Combination of all types'},
];

/// Pops with the created [Course] draft (not yet persisted — the caller,
/// AddCoursesScreen, owns the actual API call so it can batch "Proceed to
/// Dashboard" after multiple courses are added).
class ConfirmCourseDetailsScreen extends StatefulWidget {
  const ConfirmCourseDetailsScreen({super.key, required this.initialName});

  final String initialName;

  @override
  State<ConfirmCourseDetailsScreen> createState() => _ConfirmCourseDetailsScreenState();
}

class _ConfirmCourseDetailsScreenState extends State<ConfirmCourseDetailsScreen> {
  late final _titleController = TextEditingController(text: widget.initialName);
  final _codeController = TextEditingController();
  String _emoji = '📐';
  String _courseType = 'concept';

  @override
  void dispose() {
    _titleController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _pickEmoji() async {
    final picked = await showChooseEmojiSheet(context, initial: _emoji);
    if (picked != null) setState(() => _emoji = picked);
  }

  void _submit() {
    if (_titleController.text.trim().isEmpty) return;
    Navigator.of(context).pop(
      Course(
        id: '',
        name: _titleController.text.trim(),
        code: _codeController.text.trim().isEmpty ? null : _codeController.text.trim(),
        emoji: _emoji,
        courseType: _courseType,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Details')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickEmoji,
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.surfaceBorder),
                        ),
                        child: Text(_emoji, style: const TextStyle(fontSize: 28)),
                      ),
                      const SizedBox(height: 6),
                      const Text('Tap to Change Course Emoji', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const SectionLabel('Course title'),
              const SizedBox(height: 8),
              TextField(controller: _titleController),
              const SizedBox(height: 18),
              const SectionLabel('Course code - optional'),
              const SizedBox(height: 8),
              TextField(controller: _codeController, decoration: const InputDecoration(hintText: 'MATH 223')),
              const SizedBox(height: 18),
              const SectionLabel('Course type'),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.6,
                children: _kCourseTypes.map((type) {
                  final isSelected = type['value'] == _courseType;
                  return InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => setState(() => _courseType = type['value']!),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: isSelected ? AppColors.primary : AppColors.surfaceBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(type['title']!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                              if (isSelected)
                                const Icon(Icons.check_circle, color: AppColors.success, size: 16),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            type['subtitle']!,
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),
              ElevatedButton(onPressed: _submit, child: const Text('Add Course')),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
