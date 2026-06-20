import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';

/// Local cache service using Hive
/// Implements stale-while-revalidate pattern for instant loading
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  // Cache boxes
  Box? _tripsBox;
  Box? _metadataBox;

  // Cache configuration
  static const String _tripsBoxName = 'trips_cache';
  static const String _metadataBoxName = 'cache_metadata';
  static const Duration _defaultTTL = Duration(seconds: 30); // Stale after 30s

  /// Initialize Hive and open boxes
  Future<void> initialize() async {
    try {
      // Initialize Hive (works on all platforms including Web)
      await Hive.initFlutter();

      _tripsBox = await Hive.openBox(_tripsBoxName);
      _metadataBox = await Hive.openBox(_metadataBoxName);

      debugPrint('CacheService: Initialized successfully');
    } catch (e) {
      debugPrint('CacheService: Initialization error: $e');
      // Don't rethrow - app can work without cache
      debugPrint('CacheService: App will work without caching');
    }
  }

  /// Save trips to cache
  Future<void> saveTrips(List<Map<String, dynamic>> trips) async {
    try {
      await _tripsBox?.put('user_trips', jsonEncode(trips));
      await _metadataBox?.put(
          'trips_timestamp', DateTime.now().millisecondsSinceEpoch);
      debugPrint('CacheService: Saved ${trips.length} trips to cache');
    } catch (e) {
      debugPrint('CacheService: Error saving trips: $e');
    }
  }

  /// Get cached trips
  List<Map<String, dynamic>>? getCachedTrips() {
    try {
      final String? cachedData = _tripsBox?.get('user_trips');
      if (cachedData == null) return null;

      final List<dynamic> decoded = jsonDecode(cachedData);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('CacheService: Error reading trips: $e');
      return null;
    }
  }

  /// Check if cached trips are stale
  bool isTripsCacheStale({Duration ttl = _defaultTTL}) {
    try {
      final int? timestamp = _metadataBox?.get('trips_timestamp');
      if (timestamp == null) return true;

      final DateTime cachedAt = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final Duration age = DateTime.now().difference(cachedAt);

      final isStale = age > ttl;
      debugPrint(
          'CacheService: Cache age: ${age.inSeconds}s, TTL: ${ttl.inSeconds}s, Stale: $isStale');
      return isStale;
    } catch (e) {
      debugPrint('CacheService: Error checking staleness: $e');
      return true;
    }
  }

  /// Get cache age in seconds
  int getCacheAge() {
    try {
      final int? timestamp = _metadataBox?.get('trips_timestamp');
      if (timestamp == null) return -1;

      final DateTime cachedAt = DateTime.fromMillisecondsSinceEpoch(timestamp);
      return DateTime.now().difference(cachedAt).inSeconds;
    } catch (e) {
      return -1;
    }
  }

  /// Clear trips cache
  Future<void> clearTripsCache() async {
    try {
      await _tripsBox?.delete('user_trips');
      await _metadataBox?.delete('trips_timestamp');
      debugPrint('CacheService: Trips cache cleared');
    } catch (e) {
      debugPrint('CacheService: Error clearing cache: $e');
    }
  }

  /// Save single trip (for optimistic updates)
  Future<void> saveOptimisticTrip(Map<String, dynamic> trip) async {
    try {
      final List<Map<String, dynamic>> trips = getCachedTrips() ?? [];

      // Add new trip to the beginning (most recent)
      trips.insert(0, trip);

      await saveTrips(trips);
      debugPrint(
          'CacheService: Saved optimistic trip: ${trip['referenceNumber']}');
    } catch (e) {
      debugPrint('CacheService: Error saving optimistic trip: $e');
    }
  }

  /// Update trip in cache
  Future<void> updateTripInCache(
      String bookingId, Map<String, dynamic> updates) async {
    try {
      final List<Map<String, dynamic>> trips = getCachedTrips() ?? [];

      final index = trips.indexWhere(
          (trip) => trip['booking']?['id']?.toString() == bookingId);

      if (index != -1) {
        // Merge updates
        trips[index] = {...trips[index], ...updates};
        await saveTrips(trips);
        debugPrint('CacheService: Updated trip in cache: $bookingId');
      }
    } catch (e) {
      debugPrint('CacheService: Error updating trip: $e');
    }
  }

  /// Remove trip from cache (for cancelled bookings)
  Future<void> removeTripFromCache(String bookingId) async {
    try {
      final List<Map<String, dynamic>> trips = getCachedTrips() ?? [];

      trips.removeWhere(
          (trip) => trip['booking']?['id']?.toString() == bookingId);

      await saveTrips(trips);
      debugPrint('CacheService: Removed trip from cache: $bookingId');
    } catch (e) {
      debugPrint('CacheService: Error removing trip: $e');
    }
  }

  /// Generic cache methods for other data

  /// Save generic data
  Future<void> save(String key, dynamic data) async {
    try {
      final String encoded = jsonEncode(data);
      await _tripsBox?.put(key, encoded);
      await _metadataBox?.put(
          '${key}_timestamp', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('CacheService: Error saving $key: $e');
    }
  }

  /// Get generic data
  dynamic get(String key) {
    try {
      final String? cached = _tripsBox?.get(key);
      if (cached == null) return null;
      return jsonDecode(cached);
    } catch (e) {
      debugPrint('CacheService: Error getting $key: $e');
      return null;
    }
  }

  /// Check if generic cache is stale
  bool isStale(String key, {Duration ttl = _defaultTTL}) {
    try {
      final int? timestamp = _metadataBox?.get('${key}_timestamp');
      if (timestamp == null) return true;

      final DateTime cachedAt = DateTime.fromMillisecondsSinceEpoch(timestamp);
      return DateTime.now().difference(cachedAt) > ttl;
    } catch (e) {
      return true;
    }
  }

  /// Clear all cache
  Future<void> clearAll() async {
    try {
      await _tripsBox?.clear();
      await _metadataBox?.clear();
      debugPrint('CacheService: All cache cleared');
    } catch (e) {
      debugPrint('CacheService: Error clearing all cache: $e');
    }
  }

  /// Dispose (close boxes)
  Future<void> dispose() async {
    try {
      await _tripsBox?.close();
      await _metadataBox?.close();
      debugPrint('CacheService: Disposed');
    } catch (e) {
      debugPrint('CacheService: Error disposing: $e');
    }
  }
}
