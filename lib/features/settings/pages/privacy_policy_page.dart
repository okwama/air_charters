import 'package:flutter/material.dart';
import '../../../config/theme/app_theme.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPrivacyPolicy();
  }

  Future<void> _loadPrivacyPolicy() async {
    try {
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load privacy policy';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorWidget()
              : _buildPrivacyPolicyContent(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _error!,
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isLoading = true;
                _error = null;
              });
              _loadPrivacyPolicy();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyPolicyContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Privacy Policy',
            style: AppTheme.heading2.copyWith(
              color: AppTheme.textPrimaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Last updated: ${_getLastUpdatedDate()}',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 24),

          // Introduction
          _buildSection(
            title: 'Introduction',
            content: '''
AirCharters ("we," "our," or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application and services.
            ''',
          ),

          // Information We Collect
          _buildSection(
            title: 'Information We Collect',
            content: '''
We may collect the following types of information:

• Personal Information: Name, email address, phone number, billing information
• Flight Information: Departure/arrival locations, dates, passenger details
• Device Information: Device type, operating system, unique device identifiers
• Usage Information: App usage patterns, preferences, and interactions
• Location Information: With your consent, we may collect location data for flight services
            ''',
          ),

          // How We Use Information
          _buildSection(
            title: 'How We Use Your Information',
            content: '''
We use your information to:

• Provide and maintain our flight charter services
• Process bookings and payments
• Send you service-related communications
• Improve our app and services
• Comply with legal obligations
• Protect against fraud and abuse
            ''',
          ),

          // Information Sharing
          _buildSection(
            title: 'Information Sharing',
            content: '''
We do not sell your personal information. We may share your information with:

• Service providers who assist in operating our platform
• Flight operators and related service providers
• Legal authorities when required by law
• Third parties with your explicit consent
            ''',
          ),

          // Data Security
          _buildSection(
            title: 'Data Security',
            content: '''
We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. However, no method of transmission over the internet is 100% secure.
            ''',
          ),

          // Your Rights
          _buildSection(
            title: 'Your Rights',
            content: '''
You have the right to:

• Access your personal information
• Correct inaccurate information
• Delete your account and data
• Object to certain data processing
• Data portability
• Withdraw consent where applicable
            ''',
          ),

          // Contact Information
          _buildSection(
            title: 'Contact Us',
            content: '''
If you have questions about this Privacy Policy, please contact us at:

Email: privacy@aircharters.com
Phone: +1 (555) 123-4567
Address: AirCharters Privacy Team, 123 Aviation Way, Sky City, SC 12345
            ''',
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.bodyLarge.copyWith(
            color: AppTheme.textPrimaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondaryColor,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  String _getLastUpdatedDate() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year}';
  }
}
