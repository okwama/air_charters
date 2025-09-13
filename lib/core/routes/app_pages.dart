import 'package:flutter/material.dart';
import 'package:air_charters/core/routes/app_routes.dart';
import 'package:air_charters/core/models/charter_deal_model.dart';
import 'package:air_charters/core/models/booking_inquiry_model.dart';

// Main app imports
import '../../main.dart';
import '../../features/main_navigation_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/signup_screen.dart';
import '../../features/auth/verifycode.dart';
import '../../features/auth/country_selection_screen.dart';
import '../../features/splash/landing_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/settings/settings.dart';
import '../../features/mytrips/trips.dart';
import '../../features/direct_charter/direct_charter_search_screen.dart';

// Booking imports
import '../../features/booking/booking_detail.dart';
import '../../features/booking/booking_confirmation_page.dart';
import '../../features/booking/aircraft_selection_page.dart';
import '../../features/booking/passenger_form_page.dart';
import '../../features/booking/review_trip.dart';
import '../../features/booking/confirm_booking.dart';

// Payment imports
import '../../features/booking/payment/payment_screen.dart';
import '../../features/booking/payment/add_card.dart';

// Experience imports
import '../../features/experiences/experience_tours.dart';
import '../../features/experiences/tour_detail.dart';
import '../../features/experiences/tour_list.dart';
import '../../features/experiences/experience_booking_page.dart';
import '../../features/experiences/experience_passenger_form.dart';
import '../../features/experiences/experience_payment_page.dart';
import '../../features/experiences/experience_booking_confirmation.dart';

// Planning imports
import '../../features/plan/flight_search_screen.dart';
import '../../features/plan/aircraft_results_screen.dart';
import '../../features/plan/locations.dart';
import '../../features/plan/stops_selection_screen.dart';
import '../../features/plan/inquiry/create_inquiry_screen.dart';
import '../../features/plan/inquiry/inquiry_confirmation_screen.dart';

// Direct charter imports
import '../../features/direct_charter/direct_charter_results_screen.dart';
import '../../features/direct_charter/direct_charter_booking_screen.dart';

// Settings imports
import '../../features/settings/pages/notification_settings_page.dart';
import '../../features/settings/pages/currency_page.dart';
import '../../features/settings/pages/theme_page.dart';
import '../../features/settings/pages/language_page.dart';
import '../../features/settings/pages/contact_support_page.dart';
import '../../features/settings/pages/faq_page.dart';
import '../../features/settings/pages/app_version_page.dart';

/// Centralized route definitions and page mappings
/// This class provides a clean way to define all routes and their corresponding pages
class AppPages {
  // Private constructor to prevent instantiation
  AppPages._();

