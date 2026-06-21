import 'package:flutter/material.dart';
import 'glass_container.dart';
import 'glass_theme.dart';

Future<T?> showGlassBottomSheet<T>(
  BuildContext context, {
  required Widget child,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => Padding(
      padding: const EdgeInsets.all(12),
      child: GlassContainer(
        blur: GlassTokens.strongBlur,
        opacity: GlassTokens.sheetOpacity,
        borderRadius: BorderRadius.circular(GlassTokens.radiusLarge),
        padding: const EdgeInsets.all(22),
        child: child,
      ),
    ),
  );
}

Future<T?> showGlassDialog<T>(BuildContext context, {required Widget child}) {
  return showDialog<T>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: GlassContainer(
        blur: GlassTokens.strongBlur,
        opacity: GlassTokens.sheetOpacity,
        borderRadius: BorderRadius.circular(GlassTokens.radius),
        padding: const EdgeInsets.all(24),
        child: child,
      ),
    ),
  );
}
