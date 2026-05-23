// lib/models/models.dart
import 'package:flutter/material.dart';

// ─── Task Model ───────────────────────────────────────────────
enum TaskPriority { low, medium, high, urgent }
enum TaskStatus { pending, inProgress, completed }

class Task {
  final String id;
  String title;
  String description;
  TaskPriority priority;
  TaskStatus status;
  DateTime deadline;
  String subject;
  bool isCompleted;
  DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.pending,
    required this.deadline,
    this.subject = 'General',
    this.isCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'priority': priority.index,
    'status': status.index,
    'deadline': deadline.toIso8601String(),
    'subject': subject,
    'isCompleted': isCompleted,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'],
    title: json['title'],
    description: json['description'] ?? '',
    priority: TaskPriority.values[json['priority'] ?? 1],
    status: TaskStatus.values[json['status'] ?? 0],
    deadline: DateTime.parse(json['deadline']),
    subject: json['subject'] ?? 'General',
    isCompleted: json['isCompleted'] ?? false,
    createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
  );

  Color get priorityColor {
    switch (priority) {
      case TaskPriority.low: return const Color(0xFF00C896);
      case TaskPriority.medium: return const Color(0xFF00A3FF);
      case TaskPriority.high: return const Color(0xFFFFAA00);
      case TaskPriority.urgent: return const Color(0xFFFF4D6D);
    }
  }

  String get priorityLabel {
    switch (priority) {
      case TaskPriority.low: return 'Low';
      case TaskPriority.medium: return 'Medium';
      case TaskPriority.high: return 'High';
      case TaskPriority.urgent: return 'Urgent';
    }
  }
}

// ─── Study Session Model ───────────────────────────────────────
class StudySession {
  final String id;
  final DateTime date;
  final int durationMinutes;
  final String subject;
  final int pomodorosCompleted;

  StudySession({
    required this.id,
    required this.date,
    required this.durationMinutes,
    required this.subject,
    this.pomodorosCompleted = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'durationMinutes': durationMinutes,
    'subject': subject,
    'pomodorosCompleted': pomodorosCompleted,
  };

  factory StudySession.fromJson(Map<String, dynamic> json) => StudySession(
    id: json['id'],
    date: DateTime.parse(json['date']),
    durationMinutes: json['durationMinutes'],
    subject: json['subject'],
    pomodorosCompleted: json['pomodorosCompleted'] ?? 0,
  );
}

// ─── Achievement Model ─────────────────────────────────────────
class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int pointsRequired;
  bool isUnlocked;
  DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.pointsRequired,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'isUnlocked': isUnlocked,
    'unlockedAt': unlockedAt?.toIso8601String(),
  };
}

// ─── User Profile Model ────────────────────────────────────────
class UserProfile {
  String name;
  String avatar;
  int totalPoints;
  int currentStreak;
  int longestStreak;
  int level;
  int totalStudyMinutes;
  int totalTasksCompleted;
  int totalPomodoros;
  List<String> unlockedAchievements;
  DateTime lastStudyDate;
  int dailyGoalMinutes;

  UserProfile({
    this.name = 'Student',
    this.avatar = '🎓',
    this.totalPoints = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.level = 1,
    this.totalStudyMinutes = 0,
    this.totalTasksCompleted = 0,
    this.totalPomodoros = 0,
    this.unlockedAchievements = const [],
    DateTime? lastStudyDate,
    this.dailyGoalMinutes = 120,
  }) : lastStudyDate = lastStudyDate ?? DateTime.now().subtract(const Duration(days: 1));

  int get pointsForNextLevel => level * 500;
  int get currentLevelPoints => totalPoints % 500;
  double get levelProgress => currentLevelPoints / pointsForNextLevel;

  String get levelTitle {
    if (level < 3) return 'Beginner';
    if (level < 6) return 'Learner';
    if (level < 10) return 'Scholar';
    if (level < 15) return 'Expert';
    return 'Master';
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'avatar': avatar,
    'totalPoints': totalPoints,
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
    'level': level,
    'totalStudyMinutes': totalStudyMinutes,
    'totalTasksCompleted': totalTasksCompleted,
    'totalPomodoros': totalPomodoros,
    'unlockedAchievements': unlockedAchievements,
    'lastStudyDate': lastStudyDate.toIso8601String(),
    'dailyGoalMinutes': dailyGoalMinutes,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name'] ?? 'Student',
    avatar: json['avatar'] ?? '🎓',
    totalPoints: json['totalPoints'] ?? 0,
    currentStreak: json['currentStreak'] ?? 0,
    longestStreak: json['longestStreak'] ?? 0,
    level: json['level'] ?? 1,
    totalStudyMinutes: json['totalStudyMinutes'] ?? 0,
    totalTasksCompleted: json['totalTasksCompleted'] ?? 0,
    totalPomodoros: json['totalPomodoros'] ?? 0,
    unlockedAchievements: List<String>.from(json['unlockedAchievements'] ?? []),
    lastStudyDate: DateTime.parse(json['lastStudyDate'] ?? DateTime.now().subtract(const Duration(days: 1)).toIso8601String()),
    dailyGoalMinutes: json['dailyGoalMinutes'] ?? 120,
  );
}

// ─── Pomodoro Timer State ──────────────────────────────────────
enum TimerState { idle, studying, shortBreak, longBreak }

class PomodoroSettings {
  int studyMinutes;
  int shortBreakMinutes;
  int longBreakMinutes;
  int sessionsBeforeLongBreak;
  bool autoStartBreaks;
  bool autoStartPomodoros;

  PomodoroSettings({
    this.studyMinutes = 25,
    this.shortBreakMinutes = 5,
    this.longBreakMinutes = 15,
    this.sessionsBeforeLongBreak = 4,
    this.autoStartBreaks = false,
    this.autoStartPomodoros = false,
  });

  Map<String, dynamic> toJson() => {
    'studyMinutes': studyMinutes,
    'shortBreakMinutes': shortBreakMinutes,
    'longBreakMinutes': longBreakMinutes,
    'sessionsBeforeLongBreak': sessionsBeforeLongBreak,
    'autoStartBreaks': autoStartBreaks,
    'autoStartPomodoros': autoStartPomodoros,
  };

  factory PomodoroSettings.fromJson(Map<String, dynamic> json) => PomodoroSettings(
    studyMinutes: json['studyMinutes'] ?? 25,
    shortBreakMinutes: json['shortBreakMinutes'] ?? 5,
    longBreakMinutes: json['longBreakMinutes'] ?? 15,
    sessionsBeforeLongBreak: json['sessionsBeforeLongBreak'] ?? 4,
    autoStartBreaks: json['autoStartBreaks'] ?? false,
    autoStartPomodoros: json['autoStartPomodoros'] ?? false,
  );
}