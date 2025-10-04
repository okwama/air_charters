import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme/app_theme.dart';
import '../../config/env/app_config.dart';
import '../../core/services/aircraft_type_service.dart';
import '../cargo/cargo_screen.dart';
import '../experiences/experiences_screen.dart';
import '../deals/deals_screen.dart';
import '../direct_charter/aircraft_type_selection_screen.dart';
import '../direct_charter/aircraft_results_screen.dart';
import '../medivac/medivac_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Aircraft types data
  final AircraftTypeService _aircraftTypeService = AircraftTypeService();
  List<AircraftType> _aircraftTypes = [];
  bool _isLoadingAircraftTypes = true;
  
  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  List<String> _searchSuggestions = [];
  List<String> _recentSearches = [];
  List<String> _savedRoutes = [];
  bool _isSearching = false;
  
  // Filter functionality
  Set<String> _selectedFilters = {};
  final List<String> _availableFilters = [
    'Helicopter', 'Private Jet', 'Seaplane', 'Cargo', 'Medical'
  ];
  
  // Pull to refresh
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  
  // Error handling
  String? _errorMessage;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadAircraftTypes();
    _loadSavedData();
    _setupSearchListener();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  Future<void> _loadAircraftTypes() async {
    try {
      setState(() {
        _hasError = false;
        _errorMessage = null;
      });
      
      final aircraftTypes = await _aircraftTypeService.getAircraftTypes();
      if (mounted) {
        setState(() {
          _aircraftTypes = aircraftTypes;
          _isLoadingAircraftTypes = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingAircraftTypes = false;
          _hasError = true;
          _errorMessage = 'Failed to load aircraft types. Please check your connection and try again.';
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          // Background SVG
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/icons/world.svg',
                    fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.grey.shade100.withOpacity(0.9),
                BlendMode.srcATop,
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildResponsiveContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: constraints.maxWidth > 600 ? 20 : 12,
              vertical: 8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Error handling
                if (_hasError) _buildErrorWidget(),
                
                // Universal Search Section (Top)
                _buildUniversalSearchSection(),
                const SizedBox(height: 12),
                
                // Services Section
                _buildServicesSection(),
                const SizedBox(height: 12),
                
                // Quick Aircraft Access Section
                _buildAircraftQuickAccessSection(constraints),
                const SizedBox(height: 12),
                
                // Quick Actions Section
                _buildQuickActionsSection(),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget _buildServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Services',
          style: AppTheme.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.black,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        // Compact 3-Column Grid Layout
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 1,
          mainAxisSpacing: 8,
          childAspectRatio: 1.2,
            children: [
              _buildServiceIcon(
                imagePath: AppConfig.dealsIconPath,
                title: 'Deals',
                onTap: () => _navigateToDeals(),
              ),
              _buildServiceIcon(
                imagePath: AppConfig.directCharterIconPath,
                title: 'Direct Charter',
                onTap: () => _navigateToDirectCharter(),
              ),
              _buildServiceIcon(
                imagePath: AppConfig.experiencesIconPath,
                title: 'Experiences',
                onTap: () => _navigateToExperiences(),
              ),
              _buildServiceIcon(
                imagePath: AppConfig.cargoIconPath,
                title: 'Cargo',
                onTap: () => _navigateToCargo(),
              ),
              _buildServiceIcon(
                imagePath: AppConfig.medivacIconPath,
                title: 'Medical',
                onTap: () => _navigateToMedivac(),
              ),
            ],
        ),
      ],
    );
  }

  Widget _buildServiceIcon({
    required String imagePath,
    required String title,
    required VoidCallback onTap,
  }) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * _fadeAnimation.value),
          child: GestureDetector(
            onTap: onTap,
                  child: Column(
              children: [
                Opacity(
                  opacity: 0.8,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.borderColor,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Image.asset(
                        imagePath,
                        width: 54,
                        height: 54,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    fontSize: 10,
                    letterSpacing: 0.05,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAircraftQuickAccessSection(BoxConstraints constraints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Aircraft Access',
          style: AppTheme.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.black,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        
        if (_isLoadingAircraftTypes)
          _buildAircraftTypesLoading()
        else
          _buildAircraftTypesHorizontalScroll(),
      ],
    );
  }

  Widget _buildAircraftTypesLoading() {
    return SizedBox(
      height: 105,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        itemBuilder: (context, index) {
          return Container(
            width: 120,
            margin: EdgeInsets.only(
              left: index == 0 ? 0 : 8,
              right: index == 3 ? 0 : 0,
            ),
            child: _buildAircraftTypeSkeleton(),
          );
        },
      ),
    );
  }

  Widget _buildAircraftTypeSkeleton() {
    return Container(
      height: 95,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: _buildLottieLoading(width: 40, height: 40),
      ),
    );
  }

  Widget _buildAircraftTypesHorizontalScroll() {
    return SizedBox(
      height: 105,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _aircraftTypes.length,
        itemBuilder: (context, index) {
          final aircraftType = _aircraftTypes[index];
          return Container(
            width: 120,
            margin: EdgeInsets.only(
              left: index == 0 ? 0 : 8,
              right: index == _aircraftTypes.length - 1 ? 0 : 0,
            ),
            child: _buildAircraftTypeCard(aircraftType),
          );
        },
      ),
    );
  }

  Widget _buildAircraftTypeCard(AircraftType aircraftType) {
    return GestureDetector(
      onTap: () => _navigateToAircraftResults(aircraftType),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Aircraft Image
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: aircraftType.placeholderImageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: aircraftType.placeholderImageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (context, url) => Container(
                            color: Colors.grey.shade200,
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.blue.shade600,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey.shade200,
                            child: Icon(
                              _getAircraftIcon(aircraftType.type),
                              size: 32,
                              color: Colors.blue.shade600,
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey.shade200,
                          child: Icon(
                            _getAircraftIcon(aircraftType.type),
                            size: 32,
                            color: Colors.blue.shade600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 6),
              // Aircraft Type Name
              Expanded(
                flex: 1,
                child: Text(
                  aircraftType.type,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUniversalSearchSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search Aircraft & Services',
            style: AppTheme.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search aircraft type or service...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isSearching)
                    Container(
                      width: 20,
                      height: 20,
                      margin: const EdgeInsets.only(right: 8),
                      child: _buildLottieLoading(width: 20, height: 20),
                    )
                  else if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: _clearSearch,
                    ),
                  IconButton(
                    icon: const Icon(Icons.filter_list, size: 20),
                    onPressed: _showFilterModal,
                  ),
                ],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.blue.shade600),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onChanged: _onSearchChanged,
            onSubmitted: _onSearchSubmitted,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _availableFilters.map((filter) => 
              _buildSearchChip(filter, _selectedFilters.contains(filter))
            ).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => _toggleFilter(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue.shade300 : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            color: isSelected ? Colors.blue.shade700 : Colors.grey.shade700,
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppTheme.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.black,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.history,
                title: 'Recent Searches',
                subtitle: '${_recentSearches.length} searches',
                onTap: _showRecentSearches,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.bookmark,
                title: 'Saved Routes',
                subtitle: '${_savedRoutes.length} routes',
                onTap: _showSavedRoutes,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 18,
              color: Colors.blue.shade600,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: AppTheme.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTheme.bodySmall.copyWith(
                color: Colors.grey.shade600,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getAircraftIcon(String aircraftType) {
    switch (aircraftType.toLowerCase()) {
      case 'helicopter':
        return Icons.flight;
      case 'jet':
        return Icons.flight;
      case 'fixedwing':
      case 'fixed wing':
        return Icons.airplanemode_active;
      case 'seaplane':
        return Icons.flight;
      case 'balloon':
        return Icons.flight;
      case 'tiltrotor':
        return Icons.flight;
      default:
        return Icons.airplanemode_active;
    }
  }

  void _navigateToAircraftResults(AircraftType aircraftType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AircraftResultsScreen(
          aircraftType: aircraftType,
        ),
      ),
    );
  }

  // Helper method for safe Lottie loading
  Widget _buildLottieLoading({
    required double width,
    required double height,
    String? assetPath,
  }) {
    try {
      return Lottie.asset(
        assetPath ?? 'assets/animations/loading.json',
        width: width,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return SizedBox(
            width: width,
            height: height,
            child: CircularProgressIndicator(
              strokeWidth: width > 30 ? 3 : 2,
            ),
          );
        },
      );
    } catch (e) {
      return SizedBox(
        width: width,
        height: height,
        child: CircularProgressIndicator(
          strokeWidth: width > 30 ? 3 : 2,
        ),
      );
    }
  }

  // Enhanced functionality methods
  
  Future<void> _loadSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _recentSearches = prefs.getStringList('recent_searches') ?? [];
      _savedRoutes = prefs.getStringList('saved_routes') ?? [];
      if (mounted) setState(() {});
    } catch (e) {
      print('Error loading saved data: $e');
    }
  }

  Future<void> _saveRecentSearch(String search) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _recentSearches.remove(search); // Remove if exists
      _recentSearches.insert(0, search); // Add to beginning
      if (_recentSearches.length > 10) {
        _recentSearches = _recentSearches.take(10).toList();
      }
      await prefs.setStringList('recent_searches', _recentSearches);
      if (mounted) setState(() {});
    } catch (e) {
      print('Error saving recent search: $e');
    }
  }

  void _setupSearchListener() {
    _searchController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (value.isNotEmpty) {
        _performSearch(value);
      } else {
        setState(() {
          _searchSuggestions.clear();
          _isSearching = false;
        });
      }
    });
  }

  void _onSearchSubmitted(String value) {
    if (value.isNotEmpty) {
      _saveRecentSearch(value);
      _performSearch(value);
    }
  }

  void _performSearch(String query) {
    setState(() {
      _isSearching = true;
    });

    // Simulate search results
    final results = _aircraftTypes
        .where((aircraft) => 
          aircraft.type.toLowerCase().contains(query.toLowerCase()) ||
          (aircraft.description?.toLowerCase().contains(query.toLowerCase()) ?? false))
        .map((aircraft) => aircraft.type)
        .toList();

    setState(() {
      _searchSuggestions = results;
      _isSearching = false;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchSuggestions.clear();
      _isSearching = false;
    });
  }

  void _toggleFilter(String filter) {
    setState(() {
      if (_selectedFilters.contains(filter)) {
        _selectedFilters.remove(filter);
      } else {
        _selectedFilters.add(filter);
      }
    });
  }

  Future<void> _onRefresh() async {
    setState(() {
      _hasError = false;
      _errorMessage = null;
    });
    
    try {
      await _loadAircraftTypes();
      // Add a small delay to show the refresh animation
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Failed to refresh data. Please try again.';
      });
    }
  }

  Widget _buildErrorWidget() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage ?? 'An error occurred',
              style: AppTheme.bodySmall.copyWith(color: Colors.red.shade700),
            ),
          ),
          TextButton(
            onPressed: _onRefresh,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _buildFilterModal(),
    );
  }

  Widget _buildFilterModal() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Advanced Filters',
            style: AppTheme.heading3.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Aircraft Types',
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableFilters.map((filter) => 
              _buildFilterChip(filter)
            ).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _selectedFilters.clear();
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Clear All'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filter) {
    final isSelected = _selectedFilters.contains(filter);
    return GestureDetector(
      onTap: () => _toggleFilter(filter),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue.shade300 : Colors.grey.shade300,
          ),
        ),
        child: Text(
          filter,
          style: AppTheme.bodySmall.copyWith(
            color: isSelected ? Colors.blue.shade700 : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  void _showRecentSearches() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _buildRecentSearchesModal(),
    );
  }

  Widget _buildRecentSearchesModal() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Searches',
            style: AppTheme.heading3.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          if (_recentSearches.isEmpty)
            Center(
              child: Text(
                'No recent searches',
                style: AppTheme.bodyMedium.copyWith(color: Colors.grey.shade600),
              ),
            )
          else
            ..._recentSearches.map((search) => ListTile(
              leading: const Icon(Icons.history),
              title: Text(search),
              onTap: () {
                _searchController.text = search;
                _onSearchSubmitted(search);
                Navigator.pop(context);
              },
            )),
        ],
      ),
    );
  }

  void _showSavedRoutes() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _buildSavedRoutesModal(),
    );
  }

  Widget _buildSavedRoutesModal() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Saved Routes',
            style: AppTheme.heading3.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          if (_savedRoutes.isEmpty)
            Center(
              child: Text(
                'No saved routes',
                style: AppTheme.bodyMedium.copyWith(color: Colors.grey.shade600),
              ),
            )
          else
            ..._savedRoutes.map((route) => ListTile(
              leading: const Icon(Icons.bookmark),
              title: Text(route),
              onTap: () {
                Navigator.pop(context);
                // Navigate to route details
              },
            )),
        ],
      ),
    );
  }

  // Navigation methods
  void _navigateToDeals() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DealsScreen(),
      ),
    );
  }

  void _navigateToDirectCharter() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AircraftTypeSelectionScreen(),
      ),
    );
  }

  void _navigateToExperiences() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ExperiencesScreen(),
      ),
    );
  }

  void _navigateToCargo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CargoScreen(),
      ),
    );
  }

  void _navigateToMedivac() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MedivacScreen(),
      ),
    );
  }
}
