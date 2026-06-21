import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers/app_provider.dart';
import 'glass_card.dart';

class CountdownWidget extends StatefulWidget {
  const CountdownWidget({super.key});

  @override
  State<CountdownWidget> createState() => _CountdownWidgetState();
}

class _CountdownWidgetState extends State<CountdownWidget> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final nextTime = provider.nextPlayback;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (nextTime == null || !provider.settings.isEnabled) {
      return const SizedBox.shrink();
    }

    final diff = nextTime.difference(DateTime.now());
    if (diff.isNegative) {
      return const SizedBox.shrink();
    }

    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;
    final seconds = diff.inSeconds % 60;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.hourglass, color: theme.colorScheme.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'التشغيل القادم بعد', 
                style: TextStyle(
                  color: theme.colorScheme.onSurface, 
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (days > 0) _buildTimeUnit(days.toString(), 'يوم', theme, isDark),
              if (days > 0) const SizedBox(width: 16),
              _buildTimeUnit(hours.toString().padLeft(2, '0'), 'ساعة', theme, isDark),
              const SizedBox(width: 16),
              _buildTimeUnit(minutes.toString().padLeft(2, '0'), 'دقيقة', theme, isDark),
              const SizedBox(width: 16),
              _buildTimeUnit(seconds.toString().padLeft(2, '0'), 'ثانية', theme, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeUnit(String value, String label, ThemeData theme, bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3), width: 0.5),
          ),
          child: Text(
            value, 
            style: TextStyle(
              fontSize: 22, 
              fontWeight: FontWeight.bold, 
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label, 
          style: TextStyle(
            fontSize: 11, 
            color: isDark ? AppTheme.textMuted : AppTheme.lightTextMuted,
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }
}
