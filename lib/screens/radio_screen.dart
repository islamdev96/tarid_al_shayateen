import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers/app_provider.dart';
import '../widgets/mosque_header_widget.dart';
import '../widgets/glass_card.dart';
import '../widgets/glassy_background.dart';

class RadioStation {
  final String nameAr;
  final String nameEn;
  final String url;
  final String subtitleAr;

  const RadioStation({
    required this.nameAr,
    required this.nameEn,
    required this.url,
    required this.subtitleAr,
  });

  static const RadioStation egyptRadio = RadioStation(
    nameAr: 'إذاعة القرآن الكريم - القاهرة',
    nameEn: 'Quran Radio Cairo',
    url: 'https://stream.radiojar.com/8s5u5tpdtwzuv',
    subtitleAr: 'جمهورية مصر العربية • بث مباشر 24 ساعة',
  );
}

class RadioScreen extends StatefulWidget {
  final RadioStation station;
  const RadioScreen({super.key, required this.station});

  @override
  State<RadioScreen> createState() => _RadioScreenState();
}

class _RadioScreenState extends State<RadioScreen> {
  bool _isMuted = false;
  double _preMuteVolume = 1.0;

  Color get cyanAccent => AppTheme.accentTeal;
  Color get orangeAccent => Theme.of(context).colorScheme.secondary;

  void _toggleMute(AppProvider provider) {
    if (_isMuted) {
      provider.setVolume(_preMuteVolume);
      setState(() {
        _isMuted = false;
      });
    } else {
      _preMuteVolume = provider.volume > 0 ? provider.volume : 1.0;
      provider.setVolume(0.0);
      setState(() {
        _isMuted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<AppProvider>();
    final isDark = theme.brightness == Brightness.dark;

    final isCurrent = provider.isLiveStream && provider.activeAudioTitle == widget.station.nameAr;
    final isPlaying = isCurrent && provider.isPlaying;

    return Scaffold(
      body: GlassyBackground(
        child: Stack(
          children: [
            // Mosque silhouette header
            const MosqueHeaderWidget(height: 220),

            SafeArea(
              child: Column(
                children: [
                  // Top Custom Header
                  _buildTopBar(theme),

                  const Spacer(flex: 1),

                  // Beautiful Center Radio Display Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                      border: Border.all(
                        color: isCurrent && isPlaying
                            ? (isDark ? cyanAccent : AppTheme.primaryGreen)
                            : (isDark ? Colors.white.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.35)),
                        width: isCurrent && isPlaying ? 1.5 : 0.5,
                      ),
                      boxShadow: [
                        if (isCurrent && isPlaying)
                          BoxShadow(
                            color: (isDark ? cyanAccent : AppTheme.primaryGreen).withValues(alpha: 0.1),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Radio Wave / Calligraphy Circular Display
                          _buildRadioArt(isCurrent && isPlaying, isDark),
                          const SizedBox(height: 24),

                          // Active badge
                          if (isCurrent && isPlaying) ...[
                            _buildLiveBadge(),
                            const SizedBox(height: 12),
                          ],

                          // Title
                          Text(
                            widget.station.nameAr,
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Subtitle
                          Text(
                            widget.station.subtitleAr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 1),

                  // Controls and Volume Panel
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        // Player Controls
                        _buildPlayerControls(provider, isCurrent, isPlaying, theme),
                        const SizedBox(height: 32),

                        // Volume Slider
                        _buildVolumeControl(provider, theme),
                      ],
                    ),
                  ),

                  const Spacer(flex: 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_forward_ios_rounded, color: theme.brightness == Brightness.dark ? cyanAccent : AppTheme.primaryGreen, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'إذاعة القرآن الكريم',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
              color: theme.brightness == Brightness.dark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
            ),
          ),
          const SizedBox(width: 48), // Spacer to balance back button
        ],
      ),
    );
  }

  Widget _buildRadioArt(bool isPlaying, bool isDark) {
    final activeColor = isDark ? cyanAccent : AppTheme.primaryGreen;
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? AppTheme.deepBackground : Colors.white,
        border: Border.all(
          color: isPlaying ? activeColor : (isDark ? AppTheme.cardBorder : AppTheme.lightCardBorder),
          width: 3,
        ),
        boxShadow: [
          if (isPlaying)
            BoxShadow(
              color: activeColor.withValues(alpha: 0.2),
              blurRadius: 30,
              spreadRadius: 4,
            ),
        ],
      ),
      child: Center(
        child: Icon(
          CupertinoIcons.waveform,
          color: isPlaying ? activeColor : (isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary),
          size: 64,
        ),
      ),
    );
  }

  Widget _buildLiveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3), width: 1),
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
          const SizedBox(width: 6),
          const Text(
            'بث مباشر',
            style: TextStyle(
              color: Colors.red,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerControls(AppProvider provider, bool isCurrent, bool isPlaying, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Mute/Unmute
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? AppTheme.cardBackground : AppTheme.lightCardBackground,
            border: Border.all(color: isDark ? AppTheme.cardBorder : AppTheme.lightCardBorder),
          ),
          child: IconButton(
            icon: Icon(
              _isMuted || provider.volume == 0.0
                  ? CupertinoIcons.volume_off
                  : CupertinoIcons.volume_up,
              color: isDark ? cyanAccent : AppTheme.primaryGreen,
            ),
            iconSize: 24,
            onPressed: () => _toggleMute(provider),
          ),
        ),
        const SizedBox(width: 24),

        // Main Play/Pause Button
        GestureDetector(
          onTap: () {
            if (isCurrent) {
              provider.togglePlayPause();
            } else {
              provider.playRadio(widget.station.url, widget.station.nameAr);
            }
          },
          child: Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isDark ? AppTheme.cyanGradient : AppTheme.goldGradient,
              boxShadow: [
                BoxShadow(
                  color: (isDark ? cyanAccent : AppTheme.gold).withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              provider.isLoading
                  ? CupertinoIcons.hourglass
                  : isPlaying
                      ? CupertinoIcons.pause_fill
                      : CupertinoIcons.play_fill,
              size: 40,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 24),

        // Stop Button
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? AppTheme.cardBackground : AppTheme.lightCardBackground,
            border: Border.all(color: isDark ? AppTheme.cardBorder : AppTheme.lightCardBorder),
          ),
          child: IconButton(
            icon: const Icon(CupertinoIcons.stop_fill, color: Colors.red),
            iconSize: 24,
            onPressed: isCurrent ? () => provider.stopRadio() : null,
          ),
        ),
      ],
    );
  }

  Widget _buildVolumeControl(AppProvider provider, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return GlassCard(
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.volume_down,
            color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
            size: 20,
          ),
          Expanded(
            child: SliderTheme(
              data: theme.sliderTheme.copyWith(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              ),
              child: Slider(
                value: provider.volume,
                min: 0.0,
                max: 1.0,
                onChanged: (value) {
                  provider.setVolume(value);
                  if (value > 0.0 && _isMuted) {
                    setState(() {
                      _isMuted = false;
                    });
                  }
                },
              ),
            ),
          ),
          Icon(
            CupertinoIcons.volume_up,
            color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
            size: 20,
          ),
        ],
      ),
    );
  }
}
