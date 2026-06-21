import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers/app_provider.dart';
import '../screens/reciter_selection_screen.dart';

class ReciterCard extends StatelessWidget {
  const ReciterCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final reciter = provider.currentReciter;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ReciterSelectionScreen()),
      ),
      child: Container(
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
              child: Icon(Icons.mic_rounded, color: theme.colorScheme.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'القارئ', 
                    style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    reciter.nameAr,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface, 
                      fontSize: 16, 
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        reciter.isOffline ? Icons.phone_android_rounded : Icons.wifi_rounded,
                        size: 14,
                        color: reciter.isOffline ? AppTheme.successGreen : theme.colorScheme.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        reciter.isOffline ? 'بدون إنترنت' : 'أونلاين',
                        style: TextStyle(
                          fontSize: 12,
                          color: reciter.isOffline ? AppTheme.successGreen : theme.colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_left_rounded, color: theme.textTheme.bodySmall?.color),
          ],
        ),
      ),
    );
  }
}
