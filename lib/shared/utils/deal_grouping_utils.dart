import '../../core/models/charter_deal_model.dart';

class DealGroupingUtils {
  /// Groups deals by route and aircraft to show as single cards
  static List<List<CharterDealModel>> groupDeals(List<CharterDealModel> deals) {
    final Map<String, List<CharterDealModel>> groupedDeals = {};

    for (final deal in deals) {
      // Create a unique key based on route and aircraft
      final key = _createGroupKey(deal);

      if (groupedDeals.containsKey(key)) {
        groupedDeals[key]!.add(deal);
      } else {
        groupedDeals[key] = [deal];
      }
    }

    // Convert to list and sort each group by time
    final List<List<CharterDealModel>> result = [];

    for (final group in groupedDeals.values) {
      // Sort deals within each group by time
      group.sort((a, b) => a.time.compareTo(b.time));
      result.add(group);
    }

    // Sort groups by the earliest time in each group
    result.sort((a, b) {
      if (a.isEmpty || b.isEmpty) return 0;
      return a.first.time.compareTo(b.first.time);
    });

    return result;
  }

  /// Creates a unique key for grouping deals
  static String _createGroupKey(CharterDealModel deal) {
    final route = '${deal.origin ?? ''}-${deal.destination ?? ''}';
    final aircraft = '${deal.aircraftId}-${deal.aircraftType ?? ''}';
    final date = deal.date.toIso8601String().split('T')[0]; // Date only

    return '$route|$aircraft|$date';
  }

  /// Checks if deals should be grouped (same route, aircraft, and date)
  static bool shouldGroupDeals(CharterDealModel deal1, CharterDealModel deal2) {
    return _createGroupKey(deal1) == _createGroupKey(deal2);
  }

  /// Gets the display name for a group of deals
  static String getGroupDisplayName(List<CharterDealModel> deals) {
    if (deals.isEmpty) return '';

    final firstDeal = deals.first;
    return firstDeal.routeDisplay;
  }

  /// Gets the aircraft info for a group of deals
  static String getGroupAircraftInfo(List<CharterDealModel> deals) {
    if (deals.isEmpty) return '';

    final firstDeal = deals.first;
    final aircraftName = firstDeal.aircraftName ?? 'Aircraft';
    final aircraftType = firstDeal.aircraftType ?? 'Type';

    return '$aircraftName • $aircraftType';
  }

  /// Gets the price range for a group of deals
  static String getGroupPriceRange(List<CharterDealModel> deals) {
    if (deals.isEmpty) return 'Contact for pricing';

    double lowest = double.infinity;
    double highest = 0;

    for (final deal in deals) {
      final price = deal.pricePerSeat ?? deal.pricePerHour ?? 0;
      if (price > 0) {
        if (price < lowest) lowest = price;
        if (price > highest) highest = price;
      }
    }

    if (lowest == double.infinity) return 'Contact for pricing';
    if (lowest == highest) return '\$${lowest.toStringAsFixed(0)}';

    return '\$${lowest.toStringAsFixed(0)} - \$${highest.toStringAsFixed(0)}';
  }

  /// Gets the best image for a group of deals
  static String getGroupImageUrl(List<CharterDealModel> deals) {
    if (deals.isEmpty) return '';

    // Try to get the first deal with aircraft images
    for (final deal in deals) {
      if (deal.aircraftImages.isNotEmpty) {
        return deal.aircraftImages.first;
      }
    }

    // Fallback to route image
    for (final deal in deals) {
      if (deal.routeImages.isNotEmpty) {
        return deal.routeImages.first;
      }
    }

    // Final fallback to route image URL
    for (final deal in deals) {
      if (deal.routeImageUrl != null && deal.routeImageUrl!.isNotEmpty) {
        return deal.routeImageUrl!;
      }
    }

    return '';
  }
}
