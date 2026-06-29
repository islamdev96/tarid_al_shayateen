import 'dart:ui';
import 'package:flutter/material.dart';
import 'glass_theme.dart';

/// Premium glassmorphic pill-shaped button with tap scale animation.
class GlassButton extends StatefulWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback? onTap;
  final Color? color;
  final bool outlined;
  final bool iconOnly;
  final double? width;
  final EdgeInsetsGeometry? padding;

  const GlassButton({
    super.key,
    this.label,
    this.icon,
    this.onTap,
    this.color,
    this.outlined = false,
    this.iconOnly = false,
    this.width,
    this.padding,
  });

  /// Creates an outlined glass button variant.
  const GlassButton.outline({
    super.key,
    this.label,
    this.icon,
    this.onTap,
    this.color,
    this.width,
    this.padding,
  })  : outlined = true,
        iconOnly = false;

  /// Creates a circular icon-only glass button.
  const GlassButton.icon({
    super.key,
    required IconData this.icon,
    this.onTap,
    this.color,
    this.padding,
  })  : label = null,
        outlined = false,
        iconOnly = true,
        width = null;

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _scaleController.forward();
  void _onTapUp(TapUpDetails _) => _scaleController.reverse();
  void _onTapCancel() => _scaleController.reverse();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = widget.color ?? Theme.of(context).colorScheme.primary;
    final blur = GlassTokens.getSoftBlur(context) * 0.6;

    if (widget.iconOnly) {
      return _buildIconButton(isDark, accentColor, blur);
    }

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(GlassTokens.radiusPill),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: Container(
              width: widget.width,
              padding: widget.padding ??
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(GlassTokens.radiusPill),
                color: widget.outlined
                    ? Colors.transparent
                    : accentColor.withValues(alpha: isDark ? 0.18 : 0.12),
                border: Border.all(
                  color: accentColor.withValues(alpha: isDark ? 0.35 : 0.25),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: widget.width != null
                    ? MainAxisSize.max
                    : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.label != null)
                    Text(
                      widget.label!,
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  if (widget.label != null && widget.icon != null)
                    const SizedBox(width: 8),
                  if (widget.icon != null)
                    Icon(widget.icon, color: accentColor, size: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(bool isDark, Color accentColor, double blur) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.onTap,
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: Container(
              width: 48,
              height: 48,
              padding: widget.padding ?? const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withValues(alpha: isDark ? 0.15 : 0.10),
                border: Border.all(
                  color: accentColor.withValues(alpha: isDark ? 0.25 : 0.18),
                  width: 0.5,
                ),
              ),
              child: Icon(widget.icon, color: accentColor, size: 20),
            ),
          ),
        ),
      ),
    );
  }
}
