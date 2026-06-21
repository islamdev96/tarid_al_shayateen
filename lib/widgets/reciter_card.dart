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

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ReciterSelectionScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.glassCard,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.gold.withValues(alpha: 0.15),
              ),
              child: const Icon(Icons.mic_rounded, color: AppTheme.gold, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('القارئ', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(
                    reciter.nameAr,
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Row(
                    children: [
                      Icon(
                        reciter.isOffline ? Icons.phone_android_rounded : Icons.wifi_rounded,
                        size: 14,
                        color: reciter.isOffline ? AppTheme.successGreen : AppTheme.accentTeal,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        reciter.isOffline ? 'بدون إنترنت' : 'أونلاين',
                        style: TextStyle(
                          fontSize: 12,
                          color: reciter.isOffline ? AppTheme.successGreen : AppTheme.accentTeal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_left_rounded, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}
