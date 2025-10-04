import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
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

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.wifiOff,
            size: 48,
            color: AppTheme.textSecondaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Connection Lost',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondaryColor,
            ),
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
