// lib/models/models.dart
import 'package:flutter/material.dart';

// ── Task ─────────────────────────────────────────────────────
enum Priority { low, medium, high, urgent }

class Task {
  final String id;
  String title;
  String description;
  Priority priority;
  DateTime deadline;
  String subject;
  bool done;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.priority = Priority.medium,
    required this.deadline,
    this.subject = 'General',
    this.done = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Color get priorityColor {
    switch (priority) {
      case Priority.low:    return const Color(0xFF22C55E);
      case Priority.medium: return const Color(0xFF3B82F6);
      case Priority.high:   return const Color(0xFFF97316);
      case Priority.urgent: return const Color(0xFFEF4444);
    }
  }

  String get priorityLabel {
    switch (priority) {
      case Priority.low:    return 'Low';
      case Priority.medium: return 'Medium';
      case Priority.high:   return 'High';
      case Priority.urgent: return 'Urgent';
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'description': description,
    'priority': priority.index, 'deadline': deadline.toIso8601String(),
    'subject': subject, 'done': done,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Task.fromJson(Map<String, dynamic> j) => Task(
    id: j['id'], title: j['title'],
    description: j['description'] ?? '',
    priority: Priority.values[j['priority'] ?? 1],
    deadline: DateTime.parse(j['deadline']),
    subject: j['subject'] ?? 'General',
    done: j['done'] ?? false,
    createdAt: DateTime.parse(j['createdAt'] ?? DateTime.now().toIso8601String()),
  );
}

// ── Study Session ─────────────────────────────────────────────
class StudySession {
  final String id;
  final DateTime date;
  final int minutes;
  final String subject;
  final int pomodoros;

  StudySession({
    required this.id,
    required this.date,
    required this.minutes,
    required this.subject,
    this.pomodoros = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'date': date.toIso8601String(),
    'minutes': minutes, 'subject': subject, 'pomodoros': pomodoros,
  };

  factory StudySession.fromJson(Map<String, dynamic> j) => StudySession(
    id: j['id'], date: DateTime.parse(j['date']),
    minutes: j['minutes'], subject: j['subject'],
    pomodoros: j['pomodoros'] ?? 0,
  );
}

// ── Pomodoro Settings ─────────────────────────────────────────
class PomodoroSettings {
  int studyMins;
  int shortBreakMins;
  int longBreakMins;
  int sessionsUntilLong;
  bool autoStartBreaks;

  PomodoroSettings({
    this.studyMins = 25,
    this.shortBreakMins = 5,
    this.longBreakMins = 15,
    this.sessionsUntilLong = 4,
    this.autoStartBreaks = false,
  });

  Map<String, dynamic> toJson() => {
    'studyMins': studyMins, 'shortBreakMins': shortBreakMins,
    'longBreakMins': longBreakMins, 'sessionsUntilLong': sessionsUntilLong,
    'autoStartBreaks': autoStartBreaks,
  };

  factory PomodoroSettings.fromJson(Map<String, dynamic> j) => PomodoroSettings(
    studyMins: j['studyMins'] ?? 25,
    shortBreakMins: j['shortBreakMins'] ?? 5,
    longBreakMins: j['longBreakMins'] ?? 15,
    sessionsUntilLong: j['sessionsUntilLong'] ?? 4,
    autoStartBreaks: j['autoStartBreaks'] ?? false,
  );
}

// ── User Profile ──────────────────────────────────────────────
class UserProfile {
  String name;
  String avatar;
  int points;
  int level;
  int streak;
  int bestStreak;
  int totalMinutes;
  int totalTasks;
  int totalPomodoros;
  int dailyGoalMins;
  DateTime lastStudyDate;
  List<String> unlockedIds;

  UserProfile({
    this.name = 'Student',
    this.avatar = '🎓',
    this.points = 0,
    this.level = 1,
    this.streak = 0,
    this.bestStreak = 0,
    this.totalMinutes = 0,
    this.totalTasks = 0,
    this.totalPomodoros = 0,
    this.dailyGoalMins = 120,
    DateTime? lastStudyDate,
    List<String>? unlockedIds,
  })  : lastStudyDate = lastStudyDate ?? DateTime(2000),
        unlockedIds = unlockedIds ?? [];

  int get xpForNextLevel => level * 500;
  int get currentXP => points % (level * 500);
  double get xpProgress => (currentXP / xpForNextLevel).clamp(0.0, 1.0);

  String get levelTitle {
    if (level < 3)  return 'Beginner';
    if (level < 6)  return 'Learner';
    if (level < 10) return 'Scholar';
    if (level < 15) return 'Expert';
    return 'Master';
  }

  Map<String, dynamic> toJson() => {
    'name': name, 'avatar': avatar, 'points': points, 'level': level,
    'streak': streak, 'bestStreak': bestStreak,
    'totalMinutes': totalMinutes, 'totalTasks': totalTasks,
    'totalPomodoros': totalPomodoros, 'dailyGoalMins': dailyGoalMins,
    'lastStudyDate': lastStudyDate.toIso8601String(),
    'unlockedIds': unlockedIds,
  };

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
    name: j['name'] ?? 'Student', avatar: j['avatar'] ?? '🎓',
    points: j['points'] ?? 0, level: j['level'] ?? 1,
    streak: j['streak'] ?? 0, bestStreak: j['bestStreak'] ?? 0,
    totalMinutes: j['totalMinutes'] ?? 0, totalTasks: j['totalTasks'] ?? 0,
    totalPomodoros: j['totalPomodoros'] ?? 0,
    dailyGoalMins: j['dailyGoalMins'] ?? 120,
    lastStudyDate: DateTime.parse(j['lastStudyDate'] ?? '2000-01-01'),
    unlockedIds: List<String>.from(j['unlockedIds'] ?? []),
  );
}

// ── Achievement ───────────────────────────────────────────────
class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final Color color;
  bool unlocked;
  DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.unlocked = false,
    this.unlockedAt,
  });
}

