import 'package:flutter/material.dart';
import '../models/deals_filter_options.dart';

class FilterChipsWidget extends StatelessWidget {
  final DealsFilterOptions filters;
  final Function(DealsFilterOptions) onFilterRemoved;
  final VoidCallback onClearAll;

  const FilterChipsWidget({
    super.key,
    required this.filters,
    required this.onFilterRemoved,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    if (!filters.hasActiveFilters) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          ..._buildFilterChips(),
          if (filters.hasActiveFilters) _buildClearAllChip(),
        ],
      ),
    );
  }

  List<Widget> _buildFilterChips() {
    final chips = <Widget>[];

    // Search filter
    if (filters.searchQuery.isNotEmpty) {
      chips.add(_buildFilterChip(
        label: 'Search: ${filters.searchQuery}',
        onRemove: () => _removeFilter(
          filters.copyWith(searchQuery: ''),
        ),
      ));
    }

    // Origin filter
    if (filters.origin.isNotEmpty) {
      chips.add(_buildFilterChip(
        label: 'From: ${filters.origin}',
        onRemove: () => _removeFilter(
          filters.copyWith(origin: ''),
        ),
      ));
    }

    // Destination filter
    if (filters.destination.isNotEmpty) {
      chips.add(_buildFilterChip(
        label: 'To: ${filters.destination}',
        onRemove: () => _removeFilter(
          filters.copyWith(destination: ''),
        ),
      ));
    }

    // Date filters
    if (filters.fromDate != null) {
      chips.add(_buildFilterChip(
        label: 'From: ${_formatDate(filters.fromDate!)}',
        onRemove: () => _removeFilter(
          filters.copyWith(fromDate: null),
        ),
      ));
    }

    if (filters.toDate != null) {
      chips.add(_buildFilterChip(
        label: 'To: ${_formatDate(filters.toDate!)}',
        onRemove: () => _removeFilter(
          filters.copyWith(toDate: null),
        ),
      ));
    }

    // Aircraft type filter
    if (filters.aircraftTypeId != null) {
      chips.add(_buildFilterChip(
        label: 'Aircraft: ${_getAircraftTypeName(filters.aircraftTypeId!)}',
        onRemove: () => _removeFilter(
          filters.copyWith(aircraftTypeId: null),
        ),
      ));
    }

    // Price filter
    if (filters.minPrice > 0 || filters.maxPrice < 10000) {
      chips.add(_buildFilterChip(
        label: 'Price: \$${filters.minPrice} - \$${filters.maxPrice}',
        onRemove: () => _removeFilter(
          filters.copyWith(minPrice: 0, maxPrice: 10000),
        ),
      ));
    }

    // Discounts only filter
    if (filters.discountsOnly) {
      chips.add(_buildFilterChip(
        label: 'Discounted Only',
        onRemove: () => _removeFilter(
          filters.copyWith(discountsOnly: false),
        ),
      ));
    }

    return chips;
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onRemove,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
        deleteIcon: const Icon(Icons.close, size: 16),
        onDeleted: onRemove,
        backgroundColor: Colors.blue.shade50,
        side: BorderSide(color: Colors.blue.shade200),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _buildClearAllChip() {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Chip(
        label: const Text(
          'Clear All',
          style: TextStyle(fontSize: 12, color: Colors.red),
        ),
        deleteIcon: const Icon(Icons.clear_all, size: 16, color: Colors.red),
        onDeleted: onClearAll,
        backgroundColor: Colors.red.shade50,
        side: BorderSide(color: Colors.red.shade200),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  void _removeFilter(DealsFilterOptions newFilters) {
    onFilterRemoved(newFilters);
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
}
