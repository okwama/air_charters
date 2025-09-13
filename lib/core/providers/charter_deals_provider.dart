import 'package:flutter/foundation.dart';
import '../models/charter_deal_model.dart';
import '../services/charter_deals_service.dart';
import '../error/app_exceptions.dart';
import '../../shared/utils/session_manager.dart';
import 'dart:developer' as dev;
import 'dart:async';

enum CharterDealsState {
  initial,
  loading,
  loaded,
  error,
  loadingMore,
  offline, // New state for offline/cached data
}

class CharterDealsProvider extends ChangeNotifier {
  CharterDealsProvider() {
    if (kDebugMode) {
      dev.log('CharterDealsProvider: Constructor called',
          name: 'deals_provider');
    }
  }

  @override
  void dispose() {
    if (kDebugMode) {
      dev.log('CharterDealsProvider: dispose called', name: 'deals_provider');
    }
    _debounceTimer?.cancel();
    super.dispose();
  }

  CharterDealsState _state = CharterDealsState.initial;
  List<CharterDealModel> _deals = [];
  String? _errorMessage;
  bool _hasMoreData = true;
  int _currentPage = 1;
  static const int _pageSize = 10;
  
  // Debouncing and fallback UI support
  Timer? _debounceTimer;
  bool _isOfflineMode = false;
  DateTime? _lastSuccessfulLoad;

  // Getters
  CharterDealsState get state => _state;
  List<CharterDealModel> get deals => _deals;
  String? get errorMessage => _errorMessage;
  bool get hasMoreData => _hasMoreData;
  bool get isLoading => _state == CharterDealsState.loading;
  bool get isLoadingMore => _state == CharterDealsState.loadingMore;
  bool get hasError => _state == CharterDealsState.error;
  bool get isOfflineMode => _isOfflineMode;
  bool get hasCachedData => _deals.isNotEmpty && _lastSuccessfulLoad != null;
  String? get lastLoadTime => _lastSuccessfulLoad?.toString();

