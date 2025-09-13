import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../core/providers/navigation_provider.dart';

class BottomNav extends StatelessWidget {
  final List<CharterBottomNavItem>? customItems;

  const BottomNav({
    super.key,
    this.customItems,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) {
        final items = customItems ?? _defaultItems;
        final currentIndex = navigationProvider.currentIndex;

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
            onTap: (index) =>
                _handleNavigation(context, index, navigationProvider),
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
      },
    );
  }

  void _handleNavigation(
      BuildContext context, int index, NavigationProvider navigationProvider) {
    if (kDebugMode) {
      print(
          'BottomNav: Navigation requested to index $index (current: ${navigationProvider.currentIndex})');
    }

    // Don't navigate if already on the selected tab
    if (navigationProvider.currentIndex == index) {
      if (kDebugMode) {
        print('BottomNav: Already on tab $index, ignoring navigation');
      }
      return;
    }

    // Validate index bounds
    if (index < 0 || index >= _defaultItems.length) {
      if (kDebugMode) {
        print('BottomNav: Invalid index $index, ignoring navigation');
      }
      return;
    }

    // Simply update the navigation provider index
    // The MainNavigationScreen will handle the tab switching
    navigationProvider.setCurrentIndex(index);

    if (kDebugMode) {
      print('BottomNav: Navigation completed to index $index');
    }
  }

  static final List<CharterBottomNavItem> _defaultItems = [
    CharterBottomNavItem(
      icon: LucideIcons.home,
      activeIcon: LucideIcons.home,
      label: 'Home',
    ),
    CharterBottomNavItem(
      icon: LucideIcons.globe,
      activeIcon: LucideIcons.compass,
      label: 'Explore',
    ),
    CharterBottomNavItem(
      icon: LucideIcons.plane,
      activeIcon: LucideIcons.planeTakeoff,
      label: 'Direct Charter',
    ),
    CharterBottomNavItem(
      icon: LucideIcons.briefcase,
      activeIcon: LucideIcons.briefcase,
      label: 'Trips',
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
