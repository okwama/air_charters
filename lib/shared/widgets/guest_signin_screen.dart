import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme/app_theme.dart';
import '../../core/services/conversion_analytics_service.dart';
import '../../features/auth/login_screen.dart';

/// Full-screen sign-in prompt for guest users
class GuestSignInScreen extends StatelessWidget {
  final String title;
  final String message;
  final String? actionText;
  final String? feature;
  final IconData? icon;
  final List<String>? benefits;

  const GuestSignInScreen({
    super.key,
    required this.title,
    required this.message,
    this.actionText,
    this.feature,
    this.icon,
    this.benefits,
  });

  /// Create sign-in screen for trips
  factory GuestSignInScreen.forTrips() {
    return const GuestSignInScreen(
      title: 'Your Travel Dashboard',
      message: 'Track your bookings, get real-time updates, and manage your upcoming trips.',
      actionText: 'Sign In',
      feature: 'trips',
      icon: Icons.flight_takeoff,
      benefits: [
        'View all your bookings in one place',
        'Get real-time flight updates',
        'Manage upcoming trips easily',
        'Access booking history',
      ],
    );
  }

  /// Create sign-in screen for settings
  factory GuestSignInScreen.forSettings() {
    return const GuestSignInScreen(
      title: 'Personalize Your Experience',
      message: 'Save your preferences, get personalized recommendations, and enjoy a tailored charter experience.',
      actionText: 'Create Account',
      feature: 'settings',
      icon: Icons.settings,
      benefits: [
        'Save your travel preferences',
        'Get personalized recommendations',
        'Manage notification settings',
        'Access account security',
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: Icon(
                  icon ?? Icons.lock_outline,
                  size: 40,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                title,
                style: GoogleFonts.interTight(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Message
              Text(
                message,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: const Color(0xFF666666),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Benefits list
              if (benefits != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E5E5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'What you\'ll get:',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...benefits!.map((benefit) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppTheme.primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                benefit,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                  color: const Color(0xFF666666),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],

              const Spacer(),

              // Sign In Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Track sign in action
                    ConversionAnalyticsService.trackAuthPromptAction(
                      promptType: 'full_screen',
                      action: 'sign_in',
                      context: 'screen_access',
                      feature: feature,
                    );
                    
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    actionText ?? 'Sign In',
                    style: GoogleFonts.interTight(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Continue as Guest Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () {
                    // Track continue action
                    ConversionAnalyticsService.trackAuthPromptAction(
                      promptType: 'full_screen',
                      action: 'continue',
                      context: 'screen_access',
                      feature: feature,
                    );
                    
                    // Navigate back to home tab
                    Navigator.of(context).pop();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF666666),
                    backgroundColor: Colors.transparent,
                    side: const BorderSide(color: Color(0xFFE5E5E5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Continue as Guest',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF666666),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}



