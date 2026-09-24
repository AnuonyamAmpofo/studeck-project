import 'package:flutter/material.dart';
import '../services/course_insights.dart';
import '../theme/app_colors.dart';

class PerformanceBarRow extends StatelessWidget {
  const PerformanceBarRow({super.key, required this.bar, this.color = AppColors.primary});

  final PerformanceBar bar;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(width: 72, child: Text(bar.label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: (bar.percent / 100).clamp(0, 1),
                minHeight: 8,
                backgroundColor: AppColors.surface,
                color: color,
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              '${bar.percent.round()}%',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
