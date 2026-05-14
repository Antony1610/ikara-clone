import 'package:flutter/foundation.dart';

class AppLogger {
  static void logError({
    required String tag,
    required String message,
    Object? error,
    StackTrace? stackTrace,
  }) {
    debugPrint('[$tag] $message');

    if (error != null) {
      debugPrint('[$tag] Error: $error');
    }

    if (stackTrace != null) {
      debugPrint('[$tag] StackTrace: $stackTrace');
    }
  }
}
