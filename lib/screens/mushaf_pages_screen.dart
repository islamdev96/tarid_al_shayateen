import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../app_theme.dart';
import '../models/surah.dart';
import '../widgets/glassy_background.dart';

/// Interactive, full-page scanned Quran Mushaf viewer (pages 1 to 604)
/// Features: PageView, InteractiveViewer (pinch-to-zoom), Bookmark (save/resume), Surah/Page Quick Jump.
class MushafPagesScreen extends StatefulWidget {
  final int? initialPage;

  const MushafPagesScreen({super.key, this.initialPage});

  @override
  State<MushafPagesScreen> createState() => _MushafPagesScreenState();
}

class _MushafPagesScreenState extends State<MushafPagesScreen> {
  late PageController _pageController;
  int _currentPage = 1; // 1-indexed (1 to 604)
  bool _showControls = true;
  int? _bookmarkedPage;

  // Dual-CDN fallback lists
  static final List<String> _cdns = [
    'https://raw.githubusercontent.com/QuranHub/quran-pages-images/main/easyquran.com/hafs-tajweed',
    'https://cdn.jsdelivr.net/gh/QuranHub/quran-pages-images/easyquran.com/hafs-tajweed',
  ];

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage ?? 1;
    _pageController = PageController(initialPage: _currentPage - 1);
    _loadBookmark();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _bookmarkedPage = prefs.getInt('mushaf_bookmark_page');
    });
  }

  Future<void> _saveBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('mushaf_bookmark_page', _currentPage);
    setState(() {
      _bookmarkedPage = _currentPage;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حفظ علامة الحفظ عند الصفحة $_currentPage 🔖', style: const TextStyle(fontFamily: 'Cairo')),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _jumpToPage(int page) {
    if (page < 1 || page > 604) return;
    _pageController.jumpToPage(page - 1);
    setState(() {
      _currentPage = page;
    });
  }

  // Get Surah name containing current page
  String _getCurrentSurahName() {
    Surah current = Surah.allSurahs.first;
    for (final s in Surah.allSurahs) {
      if (s.startPage <= _currentPage) {
        current = s;
      } else {
        break;
      }
    }
    return current.nameAr;
  }

  // Fallback image builder that tries multiple CDNs
  Widget _buildPageImage(int pageNum) {
    // Page 1 is right-aligned normally, let's keep it centered
    return LayoutBuilder(
      builder: (context, constraints) {
        return InteractiveViewer(
          minScale: 1.0,
          maxScale: 4.0,
          child: PageImageLoader(
            urls: [
              '${_cdns[0]}/$pageNum.jpg',
              '${_cdns[1]}/$pageNum.jpg',
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
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
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index + 1;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 8.0),
                        child: _buildPageImage(index + 1),
                      ),
                    );
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
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                'سورة ${_getCurrentSurahName()} | صفحة $_currentPage',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Cairo',
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Bookmark icon
                        IconButton(
                          icon: Icon(
                            _bookmarkedPage == _currentPage
                                ? Icons.bookmark_added_rounded
                                : Icons.bookmark_add_outlined,
                            color: _bookmarkedPage == _currentPage ? Colors.amber : theme.colorScheme.primary,
                          ),
                          onPressed: _saveBookmark,
                        ),

                        // List of Surahs quick jump
                        IconButton(
                          icon: Icon(Icons.list_alt_rounded, color: theme.colorScheme.primary),
                          onPressed: () => _showSurahJumpDialog(context),
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
                        // Resume bookmark button if exists
                        if (_bookmarkedPage != null && _bookmarkedPage != _currentPage)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: TextButton.icon(
                              onPressed: () => _jumpToPage(_bookmarkedPage!),
                              icon: const Icon(Icons.bookmark, size: 16, color: Colors.amber),
                              label: Text(
                                'الذهاب إلى العلامة المحفوظة (صفحة $_bookmarkedPage)',
                                style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.amber),
                              ),
                            ),
                          ),
                        Row(
                          children: [
                            Text(
                              '1',
                              style: TextStyle(fontFamily: 'Cairo', color: theme.colorScheme.onSurface),
                            ),
                            Expanded(
                              child: Slider(
                                min: 1,
                                max: 604,
                                value: _currentPage.toDouble(),
                                activeColor: theme.colorScheme.primary,
                                inactiveColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                                onChanged: (value) {
                                  _jumpToPage(value.round());
                                },
                              ),
                            ),
                            Text(
                              '604',
                              style: TextStyle(fontFamily: 'Cairo', color: theme.colorScheme.onSurface),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              // Floating Left Navigation Arrow (Next Page in Arabic RTL)
              Positioned(
                left: 10,
                top: 0,
                bottom: 0,
                child: Center(
                  child: AnimatedOpacity(
                    opacity: _showControls ? 0.9 : 0.2, // dim when controls are hidden
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            spreadRadius: 1,
                          )
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios_rounded, color: theme.colorScheme.primary, size: 22),
                        padding: const EdgeInsets.only(left: 6), // center it visually
                        onPressed: () {
                          if (_currentPage < 604) {
                            _pageController.animateToPage(
                              _currentPage, // goes to index = currentPage (which is pageNum = currentPage + 1)
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),

              // Floating Right Navigation Arrow (Previous Page in Arabic RTL)
              Positioned(
                right: 10,
                top: 0,
                bottom: 0,
                child: Center(
                  child: AnimatedOpacity(
                    opacity: _showControls ? 0.9 : 0.2,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            spreadRadius: 1,
                          )
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(Icons.arrow_forward_ios_rounded, color: theme.colorScheme.primary, size: 22),
                        onPressed: () {
                          if (_currentPage > 1) {
                            _pageController.animateToPage(
                              _currentPage - 2, // goes to index = currentPage - 2 (which is pageNum = currentPage - 1)
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Quick jump Surah chooser dialog
  void _showSurahJumpDialog(BuildContext context) {
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
                        _jumpToPage(surah.startPage);
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

/// Helper image widget that manages fallback URLs cleanly
class PageImageLoader extends StatefulWidget {
  final List<String> urls;

  const PageImageLoader({super.key, required this.urls});

  @override
  State<PageImageLoader> createState() => _PageImageLoaderState();
}

class _PageImageLoaderState extends State<PageImageLoader> {
  int _currentUrlIndex = 0;

  @override
  void didUpdateWidget(covariant PageImageLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset index if URLs changed
    if (oldWidget.urls.first != widget.urls.first) {
      setState(() {
        _currentUrlIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUrlIndex >= widget.urls.length) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image_rounded, color: AppTheme.errorRed, size: 48),
            SizedBox(height: 8),
            Text(
              'خطأ في تحميل الصفحة - تحقق من الاتصال بالإنترنت',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 13),
            ),
          ],
        ),
      );
    }

    String url = widget.urls[_currentUrlIndex];
    if (kIsWeb && !url.contains('githubusercontent.com') && !url.contains('jsdelivr.net')) {
      // Use proxy.cors.sh to bypass CanvasKit CORS on web for non-CORS CDNs
      url = 'https://proxy.cors.sh/$url';
    }

    return Image.network(
      url,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(
          child: CupertinoActivityIndicator(radius: 16),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        // Fallback to next URL
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _currentUrlIndex++;
            });
          }
        });
        return const Center(child: CupertinoActivityIndicator(radius: 16));
      },
    );
  }
}
