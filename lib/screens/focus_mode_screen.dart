// lib/screens/focus_mode_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../utils/utils.dart';

class FocusModeScreen extends StatefulWidget {
  const FocusModeScreen({super.key});

  @override
  State<FocusModeScreen> createState() => _FocusModeScreenState();
}

class _FocusModeScreenState extends State<FocusModeScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathController;
  late AnimationController _bgController;
  late Animation<double> _breathScale;
  late Animation<double> _breathOpacity;
  late Animation<Color?> _bgColor;
  Timer? _elapsedTimer;
  int _elapsedSeconds = 0;
  String _breathPhase = 'Breathe In';

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _setupAnimations();
    _startElapsedTimer();
  }

  void _setupAnimations() {
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _breathScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );
    _breathOpacity = Tween<double>(begin: 0.4, end: 0.9).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat(reverse: true);

    _bgColor = ColorTween(
      begin: const Color(0xFF0A2540),
      end: const Color(0xFF0F2D4A),
    ).animate(_bgController);

    _breathController.addListener(() {
      final v = _breathController.value;
      setState(() {
        _breathPhase = v < 0.5 ? 'Breathe In' : 'Breathe Out';
      });
    });
  }

  void _startElapsedTimer() {
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsedSeconds++);
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _breathController.dispose();
    _bgController.dispose();
    _elapsedTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return AnimatedBuilder(
      animation: _bgColor,
      builder: (context, child) => Scaffold(
        backgroundColor: _bgColor.value,
        body: SafeArea(
          child: Stack(
            children: [
              // ─── Ambient Background Circles ────────────────
              ..._buildAmbientCircles(),

              // ─── Main Content ──────────────────────────────
              Column(
                children: [
                  // Top bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FadeIn(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Focus Mode',
                                style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 13),
                              ),
                              Text(
                                TimeUtils.formatSeconds(_elapsedSeconds),
                                style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                        FadeIn(
                          child: GestureDetector(
                            onTap: () {
                              provider.toggleFocusMode();
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.error.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: AppTheme.error.withOpacity(0.4)),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.close_rounded,
                                      color: AppTheme.error, size: 16),
                                  SizedBox(width: 6),
                                  Text('Exit Focus',
                                      style: TextStyle(
                                          color: AppTheme.error,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // ─── Breathing Circle ──────────────────────
                  AnimatedBuilder(
                    animation: _breathController,
                    builder: (context, child) {
                      return Column(
                        children: [
                          Transform.scale(
                            scale: _breathScale.value,
                            child: Opacity(
                              opacity: _breathOpacity.value,
                              child: Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      AppTheme.accent.withOpacity(0.6),
                                      AppTheme.accentPurple.withOpacity(0.3),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                                child: const Center(
                                  child: Text('🧘',
                                      style: TextStyle(fontSize: 56)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            child: Text(
                              _breathPhase,
                              key: ValueKey(_breathPhase),
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '4-second cycles for deep focus',
                            style: TextStyle(
                                color: AppTheme.textSecondary, fontSize: 13),
                          ),
                        ],
                      );
                    },
                  ),

                  const Spacer(),

                  // ─── Focus Tips ────────────────────────────
                  FadeInUp(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                      child: _FocusTips(elapsed: _elapsedSeconds),
                    ),
                  ),

                  // ─── Timer if running ──────────────────────
                  if (provider.isTimerRunning)
                    FadeInUp(
                      delay: const Duration(milliseconds: 200),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.cardBg.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: AppTheme.accent.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('🍅',
                                  style: TextStyle(fontSize: 20)),
                              const SizedBox(width: 10),
                              Text(
                                'Pomodoro: ${TimeUtils.formatSeconds(provider.secondsRemaining)}',
                                style: const TextStyle(
                                    color: AppTheme.accent,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAmbientCircles() {
    return [
      Positioned(
        top: -80,
        right: -60,
        child: AnimatedBuilder(
          animation: _breathController,
          builder: (_, __) => Opacity(
            opacity: 0.08 + _breathController.value * 0.05,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentPurple,
              ),
            ),
          ),
        ),
      ),
      Positioned(
        bottom: -100,
        left: -80,
        child: AnimatedBuilder(
          animation: _breathController,
          builder: (_, __) => Opacity(
            opacity: 0.06 + (1 - _breathController.value) * 0.05,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accent,
              ),
            ),
          ),
        ),
      ),
    ];
  }
}

// ─── Focus Tips ───────────────────────────────────────────────
class _FocusTips extends StatefulWidget {
  final int elapsed;
  const _FocusTips({required this.elapsed});

  @override
  State<_FocusTips> createState() => _FocusTipsState();
}

class _FocusTipsState extends State<_FocusTips> {
  static const tips = [
    '💡 Turn off all notifications to stay focused.',
    '🎵 Try instrumental music or white noise.',
    '📵 Put your phone face-down.',
    '💧 Stay hydrated — drink water regularly.',
    '🪴 A tidy workspace boosts concentration.',
    '✍️ Write down distracting thoughts to clear your mind.',
    '🎯 Focus on ONE task at a time.',
    '⏰ The next break is your reward — push through!',
    '🧠 Your brain is building new study habits right now.',
    '🏆 Every minute of focus is an investment in yourself.',
  ];

  int _tipIndex = 0;

  @override
  void didUpdateWidget(_FocusTips old) {
    super.didUpdateWidget(old);
    if (widget.elapsed % 60 == 0 && widget.elapsed > 0) {
      setState(() => _tipIndex = (_tipIndex + 1) % tips.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      child: Container(
        key: ValueKey(_tipIndex),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBg.withOpacity(0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.accent.withOpacity(0.15)),
        ),
        child: Text(
          tips[_tipIndex],
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: AppTheme.textSecondary, fontSize: 13, height: 1.5),
        ),
      ),
    );
  }
}