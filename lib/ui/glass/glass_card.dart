import 'package:flutter/material.dart';
import 'glass_container.dart';
import 'glass_theme.dart';

/// A premium glassmorphic card widget with optional glow and elevated variants.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final Color? color;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final Clip clipBehavior;
  final Color? glowColor;
  final bool elevated;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.color,
    this.width,
    this.height,
    this.onTap,
    this.clipBehavior = Clip.antiAlias,
    this.glowColor,
    this.elevated = false,
  });

  /// Creates a GlassCard with an accent glow effect.
  const GlassCard.glow({
    super.key,
    required this.child,
    required Color this.glowColor,
    this.padding,
    this.margin,
    this.borderRadius,
    this.border,
    this.color,
    this.width,
    this.height,
    this.onTap,
    this.clipBehavior = Clip.antiAlias,
  })  : boxShadow = null,
        elevated = false;

  /// Creates a GlassCard with deeper elevation.
  const GlassCard.elevated({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.border,
    this.color,
    this.width,
    this.height,
    this.onTap,
    this.clipBehavior = Clip.antiAlias,
  })  : boxShadow = null,
        glowColor = null,
        elevated = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Build custom shadows for glow/elevated variants
    List<BoxShadow>? resolvedShadows = boxShadow;
    if (glowColor != null) {
      resolvedShadows = [
        BoxShadow(
          color: glowColor!.withValues(alpha: 0.12),
          blurRadius: 24,
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.06),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];
    } else if (elevated) {
      resolvedShadows = [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.50 : 0.12),
          blurRadius: 36,
          spreadRadius: -2,
          offset: const Offset(0, 16),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
    }

    return GlassContainer(
      borderRadius: borderRadius ?? BorderRadius.circular(GlassTokens.radius),
      padding: padding ?? const EdgeInsets.all(18),
      margin: margin,
      onTap: onTap,
      width: width,
      height: height,
      customBorder: border,
      customBoxShadow: resolvedShadows,
      color: color,
      clipBehavior: clipBehavior,
      child: child,
    );
  }
}
