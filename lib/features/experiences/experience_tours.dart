import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:air_charters/shared/components/experience_card.dart';
import 'package:air_charters/features/experiences/tour_list.dart';
import 'package:air_charters/features/experiences/tour_detail.dart';
import 'package:air_charters/core/providers/experiences_provider.dart';

import 'dart:developer' as dev;
import 'package:flutter/foundation.dart' show kDebugMode;

class ExperienceToursScreen extends StatefulWidget {
  const ExperienceToursScreen({super.key});

  @override
  State<ExperienceToursScreen> createState() => _ExperienceToursScreenState();
}

class _ExperienceToursScreenState extends State<ExperienceToursScreen> {
  final ScrollController _scrollController = ScrollController();

  // Search and filter state
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  // String _selectedLocation = 'All'; // Temporarily unused
  RangeValues _priceRange = const RangeValues(0, 1000);
  RangeValues _durationRange = const RangeValues(0, 300);
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      dev.log('ExperienceToursScreen: initState called',
          name: 'experiences_screen');
    }
    _scrollController.addListener(_onScroll);

    // Re-enable provider initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (kDebugMode) {
        dev.log(
            'ExperienceToursScreen: Post frame callback - loading initial experiences',
            name: 'experiences_screen');
      }
      _loadInitialExperiences();
    });
  }

  @override
  void dispose() {
    if (kDebugMode) {
      dev.log('ExperienceToursScreen: dispose called',
          name: 'experiences_screen');
    }
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Re-enable provider calls
    final provider = context.read<ExperiencesProvider>();
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (provider.hasMoreData && !provider.isLoadingMore) {
        if (kDebugMode) {
          dev.log('ExperienceToursScreen: Loading more experiences...',
              name: 'experiences_screen');
        }
        provider.loadMoreExperiences();
      }
    }
  }

  void _loadInitialExperiences() {
    final provider = context.read<ExperiencesProvider>();
    provider.loadExperiences();
  }

  void _onSearchChanged() {
    // Debounce search to avoid too many API calls
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _applyFilters();
      }
    });
  }

  void _applyFilters() {
    // Re-enable provider calls
    final provider = context.read<ExperiencesProvider>();
    provider.loadExperiences(
      searchQuery:
          _searchController.text.isNotEmpty ? _searchController.text : null,
      category: _selectedCategory != 'All' ? _selectedCategory : null,
      location: null, // Temporarily disabled
      minPrice: _priceRange.start,
      maxPrice: _priceRange.end,
      minDuration: _durationRange.start.toInt(),
      maxDuration: _durationRange.end.toInt(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      dev.log('ExperienceToursScreen: build called',
          name: 'experiences_screen');
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Experience Top Destinations',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
            icon: Icon(
              _showFilters ? Icons.filter_list : Icons.filter_list_outlined,
              color: Colors.black,
            ),
          ),
        ],
      ),
      body: Consumer<ExperiencesProvider>(
        builder: (context, provider, child) {
          return RefreshIndicator(
            onRefresh: () async {
              if (kDebugMode) {
                dev.log('ExperienceToursScreen: Pull to refresh triggered',
                    name: 'experiences_screen');
              }
              await provider.refreshExperiences(
                searchQuery: _searchController.text.isNotEmpty
                    ? _searchController.text
                    : null,
                category: _selectedCategory != 'All' ? _selectedCategory : null,
                minPrice: _priceRange.start,
                maxPrice: _priceRange.end,
                minDuration: _durationRange.start.toInt(),
                maxDuration: _durationRange.end.toInt(),
              );
            },
            child: _buildContent(provider),
          );
        },
      ),
    );
  }

  Widget _buildContent(ExperiencesProvider provider) {
    if (provider.isLoading && provider.categories.isEmpty) {
      return _buildLoadingState();
    }

    if (provider.hasError) {
      return _buildErrorState(provider);
    }

    if (provider.categories.isEmpty) {
      return _buildEmptyState();
    }

    return _buildExperiencesList(provider);
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category title skeleton
              Container(
                height: 24,
                width: 200,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              // Experience cards skeleton
              SizedBox(
                height: 240,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  itemBuilder: (context, cardIndex) {
                    return Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image skeleton
                          Container(
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title skeleton
                                Container(
                                  height: 16,
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                // Location skeleton
                                Container(
                                  height: 14,
                                  width: 150,
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                // Price skeleton
                                Container(
                                  height: 16,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorState(ExperiencesProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.errorMessage ?? 'Unable to load experiences',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                provider.clearError();
                _loadInitialExperiences();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Try Again',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.explore_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No experiences found',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters or search terms',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _selectedCategory = 'All';
                  _priceRange = const RangeValues(0, 1000);
                  _durationRange = const RangeValues(0, 300);
                });
                _loadInitialExperiences();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Clear Filters',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperiencesList(ExperiencesProvider provider) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // Search Bar
          _buildSearchBar(),

          // Filters
          if (_showFilters) _buildFilters(),

          const SizedBox(height: 16),

          // Experience Categories
          ...provider.categories.map((category) {
            try {
              final title = category['title'] as String? ?? 'Unknown Category';
              final deals = (category['deals'] as List<dynamic>?)
                      ?.cast<Map<String, dynamic>>() ??
                  [];

              return _buildTourCategorySection(title, deals);
            } catch (e) {
              if (kDebugMode) {
                dev.log('Error building category section: $e',
                    name: 'experiences_screen');
              }
              return const SizedBox.shrink();
            }
          }),

          // Loading more indicator
          if (provider.isLoadingMore)
            Container(
              padding: const EdgeInsets.all(16),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),

          // End of list indicator
          if (!provider.hasMoreData && provider.categories.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'You\'ve reached the end',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => _onSearchChanged(),
        decoration: InputDecoration(
          hintText: 'Search experiences...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    // Debounce search to avoid too many API calls
                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (mounted) {
                        _onSearchChanged();
                      }
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filters',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Category Filter
          Text(
            'Category',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: [
              'All',
              'Aerial Adventures',
              'Winter Sports',
              'Water Activities',
              'Adventure Tours',
              'Luxury Experiences',
              'Extreme Sports',
              'Water Sports',
              'Romantic Getaways',
              'Natural Wonders'
            ].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value ?? 'All';
              });
              // Debounce filter application
              Future.delayed(const Duration(milliseconds: 300), () {
                if (mounted) {
                  _applyFilters();
                }
              });
            },
          ),
          const SizedBox(height: 16),

          // Price Range
          Text(
            'Price Range: \$${_priceRange.start.round()} - \$${_priceRange.end.round()}',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 1000,
            divisions: 20,
            labels: RangeLabels(
              '\$${_priceRange.start.round()}',
              '\$${_priceRange.end.round()}',
            ),
            onChanged: (values) {
              setState(() {
                _priceRange = values;
              });
              // Debounce filter application
              Future.delayed(const Duration(milliseconds: 300), () {
                if (mounted) {
                  _applyFilters();
                }
              });
            },
          ),
          const SizedBox(height: 16),

          // Duration Range
          Text(
            'Duration: ${_durationRange.start.round()} - ${_durationRange.end.round()} minutes',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          RangeSlider(
            values: _durationRange,
            min: 0,
            max: 300,
            divisions: 30,
            labels: RangeLabels(
              '${_durationRange.start.round()} min',
              '${_durationRange.end.round()} min',
            ),
            onChanged: (values) {
              setState(() {
                _durationRange = values;
              });
              // Debounce filter application
              Future.delayed(const Duration(milliseconds: 300), () {
                if (mounted) {
                  _applyFilters();
                }
              });
            },
          ),
          const SizedBox(height: 16),

          // Clear Filters Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _selectedCategory = 'All';
                  _priceRange = const RangeValues(0, 1000);
                  _durationRange = const RangeValues(0, 300);
                  _searchController.clear();
                });
                // Debounce filter application
                Future.delayed(const Duration(milliseconds: 300), () {
                  if (mounted) {
                    _applyFilters();
                  }
                });
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.black),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Clear All Filters',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTourCategorySection(
      String title, List<Map<String, dynamic>> deals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              TextButton(
                onPressed: () => _navigateToTourList(title, deals),
                child: Text(
                  'See All',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: deals.length,
            itemBuilder: (context, index) {
              try {
                final deal = deals[index];
                return Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  margin: const EdgeInsets.only(right: 16),
                  child: ExperienceCard(
                    imageUrl: deal['imageUrl']?.toString() ?? '',
                    title: deal['title']?.toString() ?? 'Unknown Experience',
                    location:
                        deal['location']?.toString() ?? 'Unknown Location',
                    duration: deal['duration']?.toString() ?? '1 hour',
                    price: _parsePrice(deal['price']),
                    rating: _parseRating(deal['rating']),
                    onTap: () => _showDealDetail(deal),
                  ),
                );
              } catch (e) {
                if (kDebugMode) {
                  dev.log('Error building experience card: $e',
                      name: 'experiences_screen');
                }
                return const SizedBox.shrink();
              }
            },
          ),
        ),
      ],
    );
  }

  void _navigateToTourList(String category, List<Map<String, dynamic>> deals) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TourListScreen(
          category: category,
          deals: deals,
        ),
      ),
    );
  }

  void _showDealDetail(Map<String, dynamic> deal) {
    // Simple, reliable navigation without complex error handling
    if (kDebugMode) {
      dev.log(
          '🔄 Navigation: Attempting to open tour detail for: ${deal['title']}',
          name: 'experiences_navigation');
    }

    // Extract basic data with safe defaults
    final String imageUrl = deal['imageUrl']?.toString() ??
        'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400';
    final String title = deal['title']?.toString() ?? 'Tour Experience';
    final String location = deal['location']?.toString() ?? 'Unknown Location';
    final String duration = deal['duration']?.toString() ?? '1 hour';
    final String price = _parsePrice(deal['price']);
    final String? rating = _parseRating(deal['rating']);
    final String description =
        deal['description']?.toString() ?? _getDescriptionForTour(title);

    // Convert ID to int safely
    int? experienceId;
    if (deal['id'] != null) {
      if (deal['id'] is int) {
        experienceId = deal['id'];
      } else if (deal['id'] is String) {
        experienceId = int.tryParse(deal['id']);
      } else {
        experienceId = int.tryParse(deal['id'].toString());
      }
    }

    if (kDebugMode) {
      dev.log('🔄 Navigation: Parsed data - Title: $title, ID: $experienceId',
          name: 'experiences_navigation');
    }

    // Simple navigation without Future.delayed
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TourDetailPage(
            imageUrl: imageUrl,
            title: title,
            location: location,
            duration: duration,
            price: price,
            rating: rating,
            description: description,
            experienceId: experienceId,
          ),
        ),
      );
      if (kDebugMode) {
        dev.log('✅ Navigation: Successfully navigated to TourDetailPage',
            name: 'experiences_navigation');
      }
    } catch (e) {
      if (kDebugMode) {
        dev.log('❌ Navigation: Failed with error: $e',
            name: 'experiences_navigation');
      }
      // Simple error handling without dialogs
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to open tour details: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  String _getDescriptionForTour(String title) {
    // Sample descriptions for each tour type
    final descriptions = {
      'Manhattan Helicopter Tour':
          'Experience the breathtaking skyline of New York City from above with our exclusive Manhattan helicopter tour. Soar over iconic landmarks including the Statue of Liberty, Empire State Building, and Central Park. Our professional pilots ensure a safe and unforgettable journey with panoramic views that will leave you speechless.',
      'Grand Canyon Scenic Flight':
          'Discover the majestic beauty of the Grand Canyon from a unique aerial perspective. This scenic flight takes you over one of the world\'s most spectacular natural wonders, offering unparalleled views of the canyon\'s dramatic rock formations and the Colorado River below.',
      'Whistler Heli Skiing':
          'Embark on an adrenaline-pumping heli-skiing adventure in the pristine backcountry of Whistler. Access untouched powder runs that are only reachable by helicopter, with expert guides ensuring your safety while you carve through some of the most spectacular terrain in North America.',
      'Alaska Fly-In Fishing':
          'Experience the ultimate fishing adventure in the remote wilderness of Alaska. Our fly-in fishing trips take you to pristine lakes and rivers teeming with salmon, trout, and other trophy fish, far from the crowds and accessible only by aircraft.',
      'Napa Valley Wine Tour':
          'Indulge in a luxurious wine country experience with our Napa Valley helicopter tour. Visit world-renowned wineries from above, enjoy exclusive tastings, and take in the stunning vineyard landscapes while learning about the region\'s rich viticultural heritage.',
      'Tandem Skydiving Experience':
          'Take the ultimate leap of faith with our tandem skydiving experience. Jump from 10,000 feet above ground level with a certified instructor, experiencing the thrill of freefall and the serenity of canopy flight while taking in spectacular aerial views.',
      'Remote Mountain Hiking':
          'Explore untouched wilderness with our remote mountain hiking adventures. Our expert guides lead you through pristine alpine landscapes, offering insights into local ecology and geology while ensuring your safety in challenging terrain.',
      'Maldives Surf Charter':
          'Ride perfect waves in the crystal-clear waters of the Maldives with our exclusive surf charter. Access world-class surf breaks by boat, staying in luxury accommodations and enjoying the tropical paradise between surf sessions.',
      'Sunset Helicopter Tour':
          'Create unforgettable memories with our romantic sunset helicopter tours. Watch the sun paint the sky in brilliant colors while soaring above stunning landscapes, perfect for special occasions and romantic getaways.',
      'Northern Lights Tour':
          'Witness the magical aurora borealis dance across the Arctic sky with our Northern Lights helicopter tours. Experience this natural phenomenon from the best vantage points, with expert guides explaining the science behind this spectacular light show.',
    };

    return descriptions[title] ??
        'Experience the adventure of a lifetime with our exclusive tour. Our professional guides ensure your safety while providing an unforgettable journey through stunning landscapes and unique destinations.';
  }

  String _parsePrice(dynamic price) {
    try {
      if (price == null) return '\$0';

      final priceStr = price.toString();

      // If it's already a formatted price string, return as is
      if (priceStr.contains('\$') || priceStr.contains('Contact for pricing')) {
        return priceStr;
      }

      // Try to parse as double and format
      final doubleValue = double.tryParse(priceStr);
      if (doubleValue != null) {
        return '\$${doubleValue.toStringAsFixed(2)}';
      }

      // If parsing fails, return the original string
      return priceStr;
    } catch (e) {
      if (kDebugMode) {
        dev.log('Error parsing price: $e', name: 'experiences_screen');
      }
      return '\$0';
    }
  }

  String? _parseRating(dynamic rating) {
    try {
      if (rating == null) return null;

      final ratingStr = rating.toString();

      // If it's already a string, return as is
      if (ratingStr.contains('.') || ratingStr.contains('stars')) {
        return ratingStr;
      }

      // Try to parse as double and format
      final doubleValue = double.tryParse(ratingStr);
      if (doubleValue != null) {
        return doubleValue.toStringAsFixed(1);
      }

      // If parsing fails, return the original string
      return ratingStr;
    } catch (e) {
      if (kDebugMode) {
        dev.log('Error parsing rating: $e', name: 'experiences_screen');
      }
      return null;
    }
  }
}
