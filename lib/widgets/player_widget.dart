import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers/app_provider.dart';

class PlayerWidget extends StatefulWidget {
  const PlayerWidget({super.key});

  @override
  State<PlayerWidget> createState() => _PlayerWidgetState();
}

class _PlayerWidgetState extends State<PlayerWidget> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
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
      },
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
