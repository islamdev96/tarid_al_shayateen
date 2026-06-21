import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../models/surah.dart';
import '../models/reciter.dart';
import '../providers/app_provider.dart';

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
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient(context)),
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

              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: _buildSearchBar(theme),
                ),
              ),

              // Surahs List
              SliverPadding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 96), // extra bottom padding for floating mini player
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final surah = filteredSurahs[index];
                      final isPlaying = provider.currentPlayingSurah?.number == surah.number;
                      return _buildSurahItem(surah, isPlaying, provider, theme);
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassCard(context),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withValues(alpha: 0.15),
            ),
            child: Icon(Icons.person_rounded, color: theme.colorScheme.primary, size: 24),
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
    return Container(
      decoration: AppTheme.glassCard(context),
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
          prefixIcon: Icon(Icons.search_rounded, color: theme.colorScheme.primary),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear_rounded, color: theme.colorScheme.primary),
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

  Widget _buildSurahItem(Surah surah, bool isPlaying, AppProvider provider, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.glassCard(context).copyWith(
        border: Border.all(
          color: isPlaying
              ? theme.colorScheme.primary
              : (isDark ? AppTheme.cardBorder : AppTheme.lightCardBorder).withValues(alpha: 0.5),
          width: isPlaying ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        onTap: () {
          provider.playSurah(surah, provider.currentReciter);
        },
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isPlaying
                ? theme.colorScheme.primary.withValues(alpha: 0.2)
                : (isDark ? AppTheme.cardBorder : AppTheme.lightCardBorder).withValues(alpha: 0.3),
          ),
          child: Center(
            child: Text(
              surah.number.toString(),
              style: TextStyle(
                color: isPlaying ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 14,
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
        trailing: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isPlaying
                ? Colors.red.withValues(alpha: 0.15)
                : theme.colorScheme.primary.withValues(alpha: 0.1),
          ),
          child: Icon(
            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            color: isPlaying ? Colors.red : theme.colorScheme.primary,
            size: 20,
          ),
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
        return Container(
          decoration: BoxDecoration(
            gradient: AppTheme.backgroundGradient(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.cardBorder : AppTheme.lightCardBorder,
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
                          Icons.mic_external_on_rounded,
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
                            ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary)
                            : null,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
