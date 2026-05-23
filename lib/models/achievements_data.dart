// lib/models/achievements_data.dart
import 'models.dart';

final List<Achievement> allAchievements = [
  Achievement(
    id: 'first_session',
    title: 'First Step',
    description: 'Complete your first study session',
    icon: '🌱',
    pointsRequired: 0,
  ),
  Achievement(
    id: 'pomodoro_5',
    title: 'Focus Starter',
    description: 'Complete 5 Pomodoro sessions',
    icon: '🍅',
    pointsRequired: 50,
  ),
  Achievement(
    id: 'pomodoro_25',
    title: 'Tomato Master',
    description: 'Complete 25 Pomodoro sessions',
    icon: '🔴',
    pointsRequired: 250,
  ),
  Achievement(
    id: 'streak_3',
    title: 'Consistent',
    description: '3-day study streak',
    icon: '🔥',
    pointsRequired: 150,
  ),
  Achievement(
    id: 'streak_7',
    title: 'Week Warrior',
    description: '7-day study streak',
    icon: '⚡',
    pointsRequired: 350,
  ),
  Achievement(
    id: 'streak_30',
    title: 'Month Champion',
    description: '30-day study streak',
    icon: '👑',
    pointsRequired: 1500,
  ),
  Achievement(
    id: 'tasks_10',
    title: 'Task Slayer',
    description: 'Complete 10 tasks',
    icon: '✅',
    pointsRequired: 100,
  ),
  Achievement(
    id: 'tasks_50',
    title: 'Task Machine',
    description: 'Complete 50 tasks',
    icon: '🎯',
    pointsRequired: 500,
  ),
  Achievement(
    id: 'hours_10',
    title: 'Dedicated',
    description: 'Study for 10 hours total',
    icon: '📚',
    pointsRequired: 200,
  ),
  Achievement(
    id: 'hours_50',
    title: 'Scholar',
    description: 'Study for 50 hours total',
    icon: '🎓',
    pointsRequired: 1000,
  ),
  Achievement(
    id: 'level_5',
    title: 'Rising Star',
    description: 'Reach Level 5',
    icon: '⭐',
    pointsRequired: 2000,
  ),
  Achievement(
    id: 'focus_mode',
    title: 'Deep Focus',
    description: 'Use Focus Mode 10 times',
    icon: '🧘',
    pointsRequired: 300,
  ),
];