import 'dart:ui';
import 'package:flutter/material.dart';
import 'glass_theme.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? blur;
  final double? opacity;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? tint;       // لون الزجاج (أبيض للوضع الفاتح / غامق للداكن)
  final bool showBorder;
  final VoidCallback? onTap;

  // Backward compatibility fields
  final double? width;
  final double? height;
  final BoxBorder? customBorder;
  final List<BoxShadow>? customBoxShadow;
  final Gradient? customGradient;
  final Color? color;
  final Clip clipBehavior;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur,
    this.opacity,
    this.borderRadius = const BorderRadius.all(Radius.circular(22)),
    this.padding,
    this.margin,
    this.tint,
    this.showBorder = true,
    this.onTap,
    this.width,
    this.height,
    this.customBorder,
    this.customBoxShadow,
    this.customGradient,
    this.color,
    this.clipBehavior = Clip.antiAlias,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resolvedBlur = blur ?? GlassTokens.getSoftBlur(context);
    
    // Specular border opacity (fades out at bottom-right)
    final double borderOpacity = isDark ? 0.22 : 0.40;
    final double baseOpacity = opacity ?? (isDark ? 0.11 : 0.26);
    
    final content = Container(
      width: width,
      height: height,
      padding: showBorder && customBorder == null ? const EdgeInsets.all(0.8) : EdgeInsets.zero, // Outer border gap
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: customBorder,
        // Gradient simulating specularity (light reflection)
        gradient: showBorder && customBorder == null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: borderOpacity),
                  Colors.white.withValues(alpha: borderOpacity * 0.12),
                ],
              )
            : null,
        boxShadow: customBoxShadow ?? [
          // iOS-style deep ambient shadow
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 28,
            spreadRadius: -2,
            offset: const Offset(0, 12),
          ),
          // iOS-style crisp outline shadow
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        clipBehavior: clipBehavior,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: resolvedBlur, sigmaY: resolvedBlur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              // Translucent frosted glass backing tint
              gradient: customGradient ?? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: baseOpacity),
                  Colors.white.withValues(alpha: baseOpacity * 0.35),
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: onTap == null
          ? content
          : Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: borderRadius,
                onTap: onTap,
                child: content,
              ),
            ),
    );
  }
}
