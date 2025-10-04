class AppConfig {
  // Authentication Configuration
  static const bool useBackend = true; // Backend-only authentication
  static const String backendUrl =
      //'http://172.20.10.3:5000'; ||
     'http://192.168.100.2:5008';
  //'http://139.59.44.175:5008'; //production

  // Storage Configuration
  static const String localAuthDataKey = 'local_auth_data';
  static const String authStorageKey =
      'auth_data'; // Standardized auth storage key

  // API Configuration
  static const int apiTimeoutSeconds = 30;
  static const int tokenRefreshThresholdMinutes = 5;

  // Token Configuration (Configurable)
  static const int accessTokenLifespanHours = 24; // Keep current user-friendly approach
  static const int refreshTokenLifespanDays = 30; // Industry standard
  static const int biometricDataExpiryDays = 30; // Biometric data expiry
  static const int sessionInactivityTimeoutMinutes = 0; // 0 = disabled (like Uber)

  // Biometric Authentication Configuration
  static const bool enableBiometricAuthentication = true;
  static const bool requirePasswordForBiometricSetup = true; // Security best practice
  static const bool enablePureBiometricLogin = false; // Requires additional backend validation
  static const int biometricRefreshWarningDays = 7; // Warn user 7 days before expiry

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
  static const String phoneLoginEndpoint = '/api/auth/login/phone';
  static const String biometricLoginEndpoint = '/api/auth/login/biometric';
  static const String registerEndpoint = '/api/auth/register';
  static const String refreshTokenEndpoint = '/api/auth/refresh';
  static const String profileEndpoint = '/api/auth/profile';
  static const String logoutEndpoint = '/api/auth/logout';

  // SMS Verification Endpoints
  static const String sendSmsVerificationEndpoint =
      '/api/sms/send-verification';
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

  // Currency Configuration
  static const String defaultCurrency = 'USD';
  static const String paystackCurrency = 'KES'; // Paystack supports KES
  static const Map<String, double> exchangeRates = {
    'USD_TO_KES': 129.0, // 1 USD = 129 KES (approximate)
    'KES_TO_USD': 0.0077, // 1 KES = 0.0077 USD
  };

  // Payment API Endpoints
  static const String mpesaStkPushEndpoint = '/api/payments/mpesa/stk-push';
  static const String paymentStatusEndpoint = '/api/payments';
  static const String paymentConfirmEndpoint = '/api/payments';
  static const String paymentMethodsEndpoint = '/api/payments/methods';
  static const String paymentIntentEndpoint = '/api/payments/intent';
  static const String paymentRefundEndpoint = '/api/payments';
  static const String paymentHistoryEndpoint = '/api/payments/history';

  // Paystack API Endpoints
  static const String paystackInitializeEndpoint =
      '/api/payments/paystack/initialize';
  static const String paystackVerifyEndpoint = '/api/payments/paystack/verify';
  static const String paystackWebhookEndpoint =
      '/api/payments/paystack/webhook';
  static const String paystackSubaccountEndpoint =
      '/api/payments/paystack/subaccount';
  static const String paystackInfoEndpoint = '/api/payments/paystack/info';

  // Payment Verification URL Patterns
  static List<String> get paymentSuccessUrlPatterns {
    final basePatterns = [
      'success',
      'callback',
      'verify',
      'complete',
      'thank',
      'approved',
      'payment-success',
      'transaction-success',
      'payments/verify', // Specific Paystack verification URL
      'api/payments/verify', // Generic verification URL
    ];

    // Add environment-specific patterns
    if (isDevelopment) {
      basePatterns.addAll([
        'localhost:5000/api/payments/verify', // Local development
        'localhost:5000/api/payments/paystack/verify', // Local Paystack verification
        '192.168.100.2:5000/api/payments/verify', // Local network
        '192.168.100.2:5000/api/payments/paystack/verify', // Local network Paystack verification
        '127.0.0.1:5000/api/payments/verify', // Localhost
        '127.0.0.1:5000/api/payments/paystack/verify', // Localhost Paystack verification
      ]);
    } else {
      basePatterns.addAll([
        'aircharters-api.vercel.app/api/payments/verify', // Production
        'aircharters-api.vercel.app/api/payments/paystack/verify', // Production Paystack verification
        'vercel.app/api/payments/verify', // Vercel deployment
        'vercel.app/api/payments/paystack/verify', // Vercel Paystack verification
      ]);
    }

    return basePatterns;
  }

  static const List<String> paymentFailureUrlPatterns = [
    'cancel',
    'error',
    'abandoned',
    'declined',
    'failed',
    'payment-failed',
    'transaction-failed',
    'cancelled',
    'timeout',
  ];

  static const List<String> paystackCheckoutUrlPatterns = [
    'checkout.paystack.com',
    'paystack.com/checkout',
    'paystack.com/pay',
  ];

  // Helper method to get current backend verification URL pattern
  static String get currentBackendVerificationUrl {
    return '$backendUrl/api/payments/verify';
  }

  // Helper method to get current backend Paystack verification URL pattern
  static String get currentBackendPaystackVerificationUrl {
    return '$backendUrl/api/payments/paystack/verify';
  }

  // Helper method to check if a URL matches the current backend verification URL
  static bool isCurrentBackendVerificationUrl(String url) {
    return url.contains(currentBackendVerificationUrl) ||
        url.contains(currentBackendPaystackVerificationUrl);
  }

  // Payment timeout configurations
  static const int paymentInitializationTimeoutSeconds = 30;
  static const int paymentVerificationTimeoutSeconds = 120; // 2 minutes
  static const int paymentStatusCheckIntervalSeconds = 6;
  static const int maxPaymentStatusChecks = 20; // 2 minutes total

  // Service Icons Configuration
  static const String dealsIconPath = 'assets/images/deal.png';
  static const String directCharterIconPath = 'assets/images/direct_charter.png';
  static const String experiencesIconPath = 'assets/images/experiences.png';
  static const String cargoIconPath = 'assets/images/cargo.png';
  static const String medivacIconPath = 'assets/images/medivac.png';

  // Service Configuration Helper
  static const Map<String, String> serviceIcons = {
    'Deals': dealsIconPath,
    'Direct Charter': directCharterIconPath,
    'Experiences': experiencesIconPath,
    'Cargo': cargoIconPath,
    'Medical': medivacIconPath,
  };

  // Legal Documents Configuration
  static const String legalDocumentsPath = 'assets/legal/';
  static const String termsOfServicePdfPath = '${legalDocumentsPath}terms_of_service.pdf';
  static const String privacyPolicyPdfPath = '${legalDocumentsPath}privacy_policy.pdf';
  static const String cookiePolicyPdfPath = '${legalDocumentsPath}cookie_policy.pdf';
  static const String dataProcessingPdfPath = '${legalDocumentsPath}data_processing.pdf';

  // Legal Documents Configuration Helper
  static const Map<String, String> legalDocuments = {
    'Terms of Service': termsOfServicePdfPath,
    'Privacy Policy': privacyPolicyPdfPath,
    'Cookie Policy': cookiePolicyPdfPath,
    'Data Processing': dataProcessingPdfPath,
  };

  // Helper method to get legal document path
  static String getLegalDocumentPath(String documentName) {
    return legalDocuments[documentName] ?? '';
  }
}
