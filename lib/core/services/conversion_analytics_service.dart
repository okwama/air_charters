import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Service for tracking guest-to-user conversion analytics
class ConversionAnalyticsService {
  static const String _conversionEventsKey = 'conversion_events';
  static const String _guestSessionKey = 'guest_session';
  static const String _conversionFunnelKey = 'conversion_funnel';

  /// Track guest session start
  static Future<void> trackGuestSessionStart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionData = {
        'sessionId': DateTime.now().millisecondsSinceEpoch.toString(),
        'startTime': DateTime.now().toIso8601String(),
        'events': <Map<String, dynamic>>[],
      };
      
      await prefs.setString(_guestSessionKey, jsonEncode(sessionData));
      
      if (kDebugMode) {
        print('ConversionAnalytics: Guest session started');
      }
    } catch (e) {
      if (kDebugMode) {
        print('ConversionAnalytics: Error tracking session start: $e');
      }
    }
  }

  /// Track conversion event
  static Future<void> trackConversionEvent({
    required String eventType,
    required String eventName,
    Map<String, dynamic>? eventData,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get current session
      final sessionJson = prefs.getString(_guestSessionKey);
      if (sessionJson != null) {
        final sessionData = jsonDecode(sessionJson) as Map<String, dynamic>;
        final events = (sessionData['events'] as List).cast<Map<String, dynamic>>();
        
        // Add new event
        events.add({
          'eventType': eventType,
          'eventName': eventName,
          'timestamp': DateTime.now().toIso8601String(),
          'data': eventData ?? {},
        });
        
        sessionData['events'] = events;
        await prefs.setString(_guestSessionKey, jsonEncode(sessionData));
      }
      
      // Also track in conversion events
      await _trackConversionEvent(eventType, eventName, eventData);
      
      if (kDebugMode) {
        print('ConversionAnalytics: Tracked event - $eventName');
      }
    } catch (e) {
      if (kDebugMode) {
        print('ConversionAnalytics: Error tracking event: $e');
      }
    }
  }

  /// Track funnel step
  static Future<void> trackFunnelStep({
    required String stepName,
    required int stepNumber,
    Map<String, dynamic>? stepData,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final funnelData = {
        'stepName': stepName,
        'stepNumber': stepNumber,
        'timestamp': DateTime.now().toIso8601String(),
        'data': stepData ?? {},
      };
      
      // Get existing funnel data
      final existingJson = prefs.getString(_conversionFunnelKey);
      List<Map<String, dynamic>> funnelSteps = [];
      
      if (existingJson != null) {
        funnelSteps = (jsonDecode(existingJson) as List).cast<Map<String, dynamic>>();
      }
      
      // Add new step
      funnelSteps.add(funnelData);
      
      // Keep only last 50 steps
      if (funnelSteps.length > 50) {
        funnelSteps = funnelSteps.sublist(funnelSteps.length - 50);
      }
      
      await prefs.setString(_conversionFunnelKey, jsonEncode(funnelSteps));
      
      if (kDebugMode) {
        print('ConversionAnalytics: Tracked funnel step - $stepName');
      }
    } catch (e) {
      if (kDebugMode) {
        print('ConversionAnalytics: Error tracking funnel step: $e');
      }
    }
  }

  /// Track auth prompt shown
  static Future<void> trackAuthPromptShown({
    required String promptType,
    required String context,
    String? feature,
  }) async {
    await trackConversionEvent(
      eventType: 'auth_prompt',
      eventName: 'prompt_shown',
      eventData: {
        'promptType': promptType,
        'context': context,
        'feature': feature,
      },
    );
  }

  /// Track auth prompt action
  static Future<void> trackAuthPromptAction({
    required String promptType,
    required String action,
    required String context,
    String? feature,
  }) async {
    await trackConversionEvent(
      eventType: 'auth_prompt',
      eventName: 'prompt_action',
      eventData: {
        'promptType': promptType,
        'action': action, // 'sign_in', 'continue', 'dismiss'
        'context': context,
        'feature': feature,
      },
    );
  }

  /// Track guest booking attempt
  static Future<void> trackGuestBookingAttempt({
    required String bookingType,
    required double amount,
    String? route,
  }) async {
    await trackConversionEvent(
      eventType: 'booking',
      eventName: 'guest_booking_attempt',
      eventData: {
        'bookingType': bookingType,
        'amount': amount,
        'route': route,
      },
    );
  }

  /// Track successful guest booking
  static Future<void> trackGuestBookingSuccess({
    required String bookingId,
    required String bookingType,
    required double amount,
    String? route,
  }) async {
    await trackConversionEvent(
      eventType: 'booking',
      eventName: 'guest_booking_success',
      eventData: {
        'bookingId': bookingId,
        'bookingType': bookingType,
        'amount': amount,
        'route': route,
      },
    );
  }

  /// Track user registration from guest
  static Future<void> trackGuestToUserConversion({
    required String registrationMethod,
    String? source,
  }) async {
    await trackConversionEvent(
      eventType: 'conversion',
      eventName: 'guest_to_user',
      eventData: {
        'registrationMethod': registrationMethod,
        'source': source,
      },
    );
  }

  /// Track feature usage in guest mode
  static Future<void> trackGuestFeatureUsage({
    required String featureName,
    required String action,
    Map<String, dynamic>? featureData,
  }) async {
    await trackConversionEvent(
      eventType: 'feature_usage',
      eventName: 'guest_feature_used',
      eventData: {
        'featureName': featureName,
        'action': action,
        'data': featureData ?? {},
      },
    );
  }

  /// Get conversion analytics data
  static Future<ConversionAnalyticsData> getAnalyticsData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get conversion events
      final eventsJson = prefs.getString(_conversionEventsKey);
      List<Map<String, dynamic>> events = [];
      if (eventsJson != null) {
        events = (jsonDecode(eventsJson) as List).cast<Map<String, dynamic>>();
      }
      
      // Get funnel data
      final funnelJson = prefs.getString(_conversionFunnelKey);
      List<Map<String, dynamic>> funnelSteps = [];
      if (funnelJson != null) {
        funnelSteps = (jsonDecode(funnelJson) as List).cast<Map<String, dynamic>>();
      }
      
      // Get session data
      final sessionJson = prefs.getString(_guestSessionKey);
      Map<String, dynamic>? sessionData;
      if (sessionJson != null) {
        sessionData = jsonDecode(sessionJson) as Map<String, dynamic>;
      }
      
      return ConversionAnalyticsData(
        events: events,
        funnelSteps: funnelSteps,
        sessionData: sessionData,
      );
    } catch (e) {
      if (kDebugMode) {
        print('ConversionAnalytics: Error getting analytics data: $e');
      }
      return ConversionAnalyticsData.empty();
    }
  }

  /// Clear analytics data
  static Future<void> clearAnalyticsData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_conversionEventsKey);
      await prefs.remove(_guestSessionKey);
      await prefs.remove(_conversionFunnelKey);
      
      if (kDebugMode) {
        print('ConversionAnalytics: Cleared analytics data');
      }
    } catch (e) {
      if (kDebugMode) {
        print('ConversionAnalytics: Error clearing analytics data: $e');
      }
    }
  }

  /// Private method to track conversion events
  static Future<void> _trackConversionEvent(
    String eventType,
    String eventName,
    Map<String, dynamic>? eventData,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get existing events
      final eventsJson = prefs.getString(_conversionEventsKey);
      List<Map<String, dynamic>> events = [];
      
      if (eventsJson != null) {
        events = (jsonDecode(eventsJson) as List).cast<Map<String, dynamic>>();
      }
      
      // Add new event
      events.add({
        'eventType': eventType,
        'eventName': eventName,
        'timestamp': DateTime.now().toIso8601String(),
        'data': eventData ?? {},
      });
      
      // Keep only last 1000 events
      if (events.length > 1000) {
        events = events.sublist(events.length - 1000);
      }
      
      await prefs.setString(_conversionEventsKey, jsonEncode(events));
    } catch (e) {
      if (kDebugMode) {
        print('ConversionAnalytics: Error tracking conversion event: $e');
      }
    }
  }
}

