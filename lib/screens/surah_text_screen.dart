import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../models/surah.dart';
import '../providers/app_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/glassy_background.dart';

class SurahTextScreen extends StatefulWidget {
  final Surah surah;

  const SurahTextScreen({super.key, required this.surah});

  @override
  State<SurahTextScreen> createState() => _SurahTextScreenState();
}

class _SurahTextScreenState extends State<SurahTextScreen> {
  double _fontSize = 20.0;
  Future<List<String>?>? _loadTextFuture;

  @override
  void initState() {
    super.initState();
    final provider = context.read<AppProvider>();
    _loadTextFuture = provider.loadSurahText(widget.surah.number);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<AppProvider>();
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: GlassyBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Custom Header Bar
              _buildAppBar(context, theme, isDark),

              Expanded(
                child: FutureBuilder<List<String>?>(
                  future: _loadTextFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CupertinoActivityIndicator(radius: 18),
                            SizedBox(height: 16),
                            Text(
                              'جاري تحميل نص السورة...',
                              style: TextStyle(fontFamily: 'Cairo', fontSize: 15),
                            ),
                          ],
                        ),
                      );
                    }

                    if (snapshot.hasError || snapshot.data == null) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(CupertinoIcons.wifi_exclamationmark, size: 56, color: Colors.red),
                              const SizedBox(height: 16),
                              Text(
                                provider.errorMessage ?? 'تعذر تحميل نص السورة. تأكد من اتصال الإنترنت.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontFamily: 'Cairo', fontSize: 15),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _loadTextFuture = provider.loadSurahText(widget.surah.number);
                                  });
                                },
                                icon: const Icon(CupertinoIcons.refresh),
                                label: const Text('إعادة المحاولة'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final verses = snapshot.data!;
                    return Column(
                      children: [
                        // Font controls & stats
                        _buildControlsBar(theme, isDark, verses.length),

                        // Verses list
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 120),
                            itemCount: verses.length + 1, // +1 for Bismillah header
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                // Bismillah header (except for Fatihah and Tawbah)
                                if (widget.surah.number == 1 || widget.surah.number == 9) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 24),
                                  child: Text(
                                    'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: _fontSize + 4,
                                      fontFamily: 'serif',
                                      color: isDark ? AppTheme.gold : AppTheme.lightGold,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              }

                              final verseIndex = index - 1;
                              final verseText = verses[verseIndex];
                              
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: GlassCard(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      // Arabic Verse text
                                      SelectableText(
                                        verseText,
                                        textDirection: TextDirection.rtl,
                                        style: GoogleFonts.amiri(
                                          fontSize: _fontSize,
                                          height: 2.0,
                                          fontWeight: FontWeight.w600,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      
                                      // Verse number badge
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: theme.colorScheme.primary.withValues(alpha: 0.2),
                                                width: 0.5,
                                              ),
                                            ),
                                            child: Text(
                                              'الآية ${verseIndex + 1}',
                                              style: TextStyle(
                                                color: theme.colorScheme.primary,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Cairo',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Bottom mini audio controller
              _buildFloatingAudioPlayer(provider, theme, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppTheme.cardBorder.withValues(alpha: 0.3) : AppTheme.lightCardBorder.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_forward_ios_rounded, color: theme.colorScheme.primary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          Column(
            children: [
              Text(
                'سورة ${widget.surah.nameAr}',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  fontFamily: 'Cairo',
                ),
              ),
              Text(
                '${widget.surah.type} • ${widget.surah.versesCount} آية',
                style: TextStyle(
                  color: isDark ? AppTheme.textMuted : AppTheme.lightTextMuted,
                  fontSize: 12,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          const Spacer(),
          // Placeholder to balance back button
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildControlsBar(ThemeData theme, bool isDark, int versesCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Text size controls
          Row(
            children: [
              IconButton(
                icon: const Icon(CupertinoIcons.minus_circle),
                color: theme.colorScheme.primary,
                onPressed: _fontSize > 16
                    ? () => setState(() => _fontSize -= 2)
                    : null,
              ),
              Text(
                'حجم الخط',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Cairo',
                  color: theme.colorScheme.onSurface,
                ),
              ),
              IconButton(
                icon: const Icon(CupertinoIcons.plus_circle),
                color: theme.colorScheme.primary,
                onPressed: _fontSize < 32
                    ? () => setState(() => _fontSize += 2)
                    : null,
              ),
            ],
          ),
          
          // Surah details badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.cardBackground : AppTheme.lightCardBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppTheme.cardBorder : AppTheme.lightCardBorder,
                width: 0.5,
              ),
            ),
            child: Text(
              'الترتيب: ${widget.surah.number}',
              style: TextStyle(
                color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
                fontSize: 12,
                fontFamily: 'Cairo',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingAudioPlayer(AppProvider provider, ThemeData theme, bool isDark) {
    final isCurrentPlaying = provider.currentPlayingSurah?.number == widget.surah.number;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: AppTheme.glassCard(context),
      child: Row(
        children: [
          // Play button
          if (provider.isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CupertinoActivityIndicator(radius: 10),
            )
          else
            IconButton(
              icon: Icon(
                provider.isPlaying && isCurrentPlaying
                    ? CupertinoIcons.pause_fill
                    : CupertinoIcons.play_fill,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              onPressed: () {
                if (isCurrentPlaying) {
                  provider.togglePlayPause();
                } else {
                  provider.playSurah(widget.surah, provider.currentReciter);
                }
              },
            ),

          const SizedBox(width: 8),

          // Audio details
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCurrentPlaying ? 'تستمع الآن' : 'تشغيل السورة بصوت',
                  style: TextStyle(
                    color: isDark ? AppTheme.textMuted : AppTheme.lightTextMuted,
                    fontSize: 10,
                    fontFamily: 'Cairo',
                  ),
                ),
                Text(
                  isCurrentPlaying ? provider.activeAudioTitle : 'سورة ${widget.surah.nameAr}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
                Text(
                  isCurrentPlaying ? provider.activeAudioSubtitle : 'القارئ: ${provider.currentReciter.nameAr}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
                    fontSize: 11,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
          
          // Stop button
          if (isCurrentPlaying && provider.isPlaying)
            IconButton(
              icon: const Icon(CupertinoIcons.stop_fill, color: AppTheme.errorRed, size: 20),
              onPressed: () => provider.stopQuranPlayback(),
            ),
        ],
      ),
    );
  }
}
