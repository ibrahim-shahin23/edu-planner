// lib/widgets/widgets.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ── Gradient Container ────────────────────────────────────────
class GradBox extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final EdgeInsets? padding;
  final double radius;
  final VoidCallback? onTap;
  final List<BoxShadow>? shadows;

  const GradBox({
    super.key,
    required this.child,
    required this.gradient,
    this.padding,
    this.radius = 18,
    this.onTap,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: shadows,
        ),
        child: child,
      ),
    );
  }
}

// ── Glass Card ────────────────────────────────────────────────
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double radius;
  final Color? borderColor;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.radius = 18,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: borderColor ?? AppColors.divider,
            width: 1,
          ),
        ),
        child: child,
      ),
    );
  }
}

// ── Stat Chip ─────────────────────────────────────────────────
class StatChip extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final Color color;

  const StatChip({
    super.key,
    required this.emoji,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 18, fontWeight: FontWeight.w800)),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}

// ── Progress Bar ──────────────────────────────────────────────
class AppProgressBar extends StatelessWidget {
  final double value;
  final Color color;
  final double height;

  const AppProgressBar({
    super.key,
    required this.value,
    required this.color,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.cardLight,
          borderRadius: BorderRadius.circular(height),
        ),
        child: AnimatedFractionallySizedBox(
          widthFactor: value.clamp(0.0, 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut,
          alignment: Alignment.centerLeft,
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(height),
              boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 6)],
            ),
          ),
        ),
      );
    });
  }
}

// ── Section Title ─────────────────────────────────────────────
class SectionTitle extends StatelessWidget {
  final String text;
  final String? trailing;
  final VoidCallback? onTrailing;

  const SectionTitle(this.text, {super.key, this.trailing, this.onTrailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(text,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w700)),
        if (trailing != null)
          GestureDetector(
            onTap: onTrailing,
            child: Text(trailing!,
                style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ),
      ],
    );
  }
}

// ── Priority Badge ────────────────────────────────────────────
class PriBadge extends StatelessWidget {
  final String label;
  final Color color;

  const PriBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────
class EmptyView extends StatelessWidget {
  final String emoji;
  final String title;
  final String body;
  final String? btnLabel;
  final VoidCallback? onBtn;

  const EmptyView({
    super.key,
    required this.emoji,
    required this.title,
    required this.body,
    this.btnLabel,
    this.onBtn,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          Text(title,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(body,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 14, height: 1.5)),
          ),
          if (btnLabel != null) ...[
            const SizedBox(height: 24),
            ElevatedButton(onPressed: onBtn, child: Text(btnLabel!)),
          ],
        ],
      ),
    );
  }
}

// ── Snackbar ──────────────────────────────────────────────────
void showSnack(BuildContext ctx, String msg,
    {bool success = false, bool error = false}) {
  ScaffoldMessenger.of(ctx)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(
      content: Text(msg,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      backgroundColor: error
          ? AppColors.red
          : success
              ? AppColors.green
              : AppColors.card,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      duration: Duration(seconds: error ? 4 : 2),
    ));
}

// ── Achievement Toast ─────────────────────────────────────────
class AchievementToast extends StatelessWidget {
  final String icon;
  final String title;

  const AchievementToast({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        gradient: AppColors.gradientWarm,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: AppColors.orange.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 6))
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Achievement Unlocked!',
                  style: TextStyle(
                      color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
              Text(title,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }
}
