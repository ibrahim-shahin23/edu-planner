// lib/screens/timer_screen.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import '../models/models.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.97, end: 1.03)
        .animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final phaseColor = _phaseColor(p.phase);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Study Timer',
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22, fontWeight: FontWeight.w800)),
                  IconButton(
                    icon: const Icon(Icons.tune_rounded, color: AppColors.textSecondary),
                    onPressed: () => _showSettings(context, p),
                  ),
                ],
              ),
            ),

            // ── Phase tabs ────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: _PhaseTabs(phase: p.phase),
            ),

            // ── Timer circle ──────────────────────────────
            Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (_, __) => Transform.scale(
                    scale: p.running ? _pulseAnim.value : 1.0,
                    child: _TimerDial(
                      secsLeft: p.secsLeft,
                      totalSecs: _totalSecs(p),
                      phase: p.phase,
                      color: phaseColor,
                    ),
                  ),
                ),
              ),
            ),

            // ── Subject picker ────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _SubjectRow(provider: p),
            ),
            const SizedBox(height: 20),

            // ── Controls ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _Controls(provider: p, color: phaseColor),
            ),

            // ── Bottom stats ──────────────────────────────
            Padding(
              padding: const EdgeInsets.all(20),
              child: _BottomStats(p: p),
            ),
          ],
        ),
      ),
    );
  }

  Color _phaseColor(TimerPhase ph) {
    switch (ph) {
      case TimerPhase.idle:
      case TimerPhase.study:       return AppColors.accent;
      case TimerPhase.shortBreak:  return AppColors.purple;
      case TimerPhase.longBreak:   return AppColors.yellow;
    }
  }

  int _totalSecs(AppProvider p) {
    switch (p.phase) {
      case TimerPhase.idle:
      case TimerPhase.study:      return p.settings.studyMins * 60;
      case TimerPhase.shortBreak: return p.settings.shortBreakMins * 60;
      case TimerPhase.longBreak:  return p.settings.longBreakMins * 60;
    }
  }

  void _showSettings(BuildContext context, AppProvider p) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _SettingsSheet(p: p),
    );
  }
}

// ── Phase Tabs ────────────────────────────────────────────────
class _PhaseTabs extends StatelessWidget {
  final TimerPhase phase;
  const _PhaseTabs({required this.phase});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: AppColors.card, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          _Tab('Focus', phase == TimerPhase.study || phase == TimerPhase.idle, AppColors.accent),
          _Tab('Short Break', phase == TimerPhase.shortBreak, AppColors.purple),
          _Tab('Long Break', phase == TimerPhase.longBreak, AppColors.yellow),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool active;
  final Color color;
  const _Tab(this.label, this.active, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
            color: active ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(10)),
        child: Center(
          child: Text(label,
              style: TextStyle(
                  color: active ? AppColors.bg : AppColors.textSecondary,
                  fontWeight: FontWeight.w700, fontSize: 12)),
        ),
      ),
    );
  }
}

// ── Timer Dial ────────────────────────────────────────────────
class _TimerDial extends StatelessWidget {
  final int secsLeft, totalSecs;
  final TimerPhase phase;
  final Color color;
  const _TimerDial({required this.secsLeft, required this.totalSecs,
                    required this.phase, required this.color});

  @override
  Widget build(BuildContext context) {
    final progress = totalSecs > 0 ? secsLeft / totalSecs : 0.0;
    final m = secsLeft ~/ 60;
    final s = secsLeft % 60;

    return SizedBox(
      width: 250, height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 250, height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.card,
              boxShadow: [
                BoxShadow(
                    color: color.withOpacity(0.12),
                    blurRadius: 40, spreadRadius: 8),
              ],
            ),
          ),
          CustomPaint(
            size: const Size(250, 250),
            painter: _ArcPainter(progress: progress, color: color),
          ),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
              '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}',
              style: TextStyle(
                  color: color, fontSize: 50,
                  fontWeight: FontWeight.w800, letterSpacing: -2),
            ),
            Text(
              _label(phase),
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13),
            ),
          ]),
        ],
      ),
    );
  }

  String _label(TimerPhase ph) {
    switch (ph) {
      case TimerPhase.idle:       return 'Ready to focus';
      case TimerPhase.study:      return 'Stay focused! 💪';
      case TimerPhase.shortBreak: return 'Short break ☕';
      case TimerPhase.longBreak:  return 'Long break 🛋️';
    }
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  final Color color;
  const _ArcPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 10;
    final bg = Paint()
      ..color = AppColors.cardLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(c, r, bg);

    if (progress > 0) {
      final glow = Paint()
        ..color = color.withOpacity(0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      final fg = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round;
      final rect = Rect.fromCircle(center: c, radius: r);
      final sweep = 2 * math.pi * progress.clamp(0.0, 1.0);
      canvas.drawArc(rect, -math.pi / 2, sweep, false, glow);
      canvas.drawArc(rect, -math.pi / 2, sweep, false, fg);
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.progress != progress || old.color != color;
}

// ── Subject Row ───────────────────────────────────────────────
class _SubjectRow extends StatelessWidget {
  final AppProvider provider;
  static const subjects = ['General','Math','Science','History','Language','Programming','Art','Other'];
  const _SubjectRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Subject',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12,
              fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      SizedBox(
        height: 34,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: subjects.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final s = subjects[i];
            final sel = provider.subject == s;
            return GestureDetector(
              onTap: () => provider.subject = s,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                    color: sel ? AppColors.accent : AppColors.card,
                    borderRadius: BorderRadius.circular(20)),
                child: Text(s,
                    style: TextStyle(
                        color: sel ? AppColors.bg : AppColors.textSecondary,
                        fontWeight: FontWeight.w600, fontSize: 12)),
              ),
            );
          },
        ),
      ),
    ]);
  }
}

