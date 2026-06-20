import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:air_charters/shared/components/experience_card.dart';
import 'package:air_charters/features/experiences/tour_detail.dart';
import 'package:air_charters/core/services/experiences_service.dart';
import 'package:air_charters/core/network/api_client.dart';
import 'package:air_charters/config/theme/app_theme.dart';

class TourListScreen extends StatefulWidget {
  final String category;
  final List<Map<String, dynamic>> deals;

  const TourListScreen({
    super.key,
    required this.category,
    required this.deals,
  });

  @override
  State<TourListScreen> createState() => _TourListScreenState();
}

class _TourListScreenState extends State<TourListScreen> {
  late ExperiencesService _experiencesService;

  @override
  void initState() {
    super.initState();
    _experiencesService = ExperiencesService(ApiClient());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textPrimaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.category,
          style: AppTheme.heading3,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Explore ${widget.deals.length} ${widget.category.toLowerCase()} experiences',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 20),

            // List of all deals
            ...widget.deals.map((deal) => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ExperienceCard(
                    imageUrl: deal['imageUrl']?.toString() ?? '',
                    title: deal['title']?.toString() ?? '',
                    location: deal['location']?.toString() ?? '',
                    duration: deal['duration']?.toString() ?? '',
                    price: _formatPrice(deal['price']),
                    rating: _formatRating(deal['rating']),
                    onTap: () => _showDealDetail(context, deal),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  void _showDealDetail(BuildContext context, Map<String, dynamic> deal) async {
    try {
      final experienceId = deal['id'] as int;
      final experienceDetails =
          await _experiencesService.getExperienceDetails(experienceId);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TourDetailPage(
              imageUrl: deal['imageUrl']?.toString() ?? '',
              title: deal['title']?.toString() ?? '',
              location: deal['location']?.toString() ?? '',
              duration: deal['duration']?.toString() ?? '',
              price: _formatPrice(deal['price']),
              rating: _formatRating(deal['rating']),
              description: experienceDetails['description'] ??
                  'Experience details coming soon...',
              experienceId: deal['id'],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load experience details: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '\$0.00';
    if (price is String) return price.startsWith('\$') ? price : '\$$price';
    if (price is num) return '\$${price.toStringAsFixed(2)}';
    return '\$${price.toString()}';
  }

  String? _formatRating(dynamic rating) {
    if (rating == null) return null;
    if (rating is String) return rating;
    if (rating is num) return rating.toStringAsFixed(1);
    return rating.toString();
  }
}
