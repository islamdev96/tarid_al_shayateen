import 'package:flutter/material.dart';
import 'glass_container.dart';
import 'glass_theme.dart';

class GlassBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<IconData> icons;

  const GlassBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.icons,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? Colors.white : Colors.black87;
    final inactiveColor = isDark ? Colors.white.withValues(alpha: 0.55) : Colors.black54;
    final selectedBgColor = isDark 
        ? Colors.white.withValues(alpha: 0.20) 
        : Colors.black.withValues(alpha: 0.08);

    final safeBottom = MediaQuery.of(context).padding.bottom;
    final double paddingBottom = safeBottom > 0 ? safeBottom + 6 : 18;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, paddingBottom),
      child: GlassContainer(
        blur: GlassTokens.getStrongBlur(context),
        opacity: GlassTokens.getBarOpacity(context),
        borderRadius: BorderRadius.circular(GlassTokens.radiusLarge),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(icons.length, (i) {
            final selected = i == currentIndex;
            return GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: selected ? selectedBgColor : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icons[i],
                  color: selected ? activeColor : inactiveColor,
                  size: 26,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
