// lib/screens/timer_screen.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Study Timer',
                      style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w800)),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined,
                        color: AppTheme.textSecondary),
                    onPressed: () => _showSettings(context, provider),
                  ),
                ],
              ),
            ),

            // ─── Session Type Tabs ───────────────────────────
            FadeInDown(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: _SessionTypeTabs(state: provider.timerState),
              ),
            ),

            // ─── Timer Circle ────────────────────────────────
            Expanded(
              child: Center(
                child: FadeIn(
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: provider.isTimerRunning
                            ? _pulseAnimation.value
                            : 1.0,
                        child: _TimerCircle(provider: provider),
                      );
                    },
                  ),
                ),
              ),
            ),

            // ─── Subject Selector ────────────────────────────
            FadeInUp(
              delay: const Duration(milliseconds: 100),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _SubjectSelector(provider: provider),
              ),
            ),

            const SizedBox(height: 24),

            // ─── Controls ───────────────────────────────────
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _TimerControls(provider: provider),
              ),
            ),

            // ─── Session Stats ───────────────────────────────
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: _SessionStats(provider: provider),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettings(BuildContext context, AppProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (_) => _PomodoroSettingsSheet(provider: provider),
    );
  }
}

// ─── Session Type Tabs ────────────────────────────────────────
class _SessionTypeTabs extends StatelessWidget {
  final TimerState state;
  const _SessionTypeTabs({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _Tab(label: 'Focus', isActive: state == TimerState.studying || state == TimerState.idle),
          _Tab(label: 'Short Break', isActive: state == TimerState.shortBreak),
          _Tab(label: 'Long Break', isActive: state == TimerState.longBreak),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool isActive;
  const _Tab({required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? AppTheme.primary : AppTheme.textSecondary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Timer Circle ─────────────────────────────────────────────
class _TimerCircle extends StatelessWidget {
  final AppProvider provider;
  const _TimerCircle({required this.provider});

  @override
  Widget build(BuildContext context) {
    final totalSeconds = _getTotalSeconds(provider);
    final progress =
        totalSeconds > 0 ? provider.secondsRemaining / totalSeconds : 0.0;
    final minutes = provider.secondsRemaining ~/ 60;
    final seconds = provider.secondsRemaining % 60;

    final color = provider.timerState == TimerState.studying || provider.timerState == TimerState.idle
        ? AppTheme.accent
        : provider.timerState == TimerState.shortBreak
            ? AppTheme.accentPurple
            : AppTheme.accentYellow;

    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.cardBg,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.15),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
          // Progress arc
          CustomPaint(
            size: const Size(260, 260),
            painter: _ArcPainter(progress: progress, color: color),
          ),
          // Time display
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: color,
                  fontSize: 52,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -2,
                ),
              ),
              Text(
                _getStateLabel(provider.timerState),
                style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _getTotalSeconds(AppProvider p) {
    switch (p.timerState) {
      case TimerState.studying:
      case TimerState.idle:
        return p.pomodoroSettings.studyMinutes * 60;
      case TimerState.shortBreak:
        return p.pomodoroSettings.shortBreakMinutes * 60;
      case TimerState.longBreak:
        return p.pomodoroSettings.longBreakMinutes * 60;
    }
  }

  String _getStateLabel(TimerState s) {
    switch (s) {
      case TimerState.idle: return 'Ready to focus';
      case TimerState.studying: return 'Stay focused!';
      case TimerState.shortBreak: return 'Short break';
      case TimerState.longBreak: return 'Long break';
    }
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  final Color color;
  const _ArcPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Background track
    final bgPaint = Paint()
      ..color = AppTheme.surfaceLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final shadowPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      shadowPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.progress != progress || old.color != color;
}

// ─── Subject Selector ─────────────────────────────────────────
class _SubjectSelector extends StatelessWidget {
  final AppProvider provider;
  const _SubjectSelector({required this.provider});

  static const subjects = [
    'General', 'Math', 'Science', 'History',
    'Language', 'Programming', 'Art', 'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Subject',
            style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: subjects.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final s = subjects[i];
              final isSelected = provider.currentTimerSubject == s;
              return GestureDetector(
                onTap: () => provider.currentTimerSubject = s,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.accent
                        : AppTheme.cardBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(s,
                      style: TextStyle(
                          color: isSelected
                              ? AppTheme.primary
                              : AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Timer Controls ───────────────────────────────────────────
class _TimerControls extends StatelessWidget {
  final AppProvider provider;
  const _TimerControls({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Reset button
        _CircleButton(
          icon: Icons.refresh_rounded,
          onTap: provider.resetTimer,
          color: AppTheme.textSecondary,
          size: 52,
        ),
        const SizedBox(width: 20),
        // Main play/pause button
        GestureDetector(
          onTap: provider.isTimerRunning
              ? provider.pauseTimer
              : provider.startTimer,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppTheme.accentGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accent.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              provider.isTimerRunning
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              color: AppTheme.primary,
              size: 40,
            ),
          ),
        ),
        const SizedBox(width: 20),
        // Skip button
        _CircleButton(
          icon: Icons.skip_next_rounded,
          onTap: provider.skipToBreak,
          color: AppTheme.textSecondary,
          size: 52,
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final double size;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AppTheme.cardBg,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: size * 0.45),
      ),
    );
  }
}

// ─── Session Stats ────────────────────────────────────────────
class _SessionStats extends StatelessWidget {
  final AppProvider provider;
  const _SessionStats({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Stat(
              label: 'Today',
              value: '${provider.completedPomodoros}',
              icon: '🍅'),
          Container(width: 1, height: 32, color: AppTheme.divider),
          _Stat(
              label: 'Total',
              value: '${provider.profile.totalPomodoros}',
              icon: '📊'),
          Container(width: 1, height: 32, color: AppTheme.divider),
          _Stat(
              label: 'Streak',
              value: '${provider.profile.currentStreak}🔥',
              icon: '⚡'),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final String icon;
  const _Stat({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 18)),
        Text(label,
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 11)),
      ],
    );
  }
}

// ─── Settings Sheet ───────────────────────────────────────────
class _PomodoroSettingsSheet extends StatefulWidget {
  final AppProvider provider;
  const _PomodoroSettingsSheet({required this.provider});

  @override
  State<_PomodoroSettingsSheet> createState() =>
      _PomodoroSettingsSheetState();
}

class _PomodoroSettingsSheetState extends State<_PomodoroSettingsSheet> {
  late int studyMins;
  late int shortBreakMins;
  late int longBreakMins;
  late bool autoBreaks;
  late bool autoPomodoros;

  @override
  void initState() {
    super.initState();
    final s = widget.provider.pomodoroSettings;
    studyMins = s.studyMinutes;
    shortBreakMins = s.shortBreakMinutes;
    longBreakMins = s.longBreakMinutes;
    autoBreaks = s.autoStartBreaks;
    autoPomodoros = s.autoStartPomodoros;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Timer Settings',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          _DurationSetting(
              label: '🍅 Focus Duration',
              value: studyMins,
              min: 5, max: 60,
              onChanged: (v) => setState(() => studyMins = v)),
          _DurationSetting(
              label: '☕ Short Break',
              value: shortBreakMins,
              min: 1, max: 30,
              onChanged: (v) => setState(() => shortBreakMins = v)),
          _DurationSetting(
              label: '🛋️ Long Break',
              value: longBreakMins,
              min: 5, max: 60,
              onChanged: (v) => setState(() => longBreakMins = v)),
          const SizedBox(height: 12),
          _SwitchSetting(
              label: 'Auto-start Breaks',
              value: autoBreaks,
              onChanged: (v) => setState(() => autoBreaks = v)),
          _SwitchSetting(
              label: 'Auto-start Pomodoros',
              value: autoPomodoros,
              onChanged: (v) => setState(() => autoPomodoros = v)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.provider.updatePomodoroSettings(PomodoroSettings(
                  studyMinutes: studyMins,
                  shortBreakMinutes: shortBreakMins,
                  longBreakMinutes: longBreakMins,
                  autoStartBreaks: autoBreaks,
                  autoStartPomodoros: autoPomodoros,
                ));
                Navigator.pop(context);
              },
              child: const Text('Save Settings'),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}

class _DurationSetting extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _DurationSetting({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textPrimary, fontWeight: FontWeight.w500)),
          Row(
            children: [
              _AdjustButton(
                  icon: Icons.remove,
                  onTap: value > min ? () => onChanged(value - 1) : null),
              Container(
                width: 52,
                alignment: Alignment.center,
                child: Text('${value}m',
                    style: const TextStyle(
                        color: AppTheme.accent,
                        fontWeight: FontWeight.w700,
                        fontSize: 16)),
              ),
              _AdjustButton(
                  icon: Icons.add,
                  onTap: value < max ? () => onChanged(value + 1) : null),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdjustButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _AdjustButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: onTap != null ? AppTheme.surfaceLight : AppTheme.cardBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon,
            color: onTap != null
                ? AppTheme.textPrimary
                : AppTheme.textSecondary,
            size: 18),
      ),
    );
  }
}

class _SwitchSetting extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchSetting({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppTheme.textPrimary, fontWeight: FontWeight.w500)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppTheme.accent,
        ),
      ],
    );
  }
}