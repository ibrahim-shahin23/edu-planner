// lib/screens/main_shell.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import 'home_screen.dart';
import 'timer_screen.dart';
import 'tasks_screen.dart';
import 'achievements_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    TimerScreen(),
    TasksScreen(),
    AchievementsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Show achievement toast when a new one is unlocked
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final a = provider.newlyUnlocked;
          if (a != null) {
            provider.clearNewlyUnlocked();
            _showAchievementToast(context, a.icon, a.title);
          }
        });

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarColor: Color(0xFF0F2044),
            systemNavigationBarIconBrightness: Brightness.light,
          ),
          child: Scaffold(
            backgroundColor: AppColors.bg,
            body: IndexedStack(index: _index, children: _screens),
            bottomNavigationBar: _BottomBar(
              index: _index,
              onTap: (i) => setState(() => _index = i),
            ),
          ),
        );
      },
    );
  }

  void _showAchievementToast(BuildContext context, String icon, String title) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutBack,
            builder: (_, v, child) =>
                Transform.scale(scale: v, child: child),
            child: AchievementToast(icon: icon, title: title),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 3), () {
      if (entry.mounted) entry.remove();
    });
  }
}

// ── Bottom Navigation Bar ─────────────────────────────────────
class _BottomBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;

  const _BottomBar({required this.index, required this.onTap});

  static const _items = [
    _NavItem(Icons.home_rounded, Icons.home_outlined, 'Home'),
    _NavItem(Icons.timer_rounded, Icons.timer_outlined, 'Timer'),
    _NavItem(Icons.task_alt_rounded, Icons.task_alt_outlined, 'Tasks'),
    _NavItem(Icons.emoji_events_rounded, Icons.emoji_events_outlined, 'Badges'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68 + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.divider)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: _items.asMap().entries.map((e) {
            final i = e.key;
            final item = e.value;
            final active = index == i;
            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      height: 3,
                      width: active ? 32 : 0,
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    AnimatedScale(
                      scale: active ? 1.15 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        active ? item.activeIcon : item.icon,
                        color: active
                            ? AppColors.accent
                            : AppColors.textSecondary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.label,
                      style: TextStyle(
                        color: active
                            ? AppColors.accent
                            : AppColors.textSecondary,
                        fontSize: 10,
                        fontWeight: active
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData activeIcon, icon;
  final String label;
  const _NavItem(this.activeIcon, this.icon, this.label);
}
