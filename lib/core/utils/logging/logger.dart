import 'package:logger/logger.dart';

/// App Logger Helper for Joba Admin Panel
/// Centralized logging utility providing formatted, professional terminal
/// and console output with emojis, timestamps, and error traces.
class AppLoggerHelper {
  AppLoggerHelper._();

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  /// Log debug message for development investigation
  static void debug(String message, [String? detail]) {
    if (detail != null) {
      _logger.d('[$message] 🔍 $detail');
    } else {
      _logger.d(message);
    }
  }

  /// Log general information message
  static void info(String message, [String? detail]) {
    if (detail != null) {
      _logger.i('[$message] ℹ️ $detail');
    } else {
      _logger.i(message);
    }
  }

  /// Log warning message for non-fatal situations
  static void warning(String message, [String? detail]) {
    if (detail != null) {
      _logger.w('[$message] ⚠️ $detail');
    } else {
      _logger.w(message);
    }
  }

  /// Log error message with optional error and stack trace
  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Structured helper to log section start or module activity
  static void section(String module, String message) {
    _logger.i('[$module] 🚀 $message');
  }

  /// Structured helper to log successful operations
  static void success(String module, String message) {
    _logger.i('[$module] ✅ $message');
  }

  /// Structured helper to log failed operations
  static void failure(
    String module,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.e('[$module] ❌ $message', error: error, stackTrace: stackTrace);
  }
}
