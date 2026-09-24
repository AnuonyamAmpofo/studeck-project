import 'package:flutter/material.dart';
import '../../models/quiz.dart';
import '../../models/session_draft.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import 'ready_to_save_screen.dart';

class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({
    super.key,
    required this.draft,
    required this.quizTitle,
    required this.score,
    required this.results,
    required this.questions,
  });

  final SessionDraft draft;
  final String quizTitle;
  final num? score;
  final List<Map<String, dynamic>> results;
  final List<QuizQuestion> questions;

  @override
  Widget build(BuildContext context) {
    final questionById = {for (final q in questions) q.id: q};

    return Scaffold(
      appBar: AppBar(title: Text(quizTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            Center(
              child: Column(
                children: [
                  Text(score != null ? '${score!.round()}%' : '—', style: AppFonts.heading(fontSize: 40)),
                  const Text('Quiz score', style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ...results.map((r) {
              final question = questionById[r['questionId']];
              final isCorrect = r['isCorrect'] == true;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isCorrect ? AppColors.success : AppColors.danger),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isCorrect ? Icons.check_circle : Icons.cancel,
                          color: isCorrect ? AppColors.success : AppColors.danger,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            question?.questionText ?? '',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    if (!isCorrect)
                      Padding(
                        padding: const EdgeInsets.only(top: 6, left: 26),
                        child: Text(
                          'Correct answer: ${r['correctOption']}',
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                        ),
                      ),
                    if (r['explanation'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, left: 26),
                        child: Text(
                          r['explanation'] as String,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => ReadyToSaveScreen(draft: draft)),
              ),
              child: const Text('Continue'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
