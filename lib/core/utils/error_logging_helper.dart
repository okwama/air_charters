import '../logging/app_logger.dart';
import '../error/network_error_handler.dart';

/// Helper class to replace raw print statements with proper error logging
class ErrorLoggingHelper {
  /// Log error with proper formatting instead of raw print
  static void logError(String message, {dynamic error, String? context}) {
    if (context != null) {
      AppLogger.error('$context: $message', error: error, context: context);
    } else {
      AppLogger.error(message, error: error);
    }
  }

  /// Log warning with proper formatting
  static void logWarning(String message, {String? context}) {
    if (context != null) {
      AppLogger.warning('$context: $message');
    } else {
      AppLogger.warning(message);
    }
  }

  /// Log info with proper formatting
  static void logInfo(String message, {String? context}) {
    if (context != null) {
      AppLogger.info('$context: $message');
    } else {
      AppLogger.info(message);
    }
  }

  /// Convert raw error to user-friendly message for logging
  static String getUserFriendlyErrorMessage(dynamic error) {
    if (error == null) return 'Unknown error occurred';

    final errorResult = NetworkErrorResult.fromException(error);
    return errorResult.message;
  }

  /// Log network error with user-friendly message
  static void logNetworkError(String operation, dynamic error) {
    final errorResult = NetworkErrorResult.fromException(error);
    AppLogger.error('$operation failed: ${errorResult.message}', error: error);
  }
}
