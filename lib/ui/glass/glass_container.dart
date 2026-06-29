import 'dart:ui';
import 'package:flutter/material.dart';
import 'glass_theme.dart';

/// Premium glassmorphic container with frosted blur, specular border,
/// inner glow, and realistic iOS-style depth.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? blur;
  final double? opacity;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? tint;
  final bool showBorder;
  final bool showInnerGlow;
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
    this.showInnerGlow = true,
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

    // Specular border gradient (light reflection from top-left to bottom-right)
    final double specularOpacity = GlassTokens.getSpecularOpacity(context);
    final double baseOpacity = opacity ?? (isDark ? 0.07 : 0.50);

    final content = Container(
      width: width,
      height: height,
      // Outer specular border container
      padding: showBorder && customBorder == null ? const EdgeInsets.all(0.5) : EdgeInsets.zero,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: customBorder,
        // Specular highlight gradient simulating glass edge reflection
        gradient: showBorder && customBorder == null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: specularOpacity),
                  Colors.white.withValues(alpha: specularOpacity * 0.05),
                ],
              )
            : null,
        boxShadow: customBoxShadow ?? [
          // Layer 1: Deep ambient shadow
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.08),
            blurRadius: GlassTokens.ambientShadowBlur,
            spreadRadius: -4,
            offset: const Offset(0, GlassTokens.floatingElevation),
          ),
          // Layer 2: Crisp outline shadow
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.04),
            blurRadius: GlassTokens.crispShadowBlur,
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
              // Translucent frosted glass tint
              gradient: customGradient ?? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: baseOpacity),
                  Colors.white.withValues(alpha: baseOpacity * 0.30),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Inner glow overlay (subtle radial highlight at top-left)
                if (showInnerGlow)
                  Positioned(
                    top: -20,
                    left: -20,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withValues(
                              alpha: GlassTokens.getInnerGlowOpacity(context),
                            ),
                            Colors.white.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                // The actual content
                child,
              ],
            ),
          ),
        ),
      ),
    );

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: onTap == null
          ? content
          : GestureDetector(
              onTap: onTap,
              child: content,
            ),
    );
  }
}
