// lib/screens/distraction_blocker_screen.dart
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';
import '../utils/utils.dart';
import '../widgets/common_widgets.dart';

class DistractionBlockerScreen extends StatefulWidget {
  const DistractionBlockerScreen({super.key});

  @override
  State<DistractionBlockerScreen> createState() =>
      _DistractionBlockerScreenState();
}

class _DistractionBlockerScreenState extends State<DistractionBlockerScreen> {
  final List<_BlockedSite> _sites = [
    _BlockedSite('YouTube', 'youtube.com', '📺', true),
    _BlockedSite('Instagram', 'instagram.com', '📸', true),
    _BlockedSite('TikTok', 'tiktok.com', '🎵', true),
    _BlockedSite('Twitter/X', 'x.com', '🐦', false),
    _BlockedSite('Facebook', 'facebook.com', '👥', false),
    _BlockedSite('Reddit', 'reddit.com', '🤖', true),
    _BlockedSite('Netflix', 'netflix.com', '🎬', false),
    _BlockedSite('Discord', 'discord.com', '💬', false),
  ];

  bool _blockingActive = false;
  final TextEditingController _customCtrl = TextEditingController();

  @override
  void dispose() {
    _customCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final blockedCount = _sites.where((s) => s.isBlocked).length;

    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: AppBar(
        title: const Text('Distraction Blocker'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ─── Main Toggle ──────────────────────────────────
          FadeInDown(
            child: GestureDetector(
              onTap: _toggleBlocking,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: _blockingActive
                      ? const LinearGradient(
                          colors: [Color(0xFFFF4D6D), Color(0xFFFF6B35)])
                      : AppTheme.accentGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (_blockingActive
                              ? AppTheme.error
                              : AppTheme.accent)
                          .withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(_blockingActive ? '🛡️' : '🔓',
                        style: const TextStyle(fontSize: 36)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _blockingActive ? 'Blocking Active' : 'Start Blocking',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800),
                          ),
                          Text(
                            _blockingActive
                                ? '$blockedCount sites blocked'
                                : 'Tap to block distracting sites',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: _blockingActive ? 0.5 : 0,
                      duration: const Duration(milliseconds: 400),
                      child: const Icon(Icons.power_settings_new_rounded,
                          color: Colors.white, size: 32),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ─── Info Banner ──────────────────────────────────
          FadeInDown(
            delay: const Duration(milliseconds: 100),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.accentYellow.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppTheme.accentYellow.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Text('ℹ️', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Distraction blocking works at the app level. For full web blocking, enable screen time controls in your device settings.',
                      style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ─── Sites List ───────────────────────────────────
          FadeInDown(
            delay: const Duration(milliseconds: 150),
            child: const SectionHeader(title: 'Sites to Block'),
          ),
          const SizedBox(height: 12),

          ..._sites.asMap().entries.map((entry) {
            final site = entry.value;
            return FadeInLeft(
              delay: Duration(milliseconds: 150 + entry.key * 50),
              child: _SiteTile(
                site: site,
                onToggle: (v) =>
                    setState(() => _sites[entry.key].isBlocked = v),
                onDelete: () =>
                    setState(() => _sites.removeAt(entry.key)),
              ),
            );
          }),

          // ─── Add Custom Site ──────────────────────────────
          const SizedBox(height: 20),
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'Add Custom Site'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _customCtrl,
                        style: const TextStyle(color: AppTheme.textPrimary),
                        decoration: const InputDecoration(
                          hintText: 'e.g. twitch.tv',
                          prefixIcon: Icon(Icons.add_link_rounded,
                              color: AppTheme.accent),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _addCustomSite,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                      ),
                      child: const Icon(Icons.add_rounded, size: 22),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ─── Focus Tips ───────────────────────────────────
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: const GradientCard(
              gradient: AppTheme.timerGradient,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('💪 Stay Strong Tips',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                  SizedBox(height: 12),
                  _TipItem('Put your phone in another room'),
                  _TipItem('Use headphones with focus music'),
                  _TipItem('Tell friends you\'re in study mode'),
                  _TipItem('Set a specific end time for your session'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  void _toggleBlocking() {
    setState(() => _blockingActive = !_blockingActive);
    AppSnackbar.show(
      context,
      message: _blockingActive
          ? '🛡️ Blocking active — stay focused!'
          : '🔓 Blocking disabled',
      isSuccess: _blockingActive,
    );
  }

  void _addCustomSite() {
    final url = _customCtrl.text.trim();
    if (url.isEmpty) return;
    final cleanUrl = url.replaceAll(RegExp(r'^https?://'), '').split('/').first;
    setState(() {
      _sites.add(_BlockedSite(cleanUrl, cleanUrl, '🌐', true));
    });
    _customCtrl.clear();
    AppSnackbar.success(context, '$cleanUrl added to block list');
  }
}

class _TipItem extends StatelessWidget {
  final String text;
  const _TipItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Text('→ ', style: TextStyle(color: Colors.white60)),
          Text(text,
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }
}

class _BlockedSite {
  final String name;
  final String url;
  final String icon;
  bool isBlocked;

  _BlockedSite(this.name, this.url, this.icon, this.isBlocked);
}

class _SiteTile extends StatelessWidget {
  final _BlockedSite site;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  const _SiteTile({
    required this.site,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: site.isBlocked
              ? AppTheme.error.withValues(alpha: 0.2)
              : AppTheme.divider,
        ),
      ),
      child: Row(
        children: [
          Text(site.icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(site.name,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600)),
                Text(site.url,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          Switch(
            value: site.isBlocked,
            onChanged: onToggle,
            activeThumbColor: AppTheme.error,
          ),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.delete_outline_rounded,
                color: AppTheme.textSecondary, size: 18),
          ),
        ],
      ),
    );
  }
}