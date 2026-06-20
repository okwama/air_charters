import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../core/providers/navigation_provider.dart';
import '../core/providers/auth_provider.dart';
import '../core/wrappers/guest_mode_wrapper.dart';
import '../shared/components/bottom_nav.dart';
import '../config/theme/app_theme.dart';
import 'dashboard/dashboard_screen.dart';
import 'home/home_screen.dart';
import 'direct_charter/aircraft_type_selection_screen.dart';
import 'mytrips/trips.dart';
import 'settings/settings.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  // Cache screens to prevent recreation on every build
  late final List<Widget> _screens;
  late final List<Widget> _screensWithAuth;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      print('MainNavigationScreen: initState called');
    }
    
    // Initialize screens once
    _screens = [
      const DashboardScreen(),
      const CharterHomePage(),
      const AircraftTypeSelectionScreen(showBackButton: false),
      const TripsPage(),
      const SettingsScreen(),
    ];
    
    // Wrap screens with auth wrappers once
    _screensWithAuth = _screens.asMap().entries.map((entry) {
      final index = entry.key;
      final screen = entry.value;
      
      // Define which screens require authentication
      bool requiresAuth = false;
      String? authMessage;
      
      switch (index) {
        case 0: // Dashboard - guest can view
        case 1: // Home - guest can browse
        case 2: // Direct Charter - guest can browse
          requiresAuth = false;
          break;
        case 3: // Trips - requires auth
          requiresAuth = true;
          authMessage = 'Track your bookings, get real-time updates, and manage your upcoming trips. Join thousands of satisfied customers.';
          break;
        case 4: // Settings - requires auth
          requiresAuth = true;
          authMessage = 'Save your preferences, get personalized recommendations, and enjoy a tailored charter experience.';
          break;
      }
      
      return GuestModeWrapper(
        key: ValueKey('screen_$index'), // Stable key for widget identity
        requiresAuth: requiresAuth,
        authPromptMessage: authMessage,
        child: ErrorBoundary(
          key: ValueKey('error_boundary_$index'),
          child: screen,
        ),
      );
    }).toList();
  }

  @override
  void dispose() {
    if (kDebugMode) {
      print('MainNavigationScreen: dispose called');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<NavigationProvider, AuthProvider>(
      builder: (context, navigationProvider, authProvider, child) {
        if (kDebugMode) {
          print(
              'MainNavigationScreen: Building with index: ${navigationProvider.currentIndex}');
        }

        // Validate index bounds
        final currentIndex =
            navigationProvider.currentIndex.clamp(0, _screensWithAuth.length - 1);

        return WillPopScope(
          onWillPop: () async {
            // Handle back button press
            if (kDebugMode) {
              print('MainNavigationScreen: Back button pressed');
            }

            // If we're not on the home tab, go to home
            if (currentIndex != 0) {
              navigationProvider.setCurrentIndex(0);
              return false; // Don't pop the route
            }

            // If we're on home, allow the app to exit
            return true;
          },
          child: Scaffold(
            backgroundColor: AppTheme.backgroundColor,
            body: SafeArea(
              child: IndexedStack(
                index: currentIndex,
                children: _screensWithAuth,
              ),
            ),
            bottomNavigationBar: const BottomNav(),
          ),
        );
      },
    );
  }
}

// Error boundary widget to catch and handle errors gracefully
class ErrorBoundary extends StatefulWidget {
  final Widget child;

  const ErrorBoundary({
    super.key,
    required this.child,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  bool _hasError = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorWidget();
    }

    return widget.child;
  }

  Widget _buildErrorWidget() {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.textSecondaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: AppTheme.heading3,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? 'An unexpected error occurred',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _hasError = false;
                    _errorMessage = null;
                  });
                },
                style: AppTheme.primaryButtonStyle,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Set up error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      if (kDebugMode) {
        print('ErrorBoundary: Caught error: ${details.exception}');
      }
      // Use post frame callback to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _hasError = true;
            _errorMessage = details.exception.toString();
          });
        }
      });
    };
  }
}
