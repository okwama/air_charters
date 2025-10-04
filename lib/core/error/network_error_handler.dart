import 'dart:io';

/// Global network error handler that converts technical errors to user-friendly messages
class NetworkErrorHandler {
  static NetworkErrorHandler? _instance;
  static NetworkErrorHandler get instance =>
      _instance ??= NetworkErrorHandler._();
  NetworkErrorHandler._();

  /// Convert network exceptions to user-friendly error types
  NetworkErrorType handleNetworkError(dynamic error) {
    final errorString = error.toString().toLowerCase();

    // Check for business logic errors first
    if (errorString.contains('aircraft slot') &&
        errorString.contains('already booked')) {
      return NetworkErrorType.aircraftSlotBooked;
    }

    if (error is SocketException) {
      if (error.osError?.errorCode == 61) {
        // Connection refused
        return NetworkErrorType.connectionRefused;
      } else if (error.osError?.errorCode == 7) {
        // No internet connection
        return NetworkErrorType.noInternet;
      } else {
        return NetworkErrorType.connectionFailed;
      }
    } else if (error is HttpException) {
      return NetworkErrorType.serverError;
    } else if (errorString.contains('connection refused')) {
      return NetworkErrorType.connectionRefused;
    } else if (errorString.contains('no internet')) {
      return NetworkErrorType.noInternet;
    } else if (errorString.contains('timeout')) {
      return NetworkErrorType.timeout;
    } else {
      return NetworkErrorType.unknown;
    }
  }

  /// Get user-friendly error message
  String getUserFriendlyMessage(NetworkErrorType errorType) {
    switch (errorType) {
      case NetworkErrorType.connectionRefused:
        return 'Unable to connect to server. Please check your connection and try again.';
      case NetworkErrorType.noInternet:
        return 'No internet connection. Please check your network settings.';
      case NetworkErrorType.connectionFailed:
        return 'Connection failed. Please try again.';
      case NetworkErrorType.serverError:
        return 'Server temporarily unavailable. Please try again later.';
      case NetworkErrorType.timeout:
        return 'Request timed out. Please try again.';
      case NetworkErrorType.aircraftSlotBooked:
        return 'This aircraft is already booked for the selected time period. Please choose a different date or time.';
      case NetworkErrorType.unknown:
        return 'Something went wrong. Please try again.';
    }
  }

  /// Get error icon data
  String getErrorIcon(NetworkErrorType errorType) {
    switch (errorType) {
      case NetworkErrorType.connectionRefused:
      case NetworkErrorType.noInternet:
      case NetworkErrorType.connectionFailed:
        return 'wifi-off'; // Broken connection icon
      case NetworkErrorType.serverError:
      case NetworkErrorType.timeout:
        return 'server-crash'; // Server error icon
      case NetworkErrorType.aircraftSlotBooked:
        return 'calendar-x'; // Calendar conflict icon
      case NetworkErrorType.unknown:
        return 'alert-circle'; // Generic error icon
    }
  }
}

/// Network error types for consistent handling
enum NetworkErrorType {
  connectionRefused,
  noInternet,
  connectionFailed,
  serverError,
  timeout,
  aircraftSlotBooked,
  unknown,
}

/// Network error result with user-friendly info
class NetworkErrorResult {
  final NetworkErrorType type;
  final String message;
  final String icon;

  NetworkErrorResult({
    required this.type,
    required this.message,
    required this.icon,
  });

  /// Create from exception
  factory NetworkErrorResult.fromException(dynamic error) {
    final handler = NetworkErrorHandler.instance;
    final errorType = handler.handleNetworkError(error);
    return NetworkErrorResult(
      type: errorType,
      message: handler.getUserFriendlyMessage(errorType),
      icon: handler.getErrorIcon(errorType),
    );
  }
}

/// Custom exception for network errors with user-friendly info
class NetworkException implements Exception {
  final String message;
  final NetworkErrorResult errorResult;

  NetworkException(this.message, this.errorResult);

  @override
  String toString() => message;
}
