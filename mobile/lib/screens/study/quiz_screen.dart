import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/quiz.dart';
import '../../models/session_draft.dart';
import '../../services/quiz_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.draft, required this.quiz, required this.questions});

  final SessionDraft draft;
  final Quiz quiz;
  final List<QuizQuestion> questions;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _index = 0;
  final Map<String, String> _answers = {}; // questionId -> option key
  bool _isSubmitting = false;

  QuizQuestion get _current => widget.questions[_index];
  bool get _isLast => _index == widget.questions.length - 1;

  void _selectOption(String optionKey) {
    setState(() => _answers[_current.id] = optionKey);
  }

  void _next() {
    if (_isLast) {
      _submit();
    } else {
      setState(() => _index += 1);
    }
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    final quizService = context.read<QuizService>();
    try {
      final attemptId = await quizService.startAttempt(widget.quiz.id);
      final answers = widget.questions
          .map((q) => {'questionId': q.id, 'selectedOption': _answers[q.id] ?? ''})
          .toList();
      final result = await quizService.submitAttempt(attemptId, answers);

      widget.draft.quiz = widget.quiz;
      widget.draft.quizScore = result['attempt']['score'] as num?;

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => QuizResultScreen(
            draft: widget.draft,
            quizTitle: widget.quiz.title,
            score: widget.draft.quizScore,
            results: List<Map<String, dynamic>>.from(result['results'] as List),
            questions: widget.questions,
          ),
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not submit the quiz. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = _current;
    final selected = _answers[question.id];

    return Scaffold(
      appBar: AppBar(title: Text(widget.quiz.title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(
                value: (_index + 1) / widget.questions.length,
                backgroundColor: AppColors.surface,
                color: AppColors.primary,
              ),
              const SizedBox(height: 8),
              Text(
                'Question ${_index + 1} of ${widget.questions.length}',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 16),
              Text(question.questionText, style: AppFonts.heading(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: question.options.entries.map((entry) {
                    final isSelected = selected == entry.key;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _selectOption(entry.key),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary.withOpacity(0.2) : AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: isSelected ? AppColors.primary : AppColors.surfaceBorder),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: isSelected ? AppColors.primary : AppColors.background,
                                child: Text(
                                  entry.key,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isSelected ? Colors.white : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text('${entry.value}')),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              ElevatedButton(
                onPressed: (selected == null || _isSubmitting) ? null : _next,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(_isLast ? 'Submit' : 'Next'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
