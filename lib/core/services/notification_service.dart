import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final AndroidInitializationSettings _androidSettings =
      const AndroidInitializationSettings('@mipmap/launcher_icon');
  final DarwinInitializationSettings _iosSettings =
      const DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  // Notification channels for Android
  static const String _bookingChannelId = 'booking_notifications';
  static const String _promotionChannelId = 'promotion_notifications';
  static const String _updateChannelId = 'update_notifications';
  static const String _securityChannelId = 'security_notifications';
  static const String _marketingChannelId = 'marketing_notifications';

  // Settings keys
  static const String _emailNotificationsKey = 'email_notifications';
  static const String _pushNotificationsKey = 'push_notifications';
  static const String _smsNotificationsKey = 'sms_notifications';
  static const String _bookingNotificationsKey = 'booking_notifications';
  static const String _promotionNotificationsKey = 'promotion_notifications';
  static const String _updateNotificationsKey = 'update_notifications';
  static const String _securityNotificationsKey = 'security_notifications';
  static const String _marketingNotificationsKey = 'marketing_notifications';
  static const String _quietHoursEnabledKey = 'quiet_hours_enabled';
  static const String _quietHoursStartKey = 'quiet_hours_start';
  static const String _quietHoursEndKey = 'quiet_hours_end';

  Future<void> initialize() async {
    try {
      // Initialize settings
      final InitializationSettings settings = InitializationSettings(
        android: _androidSettings,
        iOS: _iosSettings,
      );

      // Initialize plugin
      await _notifications.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Create notification channels for Android
      await _createNotificationChannels();

      // Request permissions
      await _requestPermissions();

      debugPrint('NotificationService: Initialized successfully');
    } catch (e) {
      debugPrint('NotificationService: Initialization failed - $e');
    }
  }

  Future<void> _createNotificationChannels() async {
    const AndroidNotificationChannel bookingChannel =
        AndroidNotificationChannel(
      _bookingChannelId,
      'Booking Updates',
      description: 'Flight confirmations, changes, and reminders',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    const AndroidNotificationChannel promotionChannel =
        AndroidNotificationChannel(
      _promotionChannelId,
      'Promotions & Deals',
      description: 'Special offers and exclusive deals',
      importance: Importance.defaultImportance,
      playSound: true,
      enableVibration: false,
    );

    const AndroidNotificationChannel updateChannel = AndroidNotificationChannel(
      _updateChannelId,
      'App Updates',
      description: 'New features and app improvements',
      importance: Importance.low,
      playSound: false,
      enableVibration: false,
    );

    const AndroidNotificationChannel securityChannel =
        AndroidNotificationChannel(
      _securityChannelId,
      'Security Alerts',
      description: 'Account security and login notifications',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    const AndroidNotificationChannel marketingChannel =
        AndroidNotificationChannel(
      _marketingChannelId,
      'Marketing Communications',
      description: 'Newsletters and promotional content',
      importance: Importance.low,
      playSound: false,
      enableVibration: false,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(bookingChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(promotionChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(updateChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(securityChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(marketingChannel);
  }

  Future<void> _requestPermissions() async {
    // Request notification permissions
    final status = await Permission.notification.request();
    debugPrint('Notification permission status: $status');
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    debugPrint('Notification tapped: ${response.payload}');
    // TODO: Navigate to appropriate screen based on notification type
  }

  // Save notification settings
  Future<void> saveNotificationSettings({
    required bool emailNotifications,
    required bool pushNotifications,
    required bool smsNotifications,
    required bool bookingNotifications,
    required bool promotionNotifications,
    required bool updateNotifications,
    required bool securityNotifications,
    required bool marketingNotifications,
    required bool quietHoursEnabled,
    required String quietHoursStart,
    required String quietHoursEnd,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_emailNotificationsKey, emailNotifications);
    await prefs.setBool(_pushNotificationsKey, pushNotifications);
    await prefs.setBool(_smsNotificationsKey, smsNotifications);
    await prefs.setBool(_bookingNotificationsKey, bookingNotifications);
    await prefs.setBool(_promotionNotificationsKey, promotionNotifications);
    await prefs.setBool(_updateNotificationsKey, updateNotifications);
    await prefs.setBool(_securityNotificationsKey, securityNotifications);
    await prefs.setBool(_marketingNotificationsKey, marketingNotifications);
    await prefs.setBool(_quietHoursEnabledKey, quietHoursEnabled);
    await prefs.setString(_quietHoursStartKey, quietHoursStart);
    await prefs.setString(_quietHoursEndKey, quietHoursEnd);
  }

  // Load notification settings
  Future<Map<String, dynamic>> loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'emailNotifications': prefs.getBool(_emailNotificationsKey) ?? true,
      'pushNotifications': prefs.getBool(_pushNotificationsKey) ?? true,
      'smsNotifications': prefs.getBool(_smsNotificationsKey) ?? false,
      'bookingNotifications': prefs.getBool(_bookingNotificationsKey) ?? true,
      'promotionNotifications':
          prefs.getBool(_promotionNotificationsKey) ?? true,
      'updateNotifications': prefs.getBool(_updateNotificationsKey) ?? true,
      'securityNotifications': prefs.getBool(_securityNotificationsKey) ?? true,
      'marketingNotifications':
          prefs.getBool(_marketingNotificationsKey) ?? false,
      'quietHoursEnabled': prefs.getBool(_quietHoursEnabledKey) ?? false,
      'quietHoursStart': prefs.getString(_quietHoursStartKey) ?? '22:00',
      'quietHoursEnd': prefs.getString(_quietHoursEndKey) ?? '08:00',
    };
  }

  // Check if we're in quiet hours
  bool _isInQuietHours(String startTime, String endTime) {
    final now = DateTime.now();
    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    // Simple time comparison (you might want to improve this logic)
    if (startTime.compareTo(endTime) > 0) {
      // Quiet hours span midnight (e.g., 22:00 to 08:00)
      return currentTime.compareTo(startTime) >= 0 ||
          currentTime.compareTo(endTime) <= 0;
    } else {
      // Quiet hours within same day
      return currentTime.compareTo(startTime) >= 0 &&
          currentTime.compareTo(endTime) <= 0;
    }
  }

  // Send notification based on type
  Future<void> sendNotification({
    required String title,
    required String body,
    required NotificationType type,
    String? payload,
  }) async {
    try {
      // Load settings
      final settings = await loadNotificationSettings();

      // Check if notifications are enabled for this type
      bool isEnabled = false;
      String channelId = '';

      switch (type) {
        case NotificationType.booking:
          isEnabled =
              settings['bookingNotifications'] && settings['pushNotifications'];
          channelId = _bookingChannelId;
          break;
        case NotificationType.promotion:
          isEnabled = settings['promotionNotifications'] &&
              settings['pushNotifications'];
          channelId = _promotionChannelId;
          break;
        case NotificationType.update:
          isEnabled =
              settings['updateNotifications'] && settings['pushNotifications'];
          channelId = _updateChannelId;
          break;
        case NotificationType.security:
          isEnabled = settings['securityNotifications'] &&
              settings['pushNotifications'];
          channelId = _securityChannelId;
          break;
        case NotificationType.marketing:
          isEnabled = settings['marketingNotifications'] &&
              settings['pushNotifications'];
          channelId = _marketingChannelId;
          break;
      }

      if (!isEnabled) {
        debugPrint(
            'NotificationService: Notifications disabled for type $type');
        return;
      }

      // Check quiet hours
      if (settings['quietHoursEnabled'] &&
          _isInQuietHours(
              settings['quietHoursStart'], settings['quietHoursEnd'])) {
        debugPrint(
            'NotificationService: In quiet hours, skipping notification');
        return;
      }

      // Create notification details
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        _bookingChannelId,
        'Booking Updates',
        channelDescription: 'Flight confirmations, changes, and reminders',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Send notification
      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        details,
        payload: payload,
      );

      debugPrint('NotificationService: Notification sent successfully');
    } catch (e) {
      debugPrint('NotificationService: Failed to send notification - $e');
    }
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // Send test notification
  Future<void> sendTestNotification() async {
    await sendNotification(
      title: 'Test Notification',
      body: 'This is a test notification from Air Charters!',
      type: NotificationType.booking,
      payload: 'test_notification',
    );
  }
}

enum NotificationType {
  booking,
  promotion,
  update,
  security,
  marketing,
}
