// lib/services/notification_service.dart
import 'dart:ui' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(settings,
        onDidReceiveNotificationResponse: _onTap);
    _initialized = true;
  }

  void _onTap(NotificationResponse response) {}

  Future<void> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> showTimerComplete({required bool isBreak}) async {
    await _plugin.show(
      1,
      isBreak ? '☕ Break Time!' : '🍅 Pomodoro Complete!',
      isBreak ? 'Great job! Time to recharge.' : 'Session done! Take a break.',
      _details(channelId: 'timer', channelName: 'Timer'),
    );
  }

  Future<void> showTaskReminder(String taskTitle, String deadline) async {
    await _plugin.show(2, '📋 Task Due Soon!', '$taskTitle — due $deadline',
        _details(channelId: 'tasks', channelName: 'Tasks'));
  }

  Future<void> showStreakReminder(int streak) async {
    await _plugin.show(3, '🔥 Keep Your Streak!',
        "You're on a $streak-day streak — don't break the chain!",
        _details(channelId: 'streak', channelName: 'Streaks'));
  }

  Future<void> showAchievementUnlocked(String title, String icon) async {
    await _plugin.show(4, '$icon Achievement Unlocked!', title,
        _details(channelId: 'achievements', channelName: 'Achievements'));
  }

  Future<void> scheduleDailyReminder({required int hour, required int minute}) async {
    await _plugin.zonedSchedule(
      10,
      '📚 Time to Study!',
      'Your daily study session awaits. Keep building great habits!',
      _nextInstance(hour, minute),
      _details(channelId: 'daily', channelName: 'Daily Reminder'),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleTaskReminder({
    required int notificationId,
    required String taskTitle,
    required DateTime deadline,
  }) async {
    final remind = deadline.subtract(const Duration(hours: 24));
    if (remind.isBefore(DateTime.now())) return;
    await _plugin.zonedSchedule(
      notificationId.hashCode & 0x7FFFFFFF,
      '⚠️ Task Due Tomorrow!',
      taskTitle,
      tz.TZDateTime.from(remind, tz.local),
      _details(channelId: 'tasks', channelName: 'Tasks'),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelAll() async => _plugin.cancelAll();
  Future<void> cancel(int id) async => _plugin.cancel(id);

  tz.TZDateTime _nextInstance(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var t = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (t.isBefore(now)) t = t.add(const Duration(days: 1));
    return t;
  }

  NotificationDetails _details({required String channelId, required String channelName}) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId, channelName,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: const Color(0xFF00D4AA),
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }
}