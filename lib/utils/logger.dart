import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(),
  );

  static void logInfo(String message) {
    _logger.i(message);
  }

  static void logError(String message) {
    _logger.e(message);
  }

  static void logDebug(String message) {
    _logger.d(message);
  }
}
