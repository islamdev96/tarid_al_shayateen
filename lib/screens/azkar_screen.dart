import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/dhikr.dart';
import 'dhikr_session_screen.dart';

class AzkarScreen extends StatelessWidget {
  const AzkarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
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
                    _buildHadithHeader(),
                    const SizedBox(height: 32),
                    
                    _buildCategoryCard(
                      context,
                      category: DhikrCategory.morning,
                      title: 'أذكار الصباح',
                      subtitle: 'تحصين يومك من شروق الشمس حتى زوالها',
                      icon: Icons.wb_sunny_rounded,
                      iconColor: AppTheme.gold,
                      count: Dhikr.getByCategory(DhikrCategory.morning).length,
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
                    ),
                    const SizedBox(height: 16),
                    
                    _buildCategoryCard(
                      context,
                      category: DhikrCategory.sleep,
                      title: 'أذكار النوم',
                      subtitle: 'حرزك وحفظك من الشياطين حتى تصبح',
                      icon: Icons.hotel_rounded,
                      iconColor: AppTheme.textSecondary,
                      count: Dhikr.getByCategory(DhikrCategory.sleep).length,
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

  Widget _buildHadithHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.gold.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.2)),
      ),
      child: const Column(
        children: [
          Icon(Icons.check_circle_outline_rounded, color: AppTheme.gold, size: 24),
          SizedBox(height: 8),
          Text(
            'أذكار مأثورة بأحاديث صحيحة مسندة من كتب السنة النبوية المطهرة لتحصين النفس والبيت.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.gold,
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
  }) {
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
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.glassCard,
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor.withValues(alpha: 0.15),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.cardBorder.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count أذكار',
                style: const TextStyle(
                  color: AppTheme.gold,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
