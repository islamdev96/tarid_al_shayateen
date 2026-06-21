import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers/app_provider.dart';

/// A premium, glassmorphic mini player docked at the bottom of the screens.
class MiniPlayerWidget extends StatefulWidget {
  const MiniPlayerWidget({super.key});

  @override
  State<MiniPlayerWidget> createState() => _MiniPlayerWidgetState();
}

class _MiniPlayerWidgetState extends State<MiniPlayerWidget> {
  bool _isDismissed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<AppProvider>();

    if (!provider.hasActiveAudio) {
      _isDismissed = false; // Reset dismissed state when playback fully stops
      return const SizedBox.shrink();
    }

    if (_isDismissed) {
      return const SizedBox.shrink();
    }

    final progress = provider.totalDuration.inMilliseconds > 0
        ? provider.currentPosition.inMilliseconds / provider.totalDuration.inMilliseconds
        : 0.0;

    return Dismissible(
      key: const ValueKey('mini_player_dismiss'),
      direction: DismissDirection.horizontal,
      onDismissed: (direction) {
        setState(() {
          _isDismissed = true; // Set local state immediately to remove from tree
        });
        if (provider.isLiveStream) {
          provider.stopRadio();
        } else {
          provider.stopQuranPlayback();
        }
      },
      child: GestureDetector(
        onTap: () => _showFullPlayer(context, provider),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: AppTheme.glassCard(context).copyWith(
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Linear Progress Indicator
              LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 3,
                backgroundColor: theme.brightness == Brightness.dark
                    ? AppTheme.cardBorder.withValues(alpha: 0.3)
                    : AppTheme.lightCardBorder.withValues(alpha: 0.4),
                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    // Spinning / Pulsing icon decoration
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      ),
                      child: Icon(
                        Icons.music_note_rounded,
                        color: theme.colorScheme.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Text Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            provider.activeAudioTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            provider.activeAudioSubtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: theme.brightness == Brightness.dark
                                  ? AppTheme.textSecondary
                                  : AppTheme.lightTextSecondary,
                              fontSize: 12,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Controls
                    if (provider.isLoading)
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                      )
                    else ...[
                      IconButton(
                        icon: Icon(
                          provider.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: theme.colorScheme.primary,
                          size: 28,
                        ),
                        onPressed: () => provider.togglePlayPause(),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.stop_rounded,
                          color: Colors.red,
                          size: 26,
                        ),
                        onPressed: () => provider.stopQuranPlayback(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Displays the full audio player in a gorgeous glassmorphic bottom sheet.
  void _showFullPlayer(BuildContext context, AppProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final innerTheme = Theme.of(context);
        return Consumer<AppProvider>(
          builder: (context, dynamicProvider, _) {
            if (!dynamicProvider.hasActiveAudio) {
              Navigator.pop(ctx);
              return const SizedBox.shrink();
            }
            
            final totalMinutes = dynamicProvider.totalDuration.inMinutes;
            final totalSeconds = dynamicProvider.totalDuration.inSeconds % 60;
            final currentMinutes = dynamicProvider.currentPosition.inMinutes;
            final currentSeconds = dynamicProvider.currentPosition.inSeconds % 60;

            final totalStr = '${totalMinutes.toString().padLeft(2, '0')}:${totalSeconds.toString().padLeft(2, '0')}';
            final currentStr = '${currentMinutes.toString().padLeft(2, '0')}:${currentSeconds.toString().padLeft(2, '0')}';

            final currentMs = dynamicProvider.currentPosition.inMilliseconds.toDouble();
            final totalMs = dynamicProvider.totalDuration.inMilliseconds.toDouble();

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                gradient: AppTheme.backgroundGradient(context),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(
                  color: innerTheme.brightness == Brightness.dark
                      ? AppTheme.cardBorder.withValues(alpha: 0.3)
                      : AppTheme.lightCardBorder.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    children: [
                      // Pull Indicator
                      Container(
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(
                          color: innerTheme.brightness == Brightness.dark
                              ? AppTheme.cardBorder
                              : AppTheme.lightCardBorder,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Surah Calligraphy / Large Ornament Symbol
                      Expanded(
                        child: Center(
                          child: Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppTheme.goldGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.gold.withValues(alpha: 0.3),
                                  blurRadius: 32,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'القرآن',
                                style: TextStyle(
                                  color: AppTheme.deepBackground,
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Text Info
                      Text(
                        dynamicProvider.activeAudioTitle,
                        style: TextStyle(
                          color: innerTheme.colorScheme.onSurface,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        dynamicProvider.activeAudioSubtitle,
                        style: TextStyle(
                          color: innerTheme.brightness == Brightness.dark
                              ? AppTheme.textSecondary
                              : AppTheme.lightTextSecondary,
                          fontSize: 16,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      if (dynamicProvider.isLiveStream) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: innerTheme.colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: innerTheme.colorScheme.primary.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'بث مباشر',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Cairo',
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ] else ...[
                        // Seek Bar Slider
                        Slider(
                          value: currentMs.clamp(0.0, totalMs > 0 ? totalMs : 1.0),
                          min: 0.0,
                          max: totalMs > 0 ? totalMs : 1.0,
                          activeColor: innerTheme.colorScheme.primary,
                          inactiveColor: innerTheme.brightness == Brightness.dark
                              ? AppTheme.cardBorder
                              : AppTheme.lightCardBorder,
                          onChanged: (v) {
                            dynamicProvider.seekTo(Duration(milliseconds: v.toInt()));
                          },
                        ),
                        
                        // Duration Labels
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                currentStr,
                                style: TextStyle(
                                  color: innerTheme.brightness == Brightness.dark
                                      ? AppTheme.textMuted
                                      : AppTheme.lightTextMuted,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                totalStr,
                                style: TextStyle(
                                  color: innerTheme.brightness == Brightness.dark
                                      ? AppTheme.textMuted
                                      : AppTheme.lightTextMuted,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),

                      // Playback Controls Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Fast Rewind
                          if (!dynamicProvider.isLiveStream) ...[
                            IconButton(
                              icon: const Icon(Icons.replay_10_rounded),
                              iconSize: 36,
                              color: innerTheme.colorScheme.primary,
                              onPressed: () {
                                final newPos = dynamicProvider.currentPosition - const Duration(seconds: 10);
                                dynamicProvider.seekTo(newPos.inMilliseconds > 0 ? newPos : Duration.zero);
                              },
                            ),
                            const SizedBox(width: 24),
                          ],

                          // Play / Pause Circle Button
                          GestureDetector(
                            onTap: () => dynamicProvider.togglePlayPause(),
                            child: Container(
                              width: 76,
                              height: 76,
                              decoration: AppTheme.glowingPlayButton,
                              child: Icon(
                                dynamicProvider.isLoading
                                    ? Icons.hourglass_empty_rounded
                                    : dynamicProvider.isPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                size: 40,
                                color: AppTheme.deepBackground,
                              ),
                            ),
                          ),

                          // Fast Forward
                          if (!dynamicProvider.isLiveStream) ...[
                            const SizedBox(width: 24),
                            IconButton(
                              icon: const Icon(Icons.forward_10_rounded),
                              iconSize: 36,
                              color: innerTheme.colorScheme.primary,
                              onPressed: () {
                                final newPos = dynamicProvider.currentPosition + const Duration(seconds: 10);
                                dynamicProvider.seekTo(newPos < dynamicProvider.totalDuration ? newPos : dynamicProvider.totalDuration);
                              },
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
