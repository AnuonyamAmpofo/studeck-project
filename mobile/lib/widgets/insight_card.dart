import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'glass_panel.dart';

enum InsightTone { positive, warning }

/// The frosted-glass "Morning sessions work best" / "Struggle Pattern Detected!!!" cards.
class InsightCard extends StatelessWidget {
  const InsightCard({super.key, required this.title, required this.body, required this.tone});

  final String title;
  final String body;
  final InsightTone tone;

  @override
  Widget build(BuildContext context) {
    final tint = tone == InsightTone.positive ? AppColors.successSurface : AppColors.warningSurface;

    return SizedBox(
      width: double.infinity,
      child: GlassPanel(
        borderRadius: 14,
        tintColor: tint,
        tintOpacity: 0.3,
        borderColor: tint.withOpacity(0.55),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 6),
            Text(body, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4)),
          ],
        ),
      ),
    );
  }
}
