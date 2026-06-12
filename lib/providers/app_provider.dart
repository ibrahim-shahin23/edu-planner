// lib/providers/app_provider.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../models/achievements_data.dart';
import '../services/notification_service.dart';

class AppProvider extends ChangeNotifier {
  final _uuid = const Uuid();

  // ─── User Data ─────────────────────────────────────────────
  UserProfile _profile = UserProfile();
  UserProfile get profile => _profile;

  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;
  List<Task> get pendingTasks => _tasks.where((t) => !t.isCompleted).toList()
    ..sort((a, b) => a.deadline.compareTo(b.deadline));
  List<Task> get completedTasks => _tasks.where((t) => t.isCompleted).toList();

  List<StudySession> _sessions = [];
  List<StudySession> get sessions => _sessions;

  final List<Achievement> _achievements = allAchievements.map((a) => Achievement(
    id: a.id, title: a.title, description: a.description,
    icon: a.icon, pointsRequired: a.pointsRequired,
  )).toList();
  List<Achievement> get achievements => _achievements;
  List<Achievement> get unlockedAchievements =>
      _achievements.where((a) => a.isUnlocked).toList();

  // ─── Timer State ────────────────────────────────────────────
  PomodoroSettings _pomodoroSettings = PomodoroSettings();
  PomodoroSettings get pomodoroSettings => _pomodoroSettings;

  TimerState _timerState = TimerState.idle;
  TimerState get timerState => _timerState;

  Timer? _timer;
  int _secondsRemaining = 0;
  int get secondsRemaining => _secondsRemaining;

  int _completedPomodoros = 0;
  int get completedPomodoros => _completedPomodoros;

  bool _isTimerRunning = false;
  bool get isTimerRunning => _isTimerRunning;

  String _currentTimerSubject = 'General';
  String get currentTimerSubject => _currentTimerSubject;
  set currentTimerSubject(String v) { _currentTimerSubject = v; notifyListeners(); }

  // ─── Focus Mode ─────────────────────────────────────────────
  bool _isFocusMode = false;
  bool get isFocusMode => _isFocusMode;
  int _focusModeUsageCount = 0;

  // ─── Daily Goal ──────────────────────────────────────────────
  int get todayStudyMinutes {
    final today = DateTime.now();
    return _sessions
        .where((s) => s.date.year == today.year &&
            s.date.month == today.month &&
            s.date.day == today.day)
        .fold(0, (sum, s) => sum + s.durationMinutes);
  }

  double get dailyGoalProgress =>
      (todayStudyMinutes / _profile.dailyGoalMinutes).clamp(0.0, 1.0);