final List<Achievement> kAchievements = [
  Achievement(id: 'first_session',  title: 'First Step',      description: 'Complete your first study session',  icon: '🌱', color: Color(0xFF22C55E)),
  Achievement(id: 'pomodoro_5',     title: 'Focus Starter',   description: 'Complete 5 Pomodoro sessions',        icon: '🍅', color: Color(0xFFF97316)),
  Achievement(id: 'pomodoro_25',    title: 'Tomato Master',   description: 'Complete 25 Pomodoro sessions',       icon: '🔴', color: Color(0xFFEF4444)),
  Achievement(id: 'streak_3',       title: 'Consistent',      description: 'Study 3 days in a row',               icon: '🔥', color: Color(0xFFF97316)),
  Achievement(id: 'streak_7',       title: 'Week Warrior',    description: 'Study 7 days in a row',               icon: '⚡', color: Color(0xFFEAB308)),
  Achievement(id: 'tasks_10',       title: 'Task Slayer',     description: 'Complete 10 tasks',                   icon: '✅', color: Color(0xFF22C55E)),
  Achievement(id: 'tasks_50',       title: 'Task Machine',    description: 'Complete 50 tasks',                   icon: '🎯', color: Color(0xFF3B82F6)),
  Achievement(id: 'hours_10',       title: 'Dedicated',       description: 'Study for 10 total hours',            icon: '📚', color: Color(0xFF8B5CF6)),
  Achievement(id: 'hours_50',       title: 'Scholar',         description: 'Study for 50 total hours',            icon: '🎓', color: Color(0xFF8B5CF6)),
  Achievement(id: 'level_5',        title: 'Rising Star',     description: 'Reach Level 5',                       icon: '⭐', color: Color(0xFFEAB308)),
  Achievement(id: 'level_10',       title: 'Expert Mind',     description: 'Reach Level 10',                      icon: '👑', color: Color(0xFFEAB308)),
  Achievement(id: 'points_1000',    title: 'Point Collector', description: 'Earn 1,000 total points',             icon: '💎', color: Color(0xFF3B82F6)),
];

// ── Timer Phase ───────────────────────────────────────────────
enum TimerPhase { idle, study, shortBreak, longBreak }
