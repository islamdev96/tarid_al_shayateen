import 'dart:ui';
import 'package:flutter/material.dart';
import 'glass_theme.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color tint;       // لون الزجاج (أبيض للوضع الفاتح / غامق للداكن)
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
    this.blur = GlassTokens.softBlur,
    this.opacity = GlassTokens.cardOpacity,
    this.borderRadius = const BorderRadius.all(Radius.circular(22)),
    this.padding,
    this.margin,
    this.tint = const Color(0xFFEBEBF5),
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
    // Resolve tint/overlay color
    final double resolvedOpacity = opacity;
    final Color tintColor = color ?? tint;

    final content = ClipRRect(
      borderRadius: borderRadius,
      clipBehavior: clipBehavior,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            // تدرّج خفيف يدّي إحساس انعكاس الضوء على الزجاج
            gradient: customGradient ?? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                tintColor.withValues(alpha: (resolvedOpacity + 0.06).clamp(0.0, 1.0)),
                tintColor.withValues(alpha: (resolvedOpacity * 0.5).clamp(0.0, 1.0)),
              ],
            ),
            border: customBorder ?? (showBorder
                ? Border.all(
                    color: tintColor.withValues(alpha: GlassTokens.borderOpacity),
                    width: 0.5,
                  )
                : null),
            boxShadow: customBoxShadow ?? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
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
