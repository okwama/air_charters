import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme/app_theme.dart';
import '../../core/error/network_error_handler.dart';

/// Reusable widget for displaying network errors with broken wings icon
class NetworkErrorWidget extends StatelessWidget {
  final NetworkErrorResult? errorResult;
  final dynamic error;
  final VoidCallback? onRetry;
  final String? customMessage;
  final bool showRetryButton;

  const NetworkErrorWidget({
    super.key,
    this.errorResult,
    this.error,
    this.onRetry,
    this.customMessage,
    this.showRetryButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final errorInfo = errorResult ??
        (error != null ? NetworkErrorResult.fromException(error) : null);

    if (errorInfo == null) {
      return const SizedBox.shrink();
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Broken wings icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                _getBrokenWingsIcon(errorInfo.type),
                size: 64,
                color: AppTheme.primaryColor,
              ),
            ),

            const SizedBox(height: 24),

            // Error title
            Text(
              _getErrorTitle(errorInfo.type),
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryColor,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Error message
            Text(
              customMessage ?? errorInfo.message,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),

            if (showRetryButton && onRetry != null) ...[
              const SizedBox(height: 32),

              // Retry button
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(LucideIcons.refreshCw),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Get the appropriate broken wings icon based on error type
  IconData _getBrokenWingsIcon(NetworkErrorType errorType) {
    switch (errorType) {
      case NetworkErrorType.connectionRefused:
      case NetworkErrorType.noInternet:
      case NetworkErrorType.connectionFailed:
        return LucideIcons.wifiOff; // Broken connection
      case NetworkErrorType.serverError:
        return LucideIcons.serverCrash; // Server error
      case NetworkErrorType.timeout:
        return LucideIcons.clock; // Timeout
      case NetworkErrorType.aircraftSlotBooked:
        return LucideIcons.calendarX; // Calendar conflict
      case NetworkErrorType.unknown:
        return LucideIcons.alertCircle; // Generic error
    }
  }

  /// Get user-friendly error title
  String _getErrorTitle(NetworkErrorType errorType) {
    switch (errorType) {
      case NetworkErrorType.connectionRefused:
      case NetworkErrorType.noInternet:
      case NetworkErrorType.connectionFailed:
        return 'Connection Lost';
      case NetworkErrorType.serverError:
        return 'Service Unavailable';
      case NetworkErrorType.timeout:
        return 'Request Timeout';
      case NetworkErrorType.aircraftSlotBooked:
        return 'Aircraft Unavailable';
      case NetworkErrorType.unknown:
        return 'Something Went Wrong';
    }
  }
}

/// Quick network error display for empty states
class QuickNetworkErrorWidget extends StatelessWidget {
  final dynamic error;
  final VoidCallback? onRetry;

  const QuickNetworkErrorWidget({
    super.key,
    this.error,
    this.onRetry,
  });

  /// Determine if this is a network error or authentication error
  bool _isNetworkError() {
    if (error == null) return false;
    final errorString = error.toString().toLowerCase();
    return errorString.contains('socketexception') ||
        errorString.contains('connection') ||
        errorString.contains('network') ||
        errorString.contains('timeout') ||
        errorString.contains('failed host lookup');
  }

  /// Get appropriate icon based on error type
  IconData _getErrorIcon() {
    if (_isNetworkError()) {
      return LucideIcons.wifiOff;
    }
    // Authentication/validation errors
    return LucideIcons.alertCircle;
  }

  /// Get error message to display
  String _getErrorMessage() {
    if (error == null) return 'An error occurred';

    // If it's a network error, show "Connection Lost"
    if (_isNetworkError()) {
      return 'Connection Lost';
    }

    // For other errors, show the actual error message
    final errorString = error.toString();

    // Clean up common error prefixes
    if (errorString.startsWith('Exception: ')) {
      return errorString.substring('Exception: '.length);
    }
    if (errorString.startsWith('AuthException: ')) {
      return errorString.substring('AuthException: '.length);
    }
    if (errorString.startsWith('ValidationException: ')) {
      return errorString.substring('ValidationException: '.length);
    }

    return errorString;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getErrorIcon(),
            size: 48,
            color: AppTheme.errorColor,
          ),
          const SizedBox(height: 16),
          Text(
            _getErrorMessage(),
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              label: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}
