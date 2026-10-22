import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class AppLogger {
  AppLogger._();

  static final Logger _logger = Logger(
    level: kReleaseMode ? Level.warning : Level.trace,
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 100,
      colors: !kIsWeb,
      printEmojis: true,
    ),
  );

  static void d(String tag, String msg) => _logger.d('[$tag] $msg');
  static void i(String tag, String msg) => _logger.i('[$tag] $msg');
  static void w(String tag, String msg) => _logger.w('[$tag] $msg');
  static void e(String tag, String msg, [Object? error, StackTrace? stack]) =>
      _logger.e('[$tag] $msg', error: error, stackTrace: stack);
}