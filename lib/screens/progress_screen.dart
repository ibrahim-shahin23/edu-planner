// lib/screens/progress_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final profile = provider.profile;

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
                child: const Text('Progress',
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.w800)),
              ),
            ),
          ),

          // ─── Overall Stats ────────────────────────────────
          SliverToBoxAdapter(
            child: FadeInUp(
              delay: const Duration(milliseconds: 100),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: 'Overall Stats'),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.6,
                      children: [
                        StatCard(
                          label: 'Total Study Hours',
                          value: '${(profile.totalStudyMinutes / 60).toStringAsFixed(1)}h',
                          icon: '⏱️',
                          color: AppTheme.accent,
                        ),
                        StatCard(
                          label: 'Pomodoros Done',
                          value: '${profile.totalPomodoros}',
                          icon: '🍅',
                          color: AppTheme.accentOrange,
                        ),
                        StatCard(
                          label: 'Tasks Completed',
                          value: '${profile.totalTasksCompleted}',
                          icon: '✅',
                          color: AppTheme.accentPurple,
                        ),
                        StatCard(
                          label: 'Best Streak',
                          value: '${profile.longestStreak} days',
                          icon: '🔥',
                          color: AppTheme.accentYellow,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ─── Weekly Chart ─────────────────────────────────
          SliverToBoxAdapter(
            child: FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: 'This Week'),
                    const SizedBox(height: 16),
                    _WeeklyChart(provider: provider),
                  ],
                ),
              ),
            ),
          ),

          // ─── Productivity Score ───────────────────────────
          SliverToBoxAdapter(
            child: FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: _ProductivityScore(provider: provider),
              ),
            ),
          ),

          // ─── Study Sessions ───────────────────────────────
          SliverToBoxAdapter(
            child: FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: const Padding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: SectionHeader(title: 'Study History'),
              ),
            ),
          ),

          if (provider.sessions.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: EmptyState(
                  emoji: '📊',
                  title: 'No sessions yet',
                  subtitle: 'Start a timer session to track your study progress',
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final session =
                      provider.sessions.reversed.toList()[i];
                  return FadeInLeft(
                    delay: Duration(milliseconds: i * 50),
                    child: Padding(
                      padding:
                          EdgeInsets.fromLTRB(20, i == 0 ? 12 : 0, 20, 8),
                      child: _SessionCard(session: session),
                    ),
                  );
                },
                childCount: provider.sessions.length,
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

// ─── Weekly Chart ─────────────────────────────────────────────
class _WeeklyChart extends StatelessWidget {
  final AppProvider provider;
  const _WeeklyChart({required this.provider});

  @override
  Widget build(BuildContext context) {
    final hours = provider.weeklyStudyHours;
    final maxHours = hours.reduce((a, b) => a > b ? a : b).clamp(1.0, double.infinity);
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();
    final todayIndex = now.weekday - 1; // 0 = Monday

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${hours.fold(0.0, (a, b) => a + b).toStringAsFixed(1)}h total',
                style: const TextStyle(
                    color: AppTheme.accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 20),
              ),
              Text(
                DateFormat('MMM yyyy').format(now),
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxHours + 0.5,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppTheme.surface,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${hours[group.x].toStringAsFixed(1)}h',
                        const TextStyle(
                            color: AppTheme.accent,
                            fontWeight: FontWeight.w700),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            days[idx % 7],
                            style: TextStyle(
                              color: idx == todayIndex
                                  ? AppTheme.accent
                                  : AppTheme.textSecondary,
                              fontSize: 11,
                              fontWeight: idx == todayIndex
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  getDrawingHorizontalLine: (v) => const FlLine(
                    color: AppTheme.divider,
                    strokeWidth: 1,
                  ),
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(7, (i) {
                  final h = hours[i];
                  final isToday = i == todayIndex;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: h,
                        gradient: LinearGradient(
                          colors: isToday
                              ? [AppTheme.accent, const Color(0xFF00A3FF)]
                              : [
                                  AppTheme.accentPurple.withValues(alpha: 0.6),
                                  AppTheme.accentPurple.withValues(alpha: 0.3),
                                ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        width: 28,
                        borderRadius: BorderRadius.circular(8),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxHours + 0.5,
                          color: AppTheme.surfaceLight,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Productivity Score ───────────────────────────────────────
class _ProductivityScore extends StatelessWidget {
  final AppProvider provider;
  const _ProductivityScore({required this.provider});

  @override
  Widget build(BuildContext context) {
    final profile = provider.profile;
    final completionRate = provider.tasks.isEmpty
        ? 0.0
        : provider.completedTasks.length / provider.tasks.length;
    final dailyProgress = provider.dailyGoalProgress;

    final score = ((completionRate * 40) +
            (dailyProgress * 40) +
            (profile.currentStreak.clamp(0, 30) / 30 * 20))
        .round();

    return GradientCard(
      gradient: AppTheme.timerGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('⚡', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text('Productivity Score',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                '$score',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -2),
              ),
              const Text(
                '/100',
                style: TextStyle(
                    color: Colors.white60,
                    fontSize: 20,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ScoreBar(label: 'Tasks Completion', value: completionRate),
          const SizedBox(height: 8),
          _ScoreBar(label: 'Daily Goal', value: dailyProgress),
          const SizedBox(height: 8),
          _ScoreBar(
              label: 'Study Streak',
              value: profile.currentStreak / 30),
        ],
      ),
    );
  }
}

class _ScoreBar extends StatelessWidget {
  final String label;
  final double value;
  const _ScoreBar({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 12)),
            Text('${(value * 100).round()}%',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

// ─── Session Card ─────────────────────────────────────────────
class _SessionCard extends StatelessWidget {
  final session;
  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: AppTheme.accentGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                session.pomodorosCompleted > 0 ? '🍅' : '📖',
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(session.subject,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w700)),
                Text(DateFormat('EEE, MMM d · HH:mm').format(session.date),
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${session.durationMinutes}m',
                style: const TextStyle(
                    color: AppTheme.accent,
                    fontWeight: FontWeight.w800,
                    fontSize: 16),
              ),
              if (session.pomodorosCompleted > 0)
                Text(
                  '${session.pomodorosCompleted} 🍅',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 11),
                ),
            ],
          ),
        ],
      ),
    );
  }
}