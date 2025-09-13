import 'package:flutter/material.dart';

class OfflineFallbackWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final bool showRetryButton;
  final IconData? icon;
  final Color? iconColor;

  const OfflineFallbackWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.showRetryButton = true,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Offline Icon
          Icon(
            icon ?? Icons.cloud_off_outlined,
            size: 64,
            color: iconColor ?? Colors.orange.shade400,
          ),
          const SizedBox(height: 16),
          
          // Message
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          
          // Retry Button
          if (showRetryButton && onRetry != null)
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}

/// Compact offline indicator for showing cached data
class OfflineIndicator extends StatelessWidget {
  final String lastLoadTime;
  final VoidCallback? onRetry;

  const OfflineIndicator({
    super.key,
    required this.lastLoadTime,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border.all(color: Colors.orange.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 16,
            color: Colors.orange.shade600,
          ),
          const SizedBox(width: 8),
          Text(
            'Offline - Data from $lastLoadTime',
            style: TextStyle(
              color: Colors.orange.shade700,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onRetry,
              child: Icon(
                Icons.refresh,
                size: 16,
                color: Colors.orange.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

