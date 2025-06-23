import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:air_charters/shared/components/experience_card.dart';
import 'package:air_charters/features/experiences/tour_list.dart';
import 'package:air_charters/features/experiences/tour_detail.dart';

class ExperienceToursScreen extends StatefulWidget {
  const ExperienceToursScreen({Key? key}) : super(key: key);

  @override
  State<ExperienceToursScreen> createState() => _ExperienceToursScreenState();
}

class _ExperienceToursScreenState extends State<ExperienceToursScreen> {
  final List<Map<String, dynamic>> _tourCategories = [
    {
      'title': 'Aerial Sightseeing Tours',
      'deals': [
        {
          'imageUrl':
              'https://images.unsplash.com/photo-1540979388789-6cee28a1cdc9?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
          'title': 'Manhattan Helicopter Tour',
          'location': 'New York, USA',
          'duration': '30 minutes',
          'price': '\$299',
          'rating': '4.8',
        },
        {
          'imageUrl':
              'https://images.unsplash.com/photo-1544551763-46a013bb70d5?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
          'title': 'Grand Canyon Scenic Flight',
          'location': 'Arizona, USA',
          'duration': '45 minutes',
          'price': '\$449',
          'rating': '4.9',
        },
      ],
    },
    {
      'title': 'Heli Skiing',
      'deals': [
        {
          'imageUrl':
              'https://images.unsplash.com/photo-1578662996442-48f60103fc96?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
          'title': 'Whistler Heli Skiing',
          'location': 'Whistler, Canada',
          'duration': 'Full Day',
          'price': '\$899',
          'rating': '4.9',
        },
        {
          'imageUrl':
              'https://images.unsplash.com/photo-1578662996442-48f60103fc96?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
          'title': 'Alps Heli Skiing Adventure',
          'location': 'Swiss Alps',
          'duration': 'Multi-Day',
          'price': '\$1,299',
          'rating': '5.0',
        },
      ],
    },
    {
      'title': 'Fishing',
      'deals': [
        {
          'imageUrl':
              'https://images.unsplash.com/photo-1544551763-77ef2d0cfc6c?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
          'title': 'Alaska Fly-In Fishing',
          'location': 'Alaska, USA',
          'duration': 'Full Day',
          'price': '\$599',
          'rating': '4.7',
        },
        {
          'imageUrl':
              'https://images.unsplash.com/photo-1559827260-dc66d52bef19?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
          'title': 'Patagonia Fishing Charter',
          'location': 'Patagonia, Chile',
          'duration': 'Multi-Day',
          'price': '\$799',
          'rating': '4.8',
        },
      ],
    },
    {
      'title': 'Fly and Dine',
      'deals': [
        {
          'imageUrl':
              'https://images.unsplash.com/photo-1551218808-94e220e084d2?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
          'title': 'Napa Valley Wine Tour',
          'location': 'Napa Valley, USA',
          'duration': 'Half Day',
          'price': '\$699',
          'rating': '4.9',
        },
        {
          'imageUrl':
              'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
          'title': 'Michelin Star Restaurant Tour',
          'location': 'Paris, France',
          'duration': 'Evening',
          'price': '\$999',
          'rating': '5.0',
        },
      ],
    },
    {
      'title': 'Skydiving',
      'deals': [
        {
          'imageUrl':
              'https://images.unsplash.com/photo-1540979388789-6cee28a1cdc9?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
          'title': 'Tandem Skydiving Experience',
          'location': 'Various Locations',
          'duration': '2-3 hours',
          'price': '\$349',
          'rating': '4.8',
        },
        {
          'imageUrl':
              'https://images.unsplash.com/photo-1578662996442-48f60103fc96?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
          'title': 'Solo Skydiving Course',
          'location': 'Training Centers',
          'duration': 'Multi-Day',
          'price': '\$1,499',
          'rating': '4.9',
        },
      ],
    },
    {
      'title': 'Hiking',
      'deals': [
        {
          'imageUrl':
              'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
          'title': 'Remote Mountain Hiking',
          'location': 'Rocky Mountains',
          'duration': 'Full Day',
          'price': '\$399',
          'rating': '4.6',
        },
        {
          'imageUrl':
              'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
          'title': 'Patagonia Trek Adventure',
          'location': 'Patagonia, Argentina',
          'duration': 'Multi-Day',
          'price': '\$899',
          'rating': '4.9',
        },
      ],
    },
    {
      'title': 'Surfing',
      'deals': [
        {
          'imageUrl':
              'https://images.unsplash.com/photo-1544551763-46a013bb70d5?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
          'title': 'Maldives Surf Charter',
          'location': 'Maldives',
          'duration': 'Multi-Day',
          'price': '\$1,199',
          'rating': '4.9',
        },
        {
          'imageUrl':
              'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
          'title': 'Costa Rica Surf Adventure',
          'location': 'Costa Rica',
          'duration': 'Week',
          'price': '\$799',
          'rating': '4.7',
        },
      ],
    },
    {
      'title': 'Romantic',
      'deals': [
        {
          'imageUrl':
              'https://images.unsplash.com/photo-1551218808-94e220e084d2?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
          'title': 'Sunset Helicopter Tour',
          'location': 'Various Cities',
          'duration': '1 hour',
          'price': '\$599',
          'rating': '4.9',
        },
        {
          'imageUrl':
              'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
          'title': 'Private Island Getaway',
          'location': 'Exotic Islands',
          'duration': 'Weekend',
          'price': '\$1,999',
          'rating': '5.0',
        },
      ],
    },
    {
      'title': 'Seasonal',
      'deals': [
        {
          'imageUrl':
              'https://images.unsplash.com/photo-1540979388789-6cee28a1cdc9?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
          'title': 'Northern Lights Tour',
          'location': 'Iceland',
          'duration': 'Evening',
          'price': '\$899',
          'rating': '4.8',
        },
        {
          'imageUrl':
              'https://images.unsplash.com/photo-1544551763-77ef2d0cfc6c?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
          'title': 'Cherry Blossom Flight',
          'location': 'Japan',
          'duration': 'Half Day',
          'price': '\$549',
          'rating': '4.7',
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
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
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Tour Categories
            ..._tourCategories
                .map((category) => _buildTourCategorySection(
                      category['title'],
                      category['deals'],
                    ))
                .toList(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTourCategorySection(
      String title, List<Map<String, dynamic>> deals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header with See All button
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
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
              GestureDetector(
                onTap: () => _navigateToTourList(title, deals),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'See All',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Horizontal scrolling cards
        LayoutBuilder(
          builder: (context, constraints) {
            // Use a more conservative height calculation to prevent overflow
            final cardHeight = (constraints.maxWidth * 0.6).clamp(280.0, 320.0);
            return SizedBox(
              height: cardHeight,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 16),
                itemCount: deals.length,
                itemBuilder: (context, index) {
                  final deal = deals[index];
                  return Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    margin: const EdgeInsets.only(right: 16),
                    child: ExperienceCard(
                      imageUrl: deal['imageUrl'],
                      title: deal['title'],
                      location: deal['location'],
                      duration: deal['duration'],
                      price: deal['price'],
                      rating: deal['rating'],
                      onTap: () => _showDealDetail(deal),
                    ),
                  );
                },
              ),
            );
          },
        ),

        const SizedBox(height: 8),
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
          description: _getDescriptionForTour(deal['title']),
        ),
      ),
    );
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
}
