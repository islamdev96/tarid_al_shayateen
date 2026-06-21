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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.cardBackground.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: provider.isPlaying 
                  ? theme.colorScheme.primary
                  : (isDark ? AppTheme.cardBorder : AppTheme.lightCardBorder),
              width: provider.isPlaying ? 2.0 : 1.5, // Solid highlight border matching screenshot
            ),
            boxShadow: [
              BoxShadow(
                color: (provider.isPlaying ? theme.colorScheme.primary : Colors.black).withValues(
                  alpha: provider.isPlaying ? (isDark ? 0.2 : 0.08) : (isDark ? 0.3 : 0.04),
                ),
                blurRadius: provider.isPlaying ? 24 : 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Top Row: Reciter info, Title, and small play toggle matching screenshot layout
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left side (in RTL): Quick toggle play button
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        provider.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      onPressed: () {
                        if (provider.isLoading) return;
                        if (provider.isPlaying || provider.currentPosition > Duration.zero) {
                          provider.togglePlayPause();
                        } else {
                          provider.playNow();
                        }
                      },
                    ),
                  ),

                  // Middle: Title and Subtitle (aligned to the right next to trailing icon)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'سورة البقرة',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            provider.currentReciter.nameAr,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Right side: Circular icon container
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.music_note_rounded,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                ],
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
                  activeColor: theme.colorScheme.primary,
                  inactiveColor: isDark ? AppTheme.cardBorder : AppTheme.lightCardBorder,
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
                      style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 12),
                    ),
                    Text(
                      _formatDuration(provider.totalDuration),
                      style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 12),
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
                    color: (provider.isPlaying || provider.currentPosition > Duration.zero) ? AppTheme.errorRed : (theme.textTheme.bodySmall?.color ?? Colors.grey),
                    onTap: (provider.isPlaying || provider.currentPosition > Duration.zero) ? () => provider.stopPlayback() : null,
                    context: context,
                  ),

                  // Rewind 10s
                  _controlButton(
                    icon: Icons.replay_10_rounded,
                    size: 32,
                    color: (provider.isPlaying || provider.currentPosition > Duration.zero) ? theme.colorScheme.onSurface : (theme.textTheme.bodySmall?.color ?? Colors.grey),
                    onTap: (provider.isPlaying || provider.currentPosition > Duration.zero)
                        ? () => provider.seekTo(
                              Duration(seconds: (provider.currentPosition.inSeconds - 10).clamp(0, 999999)),
                            )
                        : null,
                    context: context,
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
                                  color: theme.colorScheme.primary.withValues(
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
                    color: (provider.isPlaying || provider.currentPosition > Duration.zero) ? theme.colorScheme.onSurface : (theme.textTheme.bodySmall?.color ?? Colors.grey),
                    onTap: (provider.isPlaying || provider.currentPosition > Duration.zero)
                        ? () => provider.seekTo(
                              Duration(seconds: provider.currentPosition.inSeconds + 10),
                            )
                        : null,
                    context: context,
                  ),

                  // Volume
                  _controlButton(
                    icon: provider.volume == 0 ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                    size: 28,
                    color: theme.textTheme.bodyMedium?.color ?? Colors.grey,
                    onTap: () => _showVolumeSlider(context, provider),
                    context: context,
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
                    Icon(Icons.history_rounded, color: theme.textTheme.bodySmall?.color, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'آخر تشغيل: ${_getAgoText(provider.settings.lastPlayedAt!)}',
                      style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 12),
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
    required BuildContext context,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: (isDark ? AppTheme.cardBorder : AppTheme.lightCardBorder).withValues(alpha: 0.3),
        ),
        child: Icon(icon, size: size, color: color),
      ),
    );
  }

  void _showVolumeSlider(BuildContext context, AppProvider provider) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('مستوى الصوت', style: TextStyle(color: theme.colorScheme.primary, fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.volume_down_rounded, color: theme.textTheme.bodySmall?.color),
                  Expanded(
                    child: Slider(
                      value: provider.volume,
                      onChanged: (v) {
                        provider.setVolume(v);
                        setSheetState(() {});
                      },
                    ),
                  ),
                  Icon(Icons.volume_up_rounded, color: theme.textTheme.bodySmall?.color),
                ],
              ),
              Text('${(provider.volume * 100).toInt()}%', style: TextStyle(color: theme.colorScheme.primary, fontSize: 18, fontWeight: FontWeight.w700)),
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
