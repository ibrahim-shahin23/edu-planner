// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isFocusMode = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final profile = provider.profile;
    _isFocusMode = provider.isFocusMode;

    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: CustomScrollView(
        slivers: [
          // ─── Header ──────────────────────────────────────
          SliverToBoxAdapter(
            child: FadeInDown(
              child: Container(
                padding: EdgeInsets.fromLTRB(
                    20, MediaQuery.of(context).padding.top + 16, 20, 32),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF163555), Color(0xFF0A2540)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  children: [
                    // Avatar
                    GestureDetector(
                      onTap: () => _showAvatarPicker(context, provider),
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              gradient: AppTheme.accentGradient,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.accent.withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(profile.avatar,
                                  style: const TextStyle(fontSize: 44)),
                            ),
                          ),
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppTheme.primary, width: 2),
                            ),
                            child: const Icon(Icons.edit_rounded,
                                color: AppTheme.accent, size: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => _showEditName(context, provider),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(profile.name,
                              style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800)),
                          const SizedBox(width: 8),
                          const Icon(Icons.edit_outlined,
                              color: AppTheme.textSecondary, size: 16),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.accentPurple.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${profile.levelTitle} · Level ${profile.level}',
                        style: const TextStyle(
                            color: AppTheme.accentPurple,
                            fontWeight: FontWeight.w700,
                            fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Level Progress
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Level ${profile.level}',
                                style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12)),
                            Text('${profile.currentLevelPoints} / ${profile.pointsForNextLevel} XP',
                                style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12)),
                            Text('Level ${profile.level + 1}',
                                style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        AnimatedProgressBar(
                          progress: profile.levelProgress,
                          color: AppTheme.accentPurple,
                          height: 10,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ─── Focus Mode Toggle ────────────────────────────
          SliverToBoxAdapter(
            child: FadeInUp(
              delay: const Duration(milliseconds: 100),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _FocusModeCard(provider: provider),
              ),
            ),
          ),

          // ─── Daily Goal Setting ───────────────────────────
          SliverToBoxAdapter(
            child: FadeInUp(
              delay: const Duration(milliseconds: 150),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _DailyGoalCard(provider: provider),
              ),
            ),
          ),

          // ─── Settings ─────────────────────────────────────
          SliverToBoxAdapter(
            child: FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: const Padding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: SectionHeader(title: 'Preferences'),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: FadeInUp(
              delay: const Duration(milliseconds: 250),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _SettingsList(),
              ),
            ),
          ),

          // ─── App Info ─────────────────────────────────────
          SliverToBoxAdapter(
            child: FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'Edu Planner v1.0.0\nFree for all students 🎓',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12),
                  ),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  void _showAvatarPicker(BuildContext context, AppProvider provider) {
    final emojis = [
      '🎓', '📚', '🦉', '🚀', '⚡', '🌟', '🎯', '🦁',
      '🐺', '🦊', '🐻', '🐼', '🦅', '🌙', '☀️', '🔥',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choose Avatar',
                style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: emojis.map((e) {
                final isSelected = provider.profile.avatar == e;
                return GestureDetector(
                  onTap: () {
                    provider.updateProfile(avatar: e);
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.accent.withOpacity(0.2)
                          : AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(color: AppTheme.accent, width: 2)
                          : null,
                    ),
                    child: Center(
                        child: Text(e,
                            style: const TextStyle(fontSize: 28))),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditName(BuildContext context, AppProvider provider) {
    final ctrl = TextEditingController(text: provider.profile.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Name',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(labelText: 'Your name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                provider.updateProfile(name: ctrl.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

// ─── Focus Mode Card ──────────────────────────────────────────
class _FocusModeCard extends StatelessWidget {
  final AppProvider provider;
  const _FocusModeCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final isOn = provider.isFocusMode;

    return GestureDetector(
      onTap: provider.toggleFocusMode,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isOn
              ? const LinearGradient(
                  colors: [Color(0xFF7B61FF), Color(0xFF4D3BB0)],
                )
              : null,
          color: isOn ? null : AppTheme.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isOn
                ? AppTheme.accentPurple.withOpacity(0.5)
                : AppTheme.divider,
          ),
          boxShadow: isOn
              ? [
                  BoxShadow(
                    color: AppTheme.accentPurple.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            Text(isOn ? '🧘' : '🧘',
                style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Focus Mode',
                    style: TextStyle(
                      color: isOn ? Colors.white : AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    isOn
                        ? 'Deep focus active – notifications silenced'
                        : 'Tap to enter deep focus mode',
                    style: TextStyle(
                      color: isOn ? Colors.white70 : AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 52,
              height: 30,
              decoration: BoxDecoration(
                color: isOn ? Colors.white : AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(15),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                alignment:
                    isOn ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: isOn ? AppTheme.accentPurple : AppTheme.textSecondary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Daily Goal Card ──────────────────────────────────────────
class _DailyGoalCard extends StatelessWidget {
  final AppProvider provider;
  const _DailyGoalCard({required this.provider});

  static const goals = [30, 60, 90, 120, 180, 240];

  @override
  Widget build(BuildContext context) {
    final current = provider.profile.dailyGoalMinutes;

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
            children: [
              const Text('🎯', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              const Text('Daily Study Goal',
                  style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
              const Spacer(),
              Text(
                current >= 60
                    ? '${current ~/ 60}h ${current % 60 > 0 ? '${current % 60}m' : ''}'
                    : '${current}m',
                style: const TextStyle(
                    color: AppTheme.accent,
                    fontWeight: FontWeight.w800,
                    fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: goals.map((g) {
              final isSelected = current == g;
              final label = g >= 60 ? '${g ~/ 60}h' : '${g}m';
              return Expanded(
                child: GestureDetector(
                  onTap: () =>
                      provider.updateProfile(dailyGoalMinutes: g),
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.accent
                          : AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(label,
                          style: TextStyle(
                            color: isSelected
                                ? AppTheme.primary
                                : AppTheme.textSecondary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          )),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Settings List ────────────────────────────────────────────
class _SettingsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': '🔔', 'label': 'Notifications', 'subtitle': 'Study reminders & alerts'},
      {'icon': '🎵', 'label': 'Sound Effects', 'subtitle': 'Timer sounds & alerts'},
      {'icon': '🌙', 'label': 'Dark Mode', 'subtitle': 'Always on for focus'},
      {'icon': '📊', 'label': 'Export Data', 'subtitle': 'Download study reports'},
      {'icon': '🔒', 'label': 'Privacy', 'subtitle': 'Data & permissions'},
      {'icon': '💬', 'label': 'Feedback', 'subtitle': 'Help us improve'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return Column(
            children: [
              _SettingsTile(
                icon: item['icon']!,
                label: item['label']!,
                subtitle: item['subtitle']!,
              ),
              if (i < items.length - 1)
                const Divider(height: 1, indent: 56, color: AppTheme.divider),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String icon;
  final String label;
  final String subtitle;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(icon, style: const TextStyle(fontSize: 22)),
      title: Text(label,
          style: const TextStyle(
              color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle,
          style: const TextStyle(
              color: AppTheme.textSecondary, fontSize: 12)),
      trailing: const Icon(Icons.chevron_right_rounded,
          color: AppTheme.textSecondary),
      onTap: () {},
    );
  }
}