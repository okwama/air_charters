import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VirtualCard extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String points;
  final String walletBalance;
  final String loyaltyTier;
  final VoidCallback? onTap;

  const VirtualCard({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.points,
    required this.walletBalance,
    required this.loyaltyTier,
    this.onTap,
  });

  // Tier-based color schemes
  List<Color> _getTierColors() {
    switch (loyaltyTier.toLowerCase()) {
      case 'bronze':
        return [
          Color(0xFFCD7F32), // Bronze
          Color(0xFFB8860B), // Dark Goldenrod
          Color(0xFF8B4513), // Saddle Brown
        ];
      case 'silver':
        return [
          Color(0xFFC0C0C0), // Silver
          Color(0xFFA8A8A8), // Gray
          Color(0xFF808080), // Dark Gray
        ];
      case 'gold':
        return [
          Color(0xFFFFD700), // Gold
          Color(0xFFFFA500), // Orange
          Color(0xFFB8860B), // Dark Goldenrod
        ];
      case 'platinum':
        return [
          Color(0xFFE5E4E2), // Platinum
          Color(0xFFB8B8B8), // Light Gray
          Color(0xFF808080), // Medium Gray
        ];
      default:
        return [
          Color(0xFF1a1a1a), // Default dark
          Color(0xFF2d2d2d),
          Color(0xFF1a1a1a),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _getTierColors(),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // AirCharters Logo
            Positioned(
              right: 20,
              top: 20,
              child: Container(
                width: 60,
                height: 60,
                child: Image.asset(
                  'assets/images/login.png',
                  fit: BoxFit.contain,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ),

            // Card content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row - Logo and chip
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        loyaltyTier.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.9),
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Chip
                  Container(
                    width: 32,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.amber.shade600,
                      borderRadius: BorderRadius.circular(4),
                      gradient: LinearGradient(
                        colors: [
                          Colors.amber.shade300,
                          Colors.amber.shade600,
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Card number
                  Text(
                    '${firstName} ${lastName}',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Bottom row - Wallet Balance and Loyalty Points
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'WALLET BALANCE',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.7),
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            walletBalance,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'LOYALTY POINTS',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.7),
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            points,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
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
