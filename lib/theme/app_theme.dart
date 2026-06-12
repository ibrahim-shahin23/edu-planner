// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const bg         = Color(0xFF0A1628);
  static const surface    = Color(0xFF0F2044);
  static const card       = Color(0xFF162952);
  static const cardLight  = Color(0xFF1E3A6E);
  static const accent     = Color(0xFF00D9A3);
  static const accentBlue = Color(0xFF3B82F6);
  static const purple     = Color(0xFF8B5CF6);
  static const orange     = Color(0xFFF97316);
  static const yellow     = Color(0xFFEAB308);
  static const red        = Color(0xFFEF4444);
  static const green      = Color(0xFF22C55E);
  static const textPrimary   = Color(0xFFE2E8F0);
  static const textSecondary = Color(0xFF64748B);
  static const textMuted     = Color(0xFF334155);
  static const divider       = Color(0xFF1E3A6E);

  static const gradientAccent = LinearGradient(
    colors: [Color(0xFF00D9A3), Color(0xFF3B82F6)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const gradientPurple = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const gradientWarm = LinearGradient(
    colors: [Color(0xFFF97316), Color(0xFFEAB308)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const gradientDark = LinearGradient(
    colors: [Color(0xFF0F2044), Color(0xFF162952)],
    begin: Alignment.topCenter, end: Alignment.bottomCenter,
  );
}

class AppTheme {
  static ThemeData get dark {
    final base = ThemeData.dark();
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bg,
      primaryColor: AppColors.accent,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        secondary: AppColors.purple,
        surface: AppColors.surface,
        error: AppColors.red,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bg,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.bg,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.accent, width: 2),
        ),
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? AppColors.accent : AppColors.textSecondary,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.accent.withOpacity(0.3)
              : AppColors.textMuted,
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.divider, space: 1),
    );
  }
}