import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../config/theme/app_theme.dart';
import '../../core/providers/navigation_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../cargo/cargo_screen.dart';
import '../experiences/experiences_screen.dart';
import '../deals/deals_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _setupAnimations();
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

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          // Full screen background SVG
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            bottom: 0,
            child: Opacity(
              opacity: 0.15,
              child: SvgPicture.asset(
                'assets/icons/world.svg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeSection(),
                      const SizedBox(height: 60),
                      _buildServicesIcons(),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final userName = authProvider.currentUser?.firstName ?? 'User';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back,',
              style: AppTheme.bodyLarge.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              userName,
              style: AppTheme.heading2.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'What would you like to do today?',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildServicesIcons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Services',
          style: AppTheme.heading3.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildServiceIcon(
              icon: LucideIcons.ticket,
              title: 'Deals',
              onTap: () => _navigateToDeals(),
            ),
            _buildServiceIcon(
              icon: LucideIcons.planeTakeoff,
              title: 'Direct Charter',
              onTap: () => _navigateToDirectCharter(),
            ),
            _buildServiceIcon(
              icon: LucideIcons.camera,
              title: 'Experiences',
              onTap: () => _navigateToExperiences(),
            ),
            _buildServiceIcon(
              icon: LucideIcons.package,
              title: 'Cargo',
              onTap: () => _navigateToCargo(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServiceIcon({
    required IconData icon,
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
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: AppTheme.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
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
    final navigationProvider =
        Provider.of<NavigationProvider>(context, listen: false);
    navigationProvider.setCurrentIndex(2); // Switch to direct charter tab
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
}
