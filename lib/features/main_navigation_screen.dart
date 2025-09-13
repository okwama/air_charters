import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../core/providers/navigation_provider.dart';
import '../shared/components/bottom_nav.dart';
import 'dashboard/dashboard_screen.dart';
import 'home/home_screen.dart';
import 'direct_charter/direct_charter_search_screen.dart';
import 'mytrips/trips.dart';
import 'settings/settings.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final List<Widget> _screens = [
    const DashboardScreen(),
    const CharterHomePage(),
    const DirectCharterWrapper(),
    const TripsPage(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      print('MainNavigationScreen: initState called');
    }
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
    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) {
        if (kDebugMode) {
          print(
              'MainNavigationScreen: Building with index: ${navigationProvider.currentIndex}');
        }

        // Validate index bounds
        final currentIndex =
            navigationProvider.currentIndex.clamp(0, _screens.length - 1);

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
            backgroundColor: Colors.white,
            body: SafeArea(
              child: IndexedStack(
                index: currentIndex,
                children: _screens.map((screen) {
                  // Wrap each screen with error boundary
                  return ErrorBoundary(
                    child: screen,
                  );
                }).toList(),
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
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.grey[700],
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? 'An unexpected error occurred',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
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
