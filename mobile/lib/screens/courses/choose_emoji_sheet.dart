import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

const _kEmojiOptions = [
  '📐', '✏️', '🧪', '🧬', '⚛️', '📊',
  '💻', '🖥️', '🔢', '📈', '🧠', '📚',
  '🔬', '🌡️', '⚡', '🧮', '🗂️', '🎯',
];

/// Returns the picked emoji, or null if the user cancelled.
Future<String?> showChooseEmojiSheet(BuildContext context, {String? initial}) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => _ChooseEmojiSheet(initial: initial),
  );
}

class _ChooseEmojiSheet extends StatefulWidget {
  const _ChooseEmojiSheet({this.initial});
  final String? initial;

  @override
  State<_ChooseEmojiSheet> createState() => _ChooseEmojiSheetState();
}

class _ChooseEmojiSheetState extends State<_ChooseEmojiSheet> {
  late String? _selected = widget.initial;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Choose an Emoji', style: AppFonts.heading(fontSize: 18)),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: AppColors.textMuted),
              ),
            ],
          ),
          const Text('Tap a Category to Browse', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 6,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: _kEmojiOptions.map((emoji) {
              final isSelected = emoji == _selected;
              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => setState(() => _selected = emoji),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withOpacity(0.25) : AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? AppColors.primary : AppColors.surfaceBorder),
                  ),
                  child: Text(emoji, style: const TextStyle(fontSize: 20)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _selected == null ? null : () => Navigator.of(context).pop(_selected),
            child: Text(_selected == null ? 'Confirm' : 'Confirm - $_selected selected'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
