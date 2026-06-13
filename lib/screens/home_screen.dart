// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import '../models/models.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final profile = p.profile;
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          // ── Header ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(gradient: AppColors.gradientDark),
              padding: EdgeInsets.fromLTRB(
                  20, MediaQuery.of(context).padding.top + 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$greeting 👋',
                              style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14)),
                          const SizedBox(height: 2),
                          Text(profile.name,
                              style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800)),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => _showProfileEdit(context, p),
                        child: Container(
                          width: 52, height: 52,
                          decoration: BoxDecoration(
                            gradient: AppColors.gradientAccent,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(
                                color: AppColors.accent.withOpacity(0.4),
                                blurRadius: 14, offset: const Offset(0, 4))],
                          ),
                          child: Center(child: Text(profile.avatar,
                              style: const TextStyle(fontSize: 26))),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Daily Goal Card
                  _DailyGoalCard(p: p),
                ],
              ),
            ),
          ),

          // ── Quick Stats ─────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle('Quick Stats'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: StatChip(
                          emoji: '📚',
                          value: '${(profile.totalMinutes / 60).toStringAsFixed(1)}h',
                          label: 'Study Hours',
                          color: AppColors.accent)),
                      const SizedBox(width: 10),
                      Expanded(child: StatChip(
                          emoji: '🔥',
                          value: '${profile.streak}',
                          label: 'Day Streak',
                          color: AppColors.orange)),
                      const SizedBox(width: 10),
                      Expanded(child: StatChip(
                          emoji: '✅',
                          value: '${profile.totalTasks}',
                          label: 'Tasks Done',
                          color: AppColors.green)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Level Card ──────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: _LevelCard(profile: profile),
            ),
          ),

          // ── Upcoming Tasks ──────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: SectionTitle('Upcoming Tasks',
                  trailing: 'See all', onTrailing: () {}),
            ),
          ),

          p.pending.isEmpty
              ? SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GlassCard(
                      child: const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text('🎉  No pending tasks — great work!',
                              style: TextStyle(color: AppColors.textSecondary)),
                        ),
                      ),
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final task = p.pending.take(3).toList()[i];
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                        child: _HomeTaskTile(task: task, onDone: () => p.toggleTask(task.id)),
                      );
                    },
                    childCount: p.pending.take(3).length,
                  ),
                ),

          // ── Recent Sessions ─────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: const SectionTitle('Recent Sessions'),
            ),
          ),

          p.sessions.isEmpty
              ? SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GlassCard(
                      child: const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text('Start a timer session to see it here 🚀',
                              style: TextStyle(color: AppColors.textSecondary)),
                        ),
                      ),
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final s = p.sessions.reversed.take(3).toList()[i];
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                        child: _SessionTile(session: s),
                      );
                    },
                    childCount: p.sessions.reversed.take(3).length,
                  ),
                ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  void _showProfileEdit(BuildContext context, AppProvider p) {
    final nameCtrl = TextEditingController(text: p.profile.name);
    final emojis = ['🎓','📚','🦉','🚀','⚡','🌟','🎯','🦁','🐺','🦊','🐻','🐼','🦅','🌙','☀️','🔥'];
    String selectedAvatar = p.profile.avatar;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              const Text('Edit Profile',
                  style: TextStyle(color: AppColors.textPrimary,
                      fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Your Name'),
              ),
              const SizedBox(height: 16),
              const Text('Choose Avatar',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 8, shrinkWrap: true,
                mainAxisSpacing: 8, crossAxisSpacing: 8,
                children: emojis.map((e) => GestureDetector(
                  onTap: () => setState(() => selectedAvatar = e),
                  child: Container(
                    decoration: BoxDecoration(
                      color: selectedAvatar == e
                          ? AppColors.accent.withOpacity(0.2) : AppColors.card,
                      borderRadius: BorderRadius.circular(10),
                      border: selectedAvatar == e
                          ? Border.all(color: AppColors.accent, width: 2) : null,
                    ),
                    child: Center(child: Text(e, style: const TextStyle(fontSize: 22))),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    p.updateProfile(name: nameCtrl.text.trim().isEmpty
                        ? null : nameCtrl.text.trim(), avatar: selectedAvatar);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DailyGoalCard extends StatelessWidget {
  final AppProvider p;
  const _DailyGoalCard({required this.p});

  String _fmt(int mins) {
    if (mins < 60) return '${mins}m';
    return '${mins ~/ 60}h${mins % 60 > 0 ? ' ${mins % 60}m' : ''}';
  }

  @override
  Widget build(BuildContext context) {
    return GradBox(
      gradient: AppColors.gradientAccent,
      shadows: [BoxShadow(
          color: AppColors.accent.withOpacity(0.3),
          blurRadius: 20, offset: const Offset(0, 8))],
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Daily Goal', style: TextStyle(color: Colors.white70, fontSize: 13)),
            SizedBox(height: 2),
            Text('Study Progress', style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
          ]),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20)),
            child: Text('${(p.dailyProgress * 100).round()}%',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
          ),
        ]),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: p.dailyProgress,
            backgroundColor: Colors.white.withOpacity(0.25),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 6),
        Text('${_fmt(p.todayMins)} studied · Goal: ${_fmt(p.profile.dailyGoalMins)}',
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ]),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final UserProfile profile;
  const _LevelCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: AppColors.purple.withOpacity(0.3),
      child: Row(children: [
        Container(
          width: 54, height: 54,
          decoration: BoxDecoration(
              gradient: AppColors.gradientPurple,
              borderRadius: BorderRadius.circular(14)),
          child: Center(child: Text('${profile.level}',
              style: const TextStyle(
                  color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900))),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(profile.levelTitle,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700, fontSize: 15)),
            Text('${profile.points} pts',
                style: const TextStyle(
                    color: AppColors.yellow,
                    fontWeight: FontWeight.w700, fontSize: 12)),
          ]),
          const SizedBox(height: 8),
          AppProgressBar(value: profile.xpProgress, color: AppColors.purple),
          const SizedBox(height: 4),
          Text('${profile.currentXP} / ${profile.xpForNextLevel} XP to Level ${profile.level + 1}',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        ])),
      ]),
    );
  }
}

class _HomeTaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onDone;
  const _HomeTaskTile({required this.task, required this.onDone});

  @override
  Widget build(BuildContext context) {
    final overdue = task.deadline.isBefore(DateTime.now());
    final days = task.deadline.difference(DateTime.now()).inDays;

    return GlassCard(
      borderColor: task.priorityColor.withOpacity(0.2),
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        GestureDetector(
          onTap: onDone,
          child: Container(
            width: 24, height: 24,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: task.priorityColor, width: 2)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(task.title,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 3),
          Text(
            '${task.subject}  ·  ${overdue ? 'Overdue' : days == 0 ? 'Due today' : '$days days left'}',
            style: TextStyle(
                color: overdue ? AppColors.red : AppColors.textSecondary,
                fontSize: 11),
          ),
        ])),
        PriBadge(label: task.priorityLabel, color: task.priorityColor),
      ]),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final StudySession session;
  const _SessionTile({required this.session});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Row(children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
              gradient: AppColors.gradientAccent,
              borderRadius: BorderRadius.circular(12)),
          child: const Center(child: Text('📖', style: TextStyle(fontSize: 20))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(session.subject,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          Text(DateFormat('EEE, MMM d · HH:mm').format(session.date),
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        ])),
        Text('${session.minutes}m',
            style: const TextStyle(
                color: AppColors.accent, fontWeight: FontWeight.w800, fontSize: 15)),
      ]),
    );
  }
}
