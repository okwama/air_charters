import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _logoController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _logoScaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _logoScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _logoController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    final isVerySmallScreen = screenHeight < 600;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image with Overlay
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(
                  'https://ik.imagekit.io/bja2qwwdjjy/qr_YTtuZ9loi.png?updatedAt=1755500192573',
                ),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.5),
                    Colors.black.withValues(alpha: 0.85),
                  ],
                ),
              ),
            ),
          ),

          // Glassmorphism overlay for better text readability
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.1),
                  ],
                ),
              ),
            ),
          ),

          // Content
          FadeTransition(
            opacity: _fadeAnimation,
            child: SafeArea(
              child: Column(
                children: [
                  // Top Section with Logo and Tagline
                  Expanded(
                    flex: 4,
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SlideTransition(
                            position: _slideAnimation,
                            child: ScaleTransition(
                              scale: _logoScaleAnimation,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Simple text logo
                                  Text(
                                    'AirCharters',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      fontSize: isVerySmallScreen
                                          ? 32
                                          : (isSmallScreen ? 36 : 44),
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: -1.2,
                                      height: 1.0,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.3),
                                          offset: const Offset(0, 4),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(
                                      height: isVerySmallScreen
                                          ? 8
                                          : (isSmallScreen ? 12 : 20)),

                                  // Tagline with better typography
                                  Text(
                                    'Charter Beyond Borders',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      fontSize: isVerySmallScreen
                                          ? 11
                                          : (isSmallScreen ? 13 : 15),
                                      fontWeight: FontWeight.w400,
                                      color:
                                          Colors.white.withValues(alpha: 0.9),
                                      letterSpacing: 1.5,
                                      height: 1.3,
                                    ),
                                  ),

                                  SizedBox(
                                      height: isVerySmallScreen
                                          ? 12
                                          : (isSmallScreen ? 16 : 24)),

                                  // Enhanced feature highlights
                                  Wrap(
                                    spacing: isVerySmallScreen
                                        ? 4
                                        : (isSmallScreen ? 6 : 10),
                                    runSpacing: isVerySmallScreen
                                        ? 3
                                        : (isSmallScreen ? 4 : 6),
                                    alignment: WrapAlignment.center,
                                    children: [
                                      _buildFeatureChip(
                                          'Private Jets', Icons.flight_class),
                                      _buildFeatureChip(
                                          'Global Access', Icons.public),
                                      _buildFeatureChip(
                                          'Instant Booking', Icons.bolt),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Section with CTA
                  Expanded(
                    flex: 1,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical:
                              isVerySmallScreen ? 4 : (isSmallScreen ? 8 : 12)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 1),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: _slideController,
                              curve: const Interval(0.3, 1.0,
                                  curve: Curves.easeOutCubic),
                            )),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Enhanced CTA Button
                                Container(
                                  width: double.infinity,
                                  height: isVerySmallScreen
                                      ? 40
                                      : (isSmallScreen ? 44 : 48),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Colors.white,
                                        Color(0xFFF8F9FA),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.15),
                                        blurRadius: 25,
                                        offset: const Offset(0, 10),
                                        spreadRadius: -2,
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap: () async {
                                        // Mark landing page as seen for this user
                                        final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                        await authProvider.markLandingAsSeen();
                                        
                                        Navigator.of(context)
                                            .pushReplacementNamed('/login');
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Get Started',
                                              style: GoogleFonts.inter(
                                                fontSize: isVerySmallScreen
                                                    ? 13
                                                    : (isSmallScreen ? 14 : 15),
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black,
                                                letterSpacing: 0.2,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.all(3),
                                              decoration: BoxDecoration(
                                                color: Colors.black,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: const Icon(
                                                Icons.arrow_forward_rounded,
                                                color: Colors.white,
                                                size: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(
                                    height: isVerySmallScreen
                                        ? 4
                                        : (isSmallScreen ? 6 : 8)),

                                // Secondary text with better hierarchy
                                Text(
                                  'Book your private charter in minutes',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: isVerySmallScreen
                                        ? 10
                                        : (isSmallScreen ? 11 : 12),
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white.withValues(alpha: 0.75),
                                    letterSpacing: 0.2,
                                  ),
                                ),

                                const SizedBox(height: 2),

                                // Trust indicator
                                Text(
                                  '✓ Secure & Trusted',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withValues(alpha: 0.6),
                                    letterSpacing: 0.5,
                                  ),
                                ),

                                const SizedBox(height: 4),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 10,
            color: Colors.white.withValues(alpha: 0.9),
          ),
          const SizedBox(width: 3),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.9),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