/// Data class for conversion analytics
class ConversionAnalyticsData {
  final List<Map<String, dynamic>> events;
  final List<Map<String, dynamic>> funnelSteps;
  final Map<String, dynamic>? sessionData;

  const ConversionAnalyticsData({
    required this.events,
    required this.funnelSteps,
    this.sessionData,
  });

  factory ConversionAnalyticsData.empty() {
    return const ConversionAnalyticsData(
      events: [],
      funnelSteps: [],
      sessionData: null,
    );
  }

  /// Get conversion rate
  double get conversionRate {
    final authPrompts = events.where((e) => 
      e['eventType'] == 'auth_prompt' && e['eventName'] == 'prompt_shown'
    ).length;
    
    final conversions = events.where((e) => 
      e['eventType'] == 'conversion' && e['eventName'] == 'guest_to_user'
    ).length;
    
    if (authPrompts == 0) return 0.0;
    return conversions / authPrompts;
  }

  /// Get most common conversion sources
  List<MapEntry<String, int>> get topConversionSources {
    final sources = <String, int>{};
    
    for (final event in events) {
      if (event['eventType'] == 'conversion' && event['eventName'] == 'guest_to_user') {
        final source = event['data']?['source'] as String? ?? 'unknown';
        sources[source] = (sources[source] ?? 0) + 1;
      }
    }
    
    final sortedSources = sources.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedSources.take(5).toList();
  }

  /// Get funnel drop-off points
  List<MapEntry<String, int>> get funnelDropOffs {
    final stepCounts = <String, int>{};
    
    for (final step in funnelSteps) {
      final stepName = step['stepName'] as String;
      stepCounts[stepName] = (stepCounts[stepName] ?? 0) + 1;
    }
    
    final sortedSteps = stepCounts.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    
    return sortedSteps;
  }
}

