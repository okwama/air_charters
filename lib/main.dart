import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:air_charters/config/theme/app_theme.dart';
import 'package:air_charters/core/providers/auth_provider.dart';
import 'package:air_charters/core/providers/profile_provider.dart';
import 'package:air_charters/core/providers/charter_deals_provider.dart';
import 'package:air_charters/shared/utils/session_manager.dart';
import 'package:air_charters/features/mytrips/trips.dart';
import 'package:air_charters/features/splash/splash_screen.dart';
import 'package:air_charters/features/splash/landing_screen.dart';
import 'package:air_charters/features/auth/signup_screen.dart';
import 'package:air_charters/features/auth/login_screen.dart';
import 'package:air_charters/features/auth/verifycode.dart';
import 'package:air_charters/features/auth/country_selection_screen.dart';
import 'package:air_charters/features/home/home_screen.dart';
import 'package:air_charters/features/settings/settings.dart';
import 'package:air_charters/features/profile/profile.dart';
import 'package:air_charters/features/booking/booking_detail.dart';
import 'package:air_charters/test/auth_test_screen.dart';
import 'package:air_charters/test_auth_debug.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'dart:developer' as dev;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => CharterDealsProvider()),
      ],
      child: MaterialApp(
        title: 'Air Charters',
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
        routes: {
          '/signup': (context) => const SignupScreen(),
          '/login': (context) => const LoginScreen(),
          '/verify': (context) => const VerifyCodeScreen(),
          '/country-selection': (context) => const CountrySelectionScreen(),
          '/home': (context) => const CharterHomePage(),
          '/settings': (context) => const SettingsScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/booking-detail': (context) => const BookingDetailPage(
                departure: 'New York',
                destination: 'Miami',
              ),
          '/trips': (context) => const TripsPage(),
          '/landing': (context) => const LandingScreen(),
          '/auth-test': (context) => const AuthTestScreen(),
          '/auth-debug': (context) => const AuthDebugScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      authProvider.initialize().then((_) {
        // Initialize session manager after auth is initialized
        final sessionManager = SessionManager();
        sessionManager.initialize(authProvider);

        // Add debug logging
        if (kDebugMode) {
          dev.log('Main: SessionManager initialized', name: 'main');
          dev.log('Main: Auth state: ${authProvider.state}', name: 'main');
          dev.log('Main: Is authenticated: ${authProvider.isAuthenticated}',
              name: 'main');
          dev.log('Main: Has valid token: ${authProvider.hasValidToken}',
              name: 'main');
        }
      });
    });
  }

  @override
  void dispose() {
    // Clean up session manager
    SessionManager().dispose();
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
            return const CharterHomePage();
          case AuthState.unauthenticated:
          case AuthState.error:
            return const LandingScreen();
        }
      },
    );
  }
}
