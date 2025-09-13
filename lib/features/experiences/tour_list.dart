import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:air_charters/shared/components/experience_card.dart';
import 'package:air_charters/features/experiences/tour_detail.dart';
import 'package:air_charters/core/services/experiences_service.dart';
import 'package:air_charters/core/network/api_client.dart';

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.category,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Explore ${widget.deals.length} ${widget.category.toLowerCase()} experiences',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),

            // List of all deals
            ...widget.deals.map((deal) => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ExperienceCard(
                    imageUrl: deal['imageUrl'],
                    title: deal['title'],
                    location: deal['location'],
                    duration: deal['duration'],
                    price: deal['price'],
                    rating: deal['rating'],
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
              imageUrl: deal['imageUrl'],
              title: deal['title'],
              location: deal['location'],
              duration: deal['duration'],
              price: deal['price'],
              rating: deal['rating'],
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
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
