import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/charter_deal_model.dart';
import '../error/app_exceptions.dart';
import '../../shared/utils/session_manager.dart';
import '../../config/env/app_config.dart';
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart' show kDebugMode;

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
    sessionManager.debugTokenStatus();

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
    if (kDebugMode) {
      dev.log('CharterDealsService: fetchCharterDeals called',
          name: 'charter_deals_service');
      dev.log(
          'CharterDealsService: Parameters - page: $page, limit: $limit, searchQuery: $searchQuery, dealType: $dealType',
          name: 'charter_deals_service');
      dev.log(
          'CharterDealsService: Parameters - fromDate: $fromDate, toDate: $toDate, forceRefresh: $forceRefresh',
          name: 'charter_deals_service');
    }

    try {
      // Check cache first (unless force refresh is requested)
      if (!forceRefresh && _cachedDeals != null && _lastCacheTime != null) {
        final timeSinceLastCache = DateTime.now().difference(_lastCacheTime!);
        if (timeSinceLastCache < _cacheValidDuration) {
          if (kDebugMode) {
            dev.log(
                'CharterDealsService: Returning cached deals (${_cachedDeals!.length} items)',
                name: 'charter_deals_service');
          }
          return _filterCachedDeals(
            searchQuery: searchQuery,
            dealType: dealType,
            fromDate: fromDate,
            toDate: toDate,
          );
        }
      }

      if (kDebugMode) {
        dev.log(
            'CharterDealsService: Cache miss or force refresh, making API call',
            name: 'charter_deals_service');
      }

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
      if (kDebugMode) {
        dev.log('CharterDealsService: Making request to $uri',
            name: 'charter_deals_service');
        dev.log('CharterDealsService: Headers: $headers',
            name: 'charter_deals_service');
      }

      final response = await http
          .get(
            uri,
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      if (kDebugMode) {
        dev.log('CharterDealsService: Response status: ${response.statusCode}',
            name: 'charter_deals_service');
        dev.log(
            'CharterDealsService: Response body length: ${response.body.length}',
            name: 'charter_deals_service');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (kDebugMode) {
          dev.log(
              'CharterDealsService: Response data keys: ${data.keys.toList()}',
              name: 'charter_deals_service');
          dev.log('CharterDealsService: Response success: ${data['success']}',
              name: 'charter_deals_service');
        }

        if (data['success'] == true) {
          final dealsList = data['data'] as List;

          if (kDebugMode) {
            dev.log(
                'CharterDealsService: Deals list length: ${dealsList.length}',
                name: 'charter_deals_service');
            if (dealsList.isNotEmpty) {
              dev.log(
                  'CharterDealsService: First deal data: ${dealsList.first}',
                  name: 'charter_deals_service');
            }
          }

          final deals = <CharterDealModel>[];

          // Parse each deal individually to catch parsing errors
          for (int i = 0; i < dealsList.length; i++) {
            try {
              final deal = CharterDealModel.fromJson(dealsList[i]);
              deals.add(deal);
              if (kDebugMode && i == 0) {
                dev.log(
                    'CharterDealsService: Successfully parsed first deal: ${deal.routeDisplay}',
                    name: 'charter_deals_service');
              }
            } catch (e) {
              if (kDebugMode) {
                dev.log(
                    'CharterDealsService: Error parsing deal at index $i: $e',
                    name: 'charter_deals_service');
                dev.log(
                    'CharterDealsService: Problematic deal data: ${dealsList[i]}',
                    name: 'charter_deals_service');
              }
              // Continue parsing other deals instead of failing completely
            }
          }

          if (kDebugMode) {
            dev.log(
                'CharterDealsService: Successfully parsed ${deals.length} out of ${dealsList.length} deals',
                name: 'charter_deals_service');
          }

          // Update cache
          _cachedDeals = deals;
          _lastCacheTime = DateTime.now();

          if (kDebugMode) {
            dev.log(
                'CharterDealsService: Successfully fetched ${deals.length} deals',
                name: 'charter_deals_service');
            if (deals.isNotEmpty) {
              dev.log(
                  'CharterDealsService: First deal model: ${deals.first.routeDisplay}',
                  name: 'charter_deals_service');
              dev.log(
                  'CharterDealsService: First deal price: ${deals.first.priceDisplay}',
                  name: 'charter_deals_service');
            }
          }

          return deals;
        } else {
          if (kDebugMode) {
            dev.log('CharterDealsService: API returned success: false',
                name: 'charter_deals_service');
            dev.log('CharterDealsService: Error message: ${data['message']}',
                name: 'charter_deals_service');
          }
          throw ServerException(data['message'] ?? 'Failed to fetch deals');
        }
      } else if (response.statusCode == 401) {
        if (kDebugMode) {
          dev.log('CharterDealsService: Unauthorized - token may be invalid',
              name: 'charter_deals_service');
        }
        throw AuthException('Unauthorized - Please login again');
      } else if (response.statusCode == 404) {
        if (kDebugMode) {
          dev.log('CharterDealsService: 404 - No deals found',
              name: 'charter_deals_service');
        }
        throw ServerException('No deals found');
      } else {
        if (kDebugMode) {
          dev.log('CharterDealsService: Server error ${response.statusCode}',
              name: 'charter_deals_service');
          dev.log('CharterDealsService: Error response body: ${response.body}',
              name: 'charter_deals_service');
        }
        throw ServerException('Server error: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      if (kDebugMode) {
        dev.log('CharterDealsService: ClientException: $e',
            name: 'charter_deals_service');
      }
      throw NetworkException('Network error - Please check your connection');
    } on FormatException catch (e) {
      if (kDebugMode) {
        dev.log('CharterDealsService: FormatException: $e',
            name: 'charter_deals_service');
      }
      throw ServerException('Invalid response format');
    } catch (e) {
      if (kDebugMode) {
        dev.log('CharterDealsService: Unexpected error: $e',
            name: 'charter_deals_service');
        dev.log('CharterDealsService: Error type: ${e.runtimeType}',
            name: 'charter_deals_service');
      }
      if (e is AppException) rethrow;
      throw ServerException('Unexpected error: $e');
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
      if (kDebugMode) {
        dev.log('CharterDealsService: Starting API test...',
            name: 'charter_deals_service');
      }

      final uri = Uri.parse('$baseUrl/charter-deals');
      final headers = await _getAuthHeaders();

      if (kDebugMode) {
        dev.log('CharterDealsService: Testing API response...',
            name: 'charter_deals_service');
        dev.log('CharterDealsService: URI: $uri',
            name: 'charter_deals_service');
        dev.log('CharterDealsService: Headers: $headers',
            name: 'charter_deals_service');
      }

      final response = await http.get(uri, headers: headers);

      if (kDebugMode) {
        dev.log(
            'CharterDealsService: Test response status: ${response.statusCode}',
            name: 'charter_deals_service');
        dev.log(
            'CharterDealsService: Test response body length: ${response.body.length}',
            name: 'charter_deals_service');
        dev.log('CharterDealsService: Test response body: ${response.body}',
            name: 'charter_deals_service');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (kDebugMode) {
          dev.log('CharterDealsService: Test parsed data: $data',
              name: 'charter_deals_service');
          if (data['success'] == true && data['data'] != null) {
            final dealsList = data['data'] as List;
            dev.log(
                'CharterDealsService: Test found ${dealsList.length} deals in response',
                name: 'charter_deals_service');
            if (dealsList.isNotEmpty) {
              dev.log(
                  'CharterDealsService: Test first deal data: ${dealsList.first}',
                  name: 'charter_deals_service');
            }
          }
        }
      } else {
        if (kDebugMode) {
          dev.log(
              'CharterDealsService: Test failed with status ${response.statusCode}',
              name: 'charter_deals_service');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        dev.log('CharterDealsService: Test error: $e',
            name: 'charter_deals_service');
        dev.log('CharterDealsService: Test error type: ${e.runtimeType}',
            name: 'charter_deals_service');
      }
    }
  }
}
