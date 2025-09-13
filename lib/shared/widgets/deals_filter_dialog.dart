import 'package:air_charters/shared/models/deals_filter_options.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DealsFilterDialog extends StatefulWidget {
  final DealsFilterOptions initialFilters;
  final Function(DealsFilterOptions) onApplyFilters;
  final VoidCallback onClearAll;

  const DealsFilterDialog({
    super.key,
    required this.initialFilters,
    required this.onApplyFilters,
    required this.onClearAll,
  });

  @override
  State<DealsFilterDialog> createState() => _DealsFilterDialogState();
}

class _DealsFilterDialogState extends State<DealsFilterDialog> {
  late DealsFilterOptions _filters;
  final _searchController = TextEditingController();
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters.copyWith();
    _searchController.text = _filters.searchQuery;
    _originController.text = _filters.origin;
    _destinationController.text = _filters.destination;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            _buildHandle(),
            _buildHeader(),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildSearchSection(),
                  const SizedBox(height: 24),
                  _buildLocationSection(),
                  const SizedBox(height: 24),
                  _buildDateSection(),
                  const SizedBox(height: 24),
                  _buildAircraftTypeSection(),
                  const SizedBox(height: 24),
                  _buildPriceSection(),
                  const SizedBox(height: 24),
                  _buildDisplayOptionsSection(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Text(
            'Filter Deals',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              setState(() {
                _filters = DealsFilterOptions();
                _searchController.clear();
                _originController.clear();
                _destinationController.clear();
              });
              widget.onClearAll();
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return _FilterSection(
      title: 'Search',
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search deals, routes, or companies...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: (value) => _filters = _filters.copyWith(searchQuery: value),
      ),
    );
  }

  Widget _buildLocationSection() {
    return _FilterSection(
      title: 'Location',
      child: Column(
        children: [
          TextField(
            controller: _originController,
            decoration: InputDecoration(
              hintText: 'From (e.g., Wilson Airport)',
              prefixIcon: const Icon(Icons.flight_takeoff),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) => _filters = _filters.copyWith(origin: value),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _destinationController,
            decoration: InputDecoration(
              hintText: 'To (e.g., Pwani University)',
              prefixIcon: const Icon(Icons.flight_land),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) =>
                _filters = _filters.copyWith(destination: value),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection() {
    return _FilterSection(
      title: 'Date Range',
      child: Column(
        children: [
          _buildDateField(
            label: 'From Date',
            date: _filters.fromDate,
            onDateSelected: (date) =>
                _filters = _filters.copyWith(fromDate: date),
          ),
          const SizedBox(height: 12),
          _buildDateField(
            label: 'To Date',
            date: _filters.toDate,
            onDateSelected: (date) =>
                _filters = _filters.copyWith(toDate: date),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required Function(DateTime?) onDateSelected,
  }) {
    return InkWell(
      onTap: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (selectedDate != null) {
          onDateSelected(selectedDate);
          setState(() {});
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            Text(
              date != null ? DateFormat('MMM dd, yyyy').format(date) : label,
              style: TextStyle(
                color: date != null ? Colors.black : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAircraftTypeSection() {
    return _FilterSection(
      title: 'Aircraft Type',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildAircraftTypeChip(1, 'Private Jet', '✈️'),
          _buildAircraftTypeChip(2, 'Commercial Jet', '🛩️'),
          _buildAircraftTypeChip(3, 'Helicopter', '🚁'),
          _buildAircraftTypeChip(4, 'Turboprop', '🛫'),
        ],
      ),
    );
  }

  Widget _buildAircraftTypeChip(int id, String name, String emoji) {
    final isSelected = _filters.aircraftTypeId == id;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji),
          const SizedBox(width: 4),
          Text(name),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filters = _filters.copyWith(
            aircraftTypeId: selected ? id : null,
          );
        });
      },
      selectedColor: Colors.blue.shade100,
      checkmarkColor: Colors.blue.shade700,
      side: BorderSide(
        color: isSelected ? Colors.blue.shade300 : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildPriceSection() {
    return _FilterSection(
      title: 'Price Range',
      child: Column(
        children: [
          RangeSlider(
            values: RangeValues(
              _filters.minPrice.toDouble(),
              _filters.maxPrice.toDouble(),
            ),
            min: 0,
            max: 10000,
            divisions: 100,
            labels: RangeLabels(
              '\$${_filters.minPrice.toInt()}',
              '\$${_filters.maxPrice.toInt()}',
            ),
            onChanged: (values) {
              setState(() {
                _filters = _filters.copyWith(
                  minPrice: values.start.toInt(),
                  maxPrice: values.end.toInt(),
                );
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('\$${_filters.minPrice.toInt()}'),
              Text('\$${_filters.maxPrice.toInt()}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDisplayOptionsSection() {
    return _FilterSection(
      title: 'Display Options',
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Group by Aircraft Type'),
            subtitle: const Text('Group similar aircraft types together'),
            value: _filters.groupBy,
            onChanged: (value) {
              setState(() {
                _filters = _filters.copyWith(groupBy: value);
              });
            },
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            title: const Text('Show Deals with Discounts Only'),
            subtitle: const Text('Filter to show only discounted deals'),
            value: _filters.discountsOnly,
            onChanged: (value) {
              setState(() {
                _filters = _filters.copyWith(discountsOnly: value);
              });
            },
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                widget.onApplyFilters(_filters);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _FilterSection({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}
