import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:country_picker/country_picker.dart';
import 'package:country_flags/country_flags.dart';

class CountrySelectionScreen extends StatefulWidget {
  const CountrySelectionScreen({super.key});

  @override
  State<CountrySelectionScreen> createState() => _CountrySelectionScreenState();
}

class _CountrySelectionScreenState extends State<CountrySelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  List<Country> _allCountries = [];
  List<Country> _filteredCountries = [];

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  void _loadCountries() {
    // Get all countries from the country_picker package
    _allCountries = CountryService().getAll();
    _filteredCountries = _allCountries;
  }

  void _filterCountries(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCountries = _allCountries;
      } else {
        _filteredCountries = _allCountries.where((country) {
          return country.name.toLowerCase().contains(query.toLowerCase()) ||
              country.displayNameNoCountryCode
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              country.phoneCode.contains(query) ||
              country.countryCode.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _selectCountry(Country country) {
    final countryData = {
      'code': '+${country.phoneCode}',
      'flag': country.flagEmoji,
      'name': country.name,
      'fullName': country.displayNameNoCountryCode,
    };
    Navigator.pop(context, countryData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.black,
            size: 24,
          ),
        ),
        title: Text(
          'Select Country',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocus,
              onChanged: _filterCountries,
              decoration: InputDecoration(
                hintText: 'Search countries...',
                hintStyle: GoogleFonts.inter(
                  fontSize: 16,
                  color: const Color(0xFF888888),
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF888888),
                  size: 24,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0xFFE5E5E5),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.black,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.black,
              ),
              cursorColor: Colors.black,
            ),
          ),

          // Countries List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredCountries.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                thickness: 0.5,
                color: Colors.grey.shade200,
              ),
              itemBuilder: (context, index) {
                final country = _filteredCountries[index];
                return _buildCountryItem(country);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountryItem(Country country) {
    return InkWell(
      onTap: () => _selectCountry(country),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            // Colorful Flag Icon
            Container(
              width: 36,
              height: 26,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: CountryFlag.fromCountryCode(
                country.countryCode,
                height: 26,
                width: 36,
              ),
            ),

            const SizedBox(width: 16),

            // Country Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    country.name,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    country.displayNameNoCountryCode,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF666666),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Phone Code
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 0.5,
                ),
              ),
              child: Text(
                '+${country.phoneCode}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
