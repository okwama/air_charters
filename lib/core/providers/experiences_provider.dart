import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/experiences_service.dart';
import '../error/app_exceptions.dart';
import '../../core/network/api_client.dart';
import 'dart:developer' as dev;

enum ExperienceState {
  initial,
  loading,
  loaded,
  error,
  loadingMore,
}

class ExperiencesProvider extends ChangeNotifier {
  ExperiencesProvider() {
    if (kDebugMode) {
      dev.log('ExperiencesProvider: Constructor called',
          name: 'experiences_provider');
    }
  }

  @override
  void dispose() {
    if (kDebugMode) {
      dev.log('ExperiencesProvider: dispose called',
          name: 'experiences_provider');
    }
    super.dispose();
  }

  ExperienceState _state = ExperienceState.initial;
  List<Map<String, dynamic>> _categories = [];
  String? _errorMessage;
  bool _hasMoreData = true;
  int _currentPage = 1;
  static const int _pageSize = 10;

  // Search and filter state
  String? _searchQuery;
  String? _selectedCategory;
  String? _selectedLocation;
  RangeValues _priceRange = const RangeValues(0, 1000);
  RangeValues _durationRange = const RangeValues(0, 300);

  // Getters
  ExperienceState get state => _state;
  List<Map<String, dynamic>> get categories => _categories;
  String? get errorMessage => _errorMessage;
  bool get hasMoreData => _hasMoreData;
  bool get isLoading => _state == ExperienceState.loading;
  bool get isLoadingMore => _state == ExperienceState.loadingMore;
  bool get hasError => _state == ExperienceState.error;

  // Filter getters
  String? get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  String? get selectedLocation => _selectedLocation;
  RangeValues get priceRange => _priceRange;
  RangeValues get durationRange => _durationRange;

  /// Load initial experiences
  Future<void> loadExperiences({
    String? searchQuery,
    String? category,
    String? location,
    double? minPrice,
    double? maxPrice,
    int? minDuration,
    int? maxDuration,
    DateTime? date,
    bool forceRefresh = false,
  }) async {
    if (kDebugMode) {
      dev.log('ExperiencesProvider: loadExperiences method called',
          name: 'experiences_provider');
    }

    if (_state == ExperienceState.loading && !forceRefresh) return;

    // Experiences don't require authentication - proceed with API call
    if (kDebugMode) {
      dev.log('ExperiencesProvider: Loading experiences (no auth required)',
          name: 'experiences_provider');
    }

    try {
      _setState(ExperienceState.loading);
      _errorMessage = null;

      // Update filter state
      _searchQuery = searchQuery;
      _selectedCategory = category;
      _selectedLocation = location;
      if (minPrice != null && maxPrice != null) {
        _priceRange = RangeValues(minPrice, maxPrice);
      }
      if (minDuration != null && maxDuration != null) {
        _durationRange =
            RangeValues(minDuration.toDouble(), maxDuration.toDouble());
      }

      if (kDebugMode) {
        dev.log('ExperiencesProvider: Loading experiences...',
            name: 'experiences_provider');
        dev.log('ExperiencesProvider: Search query: $searchQuery',
            name: 'experiences_provider');
        dev.log('ExperiencesProvider: Category: $category',
            name: 'experiences_provider');
        dev.log('ExperiencesProvider: Location: $location',
            name: 'experiences_provider');
      }

      final experiencesService = ExperiencesService(ApiClient());
      List<Map<String, dynamic>> categories;

      // Use search if any filters are applied
      if (searchQuery != null ||
          category != null ||
          location != null ||
          minPrice != null ||
          maxPrice != null ||
          minDuration != null ||
          maxDuration != null ||
          date != null) {
        if (kDebugMode) {
          dev.log('ExperiencesProvider: Using search API with filters',
              name: 'experiences_provider');
        }

        final searchResults = await experiencesService.searchExperiences(
          query: searchQuery,
          category: category,
          location: location,
          minPrice: minPrice,
          maxPrice: maxPrice,
          minDuration: minDuration,
          maxDuration: maxDuration,
          date: date,
        );

        // Group search results by category
        categories = _groupSearchResultsByCategory(searchResults);
      } else {
        if (kDebugMode) {
          dev.log('ExperiencesProvider: Using regular experiences API',
              name: 'experiences_provider');
        }
        categories = await experiencesService.getExperiences();
      }

      if (kDebugMode) {
        dev.log('ExperiencesProvider: Fetched ${categories.length} categories',
            name: 'experiences_provider');
        if (categories.isNotEmpty) {
          try {
            dev.log(
                'ExperiencesProvider: First category: ${categories.first['title']}',
                name: 'experiences_provider');
            // Fix type casting issue - cast to List<dynamic> first, then convert
            final dealsList = categories.first['deals'] as List<dynamic>? ?? [];
            final deals = dealsList.cast<Map<String, dynamic>>();
            dev.log(
                'ExperiencesProvider: First category has ${deals.length} deals',
                name: 'experiences_provider');
          } catch (e) {
            dev.log('ExperiencesProvider: Error parsing first category: $e',
                name: 'experiences_provider');
          }
        }
      }

      _categories = categories;
      _currentPage = 1;
      _hasMoreData = categories.isNotEmpty;

      if (kDebugMode) {
        dev.log('ExperiencesProvider: Setting state to loaded',
            name: 'experiences_provider');
      }

      _setState(ExperienceState.loaded);
    } on AppException catch (e) {
      if (kDebugMode) {
        dev.log('ExperiencesProvider: Error loading experiences: ${e.message}',
            name: 'experiences_provider');
      }
      _errorMessage = e.message;
      _setState(ExperienceState.error);
    } catch (e) {
      if (kDebugMode) {
        dev.log('ExperiencesProvider: Unexpected error: $e',
            name: 'experiences_provider');
      }
      _errorMessage = 'An unexpected error occurred';
      _setState(ExperienceState.error);
    }
  }

