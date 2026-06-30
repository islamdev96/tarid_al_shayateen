import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PaperMushafScreen extends StatefulWidget {
  const PaperMushafScreen({super.key});

  @override
  State<PaperMushafScreen> createState() => _PaperMushafScreenState();
}

class _PaperMushafScreenState extends State<PaperMushafScreen> {
  late PageController _pageController;
  int _currentPage = 1;
  bool _showControls = false;

  // Real paper color - soft creamy yellow
  static const Color _paperColor = Color(0xFFF9E8C0); 
  
  @override
  void initState() {
    super.initState();
    // Start at page 1 (which is index 603 if reverse, but let's map it cleanly)
    // In PageView with reverse: true, index 0 is the right-most page.
    // If we map index to pageNumber: pageNumber = index + 1
    // Wait, Arabic reads Right-To-Left. 
    // PageView with reverse: true means swipe left to go to higher index.
    // Index 0 -> Page 1. Swipe Left -> Index 1 -> Page 2. This is exactly how Arabic books work.
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index + 1;
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFEFEFEF),
      body: SafeArea(
        child: Stack(
          children: [
            // Interactive Page Viewer
            GestureDetector(
              onTap: _toggleControls,
              child: PageView.builder(
                controller: _pageController,
                reverse: true, // Right to left flipping
                itemCount: 604,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  final pageNumber = index + 1;
                  final paddedNumber = pageNumber.toString().padLeft(3, '0');
                  String imageUrl = 'https://android.quran.com/data/width_1024/page$paddedNumber.png';
                  
                  if (kIsWeb) {
                    // Use api.allorigins.win with URL encoding since android.quran.com blocks direct web requests
                    imageUrl = 'https://api.allorigins.win/raw?url=${Uri.encodeComponent(imageUrl)}';
                  }

                  return Center(
                    child: Hero(
                      tag: 'mushaf_page_$pageNumber',
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 10,
                              spreadRadius: 2,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        child: ColorFiltered(
                          // Multiply the paper color with the white background of the image
                          colorFilter: ColorFilter.mode(
                            isDark ? _paperColor.withValues(alpha: 0.8) : _paperColor,
                            BlendMode.multiply,
                          ),
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => Container(
                              color: _paperColor,
                              child: const Center(child: CircularProgressIndicator(color: Colors.brown)),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: _paperColor,
                              child: const Center(
                                child: Icon(Icons.error_outline, color: Colors.brown, size: 40),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Top Bar
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              top: _showControls ? 0 : -100,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                color: theme.scaffoldBackgroundColor.withValues(alpha: 0.9),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'المصحف الورقي',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Balance for back button
                  ],
                ),
              ),
            ),

            // Bottom Bar (Slider)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              bottom: _showControls ? 0 : -100,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                color: theme.scaffoldBackgroundColor.withValues(alpha: 0.9),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'الصفحة $_currentPage',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Slider(
                        value: _currentPage.toDouble(),
                        min: 1,
                        max: 604,
                        activeColor: theme.colorScheme.primary,
                        inactiveColor: theme.colorScheme.primary.withValues(alpha: 0.3),
                        onChanged: (value) {
                          setState(() {
                            _currentPage = value.toInt();
                          });
                        },
                        onChangeEnd: (value) {
                          _pageController.jumpToPage(value.toInt() - 1);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
