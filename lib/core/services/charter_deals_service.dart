import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/charter_deal_model.dart';
import '../error/app_exceptions.dart';
import '../../shared/utils/session_manager.dart';
import '../../config/env/app_config.dart';

class CharterDealsService {
  static String get baseUrl => AppConfig.fullBackendUrl;

  // Cache for deals to improve performance
  static List<CharterDealModel>? _cachedDeals;
  static DateTime? _lastCacheTime;
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  /// Get authentication headers
  static Future<Map<String, String>> _getAuthHeaders() async {
    final sessionManager = SessionManager();

    // Debug token status before making request
    await sessionManager.debugTokenStatus();

    return await sessionManager.getAuthHeaders();
  }

  /// Fetch charter deals with proper joins from the database
  static Future<List<CharterDealModel>> fetchCharterDeals({
    int page = 1,
    int limit = 10,
    String? searchQuery,
    String? dealType,
    DateTime? fromDate,
    DateTime? toDate,
    bool forceRefresh = false,
  }) async {
    print('===========================================================');
    print('✅✅✅ SERVICE: fetchCharterDeals CALLED ✅✅✅');
    print('===========================================================');

    try {
      // Check cache first (unless force refresh is requested)
      if (!forceRefresh &&
          _cachedDeals != null &&
          _cachedDeals!.isNotEmpty &&
          _lastCacheTime != null) {
        final timeSinceLastCache = DateTime.now().difference(_lastCacheTime!);
        if (timeSinceLastCache < _cacheValidDuration) {
          print(
              '✅ SERVICE: Returning ${_cachedDeals!.length} deals from CACHE.');
          return _filterCachedDeals(
            searchQuery: searchQuery,
            dealType: dealType,
            fromDate: fromDate,
            toDate: toDate,
          );
        }
      }

      print('➡️ SERVICE: Cache miss or force refresh. Making API call...');

      // Build query parameters
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['search'] = searchQuery;
      }

      if (dealType != null && dealType.isNotEmpty) {
        queryParams['dealType'] = dealType;
      }

      if (fromDate != null) {
        queryParams['fromDate'] = fromDate.toIso8601String();
      }

      if (toDate != null) {
        queryParams['toDate'] = toDate.toIso8601String();
      }

      // Make API request
      final uri = Uri.parse('$baseUrl/charter-deals')
          .replace(queryParameters: queryParams);

      final headers = await _getAuthHeaders();
      print('➡️ SERVICE: Making request to $uri');

      final response = await http
          .get(
            uri,
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      print('✅ SERVICE: API Response Status: ${response.statusCode}');
      print('✅ SERVICE: RAW RESPONSE BODY: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ SERVICE: PARSED JSON DATA: $data');

        if (data['success'] == true) {
          final dealsList = data['data'] as List;
          print('✅ SERVICE: Found ${dealsList.length} deals in API response.');

          final deals = <CharterDealModel>[];

          // Parse each deal individually to catch parsing errors
          for (int i = 0; i < dealsList.length; i++) {
            try {
              final deal = CharterDealModel.fromJson(dealsList[i]);
              deals.add(deal);
            } catch (e) {
              print('❌ SERVICE: Error parsing deal at index $i: $e');
              print('❌ SERVICE: Problematic deal data: ${dealsList[i]}');
            }
          }

          // Update cache
          _cachedDeals = deals;
          _lastCacheTime = DateTime.now();

          print(
              '✅ SERVICE: Successfully parsed and returning ${deals.length} deals.');
          return deals;
        } else {
          print(
              '❌ SERVICE: API returned success: false. Message: ${data['message']}');
          throw ServerException(data['message'] ?? 'Failed to fetch deals');
        }
      } else {
        print(
            '❌ SERVICE: API call failed with status code ${response.statusCode}.');
        throw ServerException('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('🔥🔥🔥 SERVICE: UNEXPECTED ERROR in fetchCharterDeals: $e 🔥🔥🔥');
      rethrow;
    }
  }

  /// Filter cached deals based on search criteria
  static List<CharterDealModel> _filterCachedDeals({
    String? searchQuery,
    String? dealType,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    if (_cachedDeals == null) return [];

    List<CharterDealModel> filtered = _cachedDeals!;

    // Filter by search query
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((deal) {
        return deal.origin?.toLowerCase().contains(query) == true ||
            deal.destination?.toLowerCase().contains(query) == true ||
            deal.companyName?.toLowerCase().contains(query) == true ||
            deal.aircraftName?.toLowerCase().contains(query) == true;
      }).toList();
    }

    // Filter by deal type
    if (dealType != null && dealType.isNotEmpty) {
      filtered = filtered.where((deal) => deal.dealType == dealType).toList();
    }

    // Filter by date range
    if (fromDate != null) {
      filtered = filtered
          .where((deal) =>
              deal.date.isAfter(fromDate.subtract(const Duration(days: 1))))
          .toList();
    }

    if (toDate != null) {
      filtered = filtered
          .where(
              (deal) => deal.date.isBefore(toDate.add(const Duration(days: 1))))
          .toList();
    }

    return filtered;
  }

  /// Clear the cache
  static void clearCache() {
    _cachedDeals = null;
    _lastCacheTime = null;
  }

  /// Get deals for a specific route
  static Future<List<CharterDealModel>> fetchDealsForRoute({
    required String origin,
    required String destination,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    // Use the dedicated route endpoint for backend
    final uri = Uri.parse('$baseUrl/charter-deals/route/$origin/$destination')
        .replace(queryParameters: {
      if (fromDate != null) 'fromDate': fromDate.toIso8601String(),
      if (toDate != null) 'toDate': toDate.toIso8601String(),
    });

    final headers = await _getAuthHeaders();
    final response = await http
        .get(
          uri,
          headers: headers,
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return (data['data'] as List)
            .map((json) => CharterDealModel.fromJson(json))
            .toList();
      } else {
        throw ServerException(data['message'] ?? 'Failed to fetch route deals');
      }
    } else {
      throw ServerException('Failed to fetch route deals');
    }
  }

  /// Get deals for a specific company
  static Future<List<CharterDealModel>> fetchDealsForCompany({
    required int companyId,
    int page = 1,
    int limit = 10,
  }) async {
    final uri = Uri.parse('$baseUrl/charter-deals/company/$companyId')
        .replace(queryParameters: {
      'page': page.toString(),
      'limit': limit.toString(),
    });

    final headers = await _getAuthHeaders();
    final response = await http
        .get(
          uri,
          headers: headers,
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return (data['data'] as List)
            .map((json) => CharterDealModel.fromJson(json))
            .toList();
      } else {
        throw ServerException(
            data['message'] ?? 'Failed to fetch company deals');
      }
    } else {
      throw ServerException('Failed to fetch company deals');
    }
  }

