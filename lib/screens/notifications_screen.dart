// lib/screens/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import '../utils/utils.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _dailyReminder = true;
  bool _taskReminders = true;
  bool _streakReminders = true;
  bool _timerAlerts = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);

  final _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: AppBar(
        title: const Text('Notifications & Reminders'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          FadeInDown(child: _buildDailySection()),
          const SizedBox(height: 16),
          FadeInDown(delay: const Duration(milliseconds: 100),
              child: _buildTaskSection()),
          const SizedBox(height: 16),
          FadeInDown(delay: const Duration(milliseconds: 200),
              child: _buildTimerSection()),
          const SizedBox(height: 16),
          FadeInDown(delay: const Duration(milliseconds: 300),
              child: _buildStreakSection()),
          const SizedBox(height: 24),
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: ElevatedButton.icon(
              onPressed: _saveSettings,
              icon: const Icon(Icons.save_rounded),
              label: const Text('Save Settings'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailySection() {
    return _NotifCard(
      title: '📚 Daily Study Reminder',
      subtitle: 'Get reminded to start your daily study session',
      isEnabled: _dailyReminder,
      onToggle: (v) => setState(() => _dailyReminder = v),
      child: _dailyReminder
          ? Padding(
              padding: const EdgeInsets.only(top: 12),
              child: GestureDetector(
                onTap: _pickTime,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Reminder Time',
                          style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w500)),
                      Text(
                        _reminderTime.format(context),
                        style: const TextStyle(
                            color: AppTheme.accent,
                            fontWeight: FontWeight.w700,
                            fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildTaskSection() {
    return _NotifCard(
      title: '📋 Task Deadline Reminders',
      subtitle: 'Get notified 24 hours before task deadlines',
      isEnabled: _taskReminders,
      onToggle: (v) => setState(() => _taskReminders = v),
    );
  }

  Widget _buildTimerSection() {
    return _NotifCard(
      title: '🍅 Timer Alerts',
      subtitle: 'Notifications when Pomodoro sessions and breaks end',
      isEnabled: _timerAlerts,
      onToggle: (v) => setState(() => _timerAlerts = v),
    );
  }

  Widget _buildStreakSection() {
    return _NotifCard(
      title: '🔥 Streak Reminders',
      subtitle: 'Evening reminder if you haven\'t studied today',
      isEnabled: _streakReminders,
      onToggle: (v) => setState(() => _streakReminders = v),
    );
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppTheme.accent),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _reminderTime = picked);
  }

  Future<void> _saveSettings() async {
    await _notificationService.cancelAll();
    if (_dailyReminder) {
      await _notificationService.scheduleDailyReminder(
        hour: _reminderTime.hour,
        minute: _reminderTime.minute,
      );
    }
    if (mounted) AppSnackbar.success(context, 'Notification settings saved!');
    if (mounted) Navigator.pop(context);
  }
}

class _NotifCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isEnabled;
  final ValueChanged<bool> onToggle;
  final Widget? child;

  const _NotifCard({
    required this.title,
    required this.subtitle,
    required this.isEnabled,
    required this.onToggle,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEnabled
              ? AppTheme.accent.withValues(alpha: 0.3)
              : AppTheme.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              Switch(
                value: isEnabled,
                onChanged: onToggle,
                activeThumbColor: AppTheme.accent,
              ),
            ],
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}