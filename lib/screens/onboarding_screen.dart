// lib/screens/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onDone;
  const OnboardingScreen({super.key, required this.onDone});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final _ctrl = PageController();
  int _page = 0;

  static const _pages = [
    _Page(emoji: '🎓', title: 'Welcome to\nEdu Planner',
        body: 'Your all-in-one study companion. Focus better, plan smarter, and achieve more every single day.',
        gradient: AppColors.gradientAccent, btnText: 'Next'),
    _Page(emoji: '🍅', title: 'Pomodoro\nTimer',
        body: 'Study in focused sprints using the proven Pomodoro technique. Beat procrastination and build deep focus.',
        gradient: AppColors.gradientWarm, btnText: 'Next'),
    _Page(emoji: '📋', title: 'Manage\nYour Tasks',
        body: 'Create, prioritize, and track study tasks with deadlines. Never miss an assignment again.',
        gradient: AppColors.gradientPurple, btnText: 'Next'),
    _Page(emoji: '🏆', title: 'Earn Badges\n& Level Up',
        body: 'Unlock achievements, build study streaks, and level up. Make studying rewarding and fun!',
        gradient: AppColors.gradientWarm, btnText: "Let's Go! 🚀"),
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: Stack(
          children: [
            // Decorative blobs
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              top: -80, right: -60,
              child: _Blob(color: _pages[_page].gradient.colors.first.withOpacity(0.12), size: 280),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              bottom: -100, left: -80,
              child: _Blob(color: _pages[_page].gradient.colors.last.withOpacity(0.09), size: 320),
            ),

            SafeArea(
              child: Column(
                children: [
                  // Skip
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: widget.onDone,
                      child: const Text('Skip',
                          style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),

                  // Pages
                  Expanded(
                    child: PageView.builder(
                      controller: _ctrl,
                      onPageChanged: (p) => setState(() => _page = p),
                      itemCount: _pages.length,
                      itemBuilder: (_, i) => _PageView(page: _pages[i]),
                    ),
                  ),

                  // Dots + button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 0, 28, 36),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_pages.length, (i) {
                            final active = i == _page;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: active ? 28 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                gradient: active ? _pages[_page].gradient : null,
                                color: active ? null : AppColors.textMuted,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 28),
                        GestureDetector(
                          onTap: _next,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: _pages[_page].gradient,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: _pages[_page].gradient.colors.first.withOpacity(0.4),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                _pages[_page].btnText,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16),
                              ),
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
      ),
    );
  }

  void _next() {
    if (_page < _pages.length - 1) {
      _ctrl.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut);
    } else {
      widget.onDone();
    }
  }
}

class _Page {
  final String emoji, title, body, btnText;
  final LinearGradient gradient;
  const _Page({required this.emoji, required this.title, required this.body,
                required this.gradient, required this.btnText});
}

class _PageView extends StatelessWidget {
  final _Page page;
  const _PageView({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 150, height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                page.gradient.colors.first.withOpacity(0.2),
                Colors.transparent,
              ]),
            ),
            child: Center(child: Text(page.emoji, style: const TextStyle(fontSize: 70))),
          ),
          const SizedBox(height: 40),
          Text(page.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                foreground: Paint()
                  ..shader = page.gradient.createShader(
                      const Rect.fromLTWH(0, 0, 300, 80)),
                fontSize: 34,
                fontWeight: FontWeight.w900,
                height: 1.1,
              )),
          const SizedBox(height: 18),
          Text(page.body,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                  height: 1.65)),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  final double size;
  const _Blob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
