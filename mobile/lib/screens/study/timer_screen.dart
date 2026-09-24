import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/course.dart';
import '../../models/session_draft.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import 'session_audit_screen.dart';
import 'session_setup_screen.dart';

enum _Phase { focus, breakTime, paused }

class TimerScreen extends StatefulWidget {
  const TimerScreen({
    super.key,
    required this.course,
    required this.technique,
    required this.focusModeOn,
    this.uploadedFileName,
    this.pagesTotal,
    this.extractedText,
  });

  final Course course;
  final StudyTechnique technique;
  final bool focusModeOn;
  final String? uploadedFileName;
  final int? pagesTotal;
  final String? extractedText;

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  late _Phase _phase = _Phase.focus;
  _Phase? _phaseBeforePause;
  late int _remainingSeconds = widget.technique.focusMinutes * 60;
  int _cyclesCompleted = 0;
  int _focusSecondsAccumulated = 0;
  Timer? _ticker;
  final _startedAt = DateTime.now();

  @override
  void initState() {
    super.initState();
    _startTicker();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (_remainingSeconds <= 1) {
      _onPhaseComplete();
      return;
    }
    setState(() {
      _remainingSeconds -= 1;
      if (_phase == _Phase.focus) _focusSecondsAccumulated += 1;
    });
  }

  void _onPhaseComplete() {
    if (_phase == _Phase.focus) {
      setState(() => _focusSecondsAccumulated += _remainingSeconds);
      if (widget.technique.breakMinutes > 0) {
        setState(() {
          _phase = _Phase.breakTime;
          _remainingSeconds = widget.technique.breakMinutes * 60;
        });
        return;
      }
      _completeCycle();
      return;
    }
    if (_phase == _Phase.breakTime) {
      _completeCycle();
    }
  }

  void _completeCycle() {
    setState(() {
      _cyclesCompleted += 1;
      _phase = _Phase.focus;
      _remainingSeconds = widget.technique.focusMinutes * 60;
    });
  }

  void _togglePause() {
    if (_phase == _Phase.paused) {
      setState(() => _phase = _phaseBeforePause ?? _Phase.focus);
      _startTicker();
    } else {
      _ticker?.cancel();
      setState(() {
        _phaseBeforePause = _phase;
        _phase = _Phase.paused;
      });
    }
  }

  void _skipBreak() => _completeCycle();

  void _end() {
    _ticker?.cancel();
    final draft = SessionDraft(
      course: widget.course,
      technique: widget.technique.name,
      startedAt: _startedAt,
      endedAt: DateTime.now(),
      plannedDurationSeconds: widget.technique.focusMinutes * 60,
      cyclesCompleted: _cyclesCompleted,
      focusSeconds: _focusSecondsAccumulated,
      focusModeOn: widget.focusModeOn,
      uploadedFileName: widget.uploadedFileName,
      pagesTotal: widget.pagesTotal,
      extractedText: widget.extractedText,
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => SessionAuditScreen(draft: draft)),
    );
  }

  String get _formattedTime {
    final m = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final isBreak = _phase == _Phase.breakTime;
    final isPaused = _phase == _Phase.paused;
    final background = isBreak ? const Color(0xFF12331F) : AppColors.background;
    final ringColor = isBreak ? AppColors.success : AppColors.primary;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(backgroundColor: Colors.transparent, title: Text(widget.course.name)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _PhasePill(
                    label: isPaused ? 'PAUSED' : (isBreak ? 'BREAK' : 'FOCUS'),
                    color: isBreak ? AppColors.success : AppColors.primary,
                  ),
                  _PhasePill(
                    label: '$_cyclesCompleted cycle${_cyclesCompleted == 1 ? '' : 's'}',
                    color: AppColors.textMuted,
                  ),
                ],
              ),
              const Spacer(),
              Container(
                width: 220,
                height: 220,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: ringColor.withOpacity(0.5), width: 3),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_formattedTime, style: AppFonts.heading(fontSize: 44)),
                    Text(
                      isPaused ? 'PAUSED' : (isBreak ? 'BREAK LEFT' : 'REMAINING'),
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted, letterSpacing: 1),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isPaused
                    ? "YOU'RE DOING WELL — keep it up!"
                    : (isBreak ? 'Good work! Rest up 🎉' : 'Stay focused, you\'ve got this'),
                style: const TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              if (isBreak) ...[
                OutlinedButton(onPressed: _skipBreak, child: const Text('Skip break → start next cycle')),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: _end,
                  child: const Text('End session here', style: TextStyle(color: AppColors.danger)),
                ),
              ] else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _togglePause,
                        child: Text(isPaused ? 'Resume' : 'Pause'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                        onPressed: _end,
                        child: const Text('End'),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhasePill extends StatelessWidget {
  const _PhasePill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.18), borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}
