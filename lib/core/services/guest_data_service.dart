import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Service for managing guest user data persistence
class GuestDataService {
  static const String _guestPreferencesKey = 'guest_preferences';
  static const String _guestSearchHistoryKey = 'guest_search_history';
  static const String _guestFavoritesKey = 'guest_favorites';
  static const String _guestSessionKey = 'guest_session_data';

  /// Save guest preferences
  static Future<void> saveGuestPreferences(Map<String, dynamic> preferences) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final preferencesJson = jsonEncode(preferences);
      await prefs.setString(_guestPreferencesKey, preferencesJson);
      
      if (kDebugMode) {
        print('GuestDataService: Saved guest preferences');
      }
    } catch (e) {
      if (kDebugMode) {
        print('GuestDataService: Error saving preferences: $e');
      }
    }
  }

  /// Get guest preferences
  static Future<Map<String, dynamic>> getGuestPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final preferencesJson = prefs.getString(_guestPreferencesKey);
      
      if (preferencesJson != null) {
        final preferences = jsonDecode(preferencesJson) as Map<String, dynamic>;
        if (kDebugMode) {
          print('GuestDataService: Loaded guest preferences');
        }
        return preferences;
      }
    } catch (e) {
      if (kDebugMode) {
        print('GuestDataService: Error loading preferences: $e');
      }
    }
    
    return {};
  }

  /// Save search history
  static Future<void> saveSearchHistory(List<Map<String, dynamic>> searchHistory) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Keep only last 20 searches
      final limitedHistory = searchHistory.take(20).toList();
      final historyJson = jsonEncode(limitedHistory);
      await prefs.setString(_guestSearchHistoryKey, historyJson);
      
      if (kDebugMode) {
        print('GuestDataService: Saved search history (${limitedHistory.length} items)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('GuestDataService: Error saving search history: $e');
      }
    }
  }

  /// Get search history
  static Future<List<Map<String, dynamic>>> getSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_guestSearchHistoryKey);
      
      if (historyJson != null) {
        final history = (jsonDecode(historyJson) as List)
            .cast<Map<String, dynamic>>();
        if (kDebugMode) {
          print('GuestDataService: Loaded search history (${history.length} items)');
        }
        return history;
      }
    } catch (e) {
      if (kDebugMode) {
        print('GuestDataService: Error loading search history: $e');
      }
    }
    
    return [];
  }

  /// Add search to history
  static Future<void> addSearchToHistory(Map<String, dynamic> searchData) async {
    try {
      final currentHistory = await getSearchHistory();
      
      // Remove duplicate if exists
      currentHistory.removeWhere((item) => 
        item['from'] == searchData['from'] && 
        item['to'] == searchData['to'] &&
        item['date'] == searchData['date']
      );
      
      // Add to beginning
      currentHistory.insert(0, {
        ...searchData,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      await saveSearchHistory(currentHistory);
    } catch (e) {
      if (kDebugMode) {
        print('GuestDataService: Error adding search to history: $e');
      }
    }
  }

  /// Save favorite routes
  static Future<void> saveFavoriteRoutes(List<Map<String, dynamic>> favorites) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = jsonEncode(favorites);
      await prefs.setString(_guestFavoritesKey, favoritesJson);
      
      if (kDebugMode) {
        print('GuestDataService: Saved favorite routes (${favorites.length} items)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('GuestDataService: Error saving favorites: $e');
      }
    }
  }

  /// Get favorite routes
  static Future<List<Map<String, dynamic>>> getFavoriteRoutes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getString(_guestFavoritesKey);
      
      if (favoritesJson != null) {
        final favorites = (jsonDecode(favoritesJson) as List)
            .cast<Map<String, dynamic>>();
        if (kDebugMode) {
          print('GuestDataService: Loaded favorite routes (${favorites.length} items)');
        }
        return favorites;
      }
    } catch (e) {
      if (kDebugMode) {
        print('GuestDataService: Error loading favorites: $e');
      }
    }
    
    return [];
  }

  /// Add route to favorites
  static Future<void> addToFavorites(Map<String, dynamic> routeData) async {
    try {
      final currentFavorites = await getFavoriteRoutes();
      
      // Check if already exists
      final exists = currentFavorites.any((fav) => 
        fav['from'] == routeData['from'] && 
        fav['to'] == routeData['to']
      );
      
      if (!exists) {
        currentFavorites.add({
          ...routeData,
          'addedAt': DateTime.now().toIso8601String(),
        });
        await saveFavoriteRoutes(currentFavorites);
      }
    } catch (e) {
      if (kDebugMode) {
        print('GuestDataService: Error adding to favorites: $e');
      }
    }
  }

  /// Remove route from favorites
  static Future<void> removeFromFavorites(Map<String, dynamic> routeData) async {
    try {
      final currentFavorites = await getFavoriteRoutes();
      currentFavorites.removeWhere((fav) => 
        fav['from'] == routeData['from'] && 
        fav['to'] == routeData['to']
      );
      await saveFavoriteRoutes(currentFavorites);
    } catch (e) {
      if (kDebugMode) {
        print('GuestDataService: Error removing from favorites: $e');
      }
    }
  }

  /// Save session data (current search, selected options, etc.)
  static Future<void> saveSessionData(Map<String, dynamic> sessionData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionJson = jsonEncode(sessionData);
      await prefs.setString(_guestSessionKey, sessionJson);
      
      if (kDebugMode) {
        print('GuestDataService: Saved session data');
      }
    } catch (e) {
      if (kDebugMode) {
        print('GuestDataService: Error saving session data: $e');
      }
    }
  }

  /// Get session data
  static Future<Map<String, dynamic>> getSessionData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionJson = prefs.getString(_guestSessionKey);
      
      if (sessionJson != null) {
        final sessionData = jsonDecode(sessionJson) as Map<String, dynamic>;
        if (kDebugMode) {
          print('GuestDataService: Loaded session data');
        }
        return sessionData;
      }
    } catch (e) {
      if (kDebugMode) {
        print('GuestDataService: Error loading session data: $e');
      }
    }
    
    return {};
  }

  /// Clear all guest data (for privacy/cleanup)
  static Future<void> clearAllGuestData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_guestPreferencesKey);
      await prefs.remove(_guestSearchHistoryKey);
      await prefs.remove(_guestFavoritesKey);
      await prefs.remove(_guestSessionKey);
      
      if (kDebugMode) {
        print('GuestDataService: Cleared all guest data');
      }
    } catch (e) {
      if (kDebugMode) {
        print('GuestDataService: Error clearing guest data: $e');
      }
    }
  }

  /// Clear old data (keep only recent items)
  static Future<void> cleanupOldData() async {
    try {
      // Clean up old search history (keep last 30 days)
      final searchHistory = await getSearchHistory();
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      
      final recentHistory = searchHistory.where((search) {
        final timestamp = DateTime.tryParse(search['timestamp'] ?? '');
        return timestamp != null && timestamp.isAfter(thirtyDaysAgo);
      }).toList();
      
      if (recentHistory.length != searchHistory.length) {
        await saveSearchHistory(recentHistory);
        if (kDebugMode) {
          print('GuestDataService: Cleaned up old search history');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('GuestDataService: Error cleaning up old data: $e');
      }
    }
  }
}

