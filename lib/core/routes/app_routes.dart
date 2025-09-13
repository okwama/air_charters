/// Centralized route constants for the Air Charters app
/// This file contains all route names used throughout the application
/// to ensure consistency and prevent typos in route navigation.
class AppRoutes {
  // Private constructor to prevent instantiation
  AppRoutes._();

  // Root and main navigation routes
  static const String root = '/';
  static const String home = '/home';
  static const String mainNavigation = '/main-navigation';
  static const String dashboard = '/dashboard';

  // Authentication routes
  static const String login = '/login';
  static const String signup = '/signup';
  static const String verify = '/verify';
  static const String countrySelection = '/country-selection';
  static const String landing = '/landing';

  // Main feature routes
  static const String directCharter = '/direct-charter';
  static const String trips = '/trips';
  static const String settings = '/settings';
  static const String profile = '/profile';

  // Booking flow routes
  static const String bookingDetail = '/booking-detail';
  static const String bookingConfirmation = '/booking-confirmation';
  static const String aircraftSelection = '/aircraft-selection';
  static const String passengerForm = '/passenger-form';
  static const String reviewTrip = '/review-trip';
  static const String confirmBooking = '/confirm-booking';

  // Payment routes
  static const String payment = '/payment';
  static const String addCard = '/add-card';

  // Experience routes
  static const String experienceTours = '/experience-tours';
  static const String tourDetail = '/tour-detail';
  static const String tourList = '/tour-list';
  static const String experienceBooking = '/experience-booking';
  static const String experiencePassengerForm = '/experience-passenger-form';
  static const String experiencePayment = '/experience-payment';
  static const String experienceBookingConfirmation =
      '/experience-booking-confirmation';

  // Planning routes
  static const String flightSearch = '/flight-search';
  static const String aircraftResults = '/aircraft-results';
  static const String locations = '/locations';
  static const String stopsSelection = '/stops-selection';
  static const String createInquiry = '/create-inquiry';
  static const String inquiryConfirmation = '/inquiry-confirmation';

  // Settings sub-routes
  static const String notificationSettings = '/notification-settings';
  static const String currencySettings = '/currency-settings';
  static const String themeSettings = '/theme-settings';
  static const String languageSettings = '/language-settings';
  static const String contactSupport = '/contact-support';
  static const String faq = '/faq';
  static const String appVersion = '/app-version';

  // Direct charter sub-routes
  static const String directCharterSearch = '/direct-charter-search';
  static const String directCharterResults = '/direct-charter-results';
  static const String directCharterBooking = '/direct-charter-booking';

  // Route groups for easier management
  static const List<String> authRoutes = [
    login,
    signup,
    verify,
    countrySelection,
    landing,
  ];

  static const List<String> mainTabRoutes = [
    home,
    directCharter,
    trips,
    settings,
  ];

  static const List<String> bookingRoutes = [
    bookingDetail,
    bookingConfirmation,
    aircraftSelection,
    passengerForm,
    reviewTrip,
    confirmBooking,
  ];

  static const List<String> paymentRoutes = [
    payment,
    addCard,
  ];

  static const List<String> experienceRoutes = [
    experienceTours,
    tourDetail,
    tourList,
    experienceBooking,
    experiencePassengerForm,
    experiencePayment,
    experienceBookingConfirmation,
  ];

  static const List<String> planningRoutes = [
    flightSearch,
    aircraftResults,
    locations,
    stopsSelection,
    createInquiry,
    inquiryConfirmation,
  ];

  static const List<String> settingsRoutes = [
    notificationSettings,
    currencySettings,
    themeSettings,
    languageSettings,
    contactSupport,
    faq,
    appVersion,
  ];

  // Helper methods
  static bool isAuthRoute(String route) => authRoutes.contains(route);
  static bool isMainTabRoute(String route) => mainTabRoutes.contains(route);
  static bool isBookingRoute(String route) => bookingRoutes.contains(route);
  static bool isPaymentRoute(String route) => paymentRoutes.contains(route);
  static bool isExperienceRoute(String route) =>
      experienceRoutes.contains(route);
  static bool isPlanningRoute(String route) => planningRoutes.contains(route);
  static bool isSettingsRoute(String route) => settingsRoutes.contains(route);

  // Get route category for analytics
  static String getRouteCategory(String route) {
    if (isAuthRoute(route)) return 'authentication';
    if (isMainTabRoute(route)) return 'main_navigation';
    if (isBookingRoute(route)) return 'booking';
    if (isPaymentRoute(route)) return 'payment';
    if (isExperienceRoute(route)) return 'experience';
    if (isPlanningRoute(route)) return 'planning';
    if (isSettingsRoute(route)) return 'settings';
    return 'other';
  }

  // Get route display name for analytics
  static String getRouteDisplayName(String route) {
    switch (route) {
      case root:
        return 'Root';
      case home:
        return 'Home';
      case login:
        return 'Login';
      case signup:
        return 'Sign Up';
      case verify:
        return 'Verify Code';
      case countrySelection:
        return 'Country Selection';
      case landing:
        return 'Landing';
      case directCharter:
        return 'Direct Charter';
      case trips:
        return 'My Trips';
      case settings:
        return 'Settings';
      case profile:
        return 'Profile';
      case bookingDetail:
        return 'Booking Detail';
      case bookingConfirmation:
        return 'Booking Confirmation';
      case payment:
        return 'Payment';
      case experienceTours:
        return 'Experience Tours';
      case flightSearch:
        return 'Flight Search';
      default:
        return route
            .replaceAll('/', '')
            .replaceAll('-', ' ')
            .split(' ')
            .map((word) => word.isNotEmpty
                ? word[0].toUpperCase() + word.substring(1)
                : '')
            .join(' ');
    }
  }
}
