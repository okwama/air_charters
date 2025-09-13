class AppConfig {
  // Authentication Configuration
  static const bool useBackend = true; // Backend-only authentication
  static const String backendUrl =
      'http://192.168.100.2:5000'; // Updated for local development

  // Storage Configuration
  static const String localAuthDataKey = 'local_auth_data';
  static const String authStorageKey =
      'auth_data'; // Standardized auth storage key

  // API Configuration
  static const int apiTimeoutSeconds = 30;
  static const int tokenRefreshThresholdMinutes = 5;

  // App Configuration
  static const String appName = 'AirCharters';
  static const String appVersion = '1.0.0';

  // Feature Flags
  static const bool enableAnalytics = false;
  static const bool enableCrashlytics = false;
  static const bool enablePushNotifications = false;

  // Development Configuration
  static const bool isDevelopment = true;
  static const bool enableDebugLogs = true;

  // Backend API Endpoints (updated to match NestJS endpoints)
  static const String loginEndpoint = '/api/auth/login';
  static const String registerEndpoint = '/api/auth/register';
  static const String refreshTokenEndpoint = '/api/auth/refresh';
  static const String profileEndpoint = '/api/auth/profile';
  static const String logoutEndpoint = '/api/auth/logout';
  
  // SMS Verification Endpoints
  static const String sendSmsVerificationEndpoint = '/api/sms/send-verification';
  static const String verifySmsCodeEndpoint = '/api/sms/verify-code';

  // Experience API Endpoints
  static const String experiencesEndpoint = '/api/experiences';
  static const String experienceDetailsEndpoint = '/api/experiences';
  static const String experienceCategoryEndpoint = '/api/experiences/category';
  static const String experienceSearchEndpoint = '/api/experiences/search';
  static const String experienceCategoriesEndpoint =
      '/api/experiences/categories';
  static const String experiencePopularEndpoint = '/api/experiences/popular';
  static const String experienceFeaturedEndpoint = '/api/experiences/featured';
  static const String experienceSchedulesEndpoint = '/api/experiences';
  static const String experienceAvailabilityEndpoint = '/api/experiences';

  // Experience Booking API Endpoints
  static const String experienceBookingsEndpoint = '/api/experience-bookings';
  static const String experienceBookingDetailsEndpoint =
      '/api/experience-bookings';
  static const String experienceBookingCancelEndpoint =
      '/api/experience-bookings';
  static const String experienceBookingConfirmationEndpoint =
      '/api/experience-bookings';

  // Helper methods
  static String get fullBackendUrl => '$backendUrl/api';
  static String get baseUrl => backendUrl;

  static bool get isBackendEnabled => useBackend && backendUrl.isNotEmpty;

  static String get authMode => 'Backend Only';

  // Auth token getter (you'll need to implement this based on your auth system)
  static String get authToken {
    // This should return the current user's auth token
    // You'll need to implement this based on your auth system
    return '';
  }

  // Payment Configuration
  // Note: All payment keys are managed server-side for security
  // Flutter only calls backend APIs that handle payment processing

  // Payment API Endpoints
  static const String mpesaStkPushEndpoint = '/api/payments/mpesa/stk-push';
  static const String paymentStatusEndpoint = '/api/payments';
  static const String paymentConfirmEndpoint = '/api/payments';
  static const String paymentMethodsEndpoint = '/api/payments/methods';
  static const String paymentIntentEndpoint = '/api/payments/intent';
  static const String paymentRefundEndpoint = '/api/payments';
  static const String paymentHistoryEndpoint = '/api/payments/history';

  // Paystack API Endpoints
  static const String paystackInitializeEndpoint = '/api/payments/paystack/initialize';
  static const String paystackVerifyEndpoint = '/api/payments/paystack/verify';
  static const String paystackWebhookEndpoint = '/api/payments/paystack/webhook';
  static const String paystackSubaccountEndpoint = '/api/payments/paystack/subaccount';
  static const String paystackInfoEndpoint = '/api/payments/paystack/info';
}
