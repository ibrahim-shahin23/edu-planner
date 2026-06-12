// lib/screens/main_shell.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'timer_screen.dart';
import 'tasks_screen.dart';
import 'progress_screen.dart';
import 'achievements_screen.dart';
import 'profile_screen.dart';
import 'focus_mode_screen.dart';
import 'distraction_blocker_screen.dart';
import 'notifications_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  static const _screens = [
    HomeScreen(),
    TimerScreen(),
    TasksScreen(),
    ProgressScreen(),
    AchievementsScreen(),
  ];

  static const _navItems = [
    _NavItem(icon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.timer_rounded, label: 'Timer'),
    _NavItem(icon: Icons.task_alt_rounded, label: 'Tasks'),
    _NavItem(icon: Icons.bar_chart_rounded, label: 'Progress'),
    _NavItem(icon: Icons.emoji_events_rounded, label: 'Badges'),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppTheme.surface,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.primary,
        body: Stack(
          children: [
            IndexedStack(
              index: _selectedIndex,
              children: _screens,
            ),

            // Focus Mode Banner
            if (provider.isFocusMode)
              Positioned(
                bottom: 90,
                left: 16,
                right: 16,
                child: _FocusBanner(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const FocusModeScreen()),
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: _BottomNav(
          selectedIndex: _selectedIndex,
          items: _navItems,
          onTap: (i) => setState(() => _selectedIndex = i),
        ),
        floatingActionButton: _selectedIndex == 4
            ? null
            : _QuickActionsButton(
                onFocusMode: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const FocusModeScreen()),
                ),
                onBlocker: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const DistractionBlockerScreen()),
                ),
                onNotifications: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const NotificationsScreen()),
                ),
                onProfile: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                ),
              ),
      ),
    );
  }
}

// ─── Bottom Navigation ────────────────────────────────────────
class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _BottomNav extends StatelessWidget {
  final int selectedIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;

  const _BottomNav({
    required this.selectedIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72 + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: const Border(
          top: BorderSide(color: AppTheme.divider, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            final isSelected = selectedIndex == i;
            return GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 64,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      width: isSelected ? 44 : 0,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.accent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    AnimatedScale(
                      scale: isSelected ? 1.15 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        item.icon,
                        color: isSelected
                            ? AppTheme.accent
                            : AppTheme.textSecondary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.label,
                      style: TextStyle(
                        color: isSelected
                            ? AppTheme.accent
                            : AppTheme.textSecondary,
                        fontSize: 10,
                        fontWeight: isSelected
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

// ─── Focus Mode Banner ────────────────────────────────────────
class _FocusBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _FocusBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.accentPurple, Color(0xFF4D3BB0)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accentPurple.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          children: [
            Text('🧘', style: TextStyle(fontSize: 20)),
            SizedBox(width: 10),
            Expanded(
              child: Text('Focus Mode Active — Tap to open',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white70, size: 14),
          ],
        ),
      ),
    );
  }
}

// ─── Quick Actions FAB ────────────────────────────────────────
class _QuickActionsButton extends StatefulWidget {
  final VoidCallback onFocusMode;
  final VoidCallback onBlocker;
  final VoidCallback onNotifications;
  final VoidCallback onProfile;

  const _QuickActionsButton({
    required this.onFocusMode,
    required this.onBlocker,
    required this.onNotifications,
    required this.onProfile,
  });

  @override
  State<_QuickActionsButton> createState() => _QuickActionsButtonState();
}

class _QuickActionsButtonState extends State<_QuickActionsButton>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _anim;
  late Animation<double> _rotation;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _rotation = Tween<double>(begin: 0, end: 0.125).animate(
      CurvedAnimation(parent: _anim, curve: Curves.easeOut),
    );
    _scale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _anim, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _anim.forward();
    } else {
      _anim.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_expanded) ...[
          ScaleTransition(
            scale: _scale,
            child: _FabOption(
              icon: '👤',
              label: 'Profile',
              onTap: () { _toggle(); widget.onProfile(); },
            ),
          ),
          const SizedBox(height: 8),
          ScaleTransition(
            scale: _scale,
            child: _FabOption(
              icon: '🔔',
              label: 'Notifications',
              onTap: () { _toggle(); widget.onNotifications(); },
            ),
          ),
          const SizedBox(height: 8),
          ScaleTransition(
            scale: _scale,
            child: _FabOption(
              icon: '🛡️',
              label: 'Blocker',
              onTap: () { _toggle(); widget.onBlocker(); },
            ),
          ),
          const SizedBox(height: 8),
          ScaleTransition(
            scale: _scale,
            child: _FabOption(
              icon: '🧘',
              label: 'Focus Mode',
              onTap: () { _toggle(); widget.onFocusMode(); },
            ),
          ),
          const SizedBox(height: 8),
        ],
        FloatingActionButton(
          onPressed: _toggle,
          backgroundColor: AppTheme.accent,
          foregroundColor: AppTheme.primary,
          elevation: 8,
          child: RotationTransition(
            turns: _rotation,
            child: Icon(
              _expanded ? Icons.close_rounded : Icons.menu_rounded,
              size: 26,
            ),
          ),
        ),
      ],
    );
  }
}

class _FabOption extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _FabOption({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
            const SizedBox(width: 8),
            Text(icon, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}