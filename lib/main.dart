import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
// Stripe handled server-side - no client import needed

// Core imports
import 'core/providers/auth_provider.dart';
import 'core/providers/profile_provider.dart';
import 'core/providers/trips_provider.dart';
import 'core/providers/navigation_provider.dart';
import 'core/services/dependency_injection_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/onesignal_service.dart';
import 'core/services/cache_service.dart';
import 'core/network/dio_client.dart';
import 'config/env/app_config.dart';

// Theme
import 'config/theme/app_theme.dart';

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

  // 🚀 CRITICAL: Initialize cache service FIRST (required for instant loading)
  try {
    await CacheService().initialize();
    debugPrint('✅ Cache service initialized');
  } catch (e) {
    debugPrint('⚠️ Cache service initialization failed: $e');
  }

  // 🚀 Initialize Dio client with caching
  try {
    await DioClient().initialize();
    debugPrint('✅ Dio client initialized with SWR caching');
  } catch (e) {
    debugPrint('⚠️ Dio client initialization failed: $e');
  }

  // ✅ PERFORMANCE FIX: Initialize Notification Service in background
  // Don't block app startup - initialize asynchronously
  NotificationService().initialize().catchError((e) {
    if (kDebugMode) {
      print('Notification service initialization failed: $e');
    }
  });

  // Initialize OneSignal for Push Notifications
  if (AppConfig.enablePushNotifications &&
      AppConfig.oneSignalAppId != 'YOUR_ONESIGNAL_APP_ID') {
    await OneSignalService().initialize(AppConfig.oneSignalAppId);
  }

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
      child: MaterialApp(
        title: 'Air Charters',
        theme: AppTheme.lightTheme,
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

class _AuthWrapperState extends State<AuthWrapper> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initialize auth state when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializeApp();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.validateToken();
    }
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize auth provider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.initialize();

      // Set auth provider reference in other providers
      final profileProvider =
          Provider.of<ProfileProvider>(context, listen: false);
      profileProvider.setAuthProvider(authProvider);

      final tripsProvider = Provider.of<TripsProvider>(context, listen: false);
      tripsProvider.setAuthProvider(authProvider);

      // Initialize navigation provider if authenticated
      if (authProvider.isAuthenticated) {
        final navigationProvider =
            Provider.of<NavigationProvider>(context, listen: false);
        navigationProvider.setCurrentIndex(0); // Set to home tab

        // ✅ PERFORMANCE FIX: Prefetch critical data in background (Uber-style)
        // This makes subsequent screen loads instant
        Future.delayed(const Duration(milliseconds: 200), () {
          if (context.mounted) {
            profileProvider.fetchProfileIfNeeded();
            tripsProvider.fetchUserTrips();
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing app: $e');
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
            // Only navigate to main screen if token is valid
            if (authProvider.hasValidToken) {
              return const MainNavigationScreen();
            } else {
              // Token is invalid, show loading while attempting refresh
              return const SplashScreen();
            }
          case AuthState.guest:
            return const MainNavigationScreen(); // Guest can browse
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
