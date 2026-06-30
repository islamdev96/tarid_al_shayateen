import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../models/surah.dart';
import '../widgets/glass_card.dart';
import '../widgets/glassy_background.dart';
import 'surah_text_screen.dart';

class WrittenQuranScreen extends StatefulWidget {
  const WrittenQuranScreen({super.key});

  @override
  State<WrittenQuranScreen> createState() => _WrittenQuranScreenState();
}

class _WrittenQuranScreenState extends State<WrittenQuranScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  // Verse search variables
  Timer? _debounce;
  List<dynamic> _verseResults = [];
  bool _isSearchingVerses = false;
  String _lastSearchQuery = '';
  String? _searchError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), () {
      final trimmed = query.trim();
      if (trimmed.length >= 3) {
        _performVerseSearch(trimmed);
      } else {
        setState(() {
          _verseResults = [];
          _isSearchingVerses = false;
          _searchError = null;
        });
      }
    });
  }

  Future<void> _performVerseSearch(String query) async {
    if (query == _lastSearchQuery) return;
    _lastSearchQuery = query;

    setState(() {
      _isSearchingVerses = true;
      _searchError = null;
    });

    try {
      final encodedQuery = Uri.encodeComponent(query);
      final response = await http.get(
        Uri.parse('https://api.alquran.cloud/v1/search/$encodedQuery/all/ar')
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 200 && data['data'] != null) {
          setState(() {
            _verseResults = data['data']['matches'] ?? [];
            // Automatically switch to the verses tab if they searched for a word and got results
            if (_verseResults.isNotEmpty && _tabController.index == 0) {
              _tabController.animateTo(1);
            }
          });
        } else {
          setState(() {
            _searchError = 'تعذر العثور على نتائج. حاول مرة أخرى.';
          });
        }
      } else {
        setState(() {
          _searchError = 'خطأ في الاتصال بالخادم. تأكد من الإنترنت.';
        });
      }
    } catch (e) {
      setState(() {
        _searchError = 'فشل البحث: تحقق من اتصال الإنترنت';
      });
      debugPrint('Error searching verses: $e');
    } finally {
      setState(() {
        _isSearchingVerses = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final filteredSurahs = Surah.allSurahs.where((surah) {
      final nameArNormalized = surah.nameAr
          .replaceAll('أ', 'ا')
          .replaceAll('إ', 'ا')
          .replaceAll('آ', 'ا')
          .replaceAll('ة', 'ه');
      final queryNormalized = _searchQuery
          .replaceAll('أ', 'ا')
          .replaceAll('إ', 'ا')
          .replaceAll('آ', 'ا')
          .replaceAll('ة', 'ه');
      return surah.nameAr.contains(_searchQuery) ||
          nameArNormalized.contains(queryNormalized) ||
          surah.nameEn.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          surah.number.toString() == _searchQuery;
    }).toList();

    return Scaffold(
      body: GlassyBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(theme, isDark),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: _buildSearchBar(theme, isDark),
              ),

              // Custom TabBar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                      width: 0.5,
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: theme.colorScheme.primary,
                    unselectedLabelColor: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Cairo'),
                    tabs: [
                      Tab(text: 'فهرس السور (${filteredSurahs.length})'),
                      Tab(text: 'البحث بالآيات (${_verseResults.length})'),
                    ],
                  ),
                ),
              ),

              // TabBar View
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Surah List
                    _buildSurahList(filteredSurahs, theme, isDark),

                    // Tab 2: Verses Search List
                    _buildVerseSearchList(theme, isDark),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_forward_ios_rounded, color: theme.colorScheme.primary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'القرآن الكريم المكتوب',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
          ),
          const SizedBox(width: 48), // Spacer to balance back button
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme, bool isDark) {
    return GlassCard(
      borderRadius: BorderRadius.circular(16),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        style: TextStyle(color: theme.colorScheme.onSurface, fontFamily: 'Cairo'),
        decoration: InputDecoration(
          hintText: 'ابحث باسم السورة، أو اكتب آية/كلمة للبحث...',
          hintStyle: TextStyle(
            color: isDark ? AppTheme.textMuted : AppTheme.lightTextMuted,
            fontSize: 13,
            fontFamily: 'Cairo',
          ),
          prefixIcon: Icon(CupertinoIcons.search, color: theme.colorScheme.primary, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(CupertinoIcons.xmark_circle_fill, color: theme.colorScheme.primary, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildSurahList(List<Surah> surahs, ThemeData theme, bool isDark) {
    if (surahs.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد سور مطابقة لبحثك',
          style: TextStyle(fontFamily: 'Cairo', fontSize: 15),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 120),
      itemCount: surahs.length,
      itemBuilder: (context, index) {
        final surah = surahs[index];
        return GlassCard(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SurahTextScreen(surah: surah)),
              );
            },
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                  width: 0.5,
                ),
              ),
              child: Center(
                child: Text(
                  surah.number.toString(),
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            title: Text(
              'سورة ${surah.nameAr}',
              style: const TextStyle(
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
            trailing: Icon(
              Icons.arrow_forward_ios_rounded,
              color: theme.colorScheme.primary,
              size: 16,
            ),
          ),
        );
      },
    );
  }

  Widget _buildVerseSearchList(ThemeData theme, bool isDark) {
    if (_isSearchingVerses) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoActivityIndicator(radius: 16),
            SizedBox(height: 16),
            Text(
              'جاري البحث في آيات القرآن الكريم...',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (_searchError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(CupertinoIcons.wifi_exclamationmark, color: Colors.amber, size: 48),
              const SizedBox(height: 16),
              Text(
                _searchError!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    if (_searchQuery.trim().length < 3) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'اكتب 3 أحرف أو أكثر للبحث في كامل آيات المصحف الشريف بكلمة أو جملة...',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Cairo', fontSize: 14, height: 1.5),
          ),
        ),
      );
    }

    if (_verseResults.isEmpty) {
      return const Center(
        child: Text(
          'لم يتم العثور على آيات تطابق هذا البحث',
          style: TextStyle(fontFamily: 'Cairo', fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 120),
      itemCount: _verseResults.length,
      itemBuilder: (context, index) {
        final match = _verseResults[index];
        final verseText = match['text'] as String;
        final verseNum = match['numberInSurah'] as int;
        final surahData = match['surah'] as Map<String, dynamic>;
        final surahNum = surahData['number'] as int;
        final surahName = surahData['name'] as String;

        return GlassCard(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          child: InkWell(
            onTap: () {
              final surah = Surah.findByNumber(surahNum);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SurahTextScreen(
                    surah: surah,
                    initialVerseNumber: verseNum,
                  ),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Verse Text
                Text(
                  verseText,
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.amiri(
                    fontSize: 18,
                    height: 1.8,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                // Metadata
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'الآية $verseNum',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 12,
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      surahName,
                      style: TextStyle(
                        color: isDark ? AppTheme.accentTeal : AppTheme.lightGold,
                        fontSize: 13,
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
