import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

// Core imports
import 'core/providers/auth_provider.dart';
import 'core/providers/profile_provider.dart';
import 'core/providers/charter_deals_provider.dart';
import 'core/providers/passengers_provider.dart';
import 'core/providers/booking_provider.dart';
import 'core/providers/trips_provider.dart';
import 'core/controllers/booking.controller/booking_controller.dart';
import 'core/controllers/booking_inquiry_controller.dart';
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
import 'features/booking/booking_confirmation_page.dart';
import 'features/mytrips/trips.dart';
import 'features/direct_charter/direct_charter_search_screen.dart';
import 'package:air_charters/core/models/charter_deal_model.dart';
import 'core/models/booking_inquiry_model.dart';
import 'features/plan/inquiry/inquiry_confirmation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Stripe
  Stripe.publishableKey =
      'pk_test_51RTguYIo90LS4Ah4PiXhCbadG1lxbzAZAvYqwtjW9qNcjGqcIvc7a5IDVhIF9H5YrOWGZ8Yvo8LrxtfU5BNvSuhm00KykUKxUF';
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
        ChangeNotifierProvider(create: (_) => TripsProvider()),
        ChangeNotifierProvider(create: (_) => BookingInquiryController()),
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
        onUnknownRoute: (settings) {
          // Fallback for unknown routes
          return MaterialPageRoute(
            builder: (context) => const CharterHomePage(),
          );
        },
        navigatorKey: GlobalKey<NavigatorState>(),
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
          '/booking-confirmation': (context) {
            final bookingData = ModalRoute.of(context)!.settings.arguments
                as Map<String, dynamic>;
            return BookingConfirmationPage(bookingData: bookingData);
          },
          '/trips': (context) => const TripsPage(),
          '/direct-charter': (context) => const DirectCharterWrapper(),
          '/landing': (context) => const LandingScreen(),
          '/inquiry-confirmation': (context) {
            final inquiry = ModalRoute.of(context)!.settings.arguments
                as BookingInquiryModel;
            return InquiryConfirmationScreen(inquiry: inquiry);
          },
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

        // Set auth provider reference in other providers
        context.read<TripsProvider>().setAuthProvider(authProvider);
        context.read<ProfileProvider>().setAuthProvider(authProvider);
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
