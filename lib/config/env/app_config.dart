class AppConfig {
  // Authentication Configuration
  static const bool useBackend = true; // Set to true when backend is ready
  static const String backendUrl =
      'http://162.198.100.10:5000'; // Update when backend is ready

  // Firebase Configuration
  static const String firebaseVerificationIdKey = 'firebase_verification_id';
  static const String localAuthDataKey = 'local_auth_data';

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

  // Backend API Endpoints (when backend is ready)
  static const String loginEndpoint = '/api/auth/customer/login';
  static const String registerEndpoint = '/api/auth/customer/register';
  static const String profileEndpoint = '/api/auth/customer/profile';
  static const String refreshTokenEndpoint = '/api/auth/customer/refresh';

  // Helper methods
  static String get fullBackendUrl => '$backendUrl/api';

  static bool get isBackendEnabled => useBackend && backendUrl.isNotEmpty;

  static String get authMode =>
      useBackend ? 'Backend + Firebase' : 'Firebase Only';
}
