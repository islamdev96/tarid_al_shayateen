import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../models/surah.dart';
import '../widgets/glassy_background.dart';
import '../providers/mushaf_provider.dart';
import '../widgets/quran_verse_widget.dart';
import '../widgets/tafseer_bottom_sheet.dart';

class MushafPagesScreen extends StatefulWidget {
  final int? initialPage;

  const MushafPagesScreen({super.key, this.initialPage});

  @override
  State<MushafPagesScreen> createState() => _MushafPagesScreenState();
}

class _MushafPagesScreenState extends State<MushafPagesScreen> {
  late PageController _pageController;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    final initialPage = widget.initialPage ?? 1;
    _pageController = PageController(initialPage: initialPage - 1);
    
    // Init provider state after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MushafProvider>();
      if (widget.initialPage != null) {
        provider.changePage(initialPage);
      } else {
        // changePage to provider.currentPage to fetch if needed
        provider.changePage(provider.currentPage);
        _pageController.jumpToPage(provider.currentPage - 1);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _getCurrentSurahName(int page) {
    Surah current = Surah.allSurahs.first;
    for (final s in Surah.allSurahs) {
      if (s.startPage <= page) {
        current = s;
      } else {
        break;
      }
    }
    return current.nameAr;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<MushafProvider>();
    final isDark = theme.brightness == Brightness.dark || provider.isDarkMode;

    return Theme(
      data: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
      child: Scaffold(
        backgroundColor: provider.isDarkMode ? AppTheme.deepBackground : theme.scaffoldBackgroundColor,
        body: GlassyBackground(
          child: SafeArea(
            child: Stack(
              children: [
                // Swipeable pages
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showControls = !_showControls;
                    });
                  },
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: 604,
                    reverse: true, // RTL paging (Swipe left to go to next page)
                    onPageChanged: (index) {
                      provider.changePage(index + 1);
                    },
                    itemBuilder: (context, index) {
                      return _buildPageContent(context, index + 1, provider);
                    },
                  ),
                ),

                // Top Controls Header
                if (_showControls)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: isDark ? Colors.black.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.8),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back_ios_rounded, color: theme.colorScheme.primary),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'المصحف الشريف',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    fontFamily: 'Cairo',
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                Text(
                                  'سورة ${_getCurrentSurahName(provider.currentPage)} | صفحة ${provider.currentPage}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Cairo',
                                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Settings Button
                          IconButton(
                            icon: Icon(Icons.settings, color: theme.colorScheme.primary),
                            onPressed: () => _showSettingsDialog(context, provider),
                          ),

                          // Bookmark icon
                          IconButton(
                            icon: Icon(
                              provider.bookmarkedPage == provider.currentPage
                                  ? Icons.bookmark_added_rounded
                                  : Icons.bookmark_add_outlined,
                              color: provider.bookmarkedPage == provider.currentPage ? Colors.amber : theme.colorScheme.primary,
                            ),
                            onPressed: () => provider.saveBookmark(),
                          ),

                          // List of Surahs quick jump
                          IconButton(
                            icon: Icon(Icons.list_alt_rounded, color: theme.colorScheme.primary),
                            onPressed: () => _showSurahJumpDialog(context, provider),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Bottom Controls / Page Slider
                if (_showControls)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      color: isDark ? Colors.black.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.9),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (provider.bookmarkedPage != null && provider.bookmarkedPage != provider.currentPage)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: TextButton.icon(
                                onPressed: () {
                                  _pageController.jumpToPage(provider.bookmarkedPage! - 1);
                                  provider.changePage(provider.bookmarkedPage!);
                                },
                                icon: const Icon(Icons.bookmark, size: 16, color: Colors.amber),
                                label: Text(
                                  'الذهاب إلى العلامة المحفوظة (صفحة ${provider.bookmarkedPage})',
                                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.amber),
                                ),
                              ),
                            ),
                          Row(
                            children: [
                              Text(
                                '1',
                                style: TextStyle(fontFamily: 'Cairo', color: isDark ? Colors.white : Colors.black87),
                              ),
                              Expanded(
                                child: Slider(
                                  min: 1,
                                  max: 604,
                                  value: provider.currentPage.toDouble(),
                                  activeColor: theme.colorScheme.primary,
                                  inactiveColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                                  onChanged: (value) {
                                    final page = value.round();
                                    _pageController.jumpToPage(page - 1);
                                    provider.changePage(page);
                                  },
                                ),
                              ),
                              Text(
                                '604',
                                style: TextStyle(fontFamily: 'Cairo', color: isDark ? Colors.white : Colors.black87),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageContent(BuildContext context, int pageNum, MushafProvider provider) {
    if (provider.currentPage != pageNum || provider.isLoadingPage) {
      return const Center(child: CupertinoActivityIndicator(radius: 16));
    }

    if (provider.currentVerses.isEmpty) {
      return const Center(
        child: Text(
          'خطأ في تحميل الصفحة',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 80, bottom: 120, left: 16, right: 16),
      child: Column(
        children: provider.currentVerses.map((verse) {
          final isSelected = provider.selectedVerseKey == verse.verseKey;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: QuranVerseWidget(
              verse: verse,
              isSelected: isSelected,
              isPlaying: provider.playingVerseKey == verse.verseKey,
              fontSizeMultiplier: provider.fontSizeMultiplier,
              onTap: () {
                provider.selectVerse(verse.verseKey);
                TafseerBottomSheet.show(context, verse, () {
                  if (provider.playingVerseKey == verse.verseKey) {
                    provider.stopVerse();
                  } else {
                    provider.playVerse(verse.verseKey);
                  }
                });
              },
              onLongPress: () {
                provider.selectVerse(verse.verseKey);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context, MushafProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('إعدادات القراءة', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dark Mode Toggle
              SwitchListTile(
                title: const Text('الوضع الداكن للقراءة', style: TextStyle(fontFamily: 'Cairo')),
                value: provider.isDarkMode,
                onChanged: (val) {
                  provider.toggleDarkMode(val);
                  Navigator.pop(ctx);
                },
              ),
              const Divider(),
              // Font Size Slider
              const Text('حجم الخط', style: TextStyle(fontFamily: 'Cairo')),
              Slider(
                min: 0.8,
                max: 2.0,
                value: provider.fontSizeMultiplier,
                onChanged: (val) {
                  provider.updateFontSize(val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إغلاق', style: TextStyle(fontFamily: 'Cairo')),
            ),
          ],
        );
      },
    );
  }

  void _showSurahJumpDialog(BuildContext context, MushafProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            children: [
              const Text(
                'انتقال سريع لسورة',
                style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: Surah.allSurahs.length,
                  itemBuilder: (context, index) {
                    final surah = Surah.allSurahs[index];
                    return ListTile(
                      title: Text(
                        'سورة ${surah.nameAr}',
                        style: const TextStyle(fontFamily: 'Cairo'),
                      ),
                      trailing: Text(
                        'صفحة ${surah.startPage}',
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
                      ),
                      onTap: () {
                        _pageController.jumpToPage(surah.startPage - 1);
                        provider.changePage(surah.startPage);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
