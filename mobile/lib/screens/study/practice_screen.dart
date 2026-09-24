import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/session_draft.dart';
import '../../models/study_method.dart';
import '../../services/quiz_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/tag_pill.dart';
import '../../widgets/section_label.dart';
import 'quiz_screen.dart';
import 'ready_to_save_screen.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key, required this.draft});

  final SessionDraft draft;

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  final _attemptedController = TextEditingController();
  final _correctController = TextEditingController();
  bool _gotAllPages = true;
  late int _pagesCovered = widget.draft.pagesTotal ?? 0;
  bool _isGenerating = false;

  @override
  void dispose() {
    _attemptedController.dispose();
    _correctController.dispose();
    super.dispose();
  }

  double? get _accuracy {
    final attempted = int.tryParse(_attemptedController.text);
    final correct = int.tryParse(_correctController.text);
    if (attempted == null || attempted == 0 || correct == null) return null;
    return correct / attempted * 100;
  }

  bool get _hasKnownPageCount => widget.draft.pagesTotal != null;

  void _applyOutcomeToDraft() {
    widget.draft.problemsAttempted = int.tryParse(_attemptedController.text);
    widget.draft.problemsCorrect = int.tryParse(_correctController.text);
    if (_hasKnownPageCount) {
      widget.draft.pagesCovered = _gotAllPages ? widget.draft.pagesTotal : _pagesCovered;
    }
  }

  void _skipToReadyToSave() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ReadyToSaveScreen(draft: widget.draft)),
    );
  }

  void _saveSession() {
    _applyOutcomeToDraft();
    _skipToReadyToSave();
  }

  int get _quizQuestionCount {
    if (!_hasKnownPageCount) return 8;
    final total = widget.draft.pagesTotal!;
    final covered = _gotAllPages ? total : _pagesCovered;
    return (covered / total * 8).round().clamp(3, 15);
  }

  Future<void> _generateQuiz() async {
    _applyOutcomeToDraft();
    setState(() => _isGenerating = true);
    try {
      final quizService = context.read<QuizService>();
      final result = await quizService.generate(
        topic: widget.draft.course.name,
        sourceMaterial: widget.draft.extractedText,
        courseId: widget.draft.course.id,
        numQuestions: _quizQuestionCount,
      );
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => QuizScreen(draft: widget.draft, quiz: result.quiz, questions: result.questions),
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not generate a quiz right now. You can still save your session.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;

    return Scaffold(
      appBar: AppBar(
        title: Text(draft.course.name),
        actions: [
          TextButton(onPressed: _skipToReadyToSave, child: const Text('SKIP')),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            if (draft.methods.isNotEmpty)
              Wrap(
                spacing: 8,
                children: draft.methods.map((m) => TagPill(label: studyMethodLabel(m))).toList(),
              ),
            const SizedBox(height: 12),
            Text('Almost Done', style: AppFonts.heading(fontSize: 22)),
            const Text('A quick self-check on how the problems went', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionLabel('Outcome score'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _NumberField(
                          label: 'Problems attempted',
                          controller: _attemptedController,
                          onChanged: () => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _NumberField(
                          label: 'Correct',
                          controller: _correctController,
                          onChanged: () => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(_accuracy != null ? '${_accuracy!.round()}%' : '—', style: AppFonts.heading(fontSize: 32)),
                ],
              ),
            ),
            if (draft.hasSlides) ...[
              if (_hasKnownPageCount) ...[
                const SizedBox(height: 24),
                const SectionLabel('How far did you get in your slides?'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _ChoiceCard(
                        title: 'All of it',
                        subtitle: 'All ${draft.pagesTotal} pages',
                        isSelected: _gotAllPages,
                        onTap: () => setState(() => _gotAllPages = true),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ChoiceCard(
                        title: 'Stopped early',
                        subtitle: "I didn't finish",
                        isSelected: !_gotAllPages,
                        onTap: () => setState(() => _gotAllPages = false),
                      ),
                    ),
                  ],
                ),
                if (!_gotAllPages) ...[
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _pagesCovered > 1 ? () => setState(() => _pagesCovered -= 1) : null,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            Text('$_pagesCovered', style: AppFonts.heading(fontSize: 28)),
                            Text('of ${draft.pagesTotal} pages', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _pagesCovered < (draft.pagesTotal ?? 1)
                            ? () => setState(() => _pagesCovered += 1)
                            : null,
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ],
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isGenerating ? null : _generateQuiz,
                child: _isGenerating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text('Generate quiz · $_quizQuestionCount questions →'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(onPressed: _skipToReadyToSave, child: const Text('Skip quiz — save session')),
            ] else ...[
              const SizedBox(height: 28),
              ElevatedButton(onPressed: _saveSession, child: const Text('Save Session')),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back to Edit'),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({required this.label, required this.controller, required this.onChanged});
  final String label;
  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          onChanged: (_) => onChanged(),
          decoration: const InputDecoration(hintText: '0'),
        ),
      ],
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.18) : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.surfaceBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
