import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExperienceCard extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String location;
  final String duration;
  final String price;
  final String? rating;
  final VoidCallback? onTap;

  const ExperienceCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.duration,
    required this.price,
    this.rating,
    this.onTap,
  });

  @override
  State<ExperienceCard> createState() => _ExperienceCardState();
}

class _ExperienceCardState extends State<ExperienceCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section - Fixed height like deals
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    widget.imageUrl,
                    width: double.infinity,
                    height: 140,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 140,
                        color: Colors.grey.shade200,
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey.shade400,
                          size: 48,
                        ),
                      );
                    },
                  ),
                ),
                // Rating badge overlay (experience perk)
                if (widget.rating != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 12,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            widget.rating!,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // Dash Separator - Like deals
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: CustomPaint(
                painter: DashPainter(),
                size: const Size(double.infinity, 1),
              ),
            ),

            // Content Section - Horizontal layout (experience perk)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Left side - Experience details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              color: Colors.grey.shade600,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.location,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 1),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_outlined,
                              color: Colors.grey.shade600,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.duration,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Right side - Price badge (experience perk)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      widget.price,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for subtle dash line - Like deals
class DashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    const dashWidth = 5.0;
    const dashSpace = 3.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Example usage component
class ExperienceCardExample extends StatelessWidget {
  const ExperienceCardExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Experience Card Example'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ExperienceCard(
            imageUrl:
                'https://images.unsplash.com/photo-1540979388789-6cee28a1cdc9?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
            title: 'Manhattan Helicopter Tour',
            location: 'New York, USA',
            duration: '30 minutes',
            price: '\$299',
            rating: '4.8',
            onTap: () {
              // Handle tap
            },
          ),
          const SizedBox(height: 16),
          ExperienceCard(
            imageUrl:
                'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTA1MDU3Nzd8&ixlib=rb-4.1.0&q=80&w=1080',
            title: 'Grand Canyon Scenic Flight',
            location: 'Arizona, USA',
            duration: '45 minutes',
            price: '\$399',
            rating: '4.9',
            onTap: () {
              // Handle tap
            },
          ),
          const SizedBox(height: 16),
          ExperienceCard(
            imageUrl:
                'https://images.unsplash.com/photo-1556388158-158ea5ccacbd?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTA1MDU3Nzd8&ixlib=rb-4.1.0&q=80&w=1080',
            title: 'Whistler Heli Skiing',
            location: 'British Columbia, Canada',
            duration: '4 hours',
            price: '\$899',
            rating: '4.7',
            onTap: () {
              // Handle tap
            },
          ),
        ],
      ),
    );
  }
}
