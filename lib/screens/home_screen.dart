// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../models/models.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final profile = provider.profile;
    final now = DateTime.now();
    final greeting = _getGreeting(now.hour);

    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: CustomScrollView(
        slivers: [
          // ─── Header ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: FadeInDown(
              duration: const Duration(milliseconds: 600),
              child: Container(
                padding: EdgeInsets.fromLTRB(
                    20, MediaQuery.of(context).padding.top + 16, 20, 24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0A2540), Color(0xFF163555)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$greeting,',
                              style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                            Text(
                              profile.name,
                              style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: AppTheme.accentGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: AppTheme.accent.withOpacity(0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 4))
                            ],
                          ),
                          child: Center(
                            child: Text(profile.avatar,
                                style: const TextStyle(fontSize: 26)),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Daily Goal Progress
                    _DailyGoalCard(provider: provider),
                  ],
                ),
              ),
            ),
          ),

          // ─── Quick Stats ────────────────────────────────────
          SliverToBoxAdapter(
            child: FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: 'Quick Stats'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            label: 'Study Hours',
                            value: '${(profile.totalStudyMinutes / 60).toStringAsFixed(1)}h',
                            icon: '📚',
                            color: AppTheme.accent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            label: 'Day Streak',
                            value: '${profile.currentStreak}🔥',
                            icon: '⚡',
                            color: AppTheme.accentOrange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            label: 'Tasks Done',
                            value: '${profile.totalTasksCompleted}',
                            icon: '✅',
                            color: AppTheme.accentPurple,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ─── Level Progress ──────────────────────────────────
          SliverToBoxAdapter(
            child: FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _LevelCard(profile: profile),
              ),
            ),
          ),

          // ─── Upcoming Tasks ──────────────────────────────────
          SliverToBoxAdapter(
            child: FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: SectionHeader(
                  title: 'Upcoming Tasks',
                  actionLabel: 'See all',
                  onAction: () {},
                ),
              ),
            ),
          ),

          if (provider.pendingTasks.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text('🎉 No pending tasks! Great work!',
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 14)),
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final task = provider.pendingTasks
                      .take(3)
                      .toList()[i];
                  return FadeInLeft(
                    delay: Duration(milliseconds: 400 + (i * 100)),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                          20, i == 0 ? 12 : 8, 20, 0),
                      child: _TaskTile(task: task, provider: provider),
                    ),
                  );
                },
                childCount: provider.pendingTasks.take(3).length,
              ),
            ),

          // ─── Recent Activity ─────────────────────────────────
          SliverToBoxAdapter(
            child: FadeInUp(
              delay: const Duration(milliseconds: 500),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: 'Recent Sessions'),
                    const SizedBox(height: 12),
                    if (provider.sessions.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBg,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text('Start your first study session! 🚀',
                              style: TextStyle(
                                  color: AppTheme.textSecondary)),
                        ),
                      )
                    else
                      ...provider.sessions.reversed
                          .take(3)
                          .map((s) => _SessionTile(session: s)),
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

  String _getGreeting(int hour) {
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

// ─── Daily Goal Card ──────────────────────────────────────────
class _DailyGoalCard extends StatelessWidget {
  final AppProvider provider;
  const _DailyGoalCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final progress = provider.dailyGoalProgress;
    final todayMins = provider.todayStudyMinutes;
    final goalMins = provider.profile.dailyGoalMinutes;

    return GradientCard(
      gradient: AppTheme.accentGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Daily Goal',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                  SizedBox(height: 2),
                  Text('Study Progress',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(progress * 100).round()}%',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_formatMinutes(todayMins)} / ${_formatMinutes(goalMins)}',
            style: const TextStyle(
                color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _formatMinutes(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m > 0 ? '${h}h ${m}m' : '${h}h';
  }
}

// ─── Level Card ───────────────────────────────────────────────
class _LevelCard extends StatelessWidget {
  final UserProfile profile;
  const _LevelCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accentPurple.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.accentPurple, Color(0xFF00D4AA)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text('${profile.level}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(profile.levelTitle,
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 16)),
                    Text('${profile.totalPoints} pts',
                        style: const TextStyle(
                            color: AppTheme.accentYellow,
                            fontWeight: FontWeight.w700,
                            fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 8),
                AnimatedProgressBar(
                  progress: profile.levelProgress,
                  color: AppTheme.accentPurple,
                ),
                const SizedBox(height: 4),
                Text(
                  '${profile.currentLevelPoints} / ${profile.pointsForNextLevel} XP to Level ${profile.level + 1}',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Task Tile ────────────────────────────────────────────────
class _TaskTile extends StatelessWidget {
  final Task task;
  final AppProvider provider;

  const _TaskTile({required this.task, required this.provider});

  @override
  Widget build(BuildContext context) {
    final isOverdue = task.deadline.isBefore(DateTime.now());
    final daysLeft = task.deadline.difference(DateTime.now()).inDays;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: task.priorityColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => provider.toggleTaskComplete(task.id),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: task.priorityColor, width: 2),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(task.subject,
                        style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12)),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                          color: AppTheme.textSecondary,
                          shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isOverdue
                          ? 'Overdue'
                          : daysLeft == 0
                              ? 'Due today'
                              : '$daysLeft days left',
                      style: TextStyle(
                          color: isOverdue
                              ? AppTheme.error
                              : daysLeft <= 1
                                  ? AppTheme.warning
                                  : AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PriorityBadge(
              label: task.priorityLabel,
              color: task.priorityColor),
        ],
      ),
    );
  }
}

// ─── Session Tile ─────────────────────────────────────────────
class _SessionTile extends StatelessWidget {
  final StudySession session;
  const _SessionTile({required this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
                child: Text('📖', style: TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(session.subject,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                Text(DateFormat('MMM d, HH:mm').format(session.date),
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Text(
            '${session.durationMinutes}m',
            style: const TextStyle(
                color: AppTheme.accent,
                fontWeight: FontWeight.w700,
                fontSize: 14),
          ),
        ],
      ),
    );
  }
}