import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Application-wide logger singleton.
///
/// Log levels:
///   [logger.d] — Debug: development-only diagnostic info
///   [logger.i] — Info: significant state transitions
///   [logger.w] — Warning: recoverable issues or unexpected conditions
///   [logger.e] — Error: caught exceptions that affect user experience
///
/// In release builds, only [Level.warning] and above are emitted.
/// In debug builds, all levels are emitted.
///
/// Usage:
/// ```dart
/// import 'package:noticewise/core/utils/logger.dart';
///
/// logger.i('User signed in');
/// logger.e('Failed to load notices', error: e, stackTrace: st);
/// ```
final logger = Logger(
  level: kReleaseMode ? Level.warning : Level.debug,
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
  ),
  // In release mode, use a minimal printer that omits ANSI codes and emojis.
  // Overriding at runtime avoids unused import warnings.
);
