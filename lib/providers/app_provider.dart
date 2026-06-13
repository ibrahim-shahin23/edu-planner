// lib/providers/app_provider.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';

class AppProvider extends ChangeNotifier {
  static const _uuid = Uuid();

  // ── Profile ─────────────────────────────────────────
  UserProfile _profile = UserProfile();
  UserProfile get profile => _profile;

  // ── Tasks ────────────────────────────────────────────
  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;
  List<Task> get pending   => _tasks.where((t) => !t.done).toList()
    ..sort((a, b) => a.deadline.compareTo(b.deadline));
  List<Task> get completed => _tasks.where((t) => t.done).toList();

  // ── Sessions ─────────────────────────────────────────
  List<StudySession> _sessions = [];
  List<StudySession> get sessions => _sessions;

  // ── Achievements ─────────────────────────────────────
  final List<Achievement> _achievements = List.from(kAchievements.map((a) =>
      Achievement(id: a.id, title: a.title, description: a.description,
                  icon: a.icon, color: a.color)));
  List<Achievement> get achievements => _achievements;
  Achievement? _newlyUnlocked;
  Achievement? get newlyUnlocked => _newlyUnlocked;
  void clearNewlyUnlocked() { _newlyUnlocked = null; }

  // ── Timer ─────────────────────────────────────────────
  PomodoroSettings _settings = PomodoroSettings();
  PomodoroSettings get settings => _settings;

  TimerPhase _phase = TimerPhase.idle;
  TimerPhase get phase => _phase;

  Timer? _ticker;
  int _secsLeft = 0;
  int get secsLeft => _secsLeft;

  bool _running = false;
  bool get running => _running;

  int _sessionsDone = 0;
  int get sessionsDone => _sessionsDone;

  String _subject = 'General';
  String get subject => _subject;
  set subject(String v) { _subject = v; notifyListeners(); }

  // ── Daily progress ────────────────────────────────────
  int get todayMins {
    final now = DateTime.now();
    return _sessions
        .where((s) => s.date.year == now.year &&
                      s.date.month == now.month &&
                      s.date.day == now.day)
        .fold(0, (sum, s) => sum + s.minutes);
  }
  double get dailyProgress => (todayMins / _profile.dailyGoalMins).clamp(0.0, 1.0);

