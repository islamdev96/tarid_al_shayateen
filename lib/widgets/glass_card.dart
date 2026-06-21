import 'dart:ui';
import 'package:flutter/material.dart';

/// A premium, true iOS-style glassmorphic card widget.
/// Uses BackdropFilter with ImageFilter.blur to perform real-time background blurring.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final Color? color;
  final Clip clipBehavior;
  final double? width;
  final double? height;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.color,
    this.clipBehavior = Clip.antiAlias,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? BorderRadius.circular(16);

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        clipBehavior: clipBehavior,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: color ?? (isDark 
                  ? const Color(0xFF0C1921).withValues(alpha: 0.45) 
                  : Colors.white.withValues(alpha: 0.45)),
              borderRadius: radius,
              border: border ?? Border.all(
                color: isDark 
                    ? Colors.white.withValues(alpha: 0.12) 
                    : Colors.white.withValues(alpha: 0.35),
                width: 0.5, // Thin iOS border line
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
