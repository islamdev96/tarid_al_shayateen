import 'package:flutter/foundation.dart';

/// Platform-specific configuration helper.
class PlatformUtils {
  PlatformUtils._();

  /// Whether current execution environment is Web browser.
  static bool get isWeb => kIsWeb;

  /// Safe file system operations guard (blocks IO execution on web).
  static void runOnMobile(VoidCallback callback) {
    if (!kIsWeb) {
      callback();
    }
  }
}
