import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

// Core providers
import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/charter_deals_provider.dart';
import '../providers/experiences_provider.dart';
import '../providers/booking_provider.dart';
import '../providers/passengers_provider.dart';
import '../providers/booking_inquiry_provider.dart';
import '../providers/trips_provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/theme_provider.dart';

// Services
import 'user_service.dart';
import 'booking_business_service.dart';
import 'notification_service.dart';

/// Centralized dependency injection service
/// Manages all provider creation and dependencies
class DependencyInjectionService {
  static List<SingleChildWidget> getProviders() {
    return [
      // Core providers
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ChangeNotifierProvider(create: (_) => CharterDealsProvider()),
      ChangeNotifierProvider(create: (_) => ExperiencesProvider()),
      ChangeNotifierProvider(create: (_) => BookingProvider()),
      ChangeNotifierProvider(create: (_) => PassengerProvider()),
      ChangeNotifierProvider(create: (_) => BookingInquiryProvider()),
      ChangeNotifierProvider(create: (_) => TripsProvider()),
      ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ChangeNotifierProvider(create: (_) => ThemeProvider()),

      // Services
      Provider<UserService>(create: (_) => UserService()),
      Provider<NotificationService>(create: (_) => NotificationService()),

      // Settings provider with dependencies
      ChangeNotifierProxyProvider2<AuthProvider, UserService, SettingsProvider>(
        create: (context) => SettingsProvider(
          authProvider: Provider.of<AuthProvider>(context, listen: false),
          userService: Provider.of<UserService>(context, listen: false),
        ),
        update: (context, authProvider, userService, previous) =>
            previous ??
            SettingsProvider(
              authProvider: authProvider,
              userService: userService,
            ),
      ),

      // Business logic services
      ProxyProvider2<BookingProvider, PassengerProvider,
          BookingBusinessService>(
        update: (context, bookingProvider, passengerProvider, _) =>
            BookingBusinessService(
          bookingProvider: bookingProvider,
          passengerProvider: passengerProvider,
          authProvider: Provider.of<AuthProvider>(context, listen: false),
        ),
      ),
    ];
  }

  /// Get a provider instance from context
  static T getProvider<T>(BuildContext context) {
    return Provider.of<T>(context, listen: false);
  }

  /// Get a provider instance from context with listening
  static T getProviderWithListen<T>(BuildContext context) {
    return Provider.of<T>(context, listen: true);
  }

  static Future<void> initializeProviders(BuildContext context) async {
    // Any async initialization can go here
  }

  static void disposeProviders(BuildContext context) {
    // Any cleanup can go here
  }
}