  /// Debounced load deals to prevent rapid successive calls
  void debouncedLoadDeals({
    String? searchQuery,
    String? dealType,
    DateTime? fromDate,
    DateTime? toDate,
    int? aircraftTypeId,
    bool groupBy = false,
    bool forceRefresh = false,
  }) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      loadDeals(
        searchQuery: searchQuery,
        dealType: dealType,
        fromDate: fromDate,
        toDate: toDate,
        aircraftTypeId: aircraftTypeId,
        groupBy: groupBy,
        forceRefresh: forceRefresh,
      );
    });
  }

  /// Load deals with enhanced error handling and fallback UI
  Future<void> loadDeals({
    String? searchQuery,
    String? dealType,
    DateTime? fromDate,
    DateTime? toDate,
    int? aircraftTypeId,
    bool groupBy = false,
    bool forceRefresh = false,
  }) async {
    if (kDebugMode) {
      dev.log('CharterDealsProvider: loadDeals method called',
          name: 'deals_provider');
    }

    if (_state == CharterDealsState.loading && !forceRefresh) return;

    // Check if user is authenticated before making API call
    final sessionManager = SessionManager();
    final authData = await sessionManager.getStoredAuthData();
    final isAuthenticated = authData != null && !authData.isExpired;

    if (!isAuthenticated) {
      if (kDebugMode) {
        dev.log(
            'CharterDealsProvider: User not authenticated, returning empty list',
            name: 'deals_provider');
      }
      _deals = [];
      _currentPage = 1;
      _hasMoreData = false;
      _setState(CharterDealsState.loaded);
      return;
    }

    try {
      _setState(CharterDealsState.loading);
      _errorMessage = null;

      if (kDebugMode) {
        dev.log('CharterDealsProvider: Loading deals...',
            name: 'deals_provider');
        dev.log('CharterDealsProvider: Search query: $searchQuery',
            name: 'deals_provider');
        dev.log('CharterDealsProvider: Deal type: $dealType',
            name: 'deals_provider');
      }

      if (kDebugMode) {
        dev.log(
            'CharterDealsProvider: About to call CharterDealsService.fetchCharterDeals',
            name: 'deals_provider');
      }

      final deals = await CharterDealsService.fetchCharterDeals(
        page: 1,
        limit: _pageSize,
        searchQuery: searchQuery,
        dealType: dealType,
        fromDate: fromDate,
        toDate: toDate,
        aircraftTypeId: aircraftTypeId,
        groupBy: groupBy,
        forceRefresh: forceRefresh,
      );

      if (kDebugMode) {
        dev.log(
            'CharterDealsProvider: Service call completed, received ${deals.length} deals',
            name: 'deals_provider');
      }

      if (kDebugMode) {
        dev.log('CharterDealsProvider: Fetched ${deals.length} deals',
            name: 'deals_provider');
        if (deals.isNotEmpty) {
          dev.log(
              'CharterDealsProvider: First deal: ${deals.first.routeDisplay}',
              name: 'deals_provider');
          dev.log(
              'CharterDealsProvider: First deal price: ${deals.first.priceDisplay}',
              name: 'deals_provider');
        } else {
          dev.log(
              'CharterDealsProvider: No deals returned (may be due to authentication)',
              name: 'deals_provider');
        }
      }

      if (kDebugMode) {
        dev.log(
            'CharterDealsProvider: Assigning ${deals.length} deals to _deals',
            name: 'deals_provider');
        dev.log('CharterDealsProvider: Previous deals count: ${_deals.length}',
            name: 'deals_provider');
      }

      _deals = deals;
      _currentPage = 1;
      _hasMoreData = deals.length >= _pageSize;

      if (kDebugMode) {
        dev.log(
            'CharterDealsProvider: After assignment - deals count: ${_deals.length}',
            name: 'deals_provider');
        dev.log('CharterDealsProvider: Setting state to loaded',
            name: 'deals_provider');
      }

      // Mark successful load and exit offline mode
      _lastSuccessfulLoad = DateTime.now();
      _isOfflineMode = false;
      _setState(CharterDealsState.loaded);
    } on AppException catch (e) {
      if (kDebugMode) {
        dev.log('CharterDealsProvider: Error loading deals: ${e.message}',
            name: 'deals_provider');
      }

      // Handle authentication errors directly
      if (e is AuthException) {
        if (e.message.contains('401') ||
            e.message.contains('expired') ||
            e.message.contains('Invalid')) {
          // Authentication error - set error state and let UI handle redirect
          _errorMessage =
              'Authentication required. Please login to view charter deals.';
          _setState(CharterDealsState.error);
        } else {
          // Other auth errors
          _errorMessage = e.message;
          _setState(CharterDealsState.error);
        }
      } else if (e is NetworkException) {
        // Network error - show cached data if available
        _handleNetworkError(e.message);
      } else {
        // Other server errors
        _errorMessage = e.message;
        _setState(CharterDealsState.error);
      }
    } catch (e) {
      if (kDebugMode) {
        dev.log('CharterDealsProvider: Unexpected error: $e',
            name: 'deals_provider');
      }
      
      // Check if it's a timeout or network error
      if (e.toString().contains('TimeoutException') || 
          e.toString().contains('SocketException')) {
        _handleNetworkError('Connection timeout. Showing cached data.');
      } else {
        _errorMessage = 'An unexpected error occurred';
        _setState(CharterDealsState.error);
      }
    }
  }

  /// Handle network errors with fallback to cached data
  void _handleNetworkError(String message) {
    if (_deals.isNotEmpty && _lastSuccessfulLoad != null) {
      // Show cached data with offline indicator
      _isOfflineMode = true;
      _errorMessage = '$message (Showing cached data from ${_formatLastLoadTime()})';
      _setState(CharterDealsState.offline);
      
      if (kDebugMode) {
        dev.log('CharterDealsProvider: Showing ${_deals.length} cached deals in offline mode',
            name: 'deals_provider');
      }
    } else {
      // No cached data available
      _errorMessage = message;
      _setState(CharterDealsState.error);
    }
  }

  /// Format last load time for display
  String _formatLastLoadTime() {
    if (_lastSuccessfulLoad == null) return 'unknown time';
    
    final now = DateTime.now();
    final difference = now.difference(_lastSuccessfulLoad!);
    
    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  /// Load more deals for pagination
  Future<void> loadMoreDeals({
    String? searchQuery,
    String? dealType,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    if (_state == CharterDealsState.loadingMore || !_hasMoreData) return;

    try {
      _setState(CharterDealsState.loadingMore);

      final moreDeals = await CharterDealsService.fetchCharterDeals(
        page: _currentPage + 1,
        limit: _pageSize,
        searchQuery: searchQuery,
        dealType: dealType,
        fromDate: fromDate,
        toDate: toDate,
      );

      if (moreDeals.isNotEmpty) {
        _deals.addAll(moreDeals);
        _currentPage++;
        _hasMoreData = moreDeals.length >= _pageSize;
      } else {
        _hasMoreData = false;
      }

      _setState(CharterDealsState.loaded);
    } on AppException catch (e) {
      _errorMessage = e.message;
      _setState(CharterDealsState.error);
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      _setState(CharterDealsState.error);
    }
  }

  /// Refresh deals
  Future<void> refreshDeals({
    String? searchQuery,
    String? dealType,
    DateTime? fromDate,
    DateTime? toDate,
    int? aircraftTypeId,
    bool groupBy = false,
  }) async {
    await loadDeals(
      searchQuery: searchQuery,
      dealType: dealType,
      fromDate: fromDate,
      toDate: toDate,
      aircraftTypeId: aircraftTypeId,
      groupBy: groupBy,
      forceRefresh: true,
    );
  }

  /// Clear deals and reset state
  void clearDeals() {
    _deals.clear();
    _currentPage = 1;
    _hasMoreData = true;
    _errorMessage = null;
    _setState(CharterDealsState.initial);
  }

  /// Clear error state
  void clearError() {
    _errorMessage = null;
    if (_state == CharterDealsState.error) {
      _setState(CharterDealsState.loaded);
    }
  }

  /// Filter deals by search query
  List<CharterDealModel> filterDeals(String query) {
    if (query.isEmpty) return _deals;

    final lowercaseQuery = query.toLowerCase();
    return _deals.where((deal) {
      return deal.origin?.toLowerCase().contains(lowercaseQuery) == true ||
          deal.destination?.toLowerCase().contains(lowercaseQuery) == true ||
          deal.companyName?.toLowerCase().contains(lowercaseQuery) == true ||
          deal.aircraftName?.toLowerCase().contains(lowercaseQuery) == true;
    }).toList();
  }

  /// Get deals for a specific route
  Future<void> loadDealsForRoute({
    required String origin,
    required String destination,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    await loadDeals(
      searchQuery: '$origin $destination',
      fromDate: fromDate,
      toDate: toDate,
    );
  }

  /// Get deals for a specific company
  Future<void> loadDealsForCompany({
    required int companyId,
  }) async {
    try {
      _setState(CharterDealsState.loading);
      _errorMessage = null;

      final deals = await CharterDealsService.fetchDealsForCompany(
        companyId: companyId,
        page: 1,
        limit: _pageSize,
      );

      _deals = deals;
      _currentPage = 1;
      _hasMoreData = deals.length >= _pageSize;
      _setState(CharterDealsState.loaded);
    } on AppException catch (e) {
      _errorMessage = e.message;
      _setState(CharterDealsState.error);
    } catch (e) {
      // Don't treat empty results as an error - this is normal for unauthenticated users
      if (e.toString().contains('401') ||
          e.toString().contains('Authentication failed')) {
        _deals = [];
        _currentPage = 1;
        _hasMoreData = false;
        _setState(CharterDealsState.loaded);
      } else {
        _errorMessage = 'An unexpected error occurred';
        _setState(CharterDealsState.error);
      }
    }
  }

  /// Get deals by category
  List<CharterDealModel> getDealsByCategory(String category) {
    if (category.isEmpty) return _deals;
    return _deals.where((deal) => deal.dealType == category).toList();
  }

  /// Get deal by ID
  Future<CharterDealModel?> getDealById(int dealId) async {
    try {
      return await CharterDealsService.fetchDealById(dealId);
    } on AppException catch (e) {
      _errorMessage = e.message;
      _setState(CharterDealsState.error);
      return null;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      _setState(CharterDealsState.error);
      return null;
    }
  }

  void _setState(CharterDealsState newState) {
    if (kDebugMode) {
      dev.log('CharterDealsProvider: State change from $_state to $newState',
          name: 'deals_provider');
      dev.log('CharterDealsProvider: Current deals count: ${_deals.length}',
          name: 'deals_provider');
      dev.log('CharterDealsProvider: Has error: ${_errorMessage != null}',
          name: 'deals_provider');
      if (_errorMessage != null) {
        dev.log('CharterDealsProvider: Error message: $_errorMessage',
            name: 'deals_provider');
      }
    }
    _state = newState;
    notifyListeners();
  }
}
