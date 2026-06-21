import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

import '../app_theme.dart';
import '../providers/app_provider.dart';
import '../widgets/hadith_card.dart';
import '../widgets/player_widget.dart';
import '../widgets/countdown_widget.dart';
import '../widgets/reciter_card.dart';
import '../widgets/schedule_card.dart';
import '../widgets/download_progress_card.dart';
import 'azkar_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyShown = prefs.getBool('permissions_requested') ?? false;
    if (alreadyShown || !mounted) return;

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    await prefs.setBool('permissions_requested', true);
    
    // Request notification permission (Android 13+)
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    // Check if battery optimization is enabled (meaning we need to request it to be ignored)
    if (!await Permission.ignoreBatteryOptimizations.isGranted && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.cardBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.battery_alert_rounded, color: AppTheme.gold),
              SizedBox(width: 8),
              Text('صلاحية هامة للتنبيه', style: TextStyle(color: AppTheme.gold, fontSize: 18)),
            ],
          ),
          content: const Text(
            'لضمان عمل التنبيه في وقته بالثانية وإنت قافل التطبيق، نحتاج إعطاء التطبيق صلاحية (العمل في الخلفية / استثناء من توفير البطارية).\n\nاضغط "تفعيل" ثم "سماح" (Allow).',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.6),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('تخطي', style: TextStyle(color: AppTheme.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentTeal,
                foregroundColor: AppTheme.deepBackground,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                await Permission.ignoreBatteryOptimizations.request();
              },
              child: const Text('تفعيل الصلاحية', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Consumer<AppProvider>(
            builder: (context, provider, _) {
              return CustomScrollView(
                slivers: [
                  // App Bar
                  SliverAppBar(
                    floating: true,
                    backgroundColor: Colors.transparent,
                    title: const Text('🛡️ طارد الشياطين'),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.settings_rounded),
                        color: AppTheme.gold,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SettingsScreen()),
                        ),
                      ),
                    ],
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 8),

                        // Bismillah Header
                        _buildBismillahHeader(),
                        const SizedBox(height: 8),

                        // Hadith Card
                        const HadithCard(),
                        const SizedBox(height: 24),

                        // Download Progress (always visible when downloading)
                        if (provider.isDownloading) const DownloadProgressCard(),
                        if (provider.isDownloading) const SizedBox(height: 16),

                        // Error message
                        if (provider.errorMessage != null) _buildErrorCard(provider),
                        if (provider.errorMessage != null) const SizedBox(height: 16),

                        // Full Player
                        const PlayerWidget(),
                        const SizedBox(height: 16),

                        // Countdown Card (only when schedule is active)
                        if (provider.settings.isEnabled && provider.nextPlayback != null)
                          const CountdownWidget(),
                        if (provider.settings.isEnabled && provider.nextPlayback != null)
                          const SizedBox(height: 16),

                        // Reciter Card
                        const ReciterCard(),
                        const SizedBox(height: 16),

                        // Azkar Navigation Card
                        _buildAzkarNavigationCard(context),
                        const SizedBox(height: 16),

                        // Schedule Card
                        const ScheduleCard(),
                        const SizedBox(height: 32),
                      ]),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBismillahHeader() {
    return const Text(
      'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 22,
        fontFamily: 'serif',
        color: AppTheme.gold,
        fontWeight: FontWeight.w400,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildErrorCard(AppProvider provider) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.red, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              provider.errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAzkarNavigationCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AzkarScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.glassCard.copyWith(
          border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.gold.withValues(alpha: 0.15),
              ),
              child: const Icon(Icons.shield_rounded, color: AppTheme.gold, size: 24),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'أذكار التحصين اليومية',
                    style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'الصباح، المساء، والنوم بأحاديث صحيحة مسندة',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_left_rounded, color: AppTheme.gold),
          ],
        ),
      ),
    );
  }
}