  /// Load more experiences for pagination
  Future<void> loadMoreExperiences() async {
    if (_state == ExperienceState.loadingMore || !_hasMoreData) return;

    try {
      _setState(ExperienceState.loadingMore);

      final experiencesService = ExperiencesService(ApiClient());
      final moreCategories = await experiencesService.getExperiences();

      if (moreCategories.isNotEmpty) {
        _categories.addAll(moreCategories);
        _currentPage++;
        _hasMoreData = moreCategories.length >= _pageSize;
      } else {
        _hasMoreData = false;
      }

      _setState(ExperienceState.loaded);
    } on AppException catch (e) {
      _errorMessage = e.message;
      _setState(ExperienceState.error);
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      _setState(ExperienceState.error);
    }
  }

  /// Refresh experiences
  Future<void> refreshExperiences({
    String? searchQuery,
    String? category,
    String? location,
    double? minPrice,
    double? maxPrice,
    int? minDuration,
    int? maxDuration,
    DateTime? date,
  }) async {
    await loadExperiences(
      searchQuery: searchQuery,
      category: category,
      location: location,
      minPrice: minPrice,
      maxPrice: maxPrice,
      minDuration: minDuration,
      maxDuration: maxDuration,
      date: date,
      forceRefresh: true,
    );
  }

  /// Clear experiences and reset state
  void clearExperiences() {
    _categories.clear();
    _currentPage = 1;
    _hasMoreData = true;
    _errorMessage = null;
    _searchQuery = null;
    _selectedCategory = null;
    _selectedLocation = null;
    _priceRange = const RangeValues(0, 1000);
    _durationRange = const RangeValues(0, 300);
    _setState(ExperienceState.initial);
  }

  /// Clear error state
  void clearError() {
    _errorMessage = null;
    if (_state == ExperienceState.error) {
      _setState(ExperienceState.loaded);
    }
  }

  /// Update filters
  void updateFilters({
    String? searchQuery,
    String? category,
    String? location,
    RangeValues? priceRange,
    RangeValues? durationRange,
  }) {
    _searchQuery = searchQuery;
    _selectedCategory = category;
    _selectedLocation = location;
    if (priceRange != null) _priceRange = priceRange;
    if (durationRange != null) _durationRange = durationRange;
    notifyListeners();
  }

  /// Clear all filters
  void clearFilters() {
    _searchQuery = null;
    _selectedCategory = null;
    _selectedLocation = null;
    _priceRange = const RangeValues(0, 1000);
    _durationRange = const RangeValues(0, 300);
    notifyListeners();
  }

  /// Group search results by category
  List<Map<String, dynamic>> _groupSearchResultsByCategory(
      List<Map<String, dynamic>> searchResults) {
    final Map<String, List<Map<String, dynamic>>> groupedResults = {};

    for (final experience in searchResults) {
      try {
        final category = _getCategoryFromExperience(experience);
        if (!groupedResults.containsKey(category)) {
          groupedResults[category] = [];
        }
        groupedResults[category]!.add(experience);
      } catch (e) {
        if (kDebugMode) {
          dev.log('ExperiencesProvider: Error grouping experience: $e',
              name: 'experiences_provider');
        }
        // Add to "Other" category if there's an error
        if (!groupedResults.containsKey('Other')) {
          groupedResults['Other'] = [];
        }
        groupedResults['Other']!.add(experience);
      }
    }

    return groupedResults.entries.map((entry) {
      return {
        'title': entry.key,
        'deals': entry.value,
      };
    }).toList();
  }

  /// Extract category from experience
  String _getCategoryFromExperience(Map<String, dynamic> experience) {
    try {
      final title = experience['title']?.toString().toLowerCase() ?? '';
      final location = experience['location']?.toString().toLowerCase() ?? '';

      if (title.contains('helicopter') || title.contains('flight')) {
        return 'Aerial Adventures';
      } else if (title.contains('ski') || title.contains('snow')) {
        return 'Winter Sports';
      } else if (title.contains('fishing') || title.contains('boat')) {
        return 'Water Activities';
      } else if (title.contains('hiking') || title.contains('mountain')) {
        return 'Adventure Tours';
      } else if (title.contains('wine') || title.contains('napa')) {
        return 'Luxury Experiences';
      } else if (title.contains('skydiving') || title.contains('parachute')) {
        return 'Extreme Sports';
      } else if (title.contains('surf') || title.contains('beach')) {
        return 'Water Sports';
      } else if (title.contains('sunset') || title.contains('romantic')) {
        return 'Romantic Getaways';
      } else if (title.contains('northern lights') ||
          title.contains('aurora')) {
        return 'Natural Wonders';
      } else {
        return 'Adventure Tours';
      }
    } catch (e) {
      if (kDebugMode) {
        dev.log('ExperiencesProvider: Error extracting category: $e',
            name: 'experiences_provider');
      }
      return 'Adventure Tours'; // Default category
    }
  }

  /// Set state and notify listeners
  void _setState(ExperienceState newState) {
    if (kDebugMode) {
      dev.log('ExperiencesProvider: State changing from $_state to $newState',
          name: 'experiences_provider');
    }
    _state = newState;
    notifyListeners();
  }
}
