import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../models/surah.dart';
import '../models/reciter.dart';
import '../providers/app_provider.dart';
import '../providers/download_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/glassy_background.dart';
import 'surah_text_screen.dart';
import 'mushaf_pages_screen.dart';

/// Screen allowing browsing, searching, and playing the 114 Surahs of the Holy Quran.
class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<AppProvider>();
    final downloadProvider = context.watch<DownloadProvider>();

    // Filter Surahs based on search query
    final filteredSurahs = Surah.allSurahs.where((surah) {
      final nameArNormalized = surah.nameAr.replaceAll('أ', 'ا').replaceAll('إ', 'ا').replaceAll('آ', 'ا').replaceAll('ة', 'ه');
      final queryNormalized = _searchQuery.replaceAll('أ', 'ا').replaceAll('إ', 'ا').replaceAll('آ', 'ا').replaceAll('ة', 'ه');
      return surah.nameAr.contains(_searchQuery) ||
          nameArNormalized.contains(queryNormalized) ||
          surah.nameEn.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          surah.number.toString() == _searchQuery;
    }).toList();

    return Scaffold(
      body: GlassyBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Custom Screen App Bar
              SliverAppBar(
                floating: true,
                backgroundColor: Colors.transparent,
                title: const Text('القرآن الكريم'),
              ),
              
              // Reciter Selector Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: _buildReciterCard(context, provider, theme),
                ),
              ),

              // Read Mushaf Card Button
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MushafPagesScreen()),
                      );
                    },
                    child: GlassCard(
                      padding: const EdgeInsets.all(16),
                      borderRadius: BorderRadius.circular(20),
                      color: theme.colorScheme.secondary.withValues(alpha: 0.15),
                      border: Border.all(color: theme.colorScheme.secondary.withValues(alpha: 0.3)),
                      child: Row(
                        children: [
                          Icon(CupertinoIcons.book_solid, color: theme.colorScheme.secondary, size: 28),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'المصحف المقروء بالصفحات',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                                Text(
                                  'تصفح وقراءة صفحات المصحف الشريف (604 صفحة) مع التكبير وحفظ العلامات',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Cairo',
                                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded, color: theme.colorScheme.secondary, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: _buildSearchBar(theme),
                ),
              ),

              // Surahs List
              SliverPadding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 120), // extra bottom padding for floating mini player
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final surah = filteredSurahs[index];
                      final isPlaying = provider.currentPlayingSurah?.number == surah.number;
                      return _buildSurahItem(surah, isPlaying, provider, downloadProvider, theme);
                    },
                    childCount: filteredSurahs.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReciterCard(BuildContext context, AppProvider provider, ThemeData theme) {
    final reciter = provider.currentReciter;
    final isDark = theme.brightness == Brightness.dark;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withValues(alpha: 0.15),
            ),
            child: Icon(CupertinoIcons.person_fill, color: theme.colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'القارئ الحالي',
                  style: TextStyle(
                    color: isDark ? AppTheme.textMuted : AppTheme.lightTextMuted,
                    fontSize: 12,
                    fontFamily: 'Cairo',
                  ),
                ),
                Text(
                  reciter.nameAr,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            onPressed: () => _showReciterSelector(context, provider, theme),
            child: const Text('تغيير القارئ'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return GlassCard(
      borderRadius: BorderRadius.circular(16),
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          setState(() {
            _searchQuery = val;
          });
        },
        style: TextStyle(color: theme.colorScheme.onSurface, fontFamily: 'Cairo'),
        decoration: InputDecoration(
          hintText: 'البحث باسم السورة أو رقمها...',
          hintStyle: TextStyle(
            color: isDark ? AppTheme.textMuted : AppTheme.lightTextMuted,
            fontSize: 14,
            fontFamily: 'Cairo',
          ),
          prefixIcon: Icon(CupertinoIcons.search, color: theme.colorScheme.primary, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(CupertinoIcons.xmark_circle_fill, color: theme.colorScheme.primary, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildSurahItem(Surah surah, bool isPlaying, AppProvider provider, DownloadProvider downloadProvider, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    
    final reciter = provider.currentReciter;
    final cacheKey = downloadProvider.getSurahCacheKey(surah.number, reciter.id);
    final isDownloading = downloadProvider.isDownloading(cacheKey);
    final progress = downloadProvider.getProgress(cacheKey);
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      border: Border.all(
        color: isPlaying
            ? theme.colorScheme.primary.withValues(alpha: 0.6)
            : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.25)),
        width: isPlaying ? 1.5 : 0.5,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        onTap: () {
          provider.playSurah(surah, provider.currentReciter);
        },
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isPlaying
                ? theme.colorScheme.primary.withValues(alpha: 0.2)
                : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03)),
            border: Border.all(
              color: isPlaying
                  ? theme.colorScheme.primary.withValues(alpha: 0.3)
                  : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05)),
              width: 0.5,
            ),
          ),
          child: Center(
            child: Text(
              surah.number.toString(),
              style: TextStyle(
                color: isPlaying ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
        title: Text(
          'سورة ${surah.nameAr}',
          style: TextStyle(
            color: isPlaying ? theme.colorScheme.primary : theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            fontFamily: 'Cairo',
          ),
        ),
        subtitle: Text(
          '${surah.nameEn} • ${surah.type} • ${surah.versesCount} آية',
          style: TextStyle(
            color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
            fontSize: 12,
            fontFamily: 'Cairo',
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(CupertinoIcons.book, color: theme.colorScheme.primary, size: 20),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SurahTextScreen(surah: surah)),
                );
              },
            ),
            const SizedBox(width: 8),
            // Download Button
            FutureBuilder<bool>(
              future: downloadProvider.isSurahCached(surah.number, reciter.id),
              builder: (context, snapshot) {
                final isCached = snapshot.data ?? false;
                if (isCached) {
                  return Icon(CupertinoIcons.checkmark_alt_circle_fill, color: theme.colorScheme.primary, size: 24);
                }

                if (isDownloading) {
                  return SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 2.5,
                      color: theme.colorScheme.primary,
                    ),
                  );
                }

                return IconButton(
                  icon: const Icon(CupertinoIcons.cloud_download),
                  color: theme.colorScheme.primary,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    downloadProvider.downloadSurah(surah, reciter);
                  },
                );
              },
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                if (isPlaying) {
                  provider.togglePlayPause();
                } else {
                  provider.playSurah(surah, provider.currentReciter);
                }
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isPlaying
                      ? Colors.red.withValues(alpha: 0.15)
                      : theme.colorScheme.primary.withValues(alpha: 0.1),
                ),
                child: Icon(
                  isPlaying ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
                  color: isPlaying ? Colors.red : theme.colorScheme.primary,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReciterSelector(BuildContext context, AppProvider provider, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: isDark 
                    ? const Color(0xFF0C1921).withValues(alpha: 0.75) 
                    : Colors.white.withValues(alpha: 0.75),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(
                  color: isDark 
                      ? Colors.white.withValues(alpha: 0.08) 
                      : AppTheme.lightCardBorder.withValues(alpha: 0.25),
                  width: 0.5,
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
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
                    const SizedBox(height: 16),
                    const Text(
                      'اختر القارئ المفضل',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: Reciter.defaultReciters.length,
                        itemBuilder: (context, index) {
                          final r = Reciter.defaultReciters[index];
                          final isSelected = provider.currentReciter.id == r.id;
                          return ListTile(
                            onTap: () {
                              provider.selectReciter(r.id);
                              Navigator.pop(ctx);
                            },
                            leading: Icon(
                              CupertinoIcons.music_mic,
                              color: isSelected ? theme.colorScheme.primary : theme.disabledColor,
                            ),
                            title: Text(
                              r.nameAr,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                              ),
                            ),
                            trailing: isSelected
                                ? Icon(CupertinoIcons.checkmark_circle_fill, color: theme.colorScheme.primary)
                                : null,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
