// lib/screens/achievements_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final profile = provider.profile;
    final achievements = provider.achievements;
    final unlocked = achievements.where((a) => a.isUnlocked).length;

    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: CustomScrollView(
        slivers: [
          // ─── Header ──────────────────────────────────────
          SliverToBoxAdapter(
            child: FadeInDown(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    20, MediaQuery.of(context).padding.top + 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Achievements',
                        style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 26,
                            fontWeight: FontWeight.w800)),
                    Text(
                      '$unlocked / ${achievements.length} unlocked',
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ─── Profile Card ─────────────────────────────────
          SliverToBoxAdapter(
            child: FadeInUp(
              delay: const Duration(milliseconds: 100),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _ProfileHero(provider: provider),
              ),
            ),
          ),

          // ─── Streak Banner ────────────────────────────────
          if (profile.currentStreak > 0)
            SliverToBoxAdapter(
              child: FadeInUp(
                delay: const Duration(milliseconds: 150),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _StreakBanner(streak: profile.currentStreak),
                ),
              ),
            ),

          // ─── Achievement Grid ─────────────────────────────
          SliverToBoxAdapter(
            child: FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: const Padding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: SectionHeader(title: 'Badges'),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final achievement = achievements[i];
                  return FadeInUp(
                    delay: Duration(milliseconds: 200 + i * 50),
                    child: _AchievementBadge(achievement: achievement),
                  );
                },
                childCount: achievements.length,
              ),
            ),
          ),

          // ─── Leaderboard (Coming Soon) ────────────────────
          SliverToBoxAdapter(
            child: FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: 'Milestones'),
                    const SizedBox(height: 12),
                    _MilestoneList(provider: provider),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

// ─── Profile Hero ─────────────────────────────────────────────
class _ProfileHero extends StatelessWidget {
  final AppProvider provider;
  const _ProfileHero({required this.provider});

  @override
  Widget build(BuildContext context) {
    final profile = provider.profile;

    return GradientCard(
      gradient: AppTheme.timerGradient,
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
                child: Text(profile.avatar,
                    style: const TextStyle(fontSize: 36))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profile.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800)),
                Text(profile.levelTitle,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _StatChip(label: 'Level', value: '${profile.level}'),
                    const SizedBox(width: 8),
                    _StatChip(
                        label: 'Points',
                        value: '${profile.totalPoints}'),
                    const SizedBox(width: 8),
                    _StatChip(
                        label: 'Badges',
                        value:
                            '${provider.achievements.where((a) => a.isUnlocked).length}'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text('$value $label',
          style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600)),
    );
  }
}

// ─── Streak Banner ────────────────────────────────────────────
class _StreakBanner extends StatelessWidget {
  final int streak;
  const _StreakBanner({required this.streak});

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      gradient: AppTheme.warmGradient,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$streak Day Streak!',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800)),
              const Text('Keep it up! Don\'t break the chain!',
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Achievement Badge ────────────────────────────────────────
class _AchievementBadge extends StatelessWidget {
  final achievement;
  const _AchievementBadge({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final isUnlocked = achievement.isUnlocked;

    return GestureDetector(
      onTap: () => _showDetail(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUnlocked
              ? AppTheme.accentPurple.withOpacity(0.15)
              : AppTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnlocked
                ? AppTheme.accentPurple.withOpacity(0.5)
                : AppTheme.divider,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: AppTheme.accentPurple.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ColorFiltered(
              colorFilter: isUnlocked
                  ? const ColorFilter.mode(
                      Colors.transparent, BlendMode.multiply)
                  : const ColorFilter.matrix([
                      0.2126,0.7152,0.0722,0,0,
                      0.2126,0.7152,0.0722,0,0,
                      0.2126,0.7152,0.0722,0,0,
                      0,     0,     0,     1,0,
                    ]),
              child: Text(
                achievement.icon,
                style: TextStyle(
                    fontSize: 32,
                    color: isUnlocked ? null : Colors.grey),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              achievement.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isUnlocked
                    ? AppTheme.textPrimary
                    : AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (isUnlocked)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppTheme.accent,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(achievement.icon,
                style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(achievement.title,
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(achievement.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 14)),
            const SizedBox(height: 12),
            if (achievement.isUnlocked)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('✅ Unlocked!',
                    style: TextStyle(
                        color: AppTheme.success,
                        fontWeight: FontWeight.w700)),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('🔒 Locked',
                    style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w600)),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close',
                style: TextStyle(color: AppTheme.accent)),
          ),
        ],
      ),
    );
  }
}

// ─── Milestone List ───────────────────────────────────────────
class _MilestoneList extends StatelessWidget {
  final AppProvider provider;
  const _MilestoneList({required this.provider});

  @override
  Widget build(BuildContext context) {
    final milestones = [
      {'label': 'Study 10 hours', 'icon': '📚', 'target': 600,
       'current': provider.profile.totalStudyMinutes, 'unit': 'min'},
      {'label': 'Complete 50 tasks', 'icon': '✅', 'target': 50,
       'current': provider.profile.totalTasksCompleted, 'unit': ''},
      {'label': 'Reach Level 10', 'icon': '⭐', 'target': 10,
       'current': provider.profile.level, 'unit': ''},
      {'label': '7-Day Streak', 'icon': '🔥', 'target': 7,
       'current': provider.profile.currentStreak, 'unit': ''},
      {'label': '100 Pomodoros', 'icon': '🍅', 'target': 100,
       'current': provider.profile.totalPomodoros, 'unit': ''},
    ];

    return Column(
      children: milestones.map((m) {
        final current = m['current'] as int;
        final target = m['target'] as int;
        final progress = (current / target).clamp(0.0, 1.0);
        final isDone = current >= target;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: isDone
                ? Border.all(color: AppTheme.success.withOpacity(0.4))
                : null,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Text(m['icon'] as String,
                      style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(m['label'] as String,
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600)),
                  ),
                  Text(
                    isDone ? '✅' : '$current / $target',
                    style: TextStyle(
                      color:
                          isDone ? AppTheme.success : AppTheme.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              AnimatedProgressBar(
                progress: progress,
                color: isDone ? AppTheme.success : AppTheme.accent,
                height: 6,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}