import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/components/virtual_card.dart';
import '../../shared/components/bottom_nav.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profile',
          style: GoogleFonts.interTight(
            fontWeight: FontWeight.w600,
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Virtual Card
            VirtualCard(
              // userName: 'John Doe',
              // expiryDate: '01/2026',
              // cardNumber: '1234 5678 9012 3456',
              // cardType: 'Visa',
              // cardBrand: 'Mastercard',
              // cardColor: Colors.blue,
              // cardEndColor: Colors.green,
              points: '2,450',
              walletBalance: '\$1,250.00',
              onTap: () {
                // Handle card tap - could show detailed wallet/points info
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Card details coming soon!')),
                );
              },
            ),
            const SizedBox(height: 24),

            // Profile Information
            Text(
              'Personal Information',
              style: GoogleFonts.interTight(
                fontWeight: FontWeight.w600,
                color: Colors.black,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),

            // Name
            _buildInfoRow(
              icon: LucideIcons.user,
              title: 'Full Name',
              value: 'John Doe',
              onTap: () => _showEditDialog(context, 'Full Name', 'John Doe'),
            ),

            // Email
            _buildInfoRow(
              icon: LucideIcons.mail,
              title: 'Email',
              value: 'john.doe@example.com',
              onTap: () =>
                  _showEditDialog(context, 'Email', 'john.doe@example.com'),
            ),

            // Phone
            _buildInfoRow(
              icon: LucideIcons.phone,
              title: 'Phone Number',
              value: '+1 (555) 123-4567',
              onTap: () =>
                  _showEditDialog(context, 'Phone Number', '+1 (555) 123-4567'),
            ),

            // Date of Birth
            _buildInfoRow(
              icon: LucideIcons.calendar,
              title: 'Date of Birth',
              value: 'January 15, 1990',
              onTap: () => _showDatePicker(context),
            ),

            // Nationality
            _buildInfoRow(
              icon: LucideIcons.mapPin,
              title: 'Nationality',
              value: 'United States',
              onTap: () =>
                  _showEditDialog(context, 'Nationality', 'United States'),
            ),

            const SizedBox(height: 24),

            // Preferences Section
            Text(
              'Preferences',
              style: GoogleFonts.interTight(
                fontWeight: FontWeight.w600,
                color: Colors.black,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),

            // Language
            _buildInfoRow(
              icon: LucideIcons.languages,
              title: 'Language',
              value: 'English',
              onTap: () => _showLanguageDialog(context),
            ),

            // Currency
            _buildInfoRow(
              icon: LucideIcons.dollarSign,
              title: 'Currency',
              value: 'USD (\$)',
              onTap: () => _showCurrencyDialog(context),
            ),

            // Notifications
            _buildInfoRow(
              icon: LucideIcons.bell,
              title: 'Notifications',
              value: 'Enabled',
              onTap: () => _showNotificationDialog(context),
            ),

            const SizedBox(height: 20), // Bottom padding for scroll
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(
        currentIndex: 3, // Settings tab is active
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6), // Reduced from 8
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 6), // Reduced vertical padding from 8
        leading: Icon(icon, color: Colors.black, size: 16), // Reduced from 18
        title: Text(
          title,
          style: GoogleFonts.interTight(
            fontWeight: FontWeight.w500,
            color: Colors.black,
            fontSize: 12, // Reduced from 13
          ),
        ),
        subtitle: Text(
          value,
          style: GoogleFonts.interTight(
            fontWeight: FontWeight.w400,
            color: Colors.grey.shade600,
            fontSize: 11, // Reduced from 12
          ),
        ),
        trailing: const Icon(
          LucideIcons.chevronRight,
          color: Colors.grey,
          size: 12, // Reduced from 14
        ),
        onTap: onTap,
        dense: true,
        minVerticalPadding: 0, // Added to make it more compact
      ),
    );
  }

  void _showEditDialog(
      BuildContext context, String field, String currentValue) {
    final TextEditingController controller =
        TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $field'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: field,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Handle save logic here
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$field updated successfully!')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDatePicker(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: DateTime(1990, 1, 15),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    ).then((date) {
      if (date != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Date of birth updated to ${date.toString().split(' ')[0]}')),
        );
      }
    });
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['English', 'Spanish', 'French', 'German']
              .map((lang) => ListTile(
                    title: Text(lang),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Language changed to $lang')),
                      );
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['USD (\$)', 'EUR (€)', 'GBP (£)', 'JPY (¥)']
              .map((currency) => ListTile(
                    title: Text(currency),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Currency changed to $currency')),
                      );
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _showNotificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Enabled', 'Disabled']
              .map((setting) => ListTile(
                    title: Text(setting),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Notifications $setting')),
                      );
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }
}
