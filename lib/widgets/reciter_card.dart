import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers/app_provider.dart';
import '../screens/reciter_selection_screen.dart';
import 'glass_card.dart';

class ReciterCard extends StatelessWidget {
  const ReciterCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final reciter = provider.currentReciter;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ReciterSelectionScreen()),
      ),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
              ),
              child: Icon(CupertinoIcons.music_mic, color: theme.colorScheme.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'القارئ', 
                    style: TextStyle(
                      color: isDark ? AppTheme.textMuted : AppTheme.lightTextMuted, 
                      fontSize: 12,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    reciter.nameAr,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface, 
                      fontSize: 16, 
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        reciter.isOffline ? CupertinoIcons.phone : CupertinoIcons.wifi,
                        size: 14,
                        color: reciter.isOffline ? AppTheme.successGreen : theme.colorScheme.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        reciter.isOffline ? 'بدون إنترنت' : 'أونلاين',
                        style: TextStyle(
                          fontSize: 12,
                          color: reciter.isOffline ? AppTheme.successGreen : theme.colorScheme.secondary,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(CupertinoIcons.chevron_left, color: isDark ? AppTheme.textMuted : AppTheme.lightTextMuted, size: 16),
          ],
        ),
      ),
    );
  }
}
