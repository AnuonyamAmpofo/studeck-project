import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Small caps section headers like "INSIGHTS", "RECENT SESSIONS", "COURSE TYPE".
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppFonts.label(fontSize: 11, color: AppColors.textMuted, letterSpacing: 0.8),
    );
  }
}
