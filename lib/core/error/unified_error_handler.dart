import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'app_exceptions.dart';
import 'network_error_handler.dart' as network_handler;
import '../logging/app_logger.dart';

/// Unified error handling result
class UnifiedErrorResult {
  final bool isHandled;
  final String userMessage;
  final String? technicalMessage;
  final network_handler.NetworkErrorType? errorType;
  final bool shouldRetry;
  final Map<String, dynamic> metadata;

  const UnifiedErrorResult({
    required this.isHandled,
    required this.userMessage,
    this.technicalMessage,
    this.errorType,
    this.shouldRetry = false,
    this.metadata = const {},
  });

  factory UnifiedErrorResult.success() {
    return const UnifiedErrorResult(
      isHandled: true,
      userMessage: 'Operation completed successfully',
    );
  }

  factory UnifiedErrorResult.failure(
    String userMessage, {
    String? technicalMessage,
    network_handler.NetworkErrorType? errorType,
    bool shouldRetry = false,
    Map<String, dynamic> metadata = const {},
  }) {
    return UnifiedErrorResult(
      isHandled: true,
      userMessage: userMessage,
      technicalMessage: technicalMessage,
      errorType: errorType,
      shouldRetry: shouldRetry,
      metadata: metadata,
    );
  }
}

/// Unified error handler for consistent error handling across the app
class UnifiedErrorHandler {
  static final UnifiedErrorHandler _instance = UnifiedErrorHandler._internal();
  factory UnifiedErrorHandler() => _instance;
  UnifiedErrorHandler._internal();

  final AppLogger _logger = AppLogger();
  final network_handler.NetworkErrorHandler _networkErrorHandler =
      network_handler.NetworkErrorHandler.instance;

  /// Handle any error and return a unified result
  UnifiedErrorResult handleError(
    dynamic error, {
    String? context,
    Map<String, dynamic>? metadata,
    bool showToUser = true,
  }) {
    try {
      // Log the error for debugging
      _logger.error(
        'Error occurred${context != null ? ' in $context' : ''}',
        error: error,
        context: context ?? 'UnifiedErrorHandler',
        metadata: metadata,
      );

      // Handle specific exception types
      if (error is AuthException) {
        return _handleAuthError(error, context);
      } else if (error is network_handler.NetworkException) {
        return _handleNetworkError(error, context);
      } else if (error is ValidationException) {
        return _handleValidationError(error, context);
      } else if (error is ServerException) {
        return _handleServerError(error, context);
      } else if (error is TimeoutException) {
        return _handleTimeoutError(error, context);
      } else {
        return _handleGenericError(error, context);
      }
    } catch (e) {
      // Fallback if error handling itself fails
      _logger.critical(
        'Error handler failed',
        error: e,
        context: 'UnifiedErrorHandler',
      );
      return UnifiedErrorResult.failure(
        'An unexpected error occurred. Please try again.',
        technicalMessage: e.toString(),
        metadata: {'handler_failed': true},
      );
    }
  }

  /// Handle authentication errors
  UnifiedErrorResult _handleAuthError(AuthException error, String? context) {
    return UnifiedErrorResult.failure(
      'Authentication failed. Please login again.',
      technicalMessage: error.message,
      errorType: network_handler.NetworkErrorType.unknown,
      metadata: {'context': context, 'auth_error': true},
    );
  }

  /// Handle network errors
  UnifiedErrorResult _handleNetworkError(
      network_handler.NetworkException error, String? context) {
    final errorType = _networkErrorHandler.handleNetworkError(error);
    final userMessage = _networkErrorHandler.getUserFriendlyMessage(errorType);
    return UnifiedErrorResult.failure(
      userMessage,
      technicalMessage: error.message,
      errorType: errorType,
      shouldRetry: _shouldRetryForErrorType(errorType),
      metadata: {
        'context': context,
        'network_error': true,
        'error_type': errorType.toString(),
      },
    );
  }

