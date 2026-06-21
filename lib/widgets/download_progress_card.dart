import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers/app_provider.dart';
import 'glass_card.dart';

class DownloadProgressCard extends StatelessWidget {
  const DownloadProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final percent = (provider.downloadProgress * 100).toInt();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.secondary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'جاري تحميل سورة البقرة (${provider.downloadingReciterName})',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface, 
                    fontSize: 14,
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Cancel button
              GestureDetector(
                onTap: () => provider.cancelDownload(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppTheme.errorRed.withValues(alpha: 0.15),
                  ),
                  child: const Text(
                    'إلغاء', 
                    style: TextStyle(
                      color: AppTheme.errorRed, 
                      fontSize: 12, 
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: provider.downloadProgress,
              backgroundColor: isDark ? AppTheme.cardBorder : AppTheme.lightCardBorder,
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.secondary),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$percent%',
            style: TextStyle(
              color: theme.colorScheme.secondary, 
              fontSize: 13, 
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
