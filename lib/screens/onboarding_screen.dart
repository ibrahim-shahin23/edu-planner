// lib/screens/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _ctrl = PageController();
  int _page = 0;

  final _pages = const [
    _OnboardPage(
      emoji: '🎓',
      title: 'Welcome to\nEdu Planner',
      subtitle: 'Your smart study companion that helps you focus, plan, and achieve more every day.',
      color: AppTheme.accent,
    ),
    _OnboardPage(
      emoji: '🍅',
      title: 'Smart\nPomodoro Timer',
      subtitle: 'Study in focused intervals with customizable Pomodoro sessions. Maximize concentration and beat procrastination.',
      color: AppTheme.accentPurple,
    ),
    _OnboardPage(
      emoji: '📋',
      title: 'Organize\nYour Tasks',
      subtitle: 'Create, prioritize, and track study tasks with deadlines. Never miss an assignment again.',
      color: AppTheme.accentOrange,
    ),
    _OnboardPage(
      emoji: '🏆',
      title: 'Earn Rewards\n& Level Up',
      subtitle: 'Unlock achievements, build streaks, and level up as you study. Learning has never been this fun!',
      color: AppTheme.accentYellow,
    ),
    _OnboardPage(
      emoji: '🚀',
      title: "You're\nAll Set!",
      subtitle: 'Edu Planner is completely free. Let\'s build great study habits together and achieve your academic goals.',
      color: AppTheme.success,
    ),
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: Stack(
        children: [
          // Background blobs
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _pages[_page].color.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -60,
            child: Container(
              width: 250, height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _pages[_page].color.withValues(alpha: 0.06),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Skip button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: TextButton(
                      onPressed: widget.onComplete,
                      child: const Text('Skip',
                          style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),

                // Page content
                Expanded(
                  child: PageView.builder(
                    controller: _ctrl,
                    onPageChanged: (p) => setState(() => _page = p),
                    itemCount: _pages.length,
                    itemBuilder: (_, i) => _pages[i],
                  ),
                ),

                // Dots + buttons
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
                  child: Column(
                    children: [
                      // Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_pages.length, (i) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _page == i ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _page == i
                                  ? _pages[_page].color
                                  : AppTheme.divider,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 32),

                      // Action button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _next,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _pages[_page].color,
                            foregroundColor: AppTheme.primary,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(
                            _page == _pages.length - 1
                                ? 'Get Started 🚀'
                                : 'Continue',
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _next() {
    if (_page < _pages.length - 1) {
      _ctrl.nextPage(
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      widget.onComplete();
    }
  }
}

class _OnboardPage extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;

  const _OnboardPage({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeIn(
            key: ValueKey(emoji),
            duration: const Duration(milliseconds: 600),
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.15),
                border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 64)),
              ),
            ),
          ),
          const SizedBox(height: 40),
          FadeInUp(
            key: ValueKey(title),
            duration: const Duration(milliseconds: 500),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            key: ValueKey(subtitle),
            delay: const Duration(milliseconds: 150),
            duration: const Duration(milliseconds: 500),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 15,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}