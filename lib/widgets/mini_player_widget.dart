import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers/app_provider.dart';
import 'glass_card.dart';

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
        child: GlassCard(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Linear Progress Indicator
              LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 2.5, // Thinner iOS style bar
                backgroundColor: theme.brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05),
                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    // Spinning / Pulsing icon decoration
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.primary.withValues(alpha: 0.15),
                      ),
                      child: Icon(
                        CupertinoIcons.music_note_2,
                        color: theme.colorScheme.primary,
                        size: 20,
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
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: CupertinoActivityIndicator(radius: 10),
                      )
                    else ...[
                      IconButton(
                        icon: Icon(
                          provider.isPlaying
                              ? CupertinoIcons.pause_fill
                              : CupertinoIcons.play_fill,
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                        onPressed: () => provider.togglePlayPause(),
                      ),
                      IconButton(
                        icon: const Icon(
                          CupertinoIcons.stop_fill,
                          color: AppTheme.errorRed,
                          size: 22,
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
        final isDark = innerTheme.brightness == Brightness.dark;
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

            return ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.78,
                  decoration: BoxDecoration(
                    color: isDark 
                        ? const Color(0xFF0C1921).withValues(alpha: 0.5) 
                        : Colors.white.withValues(alpha: 0.5),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    border: Border.all(
                      color: isDark 
                          ? Colors.white.withValues(alpha: 0.08) 
                          : AppTheme.lightCardBorder.withValues(alpha: 0.25),
                      width: 0.5,
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Column(
                        children: [
                          // Pull Indicator
                          Container(
                            width: 44,
                            height: 5,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.15)
                                  : Colors.black.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          const SizedBox(height: 36),

                          // Surah Calligraphy / Rounded iOS Album Art Card
                          Expanded(
                            child: Center(
                              child: Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(32),
                                  gradient: LinearGradient(
                                    colors: isDark
                                        ? [AppTheme.primaryGreen, const Color(0xFF0B3A4F)]
                                        : [AppTheme.primaryGreen, AppTheme.accentTeal],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: innerTheme.colorScheme.primary.withValues(alpha: 0.25),
                                      blurRadius: 24,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        CupertinoIcons.book_fill,
                                        size: 64,
                                        color: Colors.white.withValues(alpha: 0.95),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'القرآن الكريم',
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.95),
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Cairo',
                                        ),
                                      ),
                                    ],
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
                              color: isDark
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
                                color: innerTheme.colorScheme.primary.withValues(alpha: 0.15),
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
                            const SizedBox(height: 16),
                            // Seek Bar Slider
                            Slider(
                              value: currentMs.clamp(0.0, totalMs > 0 ? totalMs : 1.0),
                              min: 0.0,
                              max: totalMs > 0 ? totalMs : 1.0,
                              activeColor: innerTheme.colorScheme.primary,
                              inactiveColor: isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.black.withValues(alpha: 0.08),
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
                                      color: isDark ? AppTheme.textMuted : AppTheme.lightTextMuted,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    totalStr,
                                    style: TextStyle(
                                      color: isDark ? AppTheme.textMuted : AppTheme.lightTextMuted,
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
                              // Fast Rewind (10s)
                              if (!dynamicProvider.isLiveStream) ...[
                                IconButton(
                                  icon: const Icon(CupertinoIcons.gobackward_10),
                                  iconSize: 34,
                                  color: innerTheme.colorScheme.primary,
                                  onPressed: () {
                                    final newPos = dynamicProvider.currentPosition - const Duration(seconds: 10);
                                    dynamicProvider.seekTo(newPos.inMilliseconds > 0 ? newPos : Duration.zero);
                                  },
                                ),
                                const SizedBox(width: 32),
                              ],

                              // Play / Pause Circle Button
                              GestureDetector(
                                onTap: () => dynamicProvider.togglePlayPause(),
                                child: Container(
                                  width: 76,
                                  height: 76,
                                  decoration: AppTheme.glowingPlayButton,
                                  child: Center(
                                    child: dynamicProvider.isLoading
                                        ? const CupertinoActivityIndicator(
                                            color: AppTheme.deepBackground,
                                            radius: 13,
                                          )
                                        : Icon(
                                            dynamicProvider.isPlaying
                                                ? CupertinoIcons.pause_fill
                                                : CupertinoIcons.play_fill,
                                            size: 34,
                                            color: AppTheme.deepBackground,
                                          ),
                                  ),
                                ),
                              ),

                              // Fast Forward (10s)
                              if (!dynamicProvider.isLiveStream) ...[
                                const SizedBox(width: 32),
                                IconButton(
                                  icon: const Icon(CupertinoIcons.goforward_10),
                                  iconSize: 34,
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
                ),
              ),
            );
          },
        );
      },
    );
  }
}
