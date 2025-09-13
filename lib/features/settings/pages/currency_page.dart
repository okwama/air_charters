import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CurrencyPage extends StatefulWidget {
  final String currentCurrency;
  final Function(String) onCurrencySelected;

  const CurrencyPage({
    super.key,
    required this.currentCurrency,
    required this.onCurrencySelected,
  });

  @override
  State<CurrencyPage> createState() => _CurrencyPageState();
}

class _CurrencyPageState extends State<CurrencyPage> {
  late String _selectedCurrency;
  String _searchQuery = '';

  final List<CurrencyOption> _currencies = [
    CurrencyOption(
      code: 'USD',
      name: 'US Dollar',
      symbol: '\$',
      flag: '🇺🇸',
      description: 'Most widely used',
      region: 'United States',
      exchangeRate: 1.0,
    ),
    CurrencyOption(
      code: 'EUR',
      name: 'Euro',
      symbol: '€',
      flag: '🇪🇺',
      description: 'European Union',
      region: 'European Union',
      exchangeRate: 0.85,
    ),
    CurrencyOption(
      code: 'GBP',
      name: 'British Pound',
      symbol: '£',
      flag: '🇬🇧',
      description: 'United Kingdom',
      region: 'United Kingdom',
      exchangeRate: 0.73,
    ),
    CurrencyOption(
      code: 'CAD',
      name: 'Canadian Dollar',
      symbol: 'C\$',
      flag: '🇨🇦',
      description: 'Canada',
      region: 'Canada',
      exchangeRate: 1.25,
    ),
    CurrencyOption(
      code: 'AUD',
      name: 'Australian Dollar',
      symbol: 'A\$',
      flag: '🇦🇺',
      description: 'Australia',
      region: 'Australia',
      exchangeRate: 1.35,
    ),
    CurrencyOption(
      code: 'JPY',
      name: 'Japanese Yen',
      symbol: '¥',
      flag: '🇯🇵',
      description: 'Japan',
      region: 'Japan',
      exchangeRate: 110.0,
    ),
    CurrencyOption(
      code: 'CHF',
      name: 'Swiss Franc',
      symbol: 'CHF',
      flag: '🇨🇭',
      description: 'Switzerland',
      region: 'Switzerland',
      exchangeRate: 0.92,
    ),
    CurrencyOption(
      code: 'CNY',
      name: 'Chinese Yuan',
      symbol: '¥',
      flag: '🇨🇳',
      description: 'China',
      region: 'China',
      exchangeRate: 6.45,
    ),
    CurrencyOption(
      code: 'INR',
      name: 'Indian Rupee',
      symbol: '₹',
      flag: '🇮🇳',
      description: 'India',
      region: 'India',
      exchangeRate: 74.5,
    ),
    CurrencyOption(
      code: 'BRL',
      name: 'Brazilian Real',
      symbol: 'R\$',
      flag: '🇧🇷',
      description: 'Brazil',
      region: 'Brazil',
      exchangeRate: 5.2,
    ),
    CurrencyOption(
      code: 'MXN',
      name: 'Mexican Peso',
      symbol: 'MX\$',
      flag: '🇲🇽',
      description: 'Mexico',
      region: 'Mexico',
      exchangeRate: 20.5,
    ),
    CurrencyOption(
      code: 'SGD',
      name: 'Singapore Dollar',
      symbol: 'S\$',
      flag: '🇸🇬',
      description: 'Singapore',
      region: 'Singapore',
      exchangeRate: 1.35,
    ),
    CurrencyOption(
      code: 'HKD',
      name: 'Hong Kong Dollar',
      symbol: 'HK\$',
      flag: '🇭🇰',
      description: 'Hong Kong',
      region: 'Hong Kong',
      exchangeRate: 7.8,
    ),
    CurrencyOption(
      code: 'KRW',
      name: 'South Korean Won',
      symbol: '₩',
      flag: '🇰🇷',
      description: 'South Korea',
      region: 'South Korea',
      exchangeRate: 1200.0,
    ),
    CurrencyOption(
      code: 'THB',
      name: 'Thai Baht',
      symbol: '฿',
      flag: '🇹🇭',
      description: 'Thailand',
      region: 'Thailand',
      exchangeRate: 33.5,
    ),
  ];

  List<CurrencyOption> get _filteredCurrencies {
    if (_searchQuery.isEmpty) {
      return _currencies;
    }
    return _currencies.where((currency) {
      return currency.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          currency.code.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          currency.region.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _selectedCurrency = widget.currentCurrency;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Currency Settings',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _applyCurrency,
            child: Text(
              'Apply',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.green.shade600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Icon(
                    LucideIcons.dollarSign,
                    size: 40,
                    color: Colors.green.shade600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Choose Your Currency',
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select your preferred currency for pricing',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Search Bar
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search currencies...',
                prefixIcon:
                    Icon(LucideIcons.search, color: Colors.grey.shade600),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: Colors.green.shade300, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
          ),

          // Exchange Rate Note
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: Colors.white,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.info, color: Colors.blue.shade600, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Exchange rates are approximate and may vary',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Currency List
          Expanded(
            child: _filteredCurrencies.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.search,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No currencies found',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try a different search term',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _filteredCurrencies.length,
                    itemBuilder: (context, index) {
                      final currency = _filteredCurrencies[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildCurrencyOption(currency),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyOption(CurrencyOption currency) {
    final isSelected = _selectedCurrency == currency.code;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCurrency = currency.code;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.green.shade300 : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Flag
            Container(
              width: 50,
              height: 35,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Center(
                child: Text(
                  currency.flag,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Currency Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        currency.name,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          currency.code,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${currency.symbol}1 = \$${(1 / currency.exchangeRate).toStringAsFixed(2)}',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.green.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currency.region,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currency.description,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            // Selection Indicator
            if (isSelected)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.green.shade600,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _applyCurrency() {
    widget.onCurrencySelected(_selectedCurrency);
    Navigator.pop(context);
  }
}

class CurrencyOption {
  final String code;
  final String name;
  final String symbol;
  final String flag;
  final String description;
  final String region;
  final double exchangeRate;

  CurrencyOption({
    required this.code,
    required this.name,
    required this.symbol,
    required this.flag,
    required this.description,
    required this.region,
    required this.exchangeRate,
  });
}

