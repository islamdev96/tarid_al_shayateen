import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/glassy_background.dart';
import 'audio_category_screen.dart';

class AudioLibraryScreen extends StatelessWidget {
  const AudioLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'المكتبة الصوتية',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        body: GlassyBackground(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // "الأصوات المحملة" Button
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (_) => const AudioCategoryScreen(
                              categoryKey: 'downloads',
                              categoryName: 'الأصوات المحملة',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(CupertinoIcons.cloud_download, size: 18),
                      label: const Text(
                        'الأصوات المحملة',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 2x3 Grid representing categories
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.1,
                      children: [
                        _buildCategoryItem(
                          context,
                          key: 'adhan',
                          name: 'أذان',
                          icon: CupertinoIcons.speaker_3_fill,
                          color: const Color(0xFF5AC8FA),
                          isDark: isDark,
                        ),
                        _buildCategoryItem(
                          context,
                          key: 'iqamah',
                          name: 'إقامه',
                          icon: CupertinoIcons.speaker_1_fill,
                          color: const Color(0xFF30D158),
                          isDark: isDark,
                        ),
                        _buildCategoryItem(
                          context,
                          key: 'azkar',
                          name: 'أذكار',
                          icon: CupertinoIcons.book_fill,
                          color: const Color(0xFFFFD60A),
                          isDark: isDark,
                        ),
                        _buildCategoryItem(
                          context,
                          key: 'dua',
                          name: 'أدعيه',
                          icon: CupertinoIcons.heart_fill,
                          color: const Color(0xFFFF9F0A),
                          isDark: isDark,
                        ),
                        _buildCategoryItem(
                          context,
                          key: 'ramadan',
                          name: 'رمضانيات',
                          icon: CupertinoIcons.moon_stars_fill,
                          color: const Color(0xFFBF5AF2),
                          isDark: isDark,
                        ),
                        _buildCategoryItem(
                          context,
                          key: 'eid',
                          name: 'العيد',
                          icon: CupertinoIcons.sparkles,
                          color: const Color(0xFFFF453A),
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context, {
    required String key,
    required String name,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (_) => AudioCategoryScreen(
              categoryKey: key,
              categoryName: name,
            ),
          ),
        );
      },
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: isDark ? 0.15 : 0.12),
                border: Border.all(
                  color: color.withValues(alpha: isDark ? 0.25 : 0.18),
                  width: 0.5,
                ),
              ),
              child: Icon(
                icon,
                color: color,
                size: 26,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