  /// Determine if error type should be retried
  bool _shouldRetryForErrorType(network_handler.NetworkErrorType errorType) {
    switch (errorType) {
      case network_handler.NetworkErrorType.connectionRefused:
      case network_handler.NetworkErrorType.connectionFailed:
      case network_handler.NetworkErrorType.timeout:
        return true;
      case network_handler.NetworkErrorType.noInternet:
      case network_handler.NetworkErrorType.serverError:
      case network_handler.NetworkErrorType.unknown:
        return false;
      case network_handler.NetworkErrorType.aircraftSlotBooked:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  /// Handle validation errors
  UnifiedErrorResult _handleValidationError(
      ValidationException error, String? context) {
    return UnifiedErrorResult.failure(
      error.message,
      technicalMessage: error.message,
      errorType: network_handler.NetworkErrorType.unknown,
      metadata: {'context': context, 'validation_error': true},
    );
  }

  /// Handle server errors
  UnifiedErrorResult _handleServerError(
      ServerException error, String? context) {
    return UnifiedErrorResult.failure(
      'Server error occurred. Please try again later.',
      technicalMessage: error.message,
      errorType: network_handler.NetworkErrorType.serverError,
      shouldRetry: true,
      metadata: {'context': context, 'server_error': true},
    );
  }

  /// Handle timeout errors
  UnifiedErrorResult _handleTimeoutError(
      TimeoutException error, String? context) {
    return UnifiedErrorResult.failure(
      'Request timed out. Please check your connection and try again.',
      technicalMessage: error.message,
      errorType: network_handler.NetworkErrorType.timeout,
      shouldRetry: true,
      metadata: {'context': context, 'timeout_error': true},
    );
  }

  /// Handle generic errors
  UnifiedErrorResult _handleGenericError(dynamic error, String? context) {
    String userMessage;
    String technicalMessage = error.toString();

    // Try to extract meaningful error message
    if (error.toString().contains('SocketException')) {
      userMessage = 'No internet connection. Please check your network.';
    } else if (error.toString().contains('FormatException')) {
      userMessage = 'Invalid data format received. Please try again.';
    } else if (error.toString().contains('StateError')) {
      userMessage = 'Application state error. Please restart the app.';
    } else {
      userMessage = 'An unexpected error occurred. Please try again.';
    }

    return UnifiedErrorResult.failure(
      userMessage,
      technicalMessage: technicalMessage,
      errorType: network_handler.NetworkErrorType.unknown,
      shouldRetry: true,
      metadata: {'context': context, 'generic_error': true},
    );
  }

  /// Show error dialog to user
  Future<void> showErrorDialog(
    BuildContext context,
    UnifiedErrorResult errorResult, {
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
  }) async {
    if (!context.mounted) return;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                _getErrorIcon(errorResult.errorType),
                color: _getErrorColor(errorResult.errorType),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                _getErrorTitle(errorResult.errorType),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _getErrorColor(errorResult.errorType),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                errorResult.userMessage,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              if (kDebugMode && errorResult.technicalMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Technical Details (Debug Mode):',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.red[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        errorResult.technicalMessage!,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.red[600],
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            if (onDismiss != null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onDismiss();
                },
                child: const Text('Dismiss'),
              ),
            if (errorResult.shouldRetry && onRetry != null)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onRetry();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getErrorColor(errorResult.errorType),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            if (onDismiss == null && onRetry == null)
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
          ],
        );
      },
    );
  }

  /// Show error snackbar
  void showErrorSnackBar(
    BuildContext context,
    UnifiedErrorResult errorResult, {
    VoidCallback? onRetry,
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _getErrorIcon(errorResult.errorType),
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(errorResult.userMessage),
            ),
          ],
        ),
        backgroundColor: _getErrorColor(errorResult.errorType),
        duration: const Duration(seconds: 4),
        action: errorResult.shouldRetry && onRetry != null
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  /// Get error icon based on error type
  IconData _getErrorIcon(network_handler.NetworkErrorType? errorType) {
    switch (errorType) {
      case network_handler.NetworkErrorType.connectionRefused:
      case network_handler.NetworkErrorType.noInternet:
      case network_handler.NetworkErrorType.connectionFailed:
        return Icons.wifi_off;
      case network_handler.NetworkErrorType.serverError:
        return Icons.error;
      case network_handler.NetworkErrorType.timeout:
        return Icons.timer_off;
      case network_handler.NetworkErrorType.unknown:
      default:
        return Icons.error_outline;
    }
  }

  /// Get error color based on error type
  Color _getErrorColor(network_handler.NetworkErrorType? errorType) {
    switch (errorType) {
      case network_handler.NetworkErrorType.connectionRefused:
      case network_handler.NetworkErrorType.noInternet:
      case network_handler.NetworkErrorType.connectionFailed:
        return Colors.orange;
      case network_handler.NetworkErrorType.serverError:
        return Colors.red;
      case network_handler.NetworkErrorType.timeout:
        return Colors.orange;
      case network_handler.NetworkErrorType.unknown:
      default:
        return Colors.red;
    }
  }

  /// Get error title based on error type
  String _getErrorTitle(network_handler.NetworkErrorType? errorType) {
    switch (errorType) {
      case network_handler.NetworkErrorType.connectionRefused:
      case network_handler.NetworkErrorType.noInternet:
      case network_handler.NetworkErrorType.connectionFailed:
        return 'Connection Error';
      case network_handler.NetworkErrorType.serverError:
        return 'Server Error';
      case network_handler.NetworkErrorType.timeout:
        return 'Timeout Error';
      case network_handler.NetworkErrorType.unknown:
      default:
        return 'Error';
    }
  }
}
