import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

// Core imports
import 'core/providers/auth_provider.dart';
import 'core/providers/profile_provider.dart';
import 'core/providers/charter_deals_provider.dart';
import 'core/providers/passengers_provider.dart';
import 'core/providers/booking_provider.dart';
import 'core/controllers/booking.controller/booking_controller.dart';
import 'shared/utils/session_manager.dart';

// Theme
import 'config/theme/app_theme.dart';

// Features
import 'features/auth/login_screen.dart';
import 'features/auth/signup_screen.dart';
import 'features/auth/verifycode.dart';
import 'features/auth/country_selection_screen.dart';
import 'features/home/home_screen.dart';
import 'features/profile/profile.dart';
import 'features/settings/settings.dart';
import 'features/splash/splash_screen.dart';
import 'features/splash/landing_screen.dart';
import 'features/booking/booking_detail.dart';
import 'features/mytrips/trips.dart';
import 'package:air_charters/core/models/charter_deal_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Stripe
  Stripe.publishableKey =
      'pk_test_51OqX8Y2eZvKYlo2C1gQ1234567890'; // Replace with your actual publishable key
  await Stripe.instance.applySettings();

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
        ChangeNotifierProvider(create: (_) => PassengerProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ProxyProvider2<BookingProvider, PassengerProvider, BookingController>(
          update: (context, bookingProvider, passengerProvider, _) =>
              BookingController(
            bookingProvider: bookingProvider,
            passengerProvider: passengerProvider,
            authProvider: Provider.of<AuthProvider>(context, listen: false),
          ),
        ),
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
          '/booking-detail': (context) {
            final deal =
                ModalRoute.of(context)!.settings.arguments as CharterDealModel?;
            return BookingDetailPage(deal: deal);
          },
          '/trips': (context) => const TripsPage(),
          '/landing': (context) => const LandingScreen(),
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
        // Initialize session manager (simplified - no AuthProvider dependency)
        final sessionManager = SessionManager();
        sessionManager.initialize();
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
