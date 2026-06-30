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
    // Build custom shadows for glow/elevated variants
    List<BoxShadow>? resolvedShadows;

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