  // ── Weekly hours ──────────────────────────────────────
  List<double> get weeklyHours {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final mins = _sessions.where((s) =>
          s.date.year == day.year &&
          s.date.month == day.month &&
          s.date.day == day.day)
          .fold(0, (sum, s) => sum + s.minutes);
      return mins / 60.0;
    });
  }

  // ── Init ──────────────────────────────────────────────
  Future<void> init() async {
    await _load();
    _secsLeft = _settings.studyMins * 60;
    _checkStreak();
  }

  // ── Timer controls ────────────────────────────────────
  void startTimer() {
    if (_phase == TimerPhase.idle) {
      _phase = TimerPhase.study;
      _secsLeft = _settings.studyMins * 60;
    }
    _running = true;
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), _tick);
    notifyListeners();
  }

  void pauseTimer() {
    _ticker?.cancel();
    _running = false;
    notifyListeners();
  }

  void resetTimer() {
    _ticker?.cancel();
    _running = false;
    _phase = TimerPhase.idle;
    _secsLeft = _settings.studyMins * 60;
    notifyListeners();
  }

  void skipPhase() {
    _ticker?.cancel();
    _running = false;
    if (_phase == TimerPhase.study) {
      _finishStudy();
    } else {
      _phase = TimerPhase.idle;
      _secsLeft = _settings.studyMins * 60;
    }
    notifyListeners();
  }

  void _tick(Timer t) {
    if (_secsLeft > 0) {
      _secsLeft--;
      notifyListeners();
    } else {
      t.cancel();
      _running = false;
      if (_phase == TimerPhase.study) {
        _finishStudy();
      } else {
        _phase = TimerPhase.idle;
        _secsLeft = _settings.studyMins * 60;
      }
      notifyListeners();
    }
  }

  void _finishStudy() {
    _sessionsDone++;
    _recordSession(_settings.studyMins);
    _addPoints(25);
    final isLong = _sessionsDone % _settings.sessionsUntilLong == 0;
    _phase = isLong ? TimerPhase.longBreak : TimerPhase.shortBreak;
    _secsLeft = isLong ? _settings.longBreakMins * 60 : _settings.shortBreakMins * 60;
    if (_settings.autoStartBreaks) {
      _running = true;
      _ticker = Timer.periodic(const Duration(seconds: 1), _tick);
    }
  }

  void updateSettings(PomodoroSettings s) {
    _settings = s;
    if (_phase == TimerPhase.idle) _secsLeft = s.studyMins * 60;
    _save();
    notifyListeners();
  }

  // ── Tasks ─────────────────────────────────────────────
  void addTask(Task t) {
    _tasks.add(t);
    _save();
    notifyListeners();
  }

  void updateTask(Task t) {
    final i = _tasks.indexWhere((x) => x.id == t.id);
    if (i != -1) { _tasks[i] = t; _save(); notifyListeners(); }
  }

  void toggleTask(String id) {
    final i = _tasks.indexWhere((t) => t.id == id);
    if (i == -1) return;
    _tasks[i].done = !_tasks[i].done;
    if (_tasks[i].done) {
      _profile.totalTasks++;
      _addPoints(20);
      _checkAll();
    }
    _save();
    notifyListeners();
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    _save();
    notifyListeners();
  }

  String newId() => _uuid.v4();

  // ── Profile ───────────────────────────────────────────
  void updateProfile({String? name, String? avatar, int? dailyGoalMins}) {
    if (name != null) _profile.name = name;
    if (avatar != null) _profile.avatar = avatar;
    if (dailyGoalMins != null) _profile.dailyGoalMins = dailyGoalMins;
    _save();
    notifyListeners();
  }

  // ── Points & levels ───────────────────────────────────
  void _addPoints(int pts) {
    _profile.points += pts;
    final newLevel = (_profile.points / 500).floor() + 1;
    if (newLevel > _profile.level) _profile.level = newLevel;
    _checkAll();
    _save();
    notifyListeners();
  }

  // ── Streak ────────────────────────────────────────────
  void _checkStreak() {
    final now = DateTime.now();
    final today   = DateTime(now.year, now.month, now.day);
    final lastDay = DateTime(_profile.lastStudyDate.year,
                             _profile.lastStudyDate.month,
                             _profile.lastStudyDate.day);
    final diff = today.difference(lastDay).inDays;
    if (diff == 1) {
      _profile.streak++;
      if (_profile.streak > _profile.bestStreak) _profile.bestStreak = _profile.streak;
      _profile.lastStudyDate = now;
    } else if (diff > 1) {
      _profile.streak = 1;
      _profile.lastStudyDate = now;
    }
    _checkAll();
  }

  // ── Session recording ─────────────────────────────────
  void _recordSession(int mins) {
    _sessions.add(StudySession(
      id: _uuid.v4(),
      date: DateTime.now(),
      minutes: mins,
      subject: _subject,
      pomodoros: 1,
    ));
    _profile.totalMinutes += mins;
    _profile.totalPomodoros++;
    _checkStreak();
    _checkAll();
    _save();
  }

  // ── Achievement checks ────────────────────────────────
  void _checkAll() {
    _check('first_session',  _profile.totalPomodoros >= 1);
    _check('pomodoro_5',     _profile.totalPomodoros >= 5);
    _check('pomodoro_25',    _profile.totalPomodoros >= 25);
    _check('streak_3',       _profile.streak >= 3);
    _check('streak_7',       _profile.streak >= 7);
    _check('tasks_10',       _profile.totalTasks >= 10);
    _check('tasks_50',       _profile.totalTasks >= 50);
    _check('hours_10',       _profile.totalMinutes >= 600);
    _check('hours_50',       _profile.totalMinutes >= 3000);
    _check('level_5',        _profile.level >= 5);
    _check('level_10',       _profile.level >= 10);
    _check('points_1000',    _profile.points >= 1000);
  }

  void _check(String id, bool condition) {
    if (!condition) return;
    final i = _achievements.indexWhere((a) => a.id == id);
    if (i != -1 && !_achievements[i].unlocked) {
      _achievements[i].unlocked = true;
      _achievements[i].unlockedAt = DateTime.now();
      _newlyUnlocked = _achievements[i];
      if (!_profile.unlockedIds.contains(id)) _profile.unlockedIds.add(id);
      _save();
      notifyListeners();
    }
  }

  // ── Persistence ───────────────────────────────────────
  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('profile',  jsonEncode(_profile.toJson()));
    await p.setString('tasks',    jsonEncode(_tasks.map((t) => t.toJson()).toList()));
    await p.setString('sessions', jsonEncode(_sessions.map((s) => s.toJson()).toList()));
    await p.setString('settings', jsonEncode(_settings.toJson()));
    await p.setInt('sessionsDone', _sessionsDone);
    // achievement unlock states
    final Map<String, dynamic> achMap = {};
    for (final a in _achievements) {
      achMap[a.id] = {'unlocked': a.unlocked, 'at': a.unlockedAt?.toIso8601String()};
    }
    await p.setString('achievements', jsonEncode(achMap));
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();

    final prof = p.getString('profile');
    if (prof != null) _profile = UserProfile.fromJson(jsonDecode(prof));

    final tasks = p.getString('tasks');
    if (tasks != null) {
      _tasks = (jsonDecode(tasks) as List).map((j) => Task.fromJson(j)).toList();
    }

    final sess = p.getString('sessions');
    if (sess != null) {
      _sessions = (jsonDecode(sess) as List).map((j) => StudySession.fromJson(j)).toList();
    }

    final sett = p.getString('settings');
    if (sett != null) _settings = PomodoroSettings.fromJson(jsonDecode(sett));

    _sessionsDone = p.getInt('sessionsDone') ?? 0;

    final ach = p.getString('achievements');
    if (ach != null) {
      final Map<String, dynamic> achMap = jsonDecode(ach);
      for (final a in _achievements) {
        if (achMap.containsKey(a.id)) {
          a.unlocked = achMap[a.id]['unlocked'] ?? false;
          final at = achMap[a.id]['at'];
          if (at != null) a.unlockedAt = DateTime.parse(at);
        }
      }
    }

    _secsLeft = _settings.studyMins * 60;
    notifyListeners();
  }
}
