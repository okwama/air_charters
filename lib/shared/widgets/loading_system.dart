import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_spinner.dart';
import 'shimmer_loading.dart';

/// Unified loading system with context-aware loading states
class LoadingSystem {
  /// Full screen loading with spinner and message
  static Widget fullScreen({
    String? message,
    Color? backgroundColor,
  }) {
    return Container(
      color: backgroundColor ?? Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppSpinner(),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Inline loading for buttons and small areas
  static Widget inline({
    double size = 20,
    Color? color,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? Colors.white,
        ),
      ),
    );
  }

  /// Skeleton loading for content placeholders
  static Widget skeleton({
    required Widget child,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return ShimmerLoading(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: child,
    );
  }

  /// Image loading placeholder
  static Widget imagePlaceholder({
    double width = 200,
    double height = 200,
    Color? backgroundColor,
    IconData? icon,
  }) {
    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? Colors.grey.shade200,
      child: Center(
        child: icon != null
            ? Icon(
                icon,
                color: Colors.grey.shade400,
                size: 48,
              )
            : const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
              ),
      ),
    );
  }

  /// Payment-specific loading with security indicators
  static Widget payment({
    String? message,
    bool showSecurityBadge = true,
  }) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Security badge
            if (showSecurityBadge) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.security,
                      color: Colors.green.shade600,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Secure Payment',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Payment spinner
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message ?? 'Processing Payment...',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please don\'t close this window',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Overlay loading for modal actions
  static Widget overlay({
    String? message,
    Color? overlayColor,
  }) {
    return Container(
      color: overlayColor ?? Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Loading context enum for type safety
enum LoadingContext {
  fullScreen,
  inline,
  skeleton,
  image,
  payment,
  overlay,
}

/// Loading widget that automatically chooses the right loading type
class SmartLoading extends StatelessWidget {
  final LoadingContext context;
  final String? message;
  final Widget? skeletonChild;
  final double? size;
  final Color? color;
  final bool showSecurityBadge;

  const SmartLoading({
    super.key,
    required this.context,
    this.message,
    this.skeletonChild,
    this.size,
    this.color,
    this.showSecurityBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    switch (this.context) {
      case LoadingContext.fullScreen:
        return LoadingSystem.fullScreen(message: message);

      case LoadingContext.inline:
        return LoadingSystem.inline(size: size ?? 20, color: color);

      case LoadingContext.skeleton:
        return LoadingSystem.skeleton(child: skeletonChild!);

      case LoadingContext.image:
        return LoadingSystem.imagePlaceholder(
          width: size ?? 200.0,
          height: size ?? 200.0,
        );

      case LoadingContext.payment:
        return LoadingSystem.payment(
          message: message,
          showSecurityBadge: showSecurityBadge,
        );

      case LoadingContext.overlay:
        return LoadingSystem.overlay(message: message);
    }
  }
}
