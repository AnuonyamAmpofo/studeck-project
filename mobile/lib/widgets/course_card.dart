import 'package:flutter/material.dart';
import '../models/course.dart';
import '../theme/app_colors.dart';
import 'tag_pill.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({
    super.key,
    required this.course,
    this.subtitle,
    this.onTap,
    this.trailing,
  });

  final Course course;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: course.colorValue.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(course.emoji ?? '📘', style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.name,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (course.code != null) TagPill(label: course.code!, color: AppColors.tagViolet),
                      if (course.code != null) const SizedBox(width: 6),
                      TagPill(label: course.courseType ?? 'Concept', color: AppColors.tagGreen),
                    ],
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(subtitle!, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ],
                ],
              ),
            ),
            trailing ?? const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
