import 'package:air_charters/core/network/api_client.dart';
import 'package:air_charters/config/env/app_config.dart';

class ExperiencesService {
  final ApiClient _apiClient;

  ExperiencesService(this._apiClient);

  /// Get all experiences grouped by category
  Future<List<Map<String, dynamic>>> getExperiences() async {
    try {
      print(
          '🔍 ExperiencesService: Making API call to ${AppConfig.experiencesEndpoint}');
      final response = await _apiClient.get(AppConfig.experiencesEndpoint);
      print(
          '🔍 ExperiencesService: API Response received: ${response.toString()}');

      if (response['success']) {
        final categories = response['data']['categories'];
        print('🔍 ExperiencesService: Categories found: ${categories.length}');
        print('🔍 ExperiencesService: First category: ${categories.first}');

        final result = List<Map<String, dynamic>>.from(categories);
        print(
            '🔍 ExperiencesService: Parsed result: ${result.length} categories');
        return result;
      } else {
        print('❌ ExperiencesService: API returned success: false');
        throw Exception('Failed to load experiences');
      }
    } catch (e) {
      print('❌ ExperiencesService: Error: $e');
      throw Exception('Network error: $e');
    }
  }

  /// Get experience details by ID
  Future<Map<String, dynamic>> getExperienceDetails(int id) async {
    try {
      final response =
          await _apiClient.get('${AppConfig.experienceDetailsEndpoint}/$id');

      if (response['success']) {
        return Map<String, dynamic>.from(response['data']);
      } else {
        throw Exception('Failed to load experience details');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Get experiences by category
  Future<List<Map<String, dynamic>>> getExperiencesByCategory(
      String category) async {
    try {
      final response = await _apiClient
          .get('${AppConfig.experienceCategoryEndpoint}/$category');

      if (response['success']) {
        return List<Map<String, dynamic>>.from(response['data']);
      } else {
        throw Exception('Failed to load experiences for category');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Search experiences
  Future<List<Map<String, dynamic>>> searchExperiences({
    String? query,
    String? category,
    String? location,
    double? minPrice,
    double? maxPrice,
    int? minDuration,
    int? maxDuration,
    DateTime? date,
  }) async {
    try {
      final Map<String, dynamic> params = {};

      if (query != null && query.isNotEmpty) params['q'] = query;
      if (category != null && category.isNotEmpty) {
        params['category'] = category;
      }
      if (location != null && location.isNotEmpty) {
        params['location'] = location;
      }
      if (minPrice != null) params['minPrice'] = minPrice;
      if (maxPrice != null) params['maxPrice'] = maxPrice;
      if (minDuration != null) params['minDuration'] = minDuration;
      if (maxDuration != null) params['maxDuration'] = maxDuration;
      if (date != null) params['date'] = date.toIso8601String().split('T')[0];

      final queryString = params.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
          .join('&');

      final response = await _apiClient
          .get('${AppConfig.experienceSearchEndpoint}?$queryString');

      if (response['success']) {
        return List<Map<String, dynamic>>.from(response['data']);
      } else {
        throw Exception('Failed to search experiences');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Get experience categories
  Future<List<String>> getExperienceCategories() async {
    try {
      final response =
          await _apiClient.get(AppConfig.experienceCategoriesEndpoint);

      if (response['success']) {
        return List<String>.from(response['data']);
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Get popular experiences
  Future<List<Map<String, dynamic>>> getPopularExperiences(
      {int limit = 10}) async {
    try {
      final response = await _apiClient
          .get('${AppConfig.experiencePopularEndpoint}?limit=$limit');

      if (response['success']) {
        return List<Map<String, dynamic>>.from(response['data']);
      } else {
        throw Exception('Failed to load popular experiences');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Get featured experiences
  Future<List<Map<String, dynamic>>> getFeaturedExperiences(
      {int limit = 5}) async {
    try {
      final response = await _apiClient
          .get('${AppConfig.experienceFeaturedEndpoint}?limit=$limit');

      if (response['success']) {
        return List<Map<String, dynamic>>.from(response['data']);
      } else {
        throw Exception('Failed to load featured experiences');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
