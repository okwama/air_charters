import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final List<CharterBottomNavItem>? customItems;

  const BottomNav({
    super.key,
    this.currentIndex = 0,
    this.onTap,
    this.customItems,
  });

  @override
  Widget build(BuildContext context) {
    final items = customItems ?? _defaultItems;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade100, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey.shade500,
        currentIndex: currentIndex,
        onTap: onTap ?? (index) => _handleNavigation(context, index),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        items: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isSelected = currentIndex == index;

          return BottomNavigationBarItem(
            icon: Icon(
                isSelected && item.activeIcon != null
                    ? item.activeIcon
                    : item.icon,
                size: 24),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    // Don't navigate if already on the selected tab
    if (currentIndex == index) return;

    switch (index) {
      case 0: // Explore
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/home', (route) => false);
        break;
      case 1: // Trips
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/trips', (route) => false);
        break;
      case 2: // Contact
        // Navigate to contact screen (placeholder)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contact feature coming soon!')),
        );
        break;
      case 3: // Settings
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/settings', (route) => false);
        break;
    }
  }

  static final List<CharterBottomNavItem> _defaultItems = [
    CharterBottomNavItem(
      icon: LucideIcons.globe,
      activeIcon: LucideIcons.compass,
      label: 'Explore',
    ),
    CharterBottomNavItem(
      icon: LucideIcons.planeTakeoff,
      activeIcon: LucideIcons.planeLanding,
      label: 'Trips',
    ),
    CharterBottomNavItem(
      icon: LucideIcons.headphones,
      activeIcon: LucideIcons.messageSquare,
      label: 'Contact',
    ),
    CharterBottomNavItem(
      icon: LucideIcons.settings,
      activeIcon: LucideIcons.settings2,
      label: 'Settings',
    ),
  ];
}

class CharterBottomNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;

  const CharterBottomNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
  });
}

// Predefined navigation item sets for different app sections
class CharterBottomNavPresets {
  static final List<CharterBottomNavItem> main = [
    CharterBottomNavItem(
      icon: LucideIcons.globe,
      activeIcon: LucideIcons.compass,
      label: 'Explore',
    ),
    CharterBottomNavItem(
      icon: LucideIcons.planeTakeoff,
      activeIcon: LucideIcons.planeLanding,
      label: 'Trips',
    ),
    CharterBottomNavItem(
      icon: LucideIcons.headphones,
      activeIcon: LucideIcons.messageSquare,
      label: 'Contact',
    ),
    CharterBottomNavItem(
      icon: LucideIcons.sliders,
      activeIcon: LucideIcons.settings2,
      label: 'Settings',
    ),
  ];

  static final List<CharterBottomNavItem> booking = [
    CharterBottomNavItem(
      icon: LucideIcons.search,
      activeIcon: LucideIcons.searchCheck,
      label: 'Search',
    ),
    CharterBottomNavItem(
      icon: LucideIcons.calendar,
      activeIcon: LucideIcons.calendarCheck,
      label: 'Schedule',
    ),
    CharterBottomNavItem(
      icon: LucideIcons.mapPin,
      activeIcon: LucideIcons.map,
      label: 'Routes',
    ),
    CharterBottomNavItem(
      icon: LucideIcons.userCircle,
      activeIcon: LucideIcons.userCheck,
      label: 'Profile',
    ),
  ];

  static final List<CharterBottomNavItem> admin = [
    CharterBottomNavItem(
      icon: LucideIcons.layoutDashboard,
      activeIcon: LucideIcons.pieChart,
      label: 'Dashboard',
    ),
    CharterBottomNavItem(
      icon: LucideIcons.users,
      activeIcon: LucideIcons.userCheck2,
      label: 'Clients',
    ),
    CharterBottomNavItem(
      icon: LucideIcons.plane,
      activeIcon: LucideIcons.planeTakeoff,
      label: 'Fleet',
    ),
    CharterBottomNavItem(
      icon: LucideIcons.barChart3,
      activeIcon: LucideIcons.trendingUp,
      label: 'Analytics',
    ),
  ];

  static final List<CharterBottomNavItem> travel = [
    CharterBottomNavItem(
      icon: LucideIcons.home,
      activeIcon: LucideIcons.building,
      label: 'Home',
    ),
    CharterBottomNavItem(
      icon: LucideIcons.luggage,
      activeIcon: LucideIcons.luggage,
      label: 'Bookings',
    ),
    CharterBottomNavItem(
      icon: LucideIcons.heart,
      activeIcon: LucideIcons.bookmark,
      label: 'Favorites',
    ),
    CharterBottomNavItem(
      icon: LucideIcons.user,
      activeIcon: LucideIcons.userCircle2,
      label: 'Account',
    ),
  ];

  static final List<CharterBottomNavItem> premium = [
    CharterBottomNavItem(
      icon: LucideIcons.sparkles,
      activeIcon: LucideIcons.crown,
      label: 'Premium',
    ),
    CharterBottomNavItem(
      icon: LucideIcons.rocket,
      activeIcon: LucideIcons.zap,
      label: 'Quick Book',
    ),
    CharterBottomNavItem(
      icon: LucideIcons.star,
      activeIcon: LucideIcons.award,
      label: 'VIP',
    ),
    CharterBottomNavItem(
      icon: LucideIcons.shield,
      activeIcon: LucideIcons.shieldCheck,
      label: 'Security',
    ),
  ];
}
