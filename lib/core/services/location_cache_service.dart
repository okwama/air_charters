import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'google_maps_service.dart';

/// Service to cache Google Places location searches
class LocationCacheService {
  static final LocationCacheService _instance =
      LocationCacheService._internal();
  factory LocationCacheService() => _instance;
  LocationCacheService._internal();

  static const String _cachePrefix = 'location_cache_';
  static const Duration _cacheExpiry =
      Duration(hours: 24); // Cache for 24 hours

  /// Get cached search results
  Future<List<GoogleLocation>?> getCachedSearch(String query,
      {String? type, String? location}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _getCacheKey(query, type: type, location: location);
      final cachedData = prefs.getString(cacheKey);

      if (cachedData == null) return null;

      final decoded = jsonDecode(cachedData);
      final timestamp = DateTime.parse(decoded['timestamp'] as String);

      // Check if cache is still valid
      if (DateTime.now().difference(timestamp) > _cacheExpiry) {
        // Cache expired, remove it
        await prefs.remove(cacheKey);
        return null;
      }

      // Parse cached locations
      final List<dynamic> locationsJson = decoded['locations'];
      return locationsJson
          .map((json) => GoogleLocation.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error reading location cache: $e');
      return null;
    }
  }

  /// Cache search results
  Future<void> cacheSearch(
    String query,
    List<GoogleLocation> locations, {
    String? type,
    String? location,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _getCacheKey(query, type: type, location: location);

      final cacheData = {
        'timestamp': DateTime.now().toIso8601String(),
        'locations': locations.map((loc) => loc.toJson()).toList(),
      };

      await prefs.setString(cacheKey, jsonEncode(cacheData));
      print('✅ Cached ${locations.length} locations for query: $query');
    } catch (e) {
      print('Error caching locations: $e');
    }
  }

  /// Generate cache key from search parameters
  String _getCacheKey(String query, {String? type, String? location}) {
    final key =
        '$_cachePrefix${query.toLowerCase()}_${type ?? 'all'}_${location ?? 'global'}';
    return key.replaceAll(' ', '_').replaceAll(',', '');
  }

  /// Clear all location cache
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith(_cachePrefix));

      for (final key in keys) {
        await prefs.remove(key);
      }

      print('✅ Location cache cleared');
    } catch (e) {
      print('Error clearing location cache: $e');
    }
  }

  /// Clear expired cache entries
  Future<void> clearExpiredCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith(_cachePrefix));

      for (final key in keys) {
        final cachedData = prefs.getString(key);
        if (cachedData != null) {
          try {
            final decoded = jsonDecode(cachedData);
            final timestamp = DateTime.parse(decoded['timestamp'] as String);

            if (DateTime.now().difference(timestamp) > _cacheExpiry) {
              await prefs.remove(key);
            }
          } catch (e) {
            // If we can't parse, remove the corrupted cache
            await prefs.remove(key);
          }
        }
      }
    } catch (e) {
      print('Error clearing expired cache: $e');
    }
  }
}
