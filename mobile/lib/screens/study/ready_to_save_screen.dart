import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/session_draft.dart';
import '../../models/study_method.dart';
import '../../services/study_session_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import 'progress_updated_screen.dart';

class ReadyToSaveScreen extends StatefulWidget {
  const ReadyToSaveScreen({super.key, required this.draft});

  final SessionDraft draft;

  @override
  State<ReadyToSaveScreen> createState() => _ReadyToSaveScreenState();
}

class _ReadyToSaveScreenState extends State<ReadyToSaveScreen> {
  bool _isSaving = false;

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final draft = widget.draft;
    try {
      await context.read<StudySessionService>().create(
            courseId: draft.course.id,
            startedAt: draft.startedAt,
            endedAt: draft.endedAt,
            plannedDurationSeconds: draft.plannedDurationSeconds,
            technique: draft.technique,
            selfRating: draft.understandingRating,
            methods: draft.methods.toList(),
            environment: draft.environment,
            focusModeOn: draft.focusModeOn,
            problemsAttempted: draft.problemsAttempted,
            problemsCorrect: draft.problemsCorrect,
            pagesTotal: draft.pagesTotal,
            pagesCovered: draft.pagesCovered,
          );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ProgressUpdatedScreen()),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save this session. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;
    final methodsLabel = draft.methods.isEmpty
        ? '—'
        : draft.methods.map(studyMethodLabel).join(' + ');

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ListView(
            children: [
              const SizedBox(height: 16),
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 32),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text('Ready to Save', style: AppFonts.heading(fontSize: 20)),
              ),
              const Center(
                child: Text(
                  'Everything has been captured.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Column(
                  children: [
                    const Text(
                      'SESSION SUMMARY',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.6),
                    ),
                    const SizedBox(height: 14),
                    _SummaryRow(label: 'Course', value: draft.course.name),
                    _SummaryRow(label: 'Methods', value: methodsLabel),
                    if (draft.environment != null) _SummaryRow(label: 'Environment', value: draft.environment!),
                    _SummaryRow(label: 'Duration', value: '${draft.minutes} min · ${draft.cyclesCompleted} cycles'),
                    _SummaryRow(
                      label: 'Rating',
                      value: draft.understandingRating != null ? '${draft.understandingRating}/5' : '—',
                    ),
                    if (draft.practiceAccuracy != null)
                      _SummaryRow(label: 'Practice score', value: '${draft.practiceAccuracy!.round()}%'),
                    if (draft.quizScore != null)
                      _SummaryRow(label: 'Quiz score', value: '${draft.quizScore!.round()}%'),
                    _SummaryRow(label: 'Focus mode', value: draft.focusModeOn ? 'On' : 'Off', isLast: true),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Save Session'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back to Edit'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value, this.isLast = false});
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
