import 'package:flutter/material.dart';
import '../../config/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/ab_testing_service.dart';

/// Compact modular dialog for authentication prompts
class AuthRequiredDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onSignIn;
  final VoidCallback? onContinue;

  const AuthRequiredDialog({
    super.key,
    this.title = 'Sign In Required',
    this.message = 'Please sign in to continue.',
    this.actionText,
    this.onSignIn,
    this.onContinue,
  });

  /// Show the auth required dialog with A/B testing support
  static Future<void> show(
    BuildContext context, {
    String? title,
    String? message,
    String? actionText,
    VoidCallback? onSignIn,
    VoidCallback? onContinue,
    String? testName,
    String? testContext,
  }) async {
    // Get A/B test variant if test is configured
    String? variant;
    if (testName != null) {
      variant = await ABTestingService.getTestAssignment(testName);
    }

    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AuthRequiredDialog(
        title: title ?? 'Sign In Required',
        message: message ?? 'Please sign in to continue.',
        actionText: actionText,
        onSignIn: () {
          // Track A/B test result
          if (testName != null && variant != null) {
            ABTestingService.recordTestResult(
              testName: testName,
              variant: variant,
              eventType: 'auth_prompt',
              eventName: 'sign_in_clicked',
              eventData: {'context': testContext},
            );
          }

          onSignIn?.call();
        },
        onContinue: () {
          // Track A/B test result
          if (testName != null && variant != null) {
            ABTestingService.recordTestResult(
              testName: testName,
              variant: variant,
              eventType: 'auth_prompt',
              eventName: 'continue_clicked',
              eventData: {'context': testContext},
            );
          }

          onContinue?.call();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: AppTheme.backgroundColor,
      child: Semantics(
        label: 'Authentication required dialog',
        child: Container(
          constraints: const BoxConstraints(maxWidth: 320),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppTheme.borderColor,
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.lock_outline,
                  size: 24,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Semantics(
                header: true,
                child: Text(
                  title,
                  style: AppTheme.heading3.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),

              // Message
              Semantics(
                child: Text(
                  message,
                  style: AppTheme.bodySmall.copyWith(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  // Continue Button
                  Expanded(
                    child: Semantics(
                      button: true,
                      label: 'Continue browsing without signing in',
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onContinue?.call();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.textSecondaryColor,
                          backgroundColor: Colors.transparent,
                          side: BorderSide(color: AppTheme.borderColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'Continue',
                          style: AppTheme.bodySmall.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Sign In Button
                  Expanded(
                    child: Semantics(
                      button: true,
                      label: 'Sign in to your account',
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onSignIn?.call();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: AppTheme.backgroundColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        child: Text(
                          actionText ?? 'Sign In',
                          style: AppTheme.bodySmall.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.backgroundColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Quick auth prompt for specific actions with conversion-optimized messaging
class QuickAuthPrompt {
  /// Show quick auth prompt for booking with enhanced messaging and A/B testing
  static Future<void> showForBooking(BuildContext context) async {
    // Get A/B test variant for booking prompts
    final variant =
        await ABTestingService.getTestAssignment('booking_prompt_test');

    String title, message, actionText;

    switch (variant) {
      case 'urgency':
        title = 'Limited Seats Available';
        message =
            'Only 3 seats left on this route! Create your account now to secure your booking with instant confirmation.';
        actionText = 'Book Now';
        break;
      case 'social_proof':
        title = 'Join 10,000+ Travelers';
        message =
            'Get instant booking confirmations, 24/7 support, and exclusive deals. Create your free account in 30 seconds.';
        actionText = 'Get Started';
        break;
      case 'benefits':
        title = 'Unlock Premium Features';
        message =
            'Get priority booking, exclusive member rates, and personalized service. Sign up now for free.';
        actionText = 'Unlock Benefits';
        break;
      default:
        title = 'Join 10,000+ Travelers';
        message =
            'Get instant booking confirmations, 24/7 support, and exclusive deals. Create your free account in 30 seconds.';
        actionText = 'Get Started';
    }

    return AuthRequiredDialog.show(
      context,
      title: title,
      message: message,
      actionText: actionText,
      testName: 'booking_prompt_test',
      testContext: 'booking',
      onSignIn: () => Navigator.of(context).pushNamed(AppRoutes.login),
    );
  }

  /// Show quick auth prompt for trips with personalized messaging
  static Future<void> showForTrips(BuildContext context) {
    return AuthRequiredDialog.show(
      context,
      title: 'Your Travel Dashboard',
      message:
          'Track your bookings, get real-time updates, and manage your upcoming trips. Join thousands of satisfied customers.',
      actionText: 'Sign In',
      onSignIn: () => Navigator.of(context).pushNamed(AppRoutes.login),
    );
  }

  /// Show quick auth prompt for settings with benefit-focused messaging
  static Future<void> showForSettings(BuildContext context) {
    return AuthRequiredDialog.show(
      context,
      title: 'Personalize Your Experience',
      message:
          'Save your preferences, get personalized recommendations, and enjoy a tailored charter experience.',
      actionText: 'Create Account',
      onSignIn: () => Navigator.of(context).pushNamed(AppRoutes.login),
    );
  }

  /// Show quick auth prompt for profile with value proposition
  static Future<void> showForProfile(BuildContext context) {
    return AuthRequiredDialog.show(
      context,
      title: 'Your Travel Profile',
      message:
          'Save your details for faster bookings, get exclusive member rates, and enjoy priority customer support.',
      actionText: 'Join Now',
      onSignIn: () => Navigator.of(context).pushNamed(AppRoutes.login),
    );
  }

  /// Show contextual auth prompt for deals with urgency
  static Future<void> showForDeals(BuildContext context) {
    return AuthRequiredDialog.show(
      context,
      title: 'Exclusive Member Deals',
      message:
          'Access limited-time offers, member-only pricing, and early access to new routes. Limited seats available.',
      actionText: 'Unlock Deals',
      onSignIn: () => Navigator.of(context).pushNamed(AppRoutes.login),
    );
  }

  /// Show contextual auth prompt for experiences with social proof
  static Future<void> showForExperiences(BuildContext context) {
    return AuthRequiredDialog.show(
      context,
      title: 'Premium Experiences Await',
      message:
          'Join our VIP community for exclusive experiences, luxury amenities, and personalized service.',
      actionText: 'Join VIP',
      onSignIn: () => Navigator.of(context).pushNamed(AppRoutes.login),
    );
  }

  /// Show contextual auth prompt for cargo with business focus
  static Future<void> showForCargo(BuildContext context) {
    return AuthRequiredDialog.show(
      context,
      title: 'Business Cargo Solutions',
      message:
          'Get dedicated cargo support, real-time tracking, and priority handling for your business shipments.',
      actionText: 'Get Started',
      onSignIn: () => Navigator.of(context).pushNamed(AppRoutes.login),
    );
  }

  /// Show contextual auth prompt for medivac with urgency
  static Future<void> showForMedivac(BuildContext context) {
    return AuthRequiredDialog.show(
      context,
      title: 'Emergency Medical Transport',
      message:
          'Access our 24/7 medivac services with immediate response and specialized medical equipment.',
      actionText: 'Get Help Now',
      onSignIn: () => Navigator.of(context).pushNamed(AppRoutes.login),
    );
  }
}
