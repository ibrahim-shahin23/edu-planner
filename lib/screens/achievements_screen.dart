// lib/screens/achievements_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final profile = p.profile;
    final unlocked = p.achievements.where((a) => a.unlocked).length;
    final total = p.achievements.length;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  20, MediaQuery.of(context).padding.top + 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Achievements',
                      style: TextStyle(color: AppColors.textPrimary,
                          fontSize: 26, fontWeight: FontWeight.w800)),
                  Text('$unlocked / $total unlocked',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ),
          ),

          // ── Profile Banner ───────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: GradBox(
                gradient: AppColors.gradientPurple,
                shadows: [BoxShadow(
                    color: AppColors.purple.withOpacity(0.3),
                    blurRadius: 20, offset: const Offset(0, 8))],
                child: Row(children: [
                  Container(
                    width: 68, height: 68,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle),
                    child: Center(child: Text(profile.avatar,
                        style: const TextStyle(fontSize: 34))),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profile.name,
                          style: const TextStyle(color: Colors.white,
                              fontSize: 18, fontWeight: FontWeight.w800)),
                      Text('${profile.levelTitle} · Level ${profile.level}',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 8),
                      Row(children: [
                        _ProfileChip('${profile.points} pts', Icons.diamond_rounded),
                        const SizedBox(width: 8),
                        _ProfileChip('${profile.streak}🔥 streak', Icons.local_fire_department_rounded),
                        const SizedBox(width: 8),
                        _ProfileChip('$unlocked badges', Icons.emoji_events_rounded),
                      ]),
                    ],
                  )),
                ]),
              ),
            ),
          ),

          // ── Streak Banner ────────────────────────────────
          if (profile.streak > 0)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: GradBox(
                  gradient: AppColors.gradientWarm,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  shadows: [BoxShadow(
                      color: AppColors.orange.withOpacity(0.3),
                      blurRadius: 14, offset: const Offset(0, 6))],
                  child: Row(children: [
                    const Text('🔥', style: TextStyle(fontSize: 30)),
                    const SizedBox(width: 12),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${profile.streak}-Day Streak!',
                          style: const TextStyle(color: Colors.white,
                              fontSize: 18, fontWeight: FontWeight.w800)),
                      const Text("Keep it up — don't break the chain!",
                          style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ]),
                  ]),
                ),
              ),
            ),

          // ── Level Progress ───────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: GlassCard(
                borderColor: AppColors.accent.withOpacity(0.2),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Level ${profile.level}',
                        style: const TextStyle(color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700)),
                    Text('${profile.currentXP} / ${profile.xpForNextLevel} XP',
                        style: const TextStyle(
                            color: AppColors.accent, fontWeight: FontWeight.w700)),
                  ]),
                  const SizedBox(height: 10),
                  AppProgressBar(value: profile.xpProgress, color: AppColors.accent, height: 10),
                  const SizedBox(height: 6),
                  Text('${profile.xpForNextLevel - profile.currentXP} XP until Level ${profile.level + 1}',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 11)),
                ]),
              ),
            ),
          ),

          // ── Badges Grid ──────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: SectionTitle('Badges ($unlocked/$total)'),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.88,
              ),
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _BadgeTile(achievement: p.achievements[i]),
                childCount: p.achievements.length,
              ),
            ),
          ),

          // ── Milestones ───────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: const SectionTitle('Milestones'),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _Milestones(p: p),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _ProfileChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _ProfileChip(this.label, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: const TextStyle(color: Colors.white,
              fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}

// ── Badge Tile ────────────────────────────────────────────────
class _BadgeTile extends StatelessWidget {
  final achievement;
  const _BadgeTile({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final bool unlocked = achievement.unlocked;

    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(achievement.icon, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(achievement.title,
                style: const TextStyle(color: AppColors.textPrimary,
                    fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(achievement.description,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 12),
            if (unlocked)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                    color: AppColors.green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(
                  '✅ Unlocked ${achievement.unlockedAt != null ? DateFormat('MMM d').format(achievement.unlockedAt!) : ''}',
                  style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w700),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                    color: AppColors.cardLight,
                    borderRadius: BorderRadius.circular(20)),
                child: const Text('🔒 Locked',
                    style: TextStyle(color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600)),
              ),
          ]),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: AppColors.accent)),
            ),
          ],
        ),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: unlocked
              ? achievement.color.withOpacity(0.1)
              : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: unlocked
                  ? achievement.color.withOpacity(0.4)
                  : AppColors.divider),
          boxShadow: unlocked
              ? [BoxShadow(
                  color: achievement.color.withOpacity(0.15),
                  blurRadius: 10)]
              : null,
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          ColorFiltered(
            colorFilter: unlocked
                ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                : const ColorFilter.matrix([
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0,      0,      0,      0.5, 0,
                  ]),
            child: Text(achievement.icon, style: const TextStyle(fontSize: 30)),
          ),
          const SizedBox(height: 6),
          Text(achievement.title,
              textAlign: TextAlign.center,
              maxLines: 2, overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: unlocked ? AppColors.textPrimary : AppColors.textSecondary,
                  fontSize: 10, fontWeight: FontWeight.w700)),
          if (unlocked)
            Container(margin: const EdgeInsets.only(top: 4),
                width: 5, height: 5,
                decoration: BoxDecoration(
                    color: achievement.color, shape: BoxShape.circle)),
        ]),
      ),
    );
  }
}

// ── Milestones ────────────────────────────────────────────────
class _Milestones extends StatelessWidget {
  final AppProvider p;
  const _Milestones({required this.p});

  @override
  Widget build(BuildContext context) {
    final items = [
      _MItem('📚', 'Study 10 hours',   p.profile.totalMinutes, 600),
      _MItem('🍅', '100 Pomodoros',    p.profile.totalPomodoros, 100),
      _MItem('✅', 'Complete 50 tasks', p.profile.totalTasks, 50),
      _MItem('🔥', '30-day streak',    p.profile.streak, 30),
      _MItem('⭐', 'Reach Level 10',   p.profile.level, 10),
      _MItem('💎', 'Earn 5000 points', p.profile.points, 5000),
    ];
    return Column(
      children: items.map((m) {
        final prog = (m.current / m.target).clamp(0.0, 1.0);
        final done = m.current >= m.target;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: done ? Border.all(color: AppColors.green.withOpacity(0.35)) : null,
          ),
          child: Column(children: [
            Row(children: [
              Text(m.icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(child: Text(m.label,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontWeight: FontWeight.w600))),
              Text(done ? '✅' : '${m.current} / ${m.target}',
                  style: TextStyle(
                      color: done ? AppColors.green : AppColors.textSecondary,
                      fontWeight: FontWeight.w700, fontSize: 12)),
            ]),
            const SizedBox(height: 8),
            AppProgressBar(
                value: prog,
                color: done ? AppColors.green : AppColors.accentBlue,
                height: 6),
          ]),
        );
      }).toList(),
    );
  }
}

class _MItem {
  final String icon, label;
  final int current, target;
  const _MItem(this.icon, this.label, this.current, this.target);
}
