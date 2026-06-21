import 'package:flutter/material.dart';
import 'glass_container.dart';
import 'glass_theme.dart';

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
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GlassContainer(
      blur: GlassTokens.softBlur,
      opacity: GlassTokens.cardOpacity,
      borderRadius: borderRadius ?? BorderRadius.circular(GlassTokens.radius),
      padding: padding ?? const EdgeInsets.all(18),
      margin: margin,
      onTap: onTap,
      width: width,
      height: height,
      customBorder: border,
      customBoxShadow: boxShadow,
      color: color,
      clipBehavior: clipBehavior,
      tint: isDark ? GlassTokens.darkTint : GlassTokens.lightTint,
      child: child,
    );
  }
}
