import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../app_theme.dart';
import '../models/dhikr.dart';
import 'dhikr_session_screen.dart';
import 'tasbeeh_screen.dart';
import '../widgets/glass_card.dart';
import '../widgets/glassy_background.dart';

class AzkarScreen extends StatelessWidget {
  const AzkarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: GlassyBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                backgroundColor: Colors.transparent,
                title: const Text(
                  'حصن المسلم',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 120), // bottom padding for floating mini player
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 12),
                    _buildHadithHeader(theme),
                    const SizedBox(height: 32),
                    
                    _buildCategoryCard(
                      context,
                      category: DhikrCategory.morning,
                      title: 'أذكار الصباح',
                      subtitle: 'تحصين يومك من شروق الشمس حتى زوالها',
                      icon: CupertinoIcons.sun_max_fill,
                      iconColor: theme.brightness == Brightness.dark ? AppTheme.gold : AppTheme.lightGold,
                      count: Dhikr.getByCategory(DhikrCategory.morning).length,
                      theme: theme,
                    ),
                    const SizedBox(height: 16),
                    
                    _buildCategoryCard(
                      context,
                      category: DhikrCategory.evening,
                      title: 'أذكار المساء',
                      subtitle: 'تحصين ليلك من زوال الشمس حتى غروبها',
                      icon: CupertinoIcons.moon_fill,
                      iconColor: AppTheme.accentTeal,
                      count: Dhikr.getByCategory(DhikrCategory.evening).length,
                      theme: theme,
                    ),
                    const SizedBox(height: 16),
                    
                    _buildCategoryCard(
                      context,
                      category: DhikrCategory.sleep,
                      title: 'أذكار النوم',
                      subtitle: 'حرزك وحفظك من الشياطين حتى تصبح',
                      icon: CupertinoIcons.bed_double_fill,
                      iconColor: theme.brightness == Brightness.dark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
                      count: Dhikr.getByCategory(DhikrCategory.sleep).length,
                      theme: theme,
                    ),
                    const SizedBox(height: 16),
 
                    _buildCategoryCard(
                      context,
                      category: DhikrCategory.afterPrayer,
                      title: 'أذكار بعد الصلاة',
                      subtitle: 'الحصن المنيع بعد أداء الصلوات المفروضة',
                      icon: Icons.mosque_rounded,
                      iconColor: theme.colorScheme.primary,
                      count: Dhikr.getByCategory(DhikrCategory.afterPrayer).length,
                      theme: theme,
                    ),
                    const SizedBox(height: 16),
 
                    _buildCategoryCard(
                      context,
                      category: DhikrCategory.mosque,
                      title: 'أذكار المسجد',
                      subtitle: 'أدعية دخول وخروج المسجد لبركة العبادة',
                      icon: CupertinoIcons.square_arrow_right_fill,
                      iconColor: Colors.amber,
                      count: Dhikr.getByCategory(DhikrCategory.mosque).length,
                      theme: theme,
                    ),
                    const SizedBox(height: 16),
 
                    _buildCategoryCard(
                      context,
                      category: DhikrCategory.wakingUp,
                      title: 'أذكار الاستيقاظ',
                      subtitle: 'أول ما تبدأ به يومك بعد اليقظة بالحمد والذكر',
                      icon: CupertinoIcons.sunrise_fill,
                      iconColor: Colors.orangeAccent,
                      count: Dhikr.getByCategory(DhikrCategory.wakingUp).length,
                      theme: theme,
                    ),
                    const SizedBox(height: 16),
 
                    _buildCategoryCard(
                      context,
                      category: DhikrCategory.travel,
                      title: 'أدعية وأذكار السفر',
                      subtitle: 'دعاء السفر المأثور للحفظ والأمان في الطريق',
                      icon: CupertinoIcons.compass_fill,
                      iconColor: Colors.cyan,
                      count: Dhikr.getByCategory(DhikrCategory.travel).length,
                      theme: theme,
                    ),
                    const SizedBox(height: 16),
                    _buildTasbeehCard(context, theme),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildHadithHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.25), width: 0.5),
      ),
      child: Column(
        children: [
          Icon(CupertinoIcons.checkmark_seal, color: theme.colorScheme.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            'أذكار مأثورة بأحاديث صحيحة مسندة من كتب السنة النبوية المطهرة لتحصين النفس والبيت.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.5,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required DhikrCategory category,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required int count,
    required ThemeData theme,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DhikrSessionScreen(category: category),
          ),
        );
      },
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        borderRadius: BorderRadius.circular(20), // Smooth iOS-style rounded corners
        child: Row(
          children: [
            // iOS Chevron on the far left (leading in RTL)
            Icon(
              CupertinoIcons.chevron_left,
              size: 14,
              color: isDark ? AppTheme.textMuted : AppTheme.lightTextMuted,
            ),
            const SizedBox(width: 8),
 
            // iOS-style count badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
            
            const Spacer(),
 
            // Texts in the middle (aligned to the right next to the trailing icon)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end, // RTL alignment
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
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
            ),
 
            // iOS-style Trailing Icon Squircle on the far right (trailing in RTL)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor, // Solid background color
                borderRadius: BorderRadius.circular(14), // Rounded square/squircle
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white, // White icon inside
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasbeehCard(BuildContext context, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final iconColor = const Color(0xFFA855F7); // Premium purple
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const TasbeehScreen(),
          ),
        );
      },
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            Icon(
              CupertinoIcons.chevron_left,
              size: 14,
              color: isDark ? AppTheme.textMuted : AppTheme.lightTextMuted,
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                CupertinoIcons.checkmark,
                color: Color(0xFFA855F7),
                size: 14,
              ),
            ),
            const Spacer(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'المسبحة الإلكترونية',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'عداد ذكي للتسبيح والاستغفار وحفظ أذكارك اليومية',
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
            ),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                CupertinoIcons.infinite,
                color: Colors.white,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
