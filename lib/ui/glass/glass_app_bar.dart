import 'dart:ui';
import 'package:flutter/material.dart';
import 'glass_theme.dart';

class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const GlassAppBar({super.key, required this.title, this.actions});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tintColor = GlassTokens.getTint(context);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: GlassTokens.getStrongBlur(context),
          sigmaY: GlassTokens.getStrongBlur(context),
        ),
        child: AppBar(
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              fontFamily: 'Cairo',
            ),
          ),
          centerTitle: true,
          backgroundColor: tintColor.withValues(alpha: GlassTokens.getBarOpacity(context)),
          elevation: 0,
          foregroundColor: isDark ? Colors.white : Colors.black87,
          actions: actions,
        ),
      ),
    );
  }
}
