import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'glass_card.dart';

class HadithCard extends StatelessWidget {
  const HadithCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(CupertinoIcons.book, color: theme.colorScheme.primary, size: 28),
          const SizedBox(height: 12),
          Text(
            '«لا تجعلوا بيوتكم مقابر،\nإن الشيطان ينفر من البيت\nالذي تُقرأ فيه سورة البقرة»',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
              height: 1.8,
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'رواه مسلم',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12, 
              color: theme.textTheme.bodySmall?.color,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }
}