  // ─── Weekly Data ─────────────────────────────────────────────
  List<double> get weeklyStudyHours {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final mins = _sessions
          .where((s) => s.date.year == day.year &&
              s.date.month == day.month &&
              s.date.day == day.day)
          .fold(0, (sum, s) => sum + s.durationMinutes);
      return mins / 60.0;
    });
  }

  // ─── Init ────────────────────────────────────────────────────
  Future<void> init() async {
    await _loadData();
    _checkStreak();
    _secondsRemaining = _pomodoroSettings.studyMinutes * 60;
  }

  // ─── Timer Controls ──────────────────────────────────────────
  void startTimer() {
    if (_timerState == TimerState.idle) {
      _timerState = TimerState.studying;
      _secondsRemaining = _pomodoroSettings.studyMinutes * 60;
    }
    _isTimerRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
    notifyListeners();
  }

  void pauseTimer() {
    _timer?.cancel();
    _isTimerRunning = false;
    notifyListeners();
  }

  void resetTimer() {
    _timer?.cancel();
    _isTimerRunning = false;
    _timerState = TimerState.idle;
    _secondsRemaining = _pomodoroSettings.studyMinutes * 60;
    notifyListeners();
  }

  void skipToBreak() {
    _timer?.cancel();
    _isTimerRunning = false;
    _completePomodoroSession();
  }

  void _onTick(Timer t) {
    if (_secondsRemaining > 0) {
      _secondsRemaining--;
      notifyListeners();
    } else {
      _timer?.cancel();
      _isTimerRunning = false;
      _onTimerComplete();
    }
  }

  void _onTimerComplete() {
    if (_timerState == TimerState.studying) {
      _completePomodoroSession();
    } else {
      // Break done → back to idle
      _timerState = TimerState.idle;
      _secondsRemaining = _pomodoroSettings.studyMinutes * 60;
      if (_pomodoroSettings.autoStartPomodoros) startTimer();
    }
    notifyListeners();
  }

  void _completePomodoroSession() {
    _completedPomodoros++;
    final studiedMinutes = _pomodoroSettings.studyMinutes;
    _recordSession(studiedMinutes);
    _addPoints(25);

    final isLong = _completedPomodoros % _pomodoroSettings.sessionsBeforeLongBreak == 0;
    if (isLong) {
      _timerState = TimerState.longBreak;
      _secondsRemaining = _pomodoroSettings.longBreakMinutes * 60;
    } else {
      _timerState = TimerState.shortBreak;
      _secondsRemaining = _pomodoroSettings.shortBreakMinutes * 60;
    }

    NotificationService().showTimerComplete(isBreak: true);

    if (_pomodoroSettings.autoStartBreaks) {
      _isTimerRunning = true;
      _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
    }
    notifyListeners();
  }

  void updatePomodoroSettings(PomodoroSettings settings) {
    _pomodoroSettings = settings;
    if (_timerState == TimerState.idle) {
      _secondsRemaining = settings.studyMinutes * 60;
    }
    _saveData();
    notifyListeners();
  }

  // ─── Focus Mode ──────────────────────────────────────────────
  void toggleFocusMode() {
    _isFocusMode = !_isFocusMode;
    if (_isFocusMode) {
      _focusModeUsageCount++;
      _checkAchievement('focus_mode', _focusModeUsageCount >= 10);
    }
    notifyListeners();
  }

  // ─── Task Management ─────────────────────────────────────────
  void addTask(Task task) {
    _tasks.add(task);
    _saveData();
    notifyListeners();
  }

  void updateTask(Task task) {
    final idx = _tasks.indexWhere((t) => t.id == task.id);
    if (idx != -1) {
      _tasks[idx] = task;
      _saveData();
      notifyListeners();
    }
  }

  void toggleTaskComplete(String taskId) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      _tasks[idx].isCompleted = !_tasks[idx].isCompleted;
      if (_tasks[idx].isCompleted) {
        _profile.totalTasksCompleted++;
        _addPoints(20);
        _checkAchievements();
      }
      _saveData();
      notifyListeners();
    }
  }

  void deleteTask(String taskId) {
    _tasks.removeWhere((t) => t.id == taskId);
    _saveData();
    notifyListeners();
  }

  String generateId() => _uuid.v4();

  // ─── Session Recording ───────────────────────────────────────
  void _recordSession(int minutes) {
    final session = StudySession(
      id: _uuid.v4(),
      date: DateTime.now(),
      durationMinutes: minutes,
      subject: _currentTimerSubject,
      pomodorosCompleted: 1,
    );
    _sessions.add(session);
    _profile.totalStudyMinutes += minutes;
    _profile.totalPomodoros++;
    _checkStreak();
    _checkAchievements();
    _saveData();
  }

  void addManualSession(int minutes, String subject) {
    final session = StudySession(
      id: _uuid.v4(),
      date: DateTime.now(),
      durationMinutes: minutes,
      subject: subject,
    );
    _sessions.add(session);
    _profile.totalStudyMinutes += minutes;
    _addPoints((minutes / 5).round());
    _checkAchievements();
    _saveData();
    notifyListeners();
  }

  // ─── Points & Leveling ───────────────────────────────────────
  void _addPoints(int points) {
    _profile.totalPoints += points;
    final newLevel = (_profile.totalPoints / 500).floor() + 1;
    if (newLevel > _profile.level) {
      _profile.level = newLevel;
      _checkAchievement('level_5', _profile.level >= 5);
    }
    _saveData();
    notifyListeners();
  }

  // ─── Streak Logic ────────────────────────────────────────────
  void _checkStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastStudy = DateTime(
      _profile.lastStudyDate.year,
      _profile.lastStudyDate.month,
      _profile.lastStudyDate.day,
    );
    final diff = today.difference(lastStudy).inDays;

    if (diff == 0) {
      // Same day, already counted
    } else if (diff == 1) {
      _profile.currentStreak++;
      if (_profile.currentStreak > _profile.longestStreak) {
        _profile.longestStreak = _profile.currentStreak;
      }
      _profile.lastStudyDate = now;
    } else if (diff > 1) {
      _profile.currentStreak = 1;
      _profile.lastStudyDate = now;
    }

    _checkAchievement('streak_3', _profile.currentStreak >= 3);
    _checkAchievement('streak_7', _profile.currentStreak >= 7);
    _checkAchievement('streak_30', _profile.currentStreak >= 30);
  }

  // ─── Achievement Checks ──────────────────────────────────────
  void _checkAchievements() {
    _checkAchievement('first_session', _profile.totalPomodoros >= 1 || _sessions.isNotEmpty);
    _checkAchievement('pomodoro_5', _profile.totalPomodoros >= 5);
    _checkAchievement('pomodoro_25', _profile.totalPomodoros >= 25);
    _checkAchievement('tasks_10', _profile.totalTasksCompleted >= 10);
    _checkAchievement('tasks_50', _profile.totalTasksCompleted >= 50);
    _checkAchievement('hours_10', _profile.totalStudyMinutes >= 600);
    _checkAchievement('hours_50', _profile.totalStudyMinutes >= 3000);
  }

  void _checkAchievement(String id, bool condition) {
    if (!condition) return;
    final idx = _achievements.indexWhere((a) => a.id == id);
    if (idx != -1 && !_achievements[idx].isUnlocked) {
      _achievements[idx].isUnlocked = true;
      _achievements[idx].unlockedAt = DateTime.now();
      if (!_profile.unlockedAchievements.contains(id)) {
        _profile.unlockedAchievements.add(id);
      }
      NotificationService().showAchievementUnlocked(
        _achievements[idx].title,
        _achievements[idx].icon,
      );
      _saveData();
      notifyListeners();
    }
  }

  // ─── Profile Update ──────────────────────────────────────────
  void updateProfile({String? name, String? avatar, int? dailyGoalMinutes}) {
    if (name != null) _profile.name = name;
    if (avatar != null) _profile.avatar = avatar;
    if (dailyGoalMinutes != null) _profile.dailyGoalMinutes = dailyGoalMinutes;
    _saveData();
    notifyListeners();
  }

  // ─── Persistence ─────────────────────────────────────────────
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('profile', jsonEncode(_profile.toJson()));
    prefs.setString('tasks', jsonEncode(_tasks.map((t) => t.toJson()).toList()));
    prefs.setString('sessions', jsonEncode(_sessions.map((s) => s.toJson()).toList()));
    prefs.setString('pomodoroSettings', jsonEncode(_pomodoroSettings.toJson()));
    prefs.setInt('focusModeCount', _focusModeUsageCount);
    prefs.setInt('completedPomodoros', _completedPomodoros);
    // Save achievement unlock state
    final achData = {};
    for (final a in _achievements) {
      achData[a.id] = {'isUnlocked': a.isUnlocked, 'unlockedAt': a.unlockedAt?.toIso8601String()};
    }
    prefs.setString('achievements', jsonEncode(achData));
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final profileStr = prefs.getString('profile');
    if (profileStr != null) {
      _profile = UserProfile.fromJson(jsonDecode(profileStr));
    }

    final tasksStr = prefs.getString('tasks');
    if (tasksStr != null) {
      _tasks = (jsonDecode(tasksStr) as List).map((j) => Task.fromJson(j)).toList();
    }

    final sessionsStr = prefs.getString('sessions');
    if (sessionsStr != null) {
      _sessions = (jsonDecode(sessionsStr) as List).map((j) => StudySession.fromJson(j)).toList();
    }

    final settingsStr = prefs.getString('pomodoroSettings');
    if (settingsStr != null) {
      _pomodoroSettings = PomodoroSettings.fromJson(jsonDecode(settingsStr));
    }

    _focusModeUsageCount = prefs.getInt('focusModeCount') ?? 0;
    _completedPomodoros = prefs.getInt('completedPomodoros') ?? 0;

    final achStr = prefs.getString('achievements');
    if (achStr != null) {
      final achData = jsonDecode(achStr) as Map;
      for (final a in _achievements) {
        if (achData.containsKey(a.id)) {
          a.isUnlocked = achData[a.id]['isUnlocked'] ?? false;
          final unlockedAt = achData[a.id]['unlockedAt'];
          if (unlockedAt != null) a.unlockedAt = DateTime.parse(unlockedAt);
        }
      }
    }

    _secondsRemaining = _pomodoroSettings.studyMinutes * 60;
    notifyListeners();
  }
}