// ── Controls ──────────────────────────────────────────────────
class _Controls extends StatelessWidget {
  final AppProvider provider;
  final Color color;
  const _Controls({required this.provider, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      _Btn(icon: Icons.refresh_rounded, size: 50,
           onTap: provider.resetTimer, color: AppColors.textSecondary),
      const SizedBox(width: 20),
      GestureDetector(
        onTap: provider.running ? provider.pauseTimer : provider.startTimer,
        child: Container(
          width: 76, height: 76,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [color, color.withOpacity(0.7)],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 18, offset: const Offset(0, 6))],
          ),
          child: Icon(
            provider.running ? Icons.pause_rounded : Icons.play_arrow_rounded,
            color: AppColors.bg, size: 38),
        ),
      ),
      const SizedBox(width: 20),
      _Btn(icon: Icons.skip_next_rounded, size: 50,
           onTap: provider.skipPhase, color: AppColors.textSecondary),
    ]);
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final double size;
  final VoidCallback onTap;
  final Color color;
  const _Btn({required this.icon, required this.size, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(color: AppColors.card, shape: BoxShape.circle),
        child: Icon(icon, color: color, size: size * 0.44),
      ),
    );
  }
}

// ── Bottom Stats ──────────────────────────────────────────────
class _BottomStats extends StatelessWidget {
  final AppProvider p;
  const _BottomStats({required this.p});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _S('Today', '${p.sessionsDone}', '🍅'),
        Container(width: 1, height: 28, color: AppColors.divider),
        _S('Total', '${p.profile.totalPomodoros}', '📊'),
        Container(width: 1, height: 28, color: AppColors.divider),
        _S('Streak', '${p.profile.streak}🔥', '⚡'),
        Container(width: 1, height: 28, color: AppColors.divider),
        _S('Points', '${p.profile.points}', '💎'),
      ]),
    );
  }
}

class _S extends StatelessWidget {
  final String label, value, icon;
  const _S(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(icon, style: const TextStyle(fontSize: 16)),
      const SizedBox(height: 2),
      Text(value,
          style: const TextStyle(color: AppColors.textPrimary,
              fontWeight: FontWeight.w800, fontSize: 15)),
      Text(label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
    ]);
  }
}

// ── Settings Sheet ────────────────────────────────────────────
class _SettingsSheet extends StatefulWidget {
  final AppProvider p;
  const _SettingsSheet({required this.p});

  @override
  State<_SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<_SettingsSheet> {
  late int study, shortB, longB;
  late bool autoBreaks;

  @override
  void initState() {
    super.initState();
    study   = widget.p.settings.studyMins;
    shortB  = widget.p.settings.shortBreakMins;
    longB   = widget.p.settings.longBreakMins;
    autoBreaks = widget.p.settings.autoStartBreaks;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Center(child: Container(width: 40, height: 4,
            decoration: BoxDecoration(color: AppColors.divider,
                borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 20),
        const Text('Timer Settings',
            style: TextStyle(color: AppColors.textPrimary,
                fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 20),
        _DurRow('🍅  Focus', study, 5, 60, (v) => setState(() => study = v)),
        _DurRow('☕  Short Break', shortB, 1, 30, (v) => setState(() => shortB = v)),
        _DurRow('🛋️  Long Break', longB, 5, 60, (v) => setState(() => longB = v)),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Auto-start breaks',
              style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
          Switch(value: autoBreaks, onChanged: (v) => setState(() => autoBreaks = v)),
        ]),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              widget.p.updateSettings(PomodoroSettings(
                studyMins: study, shortBreakMins: shortB, longBreakMins: longB,
                autoStartBreaks: autoBreaks));
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).padding.bottom + 4),
      ]),
    );
  }
}

class _DurRow extends StatelessWidget {
  final String label;
  final int value, min, max;
  final ValueChanged<int> onChanged;
  const _DurRow(this.label, this.value, this.min, this.max, this.onChanged);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(
            color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
        Row(children: [
          _adj(Icons.remove, value > min ? () => onChanged(value - 1) : null),
          SizedBox(width: 52,
              child: Center(child: Text('${value}m',
                  style: const TextStyle(color: AppColors.accent,
                      fontWeight: FontWeight.w700, fontSize: 16)))),
          _adj(Icons.add, value < max ? () => onChanged(value + 1) : null),
        ]),
      ]),
    );
  }

  Widget _adj(IconData icon, VoidCallback? cb) {
    return GestureDetector(
      onTap: cb,
      child: Container(
        width: 30, height: 30,
        decoration: BoxDecoration(
            color: cb != null ? AppColors.cardLight : AppColors.card,
            borderRadius: BorderRadius.circular(8)),
        child: Icon(icon,
            color: cb != null ? AppColors.textPrimary : AppColors.textMuted,
            size: 16),
      ),
    );
  }
}
