import 'package:flutter/foundation.dart';
import '../../models/charter_deal_model.dart';
import '../../providers/charter_deals_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/charter_deals_service.dart';

/// Controller to handle charter deals business logic
/// Coordinates between CharterDealsProvider and CharterDealsService
class CharterDealsController {
  final CharterDealsProvider _dealsProvider;
  final CharterDealsService _dealsService;
  final AuthProvider _authProvider;

  CharterDealsController({
    required CharterDealsProvider dealsProvider,
    required CharterDealsService dealsService,
    required AuthProvider authProvider,
  })  : _dealsProvider = dealsProvider,
        _dealsService = dealsService,
        _authProvider = authProvider;

  /// Search deals with filters
  Future<DealsSearchResult> searchDeals({
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
    try {
      // Validate search parameters
      final validation = validateSearchParams(
        query: query,
        minPrice: minPrice,
        maxPrice: maxPrice,
        passengers: passengers,
      );
      if (!validation.isValid) {
        return DealsSearchResult.failure(validation.errors.first);
      }

      // Perform search
      final deals = await CharterDealsService.searchDeals(
        query: query,
        category: category,
        origin: origin,
        destination: destination,
        departureDate: departureDate,
        returnDate: returnDate,
        minPrice: minPrice,
        maxPrice: maxPrice,
        passengers: passengers,
        aircraftType: aircraftType,
        companyId: companyId,
        sortBy: sortBy,
        sortOrder: sortOrder,
        page: page,
        limit: limit,
      );

      return DealsSearchResult.success(deals);
    } catch (e) {
      if (kDebugMode) {
        print('CharterDealsController.searchDeals error: $e');
      }
      return DealsSearchResult.failure(
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Get deal by ID
  Future<DealResult> getDealById(int dealId) async {
    try {
      // Validate deal ID
      if (dealId <= 0) {
        return DealResult.failure('Invalid deal ID');
      }

      // Get deal from service
      final deal = await CharterDealsService.getDealById(dealId);

      if (deal != null) {
        return DealResult.success(deal);
      } else {
        return DealResult.failure('Deal not found');
      }
    } catch (e) {
      if (kDebugMode) {
        print('CharterDealsController.getDealById error: $e');
      }
      return DealResult.failure(
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Get deals by category
  Future<DealsSearchResult> getDealsByCategory(String category) async {
    try {
      // Validate category
      if (category.trim().isEmpty) {
        return DealsSearchResult.failure('Category is required');
      }

      // Get deals by category
      final deals = await CharterDealsService.getDealsByCategory(category);
      return DealsSearchResult.success(deals);
    } catch (e) {
      if (kDebugMode) {
        print('CharterDealsController.getDealsByCategory error: $e');
      }
      return DealsSearchResult.failure(
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Get featured deals
  Future<DealsSearchResult> getFeaturedDeals({int limit = 10}) async {
    try {
      final deals = await CharterDealsService.getFeaturedDeals(limit: limit);
      return DealsSearchResult.success(deals);
    } catch (e) {
      if (kDebugMode) {
        print('CharterDealsController.getFeaturedDeals error: $e');
      }
      return DealsSearchResult.failure(
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Get deals by company
  Future<DealsSearchResult> getDealsByCompany(String companyId) async {
    try {
      // Validate company ID
      if (companyId.trim().isEmpty) {
        return DealsSearchResult.failure('Company ID is required');
      }

      final deals = await CharterDealsService.getDealsByCompany(companyId);
      return DealsSearchResult.success(deals);
    } catch (e) {
      if (kDebugMode) {
        print('CharterDealsController.getDealsByCompany error: $e');
      }
      return DealsSearchResult.failure(
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Get deals by route
  Future<DealsSearchResult> getDealsByRoute({
    required String origin,
    required String destination,
    DateTime? departureDate,
    int? passengers,
  }) async {
    try {
      // Validate route parameters
      if (origin.trim().isEmpty) {
        return DealsSearchResult.failure('Origin is required');
      }
      if (destination.trim().isEmpty) {
        return DealsSearchResult.failure('Destination is required');
      }
      if (origin.toLowerCase() == destination.toLowerCase()) {
        return DealsSearchResult.failure(
            'Origin and destination cannot be the same');
      }

      final deals = await CharterDealsService.getDealsByRoute(
        origin: origin,
        destination: destination,
        departureDate: departureDate,
        passengers: passengers,
      );
      return DealsSearchResult.success(deals);
    } catch (e) {
      if (kDebugMode) {
        print('CharterDealsController.getDealsByRoute error: $e');
      }
      return DealsSearchResult.failure(
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Get deal categories
  Future<List<String>> getDealCategories() async {
    try {
      return await CharterDealsService.getDealCategories();
    } catch (e) {
      if (kDebugMode) {
        print('CharterDealsController.getDealCategories error: $e');
      }
      return [];
    }
  }

  /// Get popular routes
  Future<List<Map<String, dynamic>>> getPopularRoutes() async {
    try {
      return await CharterDealsService.getPopularRoutes();
    } catch (e) {
      if (kDebugMode) {
        print('CharterDealsController.getPopularRoutes error: $e');
      }
      return [];
    }
  }

  /// Validate search parameters
  DealsValidationResult validateSearchParams({
    String? query,
    int? minPrice,
    int? maxPrice,
    int? passengers,
  }) {
    final errors = <String>[];

    // Price validation
    if (minPrice != null && minPrice < 0) {
      errors.add('Minimum price cannot be negative');
    }
    if (maxPrice != null && maxPrice < 0) {
      errors.add('Maximum price cannot be negative');
    }
    if (minPrice != null && maxPrice != null && minPrice > maxPrice) {
      errors.add('Minimum price cannot be greater than maximum price');
    }

    // Passenger validation
    if (passengers != null && passengers <= 0) {
      errors.add('Number of passengers must be greater than 0');
    }

    return DealsValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Get current deals state
  CharterDealsState get dealsState => _dealsProvider.state;

  /// Check if deals are loading
  bool get isLoading => _dealsProvider.isLoading;

  /// Get deals error message
  String? get errorMessage => _dealsProvider.errorMessage;

  /// Get current deals
  List<CharterDealModel> get deals => _dealsProvider.deals;

  /// Clear deals errors
  void clearError() {
    _dealsProvider.clearError();
  }

  /// Refresh deals data
  Future<void> refreshDeals() async {
    await _dealsProvider.refreshDeals();
  }
}

/// Result of deals search operation
class DealsSearchResult {
  final bool isSuccess;
  final List<CharterDealModel>? deals;
  final String? errorMessage;

  DealsSearchResult._({
    required this.isSuccess,
    this.deals,
    this.errorMessage,
  });

  factory DealsSearchResult.success(List<CharterDealModel> deals) {
    return DealsSearchResult._(
      isSuccess: true,
      deals: deals,
    );
  }

  factory DealsSearchResult.failure(String errorMessage) {
    return DealsSearchResult._(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }
}

/// Result of single deal operation
class DealResult {
  final bool isSuccess;
  final CharterDealModel? deal;
  final String? errorMessage;

  DealResult._({
    required this.isSuccess,
    this.deal,
    this.errorMessage,
  });

  factory DealResult.success(CharterDealModel deal) {
    return DealResult._(
      isSuccess: true,
      deal: deal,
    );
  }

  factory DealResult.failure(String errorMessage) {
    return DealResult._(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }
}

/// Result of deals validation
class DealsValidationResult {
  final bool isValid;
  final List<String> errors;

  DealsValidationResult({
    required this.isValid,
    required this.errors,
  });
}
