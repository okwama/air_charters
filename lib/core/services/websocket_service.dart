import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'notification_service.dart';
import '../../config/env/app_config.dart';

/// WebSocket Service for real-time notifications
/// Connects to Communication Service WebSocket gateway
class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  IO.Socket? _socket;
  final NotificationService _notificationService = NotificationService();

  String? _userId;
  String? _authToken;
  bool _isConnected = false;
  Timer? _reconnectTimer;
  Timer? _fallbackPollTimer;

  // Callbacks for trip updates
  final List<Function()> _tripUpdateCallbacks = [];

  /// Initialize and connect to WebSocket
  Future<void> initialize(String userId, {String? authToken}) async {
    _userId = userId;
    _authToken = authToken;

    await _connect();
    _startFallbackPolling();

    debugPrint('WebSocketService: Initialized for user $userId');
  }

  /// Connect to Socket.IO backend
  Future<void> _connect() async {
    if (_socket != null && _socket!.connected) {
      debugPrint('WebSocketService: Already connected');
      return;
    }

    try {
      // Connect to API Gateway WebSocket endpoint
      // Gateway proxies events from Communication Service via Redis
      final socketUrl = '${AppConfig.backendUrl}/notifications';

      debugPrint(
          'WebSocketService: Connecting to $socketUrl (via API Gateway)');

      _socket = IO.io(
        socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionAttempts(5)
            .setReconnectionDelay(3000)
            .build(),
      );

      // Connection handlers
      _socket!.onConnect((_) {
        debugPrint('WebSocketService: Connected to server');
        _isConnected = true;
        _authenticate();
      });

      _socket!.onDisconnect((_) {
        debugPrint('WebSocketService: Disconnected from server');
        _isConnected = false;
      });

      _socket!.onConnectError((error) {
        debugPrint('WebSocketService: Connection error: $error');
        _isConnected = false;
      });

      _socket!.onError((error) {
        debugPrint('WebSocketService: Socket error: $error');
      });

      // Authentication response
      _socket!.on('authenticated', (data) {
        debugPrint('WebSocketService: Authenticated successfully');
      });

      // Listen for booking notifications
      _setupEventListeners();
    } catch (e) {
      debugPrint('WebSocketService: Error connecting: $e');
      _scheduleReconnect();
    }
  }

  /// Authenticate with the server
  void _authenticate() {
    if (_userId == null) return;

    _socket?.emit('authenticate', {
      'userId': _userId,
      'token': _authToken ?? '',
    });
  }

  /// Setup event listeners for booking updates
  void _setupEventListeners() {
    // Booking quoted event
    _socket!.on('notification', (data) {
      debugPrint('WebSocketService: Received notification: $data');
      _handleNotification(data);
    });

    // Legacy event listeners (if backend sends these directly)
    _socket!.on('booking.quoted', (data) {
      debugPrint('WebSocketService: Booking quoted: $data');
      _notifyTripUpdate();
      _showNotification('Quote Ready! 🎉', 'Your booking quote is ready');
    });

    _socket!.on('booking.confirmed', (data) {
      debugPrint('WebSocketService: Booking confirmed: $data');
      _notifyTripUpdate();
      _showNotification(
          'Booking Confirmed 🎊', 'Your booking has been confirmed');
    });

    _socket!.on('booking.cancelled', (data) {
      debugPrint('WebSocketService: Booking cancelled: $data');
      _notifyTripUpdate();
      _showNotification('Booking Cancelled', 'Your booking has been cancelled');
    });

    _socket!.on('booking.status_changed', (data) {
      debugPrint('WebSocketService: Booking status changed: $data');
      _notifyTripUpdate();
    });

    _socket!.on('payment.completed', (data) {
      debugPrint('WebSocketService: Payment completed: $data');
      _notifyTripUpdate();
      _showNotification(
          'Payment Successful ✅', 'Your payment has been confirmed');
    });
  }

  /// Fallback polling mechanism (runs every 15 seconds when not connected)
  /// Industry standard: Uber polls every 10-15s, Airbnb every 15-30s
  void _startFallbackPolling() {
    _fallbackPollTimer?.cancel();
    _fallbackPollTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (!_isConnected) {
        debugPrint(
            'WebSocketService: Fallback poll - not connected, attempting reconnect');
        _connect();
        // Also trigger data refresh via callback
        _notifyTripUpdate();
      }
    });
  }

  /// Handle incoming notification
  void _handleNotification(dynamic notificationData) {
    try {
      final notification = notificationData is Map<String, dynamic>
          ? notificationData
          : Map<String, dynamic>.from(notificationData);

    final type = notification['type'] as String?;
    final title = notification['title'] as String? ?? 'Notification';
    final message = notification['message'] as String? ?? '';

    debugPrint('WebSocketService: Received notification: $title');

      // Trigger trip update for booking-related notifications
      if (type != null && _isBookingNotification(type)) {
        _notifyTripUpdate();
      }

    // Show local notification
      _showNotification(title, message);
    } catch (e) {
      debugPrint('WebSocketService: Error handling notification: $e');
    }
  }

  /// Check if notification is booking-related
  bool _isBookingNotification(String type) {
    return type == 'booking_created' || // NEW: inquiry created
        type == 'booking_quoted' ||
        type == 'payment_completed' ||
        type == 'booking_confirmed' ||
        type == 'booking_cancelled' ||
        type == 'booking_status_changed';
  }

  /// Show local notification
  void _showNotification(String title, String message) {
    try {
    _notificationService.sendNotification(
      title: title,
      body: message,
        type: NotificationType.booking,
      );
    } catch (e) {
      debugPrint('WebSocketService: Error showing notification: $e');
    }
  }

  /// Notify all trip update listeners
  void _notifyTripUpdate() {
    debugPrint(
        'WebSocketService: Notifying ${_tripUpdateCallbacks.length} trip update listeners');
    for (var callback in _tripUpdateCallbacks) {
      try {
        callback();
      } catch (e) {
        debugPrint('WebSocketService: Error calling trip update callback: $e');
      }
    }
  }

  /// Register callback for trip updates
  void onTripUpdate(Function() callback) {
    if (!_tripUpdateCallbacks.contains(callback)) {
      _tripUpdateCallbacks.add(callback);
      debugPrint('WebSocketService: Registered trip update callback');
    }
  }

  /// Unregister callback for trip updates
  void removeTripUpdateCallback(Function() callback) {
    _tripUpdateCallbacks.remove(callback);
    debugPrint('WebSocketService: Removed trip update callback');
  }

  /// Schedule reconnection
  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      debugPrint('WebSocketService: Attempting to reconnect...');
      _connect();
    });
  }

  /// Disconnect and cleanup
  void disconnect() {
    debugPrint('WebSocketService: Disconnecting...');

    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    _fallbackPollTimer?.cancel();
    _fallbackPollTimer = null;

    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;

    _isConnected = false;
    _userId = null;
    _authToken = null;
    _tripUpdateCallbacks.clear();

    debugPrint('WebSocketService: Disconnected');
  }

  /// Check if connected
  bool get isConnected => _isConnected && _socket != null && _socket!.connected;

  /// Reconnect
  Future<void> reconnect() async {
    disconnect();
    if (_userId != null) {
      await initialize(_userId!, authToken: _authToken);
    }
  }

  /// Manual trigger for testing
  void triggerTestNotification() {
    _notifyTripUpdate();
    _showNotification('Test Notification', 'Testing real-time updates');
  }
}
