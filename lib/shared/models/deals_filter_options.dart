class DealsFilterOptions {
  final String searchQuery;
  final String origin;
  final String destination;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int? aircraftTypeId;
  final int minPrice;
  final int maxPrice;
  final bool groupBy;
  final bool discountsOnly;

  const DealsFilterOptions({
    this.searchQuery = '',
    this.origin = '',
    this.destination = '',
    this.fromDate,
    this.toDate,
    this.aircraftTypeId,
    this.minPrice = 0,
    this.maxPrice = 10000,
    this.groupBy = true,
    this.discountsOnly = false,
  });

  DealsFilterOptions copyWith({
    String? searchQuery,
    String? origin,
    String? destination,
    DateTime? fromDate,
    DateTime? toDate,
    int? aircraftTypeId,
    int? minPrice,
    int? maxPrice,
    bool? groupBy,
    bool? discountsOnly,
  }) {
    return DealsFilterOptions(
      searchQuery: searchQuery ?? this.searchQuery,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      aircraftTypeId: aircraftTypeId ?? this.aircraftTypeId,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      groupBy: groupBy ?? this.groupBy,
      discountsOnly: discountsOnly ?? this.discountsOnly,
    );
  }

  bool get hasActiveFilters {
    return searchQuery.isNotEmpty ||
        origin.isNotEmpty ||
        destination.isNotEmpty ||
        fromDate != null ||
        toDate != null ||
        aircraftTypeId != null ||
        minPrice > 0 ||
        maxPrice < 10000 ||
        discountsOnly;
  }

  String get filterSummary {
    final filters = <String>[];

    if (searchQuery.isNotEmpty) filters.add('Search: $searchQuery');
    if (origin.isNotEmpty) filters.add('From: $origin');
    if (destination.isNotEmpty) filters.add('To: $destination');
    if (fromDate != null) filters.add('From: ${_formatDate(fromDate!)}');
    if (toDate != null) filters.add('To: ${_formatDate(toDate!)}');
    if (aircraftTypeId != null) {
      filters.add('Aircraft: ${_getAircraftTypeName(aircraftTypeId!)}');
    }
    if (minPrice > 0 || maxPrice < 10000) {
      filters.add('Price: \$$minPrice - \$$maxPrice');
    }
    if (discountsOnly) filters.add('Discounted Only');

    return filters.join(', ');
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getAircraftTypeName(int id) {
    switch (id) {
      case 1:
        return 'Private Jet';
      case 2:
        return 'Commercial Jet';
      case 3:
        return 'Helicopter';
      case 4:
        return 'Turboprop';
      default:
        return 'Aircraft Type $id';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DealsFilterOptions &&
        other.searchQuery == searchQuery &&
        other.origin == origin &&
        other.destination == destination &&
        other.fromDate == fromDate &&
        other.toDate == toDate &&
        other.aircraftTypeId == aircraftTypeId &&
        other.minPrice == minPrice &&
        other.maxPrice == maxPrice &&
        other.groupBy == groupBy &&
        other.discountsOnly == discountsOnly;
  }

  @override
  int get hashCode {
    return Object.hash(
      searchQuery,
      origin,
      destination,
      fromDate,
      toDate,
      aircraftTypeId,
      minPrice,
      maxPrice,
      groupBy,
      discountsOnly,
    );
  }

  @override
  String toString() {
    return 'DealsFilterOptions('
        'searchQuery: $searchQuery, '
        'origin: $origin, '
        'destination: $destination, '
        'fromDate: $fromDate, '
        'toDate: $toDate, '
        'aircraftTypeId: $aircraftTypeId, '
        'minPrice: $minPrice, '
        'maxPrice: $maxPrice, '
        'groupBy: $groupBy, '
        'discountsOnly: $discountsOnly)';
  }
}
