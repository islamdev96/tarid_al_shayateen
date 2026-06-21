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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      child: GlassContainer(
        blur: GlassTokens.strongBlur,
        opacity: GlassTokens.barOpacity,
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
                  color: selected
                      ? Colors.white.withValues(alpha: 0.22)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icons[i],
                  color: selected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.6),
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
