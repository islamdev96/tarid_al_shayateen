import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers/app_provider.dart';

class ScheduleCard extends StatelessWidget {
  const ScheduleCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassCard(context),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.secondary.withValues(alpha: 0.15),
            ),
            child: Icon(Icons.schedule_rounded, color: theme.colorScheme.secondary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'جدولة التشغيل', 
                  style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  provider.settings.getScheduleDescription(),
                  style: TextStyle(
                    color: theme.colorScheme.onSurface, 
                    fontSize: 14, 
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: provider.settings.isEnabled,
            onChanged: (val) {
              provider.updateSettings(provider.settings.copyWith(isEnabled: val));
            },
          ),
        ],
      ),
    );
  }
}
