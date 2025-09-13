import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AppVersionPage extends StatefulWidget {
  const AppVersionPage({super.key});

  @override
  State<AppVersionPage> createState() => _AppVersionPageState();
}

class _AppVersionPageState extends State<AppVersionPage> {
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
          'App Version',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Icon and Name
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      LucideIcons.plane,
                      size: 40,
                      color: Colors.blue.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Air Charters',
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Premium Air Charter Services',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Version Information
            _buildInfoCard(
              title: 'Version Information',
              children: [
                _buildInfoRow('Version', '1.0.0'),
                _buildInfoRow('Build Number', '1'),
                _buildInfoRow('Package Name', 'com.aircharters.app'),
                _buildInfoRow('Platform', 'Flutter'),
                _buildInfoRow(
                    'Last Updated', DateTime.now().toString().split(' ')[0]),
              ],
            ),

            const SizedBox(height: 24),

            // System Information
            _buildInfoCard(
              title: 'System Information',
              children: [
                _buildInfoRow('Operating System', 'iOS/Android'),
                _buildInfoRow('Flutter Version', '3.16.0'),
                _buildInfoRow('Dart Version', '3.2.0'),
                _buildInfoRow('Target Platform', 'Mobile'),
              ],
            ),

            const SizedBox(height: 24),

            // Release Notes
            _buildInfoCard(
              title: 'What\'s New',
              children: [
                _buildReleaseNote(
                    '🎉 New booking system with real-time availability'),
                _buildReleaseNote('✈️ Enhanced direct charter search'),
                _buildReleaseNote('🔔 Improved notification system'),
                _buildReleaseNote('🎨 Updated user interface design'),
                _buildReleaseNote('🐛 Bug fixes and performance improvements'),
              ],
            ),

            const SizedBox(height: 24),

            // Support Information
            _buildInfoCard(
              title: 'Support',
              children: [
                _buildInfoRow('Support Email', 'support@aircharters.com'),
                _buildInfoRow('Website', 'www.aircharters.com'),
                _buildInfoRow('Privacy Policy', 'Available in settings'),
                _buildInfoRow('Terms of Service', 'Available in settings'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReleaseNote(String note) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              note,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
