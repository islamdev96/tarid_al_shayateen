import 'package:flutter/services.dart';

/// Service to request ignoring battery optimizations on Android.
/// This ensures alarms fire reliably even when the app is in background.
class BatteryService {
  static const _channel = MethodChannel('com.islamglab.tarid/battery');

  /// Checks if battery optimization is already ignored for this app.
  static Future<bool> isIgnoringBatteryOptimizations() async {
    try {
      final result = await _channel.invokeMethod<bool>('isIgnoringBatteryOptimizations');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Requests the user to disable battery optimization for this app.
  static Future<void> requestIgnoreBatteryOptimizations() async {
    try {
      await _channel.invokeMethod('requestIgnoreBatteryOptimizations');
    } catch (_) {
      // Silently fail - not critical
    }
  }
}
