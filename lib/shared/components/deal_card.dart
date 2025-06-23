import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DealCard extends StatelessWidget {
  final String imageUrl;
  final String route;
  final String date;
  final String flightsAvailable;
  final String price;
  final VoidCallback? onTap;

  const DealCard({
    super.key,
    required this.imageUrl,
    required this.route,
    required this.date,
    required this.flightsAvailable,
    required this.price,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: 160,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 160,
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

            // Subtle Dash Separator
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: CustomPaint(
                painter: DashPainter(),
                size: const Size(double.infinity, 1),
              ),
            ),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left side - Route and details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          route,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          date,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          flightsAvailable,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Right side - Price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Starting from',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        price,
                        style: GoogleFonts.interTight(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                    ],
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

// Custom painter for subtle dash line
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
class DealCardExample extends StatelessWidget {
  const DealCardExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        DealCard(
          imageUrl:
              'https://images.unsplash.com/photo-1543903905-cee4ab46985c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTA1MDU3Nzd8&ixlib=rb-4.1.0&q=80&w=1080',
          route: 'New York to Paris',
          date: 'Departing March 15, 2024',
          flightsAvailable: '12 flights available',
          price: '\$489.00',
          onTap: () => print('Deal card tapped'),
        ),
        DealCard(
          imageUrl:
              'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTA1MDU3Nzd8&ixlib=rb-4.1.0&q=80&w=1080',
          route: 'London to Tokyo',
          date: 'Departing April 10, 2024',
          flightsAvailable: '8 flights available',
          price: '\$1,299.00',
          onTap: () => print('Deal card tapped'),
        ),
        DealCard(
          imageUrl:
              'https://images.unsplash.com/photo-1556388158-158ea5ccacbd?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTA1MDU3Nzd8&ixlib=rb-4.1.0&q=80&w=1080',
          route: 'Sydney to Singapore',
          date: 'Departing May 5, 2024',
          flightsAvailable: '15 flights available',
          price: '\$899.00',
          onTap: () => print('Deal card tapped'),
        ),
      ],
    );
  }
}
