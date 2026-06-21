import 'package:flutter/material.dart';
import '../app_theme.dart';

class HadithCard extends StatelessWidget {
  const HadithCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassCard,
      child: Column(
        children: [
          const Icon(Icons.auto_stories_rounded, color: AppTheme.gold, size: 28),
          const SizedBox(height: 8),
          Text(
            '«لا تجعلوا بيوتكم مقابر،\nإن الشيطان ينفر من البيت\nالذي تُقرأ فيه سورة البقرة»',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppTheme.textPrimary.withValues(alpha: 0.9),
              height: 1.8,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'رواه مسلم',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }
}
