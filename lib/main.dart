// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/app_provider.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'screens/main_shell.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparent status bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0F2D4A),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Init notifications
  final notifService = NotificationService();
  await notifService.init();
  await notifService.requestPermissions();

  // Check onboarding
  final prefs = await SharedPreferences.getInstance();
  final onboardingDone = prefs.getBool('onboarding_complete') ?? false;

  runApp(EduPlannerApp(showOnboarding: !onboardingDone));
}

class EduPlannerApp extends StatelessWidget {
  final bool showOnboarding;
  const EduPlannerApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider()..init(),
      child: MaterialApp(
        title: 'Edu Planner',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: showOnboarding
            ? _OnboardingGate()
            : const MainShell(),
      ),
    );
  }
}

/// Shows onboarding then transitions to MainShell, persisting the flag.
class _OnboardingGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OnboardingScreen(
      onComplete: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('onboarding_complete', true);
        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const MainShell(),
              transitionsBuilder: (_, anim, __, child) => FadeTransition(
                opacity: anim,
                child: child,
              ),
              transitionDuration: const Duration(milliseconds: 600),
            ),
          );
        }
      },
    );
  }
}