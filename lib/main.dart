import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
// Stripe handled server-side - no client import needed

// Core imports
import 'core/providers/auth_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/navigation_provider.dart';
import 'core/services/dependency_injection_service.dart';
import 'core/services/notification_service.dart';

// Theme

// Features
import 'features/auth/login_screen.dart';
import 'features/main_navigation_screen.dart';
import 'features/home/home_screen.dart';
import 'features/splash/splash_screen.dart';
import 'features/splash/landing_screen.dart';
// Configuration

// Routes
import 'core/routes/app_pages.dart';
import 'core/routes/route_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Payment processing is handled server-side for security
  // No client-side Stripe initialization needed

  // Initialize Notification Service
  await NotificationService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Create route observer instance
  static final AppRouteObserver _routeObserver = AppRouteObserver();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: DependencyInjectionService.getProviders(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Air Charters',
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            onUnknownRoute: (settings) {
              // Fallback for unknown routes
              return MaterialPageRoute(
                builder: (context) => const CharterHomePage(),
              );
            },
            navigatorKey: GlobalKey<NavigatorState>(),
            navigatorObservers: [_routeObserver],
            routes: AppPages.routes,
            onGenerateRoute: AppPages.generateRoute,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }

  // Get route observer for external access
  static AppRouteObserver get routeObserver => _routeObserver;
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Initialize auth state when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize auth provider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.initialize();

      // Initialize navigation provider if authenticated
      if (authProvider.isAuthenticated) {
        final navigationProvider =
            Provider.of<NavigationProvider>(context, listen: false);
        navigationProvider.setCurrentIndex(0); // Set to home tab
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing app: $e');
      }
    }
  }

  @override
  void dispose() {
    // Clean up providers
    DependencyInjectionService.disposeProviders(context);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        switch (authProvider.state) {
          case AuthState.initial:
          case AuthState.loading:
            return const SplashScreen();
          case AuthState.authenticated:
            return const MainNavigationScreen();
          case AuthState.unauthenticated:
          case AuthState.error:
            return FutureBuilder<bool>(
              future: authProvider.hasSeenLanding(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SplashScreen();
                }

                final hasSeenLanding = snapshot.data ?? false;
                if (hasSeenLanding) {
                  return const LoginScreen(); // Returning user
                } else {
                  return const LandingScreen(); // New user
                }
              },
            );
        }
      },
    );
  }
}
