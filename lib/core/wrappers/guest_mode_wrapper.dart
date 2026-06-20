import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/conversion_analytics_service.dart';
import '../../shared/widgets/guest_signin_screen.dart';

/// Wrapper that handles guest mode navigation and prompts for authentication
class GuestModeWrapper extends StatefulWidget {
  final Widget child;
  final bool requiresAuth;
  final String? authPromptMessage;

  const GuestModeWrapper({
    super.key,
    required this.child,
    this.requiresAuth = false,
    this.authPromptMessage,
  });

  @override
  State<GuestModeWrapper> createState() => _GuestModeWrapperState();
}

class _GuestModeWrapperState extends State<GuestModeWrapper> {

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // If feature requires auth and user is in guest mode, show auth prompt
        if (widget.requiresAuth && authProvider.isGuest) {
          return _buildAuthPrompt(context, authProvider);
        }

        // Allow guest access to browsing features
        return widget.child;
      },
    );
  }

  Widget _buildAuthPrompt(BuildContext context, AuthProvider authProvider) {
    // Track auth prompt shown
    ConversionAnalyticsService.trackAuthPromptShown(
      promptType: 'full_screen',
      context: 'screen_access',
      feature: widget.authPromptMessage?.contains('trip') == true ? 'trips' : 'settings',
    );

    // Determine which sign-in screen to show based on the context
    if (widget.authPromptMessage?.contains('trip') == true) {
      return GuestSignInScreen.forTrips();
    } else if (widget.authPromptMessage?.contains('settings') == true || 
               widget.authPromptMessage?.contains('preferences') == true) {
      return GuestSignInScreen.forSettings();
    } else {
      // Fallback to generic sign-in screen
      return GuestSignInScreen(
        title: 'Sign In Required',
        message: widget.authPromptMessage ?? 
        'To access this feature, please sign in to your account or create a new one.',
        actionText: 'Sign In',
        feature: 'generic',
        icon: Icons.lock_outline,
      );
    }
  }
}