  /// Get deal details by ID
  static Future<CharterDealModel?> fetchDealById(int dealId) async {
    final uri = Uri.parse('$baseUrl/charter-deals/$dealId');
    final headers = await _getAuthHeaders();
    final response = await http
        .get(
          uri,
          headers: headers,
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return CharterDealModel.fromJson(data['data']);
      } else {
        throw ServerException(
            data['message'] ?? 'Failed to fetch deal details');
      }
    } else if (response.statusCode == 404) {
      return null; // Deal not found
    } else {
      throw ServerException('Failed to fetch deal details');
    }
  }

  /// Test method to debug API response
  static Future<void> testApiResponse() async {
    try {
      print('--- Starting API test ---');

      final uri = Uri.parse('$baseUrl/charter-deals');
      final headers = await _getAuthHeaders();

      print('CharterDealsService: Testing API response...');
      print('CharterDealsService: URI: $uri');
      print('CharterDealsService: Headers: $headers');

      final response = await http.get(uri, headers: headers);

      print(
          'CharterDealsService: Test response status: ${response.statusCode}');
      print(
          'CharterDealsService: Test response body length: ${response.body.length}');
      print('CharterDealsService: Test response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('CharterDealsService: Test parsed data: $data');
        if (data['success'] == true && data['data'] != null) {
          final dealsList = data['data'] as List;
          print(
              'CharterDealsService: Test found ${dealsList.length} deals in response');
          if (dealsList.isNotEmpty) {
            print(
                'CharterDealsService: Test first deal data: ${dealsList.first}');
          }
        }
      } else {
        print(
            'CharterDealsService: Test failed with status ${response.statusCode}');
      }
    } catch (e) {
      print('CharterDealsService: Test error: $e');
      print('CharterDealsService: Test error type: ${e.runtimeType}');
    }
  }

  // New methods for CharterDealsController

  /// Search deals with advanced filters
  static Future<List<CharterDealModel>> searchDeals({
    String? query,
    String? category,
    String? origin,
    String? destination,
    DateTime? departureDate,
    DateTime? returnDate,
    int? minPrice,
    int? maxPrice,
    int? passengers,
    String? aircraftType,
    String? companyId,
    String? sortBy = 'price',
    String? sortOrder = 'asc',
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      if (query != null && query.isNotEmpty) 'search': query,
      if (category != null && category.isNotEmpty) 'dealType': category,
      if (origin != null && origin.isNotEmpty) 'origin': origin,
      if (destination != null && destination.isNotEmpty)
        'destination': destination,
      if (departureDate != null) 'fromDate': departureDate.toIso8601String(),
      if (returnDate != null) 'toDate': returnDate.toIso8601String(),
      if (minPrice != null) 'minPrice': minPrice.toString(),
      if (maxPrice != null) 'maxPrice': maxPrice.toString(),
      if (passengers != null) 'passengers': passengers.toString(),
      if (aircraftType != null && aircraftType.isNotEmpty)
        'aircraftType': aircraftType,
      if (companyId != null && companyId.isNotEmpty) 'companyId': companyId,
      if (sortBy != null && sortBy.isNotEmpty) 'sortBy': sortBy,
      if (sortOrder != null && sortOrder.isNotEmpty) 'sortOrder': sortOrder,
    };	  

    final uri = Uri.parse('$baseUrl/charter-deals')
        .replace(queryParameters: queryParams);
    final headers = await _getAuthHeaders();
    final response = await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return (data['data'] as List)
            .map((json) => CharterDealModel.fromJson(json))
            .toList();
      } else {
        throw ServerException(data['message'] ?? 'Failed to search deals');
      }
    } else {
      throw ServerException('Failed to search deals');
    }
  }

  /// Get deal by ID (alias for fetchDealById)
  static Future<CharterDealModel?> getDealById(int dealId) async {
    return await fetchDealById(dealId);
  }

  /// Get deals by category
  static Future<List<CharterDealModel>> getDealsByCategory(
      String category) async {
    return await fetchCharterDeals(dealType: category);
  }

  /// Get featured deals
  static Future<List<CharterDealModel>> getFeaturedDeals(
      {int limit = 10}) async {
    final queryParams = <String, String>{
      'featured': 'true',
      'limit': limit.toString(),
    };

    final uri = Uri.parse('$baseUrl/charter-deals')
        .replace(queryParameters: queryParams);
    final headers = await _getAuthHeaders();
    final response = await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return (data['data'] as List)
            .map((json) => CharterDealModel.fromJson(json))
            .toList();
      } else {
        throw ServerException(
            data['message'] ?? 'Failed to fetch featured deals');
      }
    } else {
      throw ServerException('Failed to fetch featured deals');
    }
  }

  /// Get deals by company (alias for fetchDealsForCompany)
  static Future<List<CharterDealModel>> getDealsByCompany(
      String companyId) async {
    return await fetchDealsForCompany(companyId: int.parse(companyId));
  }

  /// Get deals by route (alias for fetchDealsForRoute)
  static Future<List<CharterDealModel>> getDealsByRoute({
    required String origin,
    required String destination,
    DateTime? departureDate,
    int? passengers,
  }) async {
    return await fetchDealsForRoute(
      origin: origin,
      destination: destination,
      fromDate: departureDate,
    );
  }

  /// Get deal categories
  static Future<List<String>> getDealCategories() async {
    final uri = Uri.parse('$baseUrl/charter-deals/categories');
    final headers = await _getAuthHeaders();
    final response = await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return (data['data'] as List).cast<String>();
      } else {
        throw ServerException(data['message'] ?? 'Failed to fetch categories');
      }
    } else {
      throw ServerException('Failed to fetch categories');
    }
  }

  /// Get popular routes
  static Future<List<Map<String, dynamic>>> getPopularRoutes() async {
    final uri = Uri.parse('$baseUrl/charter-deals/popular-routes');
    final headers = await _getAuthHeaders();
    final response = await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return (data['data'] as List).cast<Map<String, dynamic>>();
      } else {
        throw ServerException(
            data['message'] ?? 'Failed to fetch popular routes');
      }
    } else {
      throw ServerException('Failed to fetch popular routes');
    }
  }
}
