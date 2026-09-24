import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../../models/course.dart';
import '../../theme/app_colors.dart';
import '../../widgets/section_label.dart';
import 'timer_screen.dart';

const _kAllowedExtensions = ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'txt'];

class StudyTechnique {
  const StudyTechnique(this.name, this.focusMinutes, this.breakMinutes, this.icon);
  final String name;
  final int focusMinutes;
  final int breakMinutes;
  final IconData icon;

  String get label => breakMinutes > 0
      ? '${focusMinutes}min focus · ${breakMinutes}min break'
      : '$focusMinutes min';
}

const _kTechniques = [
  StudyTechnique('Pomodoro', 25, 5, Icons.local_fire_department_rounded),
  StudyTechnique('Deep work', 90, 0, Icons.psychology_alt_rounded),
  StudyTechnique('Ultradian sprint', 50, 10, Icons.bolt_rounded),
  StudyTechnique('Quick review', 15, 0, Icons.flash_on_rounded),
];

class SessionSetupScreen extends StatefulWidget {
  const SessionSetupScreen({super.key, required this.course});

  final Course course;

  @override
  State<SessionSetupScreen> createState() => _SessionSetupScreenState();
}

class _SessionSetupScreenState extends State<SessionSetupScreen> {
  StudyTechnique _selected = _kTechniques.first;
  bool _focusMode = true;
  String? _uploadedFileName;
  int? _pagesTotal;
  String? _extractedText;
  bool _isPickingFile = false;

  Future<void> _chooseFile() async {
    setState(() => _isPickingFile = true);
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: _kAllowedExtensions,
      );
      if (result.isEmpty || result.first.path == null) return;
      final picked = result.first;

      final path = picked.path!;
      final extension = picked.extension?.toLowerCase();
      int? pagesTotal;
      String? extractedText;

      // PDFs: read the real page count. Plain text: read it directly as quiz
      // source material. Word/PowerPoint files are accepted but not parsed —
      // that would need a dedicated docx/pptx text-extraction library.
      if (extension == 'pdf') {
        try {
          final document = PdfDocument(inputBytes: await File(path).readAsBytes());
          pagesTotal = document.pages.count;
          document.dispose();
        } catch (_) {
          // Corrupt or unreadable PDF — still accept the upload, just without a page count.
        }
      } else if (extension == 'txt') {
        extractedText = await File(path).readAsString();
      }

      setState(() {
        _uploadedFileName = picked.name;
        _pagesTotal = pagesTotal;
        _extractedText = extractedText;
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't open that file. Try a different one.")),
        );
      }
    } finally {
      if (mounted) setState(() => _isPickingFile = false);
    }
  }

  void _clearFile() {
    setState(() {
      _uploadedFileName = null;
      _pagesTotal = null;
      _extractedText = null;
    });
  }

  void _begin() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TimerScreen(
          course: widget.course,
          technique: _selected,
          focusModeOn: _focusMode,
          uploadedFileName: _uploadedFileName,
          pagesTotal: _pagesTotal,
          extractedText: _extractedText,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.course.name)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          children: [
            const Text('How long will you study?', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            ..._kTechniques.map((t) {
              final isSelected = t.name == _selected.name;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => setState(() => _selected = t),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isSelected ? AppColors.primary : AppColors.surfaceBorder),
                    ),
                    child: Row(
                      children: [
                        Icon(t.icon, color: AppColors.primary, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                              Text(t.label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                        if (isSelected) const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Focus Mode', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text(
                  'Turns on Do Not Disturb for your session',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                value: _focusMode,
                activeColor: AppColors.primary,
                onChanged: (v) => setState(() => _focusMode = v),
              ),
            ),
            const SizedBox(height: 24),
            const SectionLabel('Upload your slides'),
            const SizedBox(height: 4),
            const Text(
              "Optional — we'll generate a quiz at the end based on the pages you studied",
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 10),
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _isPickingFile ? null : _chooseFile,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _uploadedFileName != null ? AppColors.success : AppColors.surfaceBorder,
                  ),
                ),
                child: _isPickingFile
                    ? const Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : _uploadedFileName == null
                        ? const Column(
                            children: [
                              Icon(Icons.upload_file_rounded, color: AppColors.primary, size: 28),
                              SizedBox(height: 8),
                              Text('Choose your lecture material', style: TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          )
                        : Row(
                            children: [
                              const Icon(Icons.description_rounded, color: AppColors.success),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _pagesTotal != null ? '$_uploadedFileName · $_pagesTotal pages' : _uploadedFileName!,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                onPressed: _clearFile,
                                icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textMuted),
                              ),
                            ],
                          ),
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton(onPressed: _begin, child: const Text('Begin Session')),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
