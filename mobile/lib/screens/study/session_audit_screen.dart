import 'package:flutter/material.dart';
import '../../models/session_draft.dart';
import '../../models/study_method.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import 'practice_screen.dart';

const _kRatingLabels = {1: 'Confused', 5: "Could teach it"};
const _kEnvironments = ['Library', 'Home', 'Dorm', 'Cafe', 'Other'];

class SessionAuditScreen extends StatefulWidget {
  const SessionAuditScreen({super.key, required this.draft});

  final SessionDraft draft;

  @override
  State<SessionAuditScreen> createState() => _SessionAuditScreenState();
}

class _SessionAuditScreenState extends State<SessionAuditScreen> {
  final Set<String> _methods = {};
  int? _rating;
  String? _environment;

  void _toggleMethod(String value) {
    setState(() {
      if (_methods.contains(value)) {
        _methods.remove(value);
      } else {
        _methods.add(value);
      }
    });
  }

  void _next() {
    if (_rating == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rate how well you understood it first')),
      );
      return;
    }
    widget.draft.methods = _methods;
    widget.draft.understandingRating = _rating;
    widget.draft.environment = _environment;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PracticeScreen(draft: widget.draft)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Row(
                children: [
                  Text(draft.course.emoji ?? '📘', style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(draft.course.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                  Text(
                    '${draft.minutes}min · ${draft.cyclesCompleted} cycles',
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('How did it go?', style: AppFonts.heading(fontSize: 20)),
            const SizedBox(height: 4),
            const Text(
              'Select all methods used then rate yourself',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.05,
              children: kStudyMethods.map((method) {
                final isSelected = _methods.contains(method.value);
                return InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => _toggleMethod(method.value),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withOpacity(0.22) : AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isSelected ? AppColors.primary : AppColors.surfaceBorder),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(method.icon, color: isSelected ? AppColors.primary : AppColors.textSecondary),
                        const SizedBox(height: 6),
                        Text(
                          method.label,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text('How well did you understand it?', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (i) {
                final value = i + 1;
                final isSelected = _rating == value;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => setState(() => _rating = value),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: isSelected ? AppColors.primary : AppColors.surface,
                            child: Text(
                              '$value',
                              style: TextStyle(
                                color: isSelected ? Colors.white : AppColors.textSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          if (_kRatingLabels.containsKey(value))
                            Text(
                              _kRatingLabels[value]!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            const Text('Where did you study?', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            const Text('Optional', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _kEnvironments.map((env) {
                final isSelected = _environment == env;
                return InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () => setState(() => _environment = isSelected ? null : env),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withOpacity(0.22) : AppColors.surface,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: isSelected ? AppColors.primary : AppColors.surfaceBorder),
                    ),
                    child: Text(
                      env,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            ElevatedButton(onPressed: _next, child: const Text('Next →')),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
