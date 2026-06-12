// lib/utils/utils.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ─── Time Formatters ───────────────────────────────────────────
class TimeUtils {
  static String formatSeconds(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  static String formatMinutes(int minutes) {
    if (minutes == 0) return '0m';
    if (minutes < 60) return '${minutes}m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m > 0 ? '${h}h ${m}m' : '${h}h';
  }

  static String formatHours(double hours) {
    if (hours < 1) return '${(hours * 60).round()}m';
    return '${hours.toStringAsFixed(1)}h';
  }

  static String relativeDate(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(DateTime(now.year, now.month, now.day));
    final days = diff.inDays;
    if (days < 0) return 'Overdue by ${-days}d';
    if (days == 0) return 'Today';
    if (days == 1) return 'Tomorrow';
    if (days < 7) return 'In $days days';
    return DateFormat('MMM d').format(date);
  }

  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(date);
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool isToday(DateTime date) => isSameDay(date, DateTime.now());
}

// ─── Validators ────────────────────────────────────────────────
class Validators {
  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? minLength(String? value, int min) {
    if (value != null && value.trim().length < min) {
      return 'Must be at least $min characters';
    }
    return null;
  }
}

// ─── App Constants ─────────────────────────────────────────────
class AppConstants {
  static const List<String> subjects = [
    'General', 'Mathematics', 'Science', 'History',
    'Language', 'Programming', 'Art', 'Music',
    'Geography', 'Literature', 'Physics', 'Chemistry',
    'Biology', 'Economics', 'Other',
  ];

  static const List<String> avatarEmojis = [
    '🎓', '📚', '🦉', '🚀', '⚡', '🌟', '🎯', '🦁',
    '🐺', '🦊', '🐻', '🐼', '🦅', '🌙', '☀️', '🔥',
    '💎', '🏆', '🎪', '🧩', '🎭', '🌺', '⚙️', '🎸',
  ];

  static const int defaultStudyMinutes = 25;
  static const int defaultShortBreak = 5;
  static const int defaultLongBreak = 15;
  static const int defaultDailyGoalMinutes = 120;

  static const int pointsPerPomodoro = 25;
  static const int pointsPerTask = 20;
  static const int pointsPerManualMinute = 1;

  static const Map<String, String> dayLabels = {
    'Mon': 'Monday', 'Tue': 'Tuesday', 'Wed': 'Wednesday',
    'Thu': 'Thursday', 'Fri': 'Friday', 'Sat': 'Saturday', 'Sun': 'Sunday',
  };
}

// ─── Snackbar Helper ───────────────────────────────────────────
class AppSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    bool isError = false,
    bool isSuccess = false,
    SnackBarAction? action,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        backgroundColor: isError
            ? const Color(0xFFFF4D6D)
            : isSuccess
                ? const Color(0xFF00C896)
                : const Color(0xFF1A3A5C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: Duration(seconds: isError ? 4 : 2),
        action: action,
      ),
    );
  }

  static void success(BuildContext context, String message) =>
      show(context, message: message, isSuccess: true);

  static void error(BuildContext context, String message) =>
      show(context, message: message, isError: true);
}

// ─── Navigation Helper ─────────────────────────────────────────
extension ContextExtensions on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  EdgeInsets get padding => MediaQuery.of(this).padding;
  ThemeData get theme => Theme.of(this);
  bool get isSmallScreen => screenWidth < 360;
}