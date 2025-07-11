class AppConfig {
  // Authentication Configuration
  static const bool useBackend = true; // Backend-only authentication
  static const String backendUrl =
      'http://192.168.100.10:5000'; // Updated for local development

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

  // Helper methods
  static String get fullBackendUrl => '$backendUrl/api';

  static bool get isBackendEnabled => useBackend && backendUrl.isNotEmpty;

  static String get authMode => 'Backend Only';
}
