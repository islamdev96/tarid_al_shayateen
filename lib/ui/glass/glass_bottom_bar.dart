import 'package:flutter/material.dart';
import 'glass_container.dart';
import 'glass_theme.dart';

/// Premium glassmorphic bottom navigation bar with animated pill indicator.
class GlassBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<IconData> icons;
  final List<String>? labels;

  const GlassBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.icons,
    this.labels,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? Colors.white : Colors.black87;
    final inactiveColor = isDark ? Colors.white.withValues(alpha: 0.40) : Colors.black38;

    final safeBottom = MediaQuery.of(context).padding.bottom;
    final double paddingBottom = safeBottom > 0 ? safeBottom + 6 : 18;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, paddingBottom),
      child: GlassContainer(
        blur: GlassTokens.getStrongBlur(context),
        opacity: GlassTokens.getBarOpacity(context),
        borderRadius: BorderRadius.circular(GlassTokens.radiusLarge),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        showInnerGlow: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(icons.length, (i) {
            final selected = i == currentIndex;
            final label = labels != null && i < labels!.length ? labels![i] : null;

            return GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 60,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: GlassTokens.normalDuration,
                      curve: GlassTokens.defaultCurve,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: selected
                            ? (isDark
                                ? Colors.white.withValues(alpha: 0.15)
                                : Colors.black.withValues(alpha: 0.07))
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        icons[i],
                        color: selected ? activeColor : inactiveColor,
                        size: 22,
                      ),
                    ),
                    if (label != null) ...[
                      const SizedBox(height: 2),
                      AnimatedDefaultTextStyle(
                        duration: GlassTokens.fastDuration,
                        style: TextStyle(
                          color: selected ? activeColor : inactiveColor,
                          fontSize: 9,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                          fontFamily: 'Cairo',
                        ),
                        child: Text(label),
                      ),
                    ],
                    // Animated pill indicator dot
                    const SizedBox(height: 3),
                    AnimatedContainer(
                      duration: GlassTokens.normalDuration,
                      curve: GlassTokens.defaultCurve,
                      width: selected ? 16 : 0,
                      height: 3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: selected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
