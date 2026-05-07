import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

import '../app_theme.dart';
import '../providers/app_provider.dart';
import 'reciter_selection_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });

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
  void dispose() {
    _pulseController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
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
                        _buildHadithCard(),
                        const SizedBox(height: 24),

                        // Download Progress (always visible when downloading)
                        if (provider.isDownloading) _buildDownloadProgress(provider),
                        if (provider.isDownloading) const SizedBox(height: 16),

                        // Error message
                        if (provider.errorMessage != null) _buildErrorCard(provider),
                        if (provider.errorMessage != null) const SizedBox(height: 16),

                        // Full Player
                        _buildPlayer(provider),
                        const SizedBox(height: 16),

                        // Countdown Card (only when schedule is active)
                        if (provider.settings.isEnabled && provider.nextPlayback != null)
                          _buildCountdownCard(provider),
                        if (provider.settings.isEnabled && provider.nextPlayback != null)
                          const SizedBox(height: 16),

                        // Reciter Card
                        _buildReciterCard(provider),
                        const SizedBox(height: 16),

                        // Schedule Card
                        _buildScheduleCard(provider),
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

  Widget _buildHadithCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassCard,
      child: Column(
        children: [
          const Icon(Icons.auto_stories_rounded, color: AppTheme.gold, size: 28),
          const SizedBox(height: 8),
          Text(
            '«لا تجعلوا بيوتكم مقابر،\nإن الشيطان ينفر من البيت\nالذي تُقرأ فيه سورة البقرة»',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppTheme.textPrimary.withValues(alpha: 0.9),
              height: 1.8,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'رواه مسلم',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }

  /// Full professional player widget with all controls.
  Widget _buildPlayer(AppProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: provider.isPlaying ? AppTheme.gold.withValues(alpha: 0.4) : AppTheme.cardBorder,
        ),
        boxShadow: provider.isPlaying
            ? [BoxShadow(color: AppTheme.gold.withValues(alpha: 0.15), blurRadius: 20)]
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 12)],
      ),
      child: Column(
        children: [
          // Surah name & reciter
          Text(
            'سورة البقرة',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: provider.isPlaying ? AppTheme.gold : AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            provider.currentReciter.nameAr,
            style: const TextStyle(fontSize: 14, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 20),

          // Progress bar
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 5,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            ),
            child: Slider(
              value: _clampPosition(provider),
              max: _getMaxDuration(provider),
              onChanged: (provider.isPlaying || provider.currentPosition > Duration.zero)
                  ? (v) => provider.seekTo(Duration(seconds: v.toInt()))
                  : null,
              activeColor: AppTheme.gold,
              inactiveColor: AppTheme.cardBorder,
            ),
          ),

          // Time labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(provider.currentPosition),
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                ),
                Text(
                  _formatDuration(provider.totalDuration),
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Stop button
              _controlButton(
                icon: Icons.stop_rounded,
                size: 28,
                color: (provider.isPlaying || provider.currentPosition > Duration.zero) ? AppTheme.errorRed : AppTheme.textMuted,
                onTap: (provider.isPlaying || provider.currentPosition > Duration.zero) ? () => provider.stopPlayback() : null,
              ),

              // Rewind 10s
              _controlButton(
                icon: Icons.replay_10_rounded,
                size: 32,
                color: (provider.isPlaying || provider.currentPosition > Duration.zero) ? AppTheme.textPrimary : AppTheme.textMuted,
                onTap: (provider.isPlaying || provider.currentPosition > Duration.zero)
                    ? () => provider.seekTo(
                          Duration(seconds: (provider.currentPosition.inSeconds - 10).clamp(0, 999999)),
                        )
                    : null,
              ),

              // Main play/pause button
              GestureDetector(
                onTap: () {
                  if (provider.isLoading) return;
                  if (provider.isPlaying) {
                    provider.togglePlayPause();
                  } else if (provider.currentPosition > Duration.zero) {
                    // Paused - resume
                    provider.togglePlayPause();
                  } else {
                    provider.playNow();
                  }
                },
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, _) {
                    final scale = provider.isPlaying
                        ? 1.0 + (_pulseController.value * 0.04)
                        : 1.0;
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppTheme.goldGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.gold.withValues(
                                alpha: provider.isPlaying ? 0.5 : 0.3,
                              ),
                              blurRadius: provider.isPlaying ? 20 : 12,
                            ),
                          ],
                        ),
                        child: provider.isLoading
                            ? const Center(
                                child: SizedBox(
                                  width: 28, height: 28,
                                  child: CircularProgressIndicator(
                                    color: AppTheme.deepBackground,
                                    strokeWidth: 3,
                                  ),
                                ),
                              )
                            : Icon(
                                provider.isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                size: 36,
                                color: AppTheme.deepBackground,
                              ),
                      ),
                    );
                  },
                ),
              ),

              // Forward 10s
              _controlButton(
                icon: Icons.forward_10_rounded,
                size: 32,
                color: (provider.isPlaying || provider.currentPosition > Duration.zero) ? AppTheme.textPrimary : AppTheme.textMuted,
                onTap: (provider.isPlaying || provider.currentPosition > Duration.zero)
                    ? () => provider.seekTo(
                          Duration(seconds: provider.currentPosition.inSeconds + 10),
                        )
                    : null,
              ),

              // Volume
              _controlButton(
                icon: provider.volume == 0 ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                size: 28,
                color: AppTheme.textSecondary,
                onTap: () => _showVolumeSlider(context, provider),
              ),
            ],
          ),

          // Playing status
          if (provider.isPlaying) ...[
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: AppTheme.successGreen),
                ),
                const SizedBox(width: 6),
                const Text('يشتغل الآن', style: TextStyle(color: AppTheme.successGreen, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ],

          // Last played info (when not playing)
          if (!provider.isPlaying && provider.settings.lastPlayedAt != null) ...[
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.history_rounded, color: AppTheme.textMuted, size: 16),
                const SizedBox(width: 4),
                Text(
                  'آخر تشغيل: ${_getAgoText(provider.settings.lastPlayedAt!)}',
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required double size,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.cardBorder.withValues(alpha: 0.3),
        ),
        child: Icon(icon, size: size, color: color),
      ),
    );
  }

  void _showVolumeSlider(BuildContext context, AppProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('مستوى الصوت', style: TextStyle(color: AppTheme.gold, fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.volume_down_rounded, color: AppTheme.textMuted),
                  Expanded(
                    child: Slider(
                      value: provider.volume,
                      onChanged: (v) {
                        provider.setVolume(v);
                        setSheetState(() {});
                      },
                    ),
                  ),
                  const Icon(Icons.volume_up_rounded, color: AppTheme.textMuted),
                ],
              ),
              Text('${(provider.volume * 100).toInt()}%', style: const TextStyle(color: AppTheme.gold, fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildCountdownCard(AppProvider provider) {
    final nextTime = provider.nextPlayback!;
    final diff = nextTime.difference(DateTime.now());
    if (diff.isNegative) return const SizedBox.shrink();

    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;
    final seconds = diff.inSeconds % 60;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glassCard,
      child: Column(
        children: [
          const Text('التشغيل القادم بعد', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (days > 0) _buildTimeUnit(days.toString(), 'يوم'),
              if (days > 0) const SizedBox(width: 16),
              _buildTimeUnit(hours.toString().padLeft(2, '0'), 'ساعة'),
              const SizedBox(width: 16),
              _buildTimeUnit(minutes.toString().padLeft(2, '0'), 'دقيقة'),
              const SizedBox(width: 16),
              _buildTimeUnit(seconds.toString().padLeft(2, '0'), 'ثانية'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeUnit(String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.gold.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3)),
          ),
          child: Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.gold)),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
      ],
    );
  }

  Widget _buildReciterCard(AppProvider provider) {
    final reciter = provider.currentReciter;
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReciterSelectionScreen())),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.glassCard,
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.gold.withValues(alpha: 0.15),
              ),
              child: const Icon(Icons.mic_rounded, color: AppTheme.gold, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('القارئ', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(reciter.nameAr, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                  Row(children: [
                    Icon(reciter.isOffline ? Icons.phone_android_rounded : Icons.wifi_rounded, size: 14, color: reciter.isOffline ? AppTheme.successGreen : AppTheme.accentTeal),
                    const SizedBox(width: 4),
                    Text(reciter.isOffline ? 'بدون إنترنت' : 'أونلاين', style: TextStyle(fontSize: 12, color: reciter.isOffline ? AppTheme.successGreen : AppTheme.accentTeal)),
                  ]),
                ],
              ),
            ),
            const Icon(Icons.chevron_left_rounded, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard(AppProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassCard,
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.accentTeal.withValues(alpha: 0.15),
            ),
            child: const Icon(Icons.schedule_rounded, color: AppTheme.accentTeal, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('جدولة التشغيل', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                const SizedBox(height: 2),
                Text(
                  provider.settings.getScheduleDescription(),
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Switch(
            value: provider.settings.isEnabled,
            onChanged: (val) {
              provider.updateSettings(provider.settings.copyWith(isEnabled: val));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadProgress(AppProvider provider) {
    final percent = (provider.downloadProgress * 100).toInt();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassCard,
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accentTeal),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'جاري تحميل سورة البقرة (${provider.downloadingReciterName})',
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                ),
              ),
              // Cancel button
              GestureDetector(
                onTap: () => provider.cancelDownload(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.red.withValues(alpha: 0.15),
                  ),
                  child: const Text('إلغاء', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: provider.downloadProgress,
              backgroundColor: AppTheme.cardBorder,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentTeal),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$percent%',
            style: const TextStyle(color: AppTheme.accentTeal, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
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

  // Helpers
  double _clampPosition(AppProvider p) {
    final pos = p.currentPosition.inSeconds.toDouble();
    final max = _getMaxDuration(p);
    return pos.clamp(0, max);
  }

  double _getMaxDuration(AppProvider p) {
    final dur = p.totalDuration.inSeconds.toDouble();
    return dur > 0 ? dur : 1.0;
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    if (h > 0) return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _getAgoText(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return 'منذ ${diff.inDays} يوم';
    if (diff.inHours > 0) return 'منذ ${diff.inHours} ساعة';
    return 'منذ ${diff.inMinutes} دقيقة';
  }
}
