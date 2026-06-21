import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/dhikr.dart';
import 'dhikr_session_screen.dart';

class AzkarScreen extends StatelessWidget {
  const AzkarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient(context)),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                backgroundColor: Colors.transparent,
                title: const Text('أذكار التحصين اليومية'),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
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
                      icon: Icons.wb_sunny_rounded,
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
                      icon: Icons.mode_night_rounded,
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
                      icon: Icons.hotel_rounded,
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
                      icon: Icons.meeting_room_rounded,
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
                      icon: Icons.wb_twilight_rounded,
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
                      icon: Icons.explore_rounded,
                      iconColor: Colors.cyan,
                      count: Dhikr.getByCategory(DhikrCategory.travel).length,
                      theme: theme,
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHadithHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(Icons.check_circle_outline_rounded, color: theme.colorScheme.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            'أذكار مأثورة بأحاديث صحيحة مسندة من كتب السنة النبوية المطهرة لتحصين النفس والبيت.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.5,
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: AppTheme.glassCard(context).copyWith(
          borderRadius: BorderRadius.circular(20), // Smooth iOS-style rounded corners
        ),
        child: Row(
          children: [
            // iOS Chevron on the far left (leading in RTL)
            Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 14,
              color: isDark ? AppTheme.textMuted : AppTheme.lightTextMuted,
            ),
            const SizedBox(width: 8),

            // iOS-style count badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: (isDark ? AppTheme.cardBorder : AppTheme.lightCardBorder).withValues(alpha: 0.15),
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
                color: iconColor, // Solid background color matching screenshot
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
}