  /// Get all route definitions for the MaterialApp
  static Map<String, WidgetBuilder> get routes => {
        // Root and main navigation
        AppRoutes.root: (context) => const AuthWrapper(),
        AppRoutes.home: (context) => const CharterHomePage(),
        AppRoutes.mainNavigation: (context) => const MainNavigationScreen(),
        AppRoutes.dashboard: (context) => const DashboardScreen(),

        // Authentication routes
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.signup: (context) => const SignupScreen(),
        AppRoutes.verify: (context) => const VerifyCodeScreen(),
        AppRoutes.countrySelection: (context) => const CountrySelectionScreen(),
        AppRoutes.landing: (context) => const LandingScreen(),

        // Main feature routes
        AppRoutes.directCharter: (context) => const DirectCharterWrapper(),
        AppRoutes.trips: (context) => const TripsPage(),
        AppRoutes.settings: (context) => const SettingsScreen(),

        // Booking flow routes
        AppRoutes.bookingDetail: (context) {
          final deal =
              ModalRoute.of(context)!.settings.arguments as CharterDealModel?;
          return BookingDetailPage(deal: deal);
        },
        AppRoutes.bookingConfirmation: (context) {
          final bookingData = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return BookingConfirmationPage(bookingData: bookingData);
        },
        AppRoutes.aircraftSelection: (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return AircraftSelectionPage(
            aircraft: args['aircraft'],
            origin: args['origin'],
            destination: args['destination'],
            departureDate: args['departureDate'],
            returnDate: args['returnDate'],
            passengerCount: args['passengerCount'],
            isRoundTrip: args['isRoundTrip'],
          );
        },
        AppRoutes.passengerForm: (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>?;
          return PassengerFormPage(
            passenger: args?['passenger'],
            onSuccess: args?['onSuccess'],
          );
        },
        AppRoutes.reviewTrip: (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return ReviewTripPage(
            departure: args['departure'],
            destination: args['destination'],
            date: args['date'],
            time: args['time'],
            aircraft: args['aircraft'],
            seats: args['seats'],
            duration: args['duration'],
            price: args['price'],
            deal: args['deal'],
          );
        },
        AppRoutes.confirmBooking: (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return ConfirmBookingPage(
            departure: args['departure'],
            destination: args['destination'],
            date: args['date'],
            time: args['time'],
            aircraft: args['aircraft'],
            seats: args['seats'],
            duration: args['duration'],
            price: args['price'],
            deal: args['deal'],
          );
        },

        // Payment routes
        AppRoutes.payment: (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return PaymentScreen(
            bookingId: args['bookingId'],
            amount: args['amount'],
            clientSecret: args['clientSecret'],
            currency: args['currency'],
            paymentIntentId: args['paymentIntentId'],
            savedCard: args['savedCard'],
          );
        },
        AppRoutes.addCard: (context) => const AddCardPage(),

        // Experience routes
        AppRoutes.experienceTours: (context) => const ExperienceToursScreen(),
        AppRoutes.tourDetail: (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return TourDetailPage(
            imageUrl: args['imageUrl'],
            title: args['title'],
            location: args['location'],
            duration: args['duration'],
            price: args['price'],
            rating: args['rating'],
            description: args['description'],
            experienceId: args['experienceId'],
          );
        },
        AppRoutes.tourList: (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return TourListScreen(
            category: args['category'],
            deals: args['deals'],
          );
        },
        AppRoutes.experienceBooking: (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return ExperienceBookingPage(
            experienceId: args['experienceId'],
            title: args['title'],
            location: args['location'],
            imageUrl: args['imageUrl'],
            price: args['price'],
            priceUnit: args['priceUnit'],
            durationMinutes: args['durationMinutes'],
            description: args['description'],
          );
        },
        AppRoutes.experiencePassengerForm: (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return ExperiencePassengerForm(
            booking: args['booking'],
          );
        },
        AppRoutes.experiencePayment: (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return ExperiencePaymentPage(
            booking: args['booking'],
          );
        },
        AppRoutes.experienceBookingConfirmation: (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return ExperienceBookingConfirmation(
            bookingId: args['bookingId'],
            booking: args['booking'],
          );
        },

        // Planning routes
        AppRoutes.flightSearch: (context) => const FlightSearchScreen(),
        AppRoutes.aircraftResults: (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return AircraftResultsScreen(
            origin: args['origin'],
            destination: args['destination'],
            departureDate: args['departureDate'],
            returnDate: args['returnDate'],
            passengerCount: args['passengerCount'],
            isRoundTrip: args['isRoundTrip'],
          );
        },

        AppRoutes.locations: (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return LocationsScreen(
            title: args['title'],
            onLocationSelected: args['onLocationSelected'],
          );
        },
        AppRoutes.stopsSelection: (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return StopsSelectionScreen(
            onStopsSelected: args['onStopsSelected'],
          );
        },
        AppRoutes.createInquiry: (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return CreateInquiryScreen(
            origin: args['origin'],
            destination: args['destination'],
            departureDate: args['departureDate'],
            returnDate: args['returnDate'],
            passengerCount: args['passengerCount'],
            isRoundTrip: args['isRoundTrip'],
          );
        },
        AppRoutes.inquiryConfirmation: (context) {
          final inquiry =
              ModalRoute.of(context)!.settings.arguments as BookingInquiryModel;
          return InquiryConfirmationScreen(inquiry: inquiry);
        },

        // Direct charter sub-routes
        AppRoutes.directCharterSearch: (context) =>
            const DirectCharterSearchScreen(),
        AppRoutes.directCharterResults: (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return DirectCharterResultsScreen(
            aircraft: args['aircraft'],
            searchData: args['searchData'],
          );
        },
        AppRoutes.directCharterBooking: (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return DirectCharterBookingScreen(
            aircraft: args['aircraft'],
            searchData: args['searchData'],
          );
        },

        // Settings sub-routes
        AppRoutes.notificationSettings: (context) =>
            const NotificationSettingsPage(),
        AppRoutes.currencySettings: (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return CurrencyPage(
            currentCurrency: args['currentCurrency'],
            onCurrencySelected: args['onCurrencySelected'],
          );
        },
        AppRoutes.themeSettings: (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return ThemePage(
            currentTheme: args['currentTheme'],
            onThemeSelected: args['onThemeSelected'],
          );
        },
        AppRoutes.languageSettings: (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return LanguagePage(
            currentLanguage: args['currentLanguage'],
            onLanguageSelected: args['onLanguageSelected'],
          );
        },
        AppRoutes.contactSupport: (context) => const ContactSupportPage(),
        AppRoutes.faq: (context) => const FAQPage(),
        AppRoutes.appVersion: (context) => const AppVersionPage(),
      };

  /// Get route with arguments for complex navigation
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    final String routeName = settings.name ?? AppRoutes.root;
    final WidgetBuilder? builder = routes[routeName];

    if (builder == null) {
      // Return a fallback route for unknown routes
      return MaterialPageRoute(
        builder: (context) => const CharterHomePage(),
        settings: settings,
      );
    }

    return MaterialPageRoute(
      builder: builder,
      settings: settings,
    );
  }

  /// Check if a route exists
  static bool routeExists(String routeName) {
    return routes.containsKey(routeName);
  }

  /// Get all available routes
  static List<String> getAllRoutes() {
    return routes.keys.toList();
  }

  /// Get routes by category
  static List<String> getRoutesByCategory(String category) {
    switch (category.toLowerCase()) {
      case 'auth':
        return AppRoutes.authRoutes;
      case 'main':
        return AppRoutes.mainTabRoutes;
      case 'booking':
        return AppRoutes.bookingRoutes;
      case 'payment':
        return AppRoutes.paymentRoutes;
      case 'experience':
        return AppRoutes.experienceRoutes;
      case 'planning':
        return AppRoutes.planningRoutes;
      case 'settings':
        return AppRoutes.settingsRoutes;
      default:
        return [];
    }
  }

  /// Validate route arguments
  static bool validateRouteArguments(String routeName, dynamic arguments) {
    switch (routeName) {
      case AppRoutes.bookingDetail:
        return arguments is CharterDealModel?;
      case AppRoutes.bookingConfirmation:
        return arguments is Map<String, dynamic>;
      case AppRoutes.inquiryConfirmation:
        return arguments is BookingInquiryModel;
      default:
        return true; // Most routes don't require specific arguments
    }
  }
}
