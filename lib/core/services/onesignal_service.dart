import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'dart:io' show Platform;
import '../network/api_client.dart';

class OneSignalService {
  static final OneSignalService _instance = OneSignalService._internal();
  factory OneSignalService() => _instance;
  OneSignalService._internal();

  final ApiClient _apiClient = ApiClient();
  String? _playerId;
  String? _userId;
  bool _isInitialized = false;

  // Callbacks for notification events
  final List<Function(Map<String, dynamic>)> _notificationCallbacks = [];

  /// Initialize OneSignal
  Future<void> initialize(String oneSignalAppId) async {
    if (_isInitialized) {
      debugPrint('OneSignalService: Already initialized');
      return;
    }

    try {
      debugPrint('OneSignalService: Initializing with App ID: $oneSignalAppId');

      // Initialize OneSignal
      OneSignal.initialize(oneSignalAppId);

      // Request notification permissions (iOS)
      await OneSignal.Notifications.requestPermission(true);

      // Set up notification handlers
      _setupNotificationHandlers();

      // Get player ID
      final status = await OneSignal.User.pushSubscription.optedIn;
      if (status != null && status) {
        _playerId = OneSignal.User.pushSubscription.id;
        debugPrint('OneSignalService: Player ID: $_playerId');
      }

      _isInitialized = true;
      debugPrint('OneSignalService: Initialized successfully');
    } catch (e) {
      debugPrint('OneSignalService: Initialization failed - $e');
    }
  }

  /// Setup notification event handlers
  void _setupNotificationHandlers() {
    // Handle notification received (foreground)
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      debugPrint(
          'OneSignalService: Foreground notification: ${event.notification.title}');

      // Notify listeners
      _notifyListeners({
        'title': event.notification.title,
        'body': event.notification.body,
        'additionalData': event.notification.additionalData,
      });

      // Display notification
      event.notification.display();
    });

    // Handle notification opened (user tapped)
    OneSignal.Notifications.addClickListener((event) {
      debugPrint(
          'OneSignalService: Notification clicked: ${event.notification.title}');

      final additionalData = event.notification.additionalData;
      if (additionalData != null) {
        _handleNotificationAction(additionalData);
      }
    });

    // Handle subscription changes
    OneSignal.User.pushSubscription.addObserver((state) {
      debugPrint('OneSignalService: Subscription changed');
      debugPrint('  Player ID: ${state.current.id}');
      debugPrint('  Opted in: ${state.current.optedIn}');

      if (state.current.id != null) {
        _playerId = state.current.id;

        // Re-register with backend if user is logged in
        if (_userId != null) {
          registerDeviceWithBackend(_userId!);
        }
      }
    });
  }

  /// Set user ID (external ID in OneSignal)
  /// This follows OneSignal's user identification best practice
  Future<void> setUser(String userId) async {
    _userId = userId;

    try {
      // Login user to OneSignal (new API in v5+)
      // This replaces the old setExternalUserId method
      await OneSignal.login(userId);
      debugPrint('OneSignalService: User logged in to OneSignal: $userId');

      // Wait a moment for player ID to be available
      await Future.delayed(const Duration(milliseconds: 500));

      // Get the player ID after login
      final playerId = OneSignal.User.pushSubscription.id;
      if (playerId != null) {
        _playerId = playerId;
        debugPrint('OneSignalService: Player ID after login: $_playerId');

        // Register device with backend
        await registerDeviceWithBackend(userId);
      } else {
        debugPrint(
            'OneSignalService: Player ID not yet available, will register on subscription change');
      }
    } catch (e) {
      debugPrint('OneSignalService: Failed to set user - $e');
    }
  }

  /// Register device token with backend
  Future<void> registerDeviceWithBackend(String userId) async {
    if (_playerId == null) {
      debugPrint('OneSignalService: No player ID available');
      return;
    }

    try {
      final deviceType =
          Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : 'web');

      final response = await _apiClient.post('/api/devices/register', {
        'userId': userId,
        'playerId': _playerId,
        'deviceType': deviceType,
        'deviceModel': '', // Can be populated from device_info_plus
        'osVersion': '', // Can be populated from device_info_plus
        'appVersion': '1.0.0', // From package_info_plus
      });

      if (response['success'] == true) {
        debugPrint('OneSignalService: Device registered with backend');
      }
    } catch (e) {
      debugPrint('OneSignalService: Failed to register with backend - $e');
    }
  }

  /// Logout user (unregister device)
  Future<void> logout() async {
    try {
      if (_playerId != null) {
        await _apiClient.post('/api/devices/unregister', {
          'playerId': _playerId,
        });
      }

      // Logout from OneSignal
      await OneSignal.logout();

      _userId = null;
      debugPrint('OneSignalService: User logged out');
    } catch (e) {
      debugPrint('OneSignalService: Logout failed - $e');
    }
  }

  /// Handle notification action
  void _handleNotificationAction(Map<String, dynamic> data) {
    debugPrint('OneSignalService: Handling notification action: $data');

    // Notify listeners with action data
    _notifyListeners(data);
  }

  /// Register callback for notification events
  void onNotificationReceived(Function(Map<String, dynamic>) callback) {
    if (!_notificationCallbacks.contains(callback)) {
      _notificationCallbacks.add(callback);
      debugPrint('OneSignalService: Registered notification callback');
    }
  }

  /// Unregister callback
  void removeNotificationCallback(Function(Map<String, dynamic>) callback) {
    _notificationCallbacks.remove(callback);
  }

  /// Notify all listeners
  void _notifyListeners(Map<String, dynamic> data) {
    for (var callback in _notificationCallbacks) {
      try {
        callback(data);
      } catch (e) {
        debugPrint('OneSignalService: Error in callback - $e');
      }
    }
  }

  /// Send tags to OneSignal for targeting
  Future<void> sendTags(Map<String, String> tags) async {
    try {
      await OneSignal.User.addTags(tags);
      debugPrint('OneSignalService: Tags sent: $tags');
    } catch (e) {
      debugPrint('OneSignalService: Failed to send tags - $e');
    }
  }

  /// Get permission status
  Future<bool> get hasPermission async {
    return await OneSignal.Notifications.permission;
  }

  /// Request permission
  Future<bool> requestPermission() async {
    final granted = await OneSignal.Notifications.requestPermission(true);
    debugPrint('OneSignalService: Permission granted: $granted');
    return granted;
  }

  // Getters
  String? get playerId => _playerId;
  String? get userId => _userId;
  bool get isInitialized => _isInitialized;
}
