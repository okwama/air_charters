import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:air_charters/shared/components/experience_card.dart';

class TourListScreen extends StatelessWidget {
  final String category;
  final List<Map<String, dynamic>> deals;

  const TourListScreen({
    super.key,
    required this.category,
    required this.deals,
  });

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
          category,
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
              'Explore ${deals.length} ${category.toLowerCase()} experiences',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),

            // List of all deals
            ...deals
                .map((deal) => Container(
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
                    ))
                ,
          ],
        ),
      ),
    );
  }

  void _showDealDetail(BuildContext context, Map<String, dynamic> deal) {
    // TODO: Navigate to deal detail page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Selected: ${deal['title']}',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
