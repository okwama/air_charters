import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../config/theme/app_theme.dart';

class OpenSourceLicensesPage extends StatelessWidget {
  const OpenSourceLicensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Open Source Licenses',
          style: AppTheme.heading3.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Icon(
                    LucideIcons.code,
                    size: 48,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Open Source Licenses',
                    style: AppTheme.heading3.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Third-party library licenses and acknowledgments',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Licenses List
            Container(
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
                    'Third-Party Libraries',
                    style: AppTheme.heading3.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Flutter
                  _buildLicenseItem(
                    'Flutter',
                    'BSD 3-Clause License',
                    'UI toolkit for building natively compiled applications',
                  ),
                  
                  // Provider
                  _buildLicenseItem(
                    'Provider',
                    'MIT License',
                    'State management solution for Flutter',
                  ),
                  
                  // HTTP
                  _buildLicenseItem(
                    'HTTP',
                    'BSD 3-Clause License',
                    'HTTP client for making API requests',
                  ),
                  
                  // Shared Preferences
                  _buildLicenseItem(
                    'Shared Preferences',
                    'BSD 3-Clause License',
                    'Persistent storage for simple data',
                  ),
                  
                  // Local Auth
                  _buildLicenseItem(
                    'Local Auth',
                    'Apache License 2.0',
                    'Biometric authentication support',
                  ),
                  
                  // Flutter Secure Storage
                  _buildLicenseItem(
                    'Flutter Secure Storage',
                    'BSD 3-Clause License',
                    'Secure storage for sensitive data',
                  ),
                  
                  // Lottie
                  _buildLicenseItem(
                    'Lottie',
                    'Apache License 2.0',
                    'Animation library for Flutter',
                  ),
                  
                  // Cached Network Image
                  _buildLicenseItem(
                    'Cached Network Image',
                    'MIT License',
                    'Image caching and loading',
                  ),
                  
                  // SVG
                  _buildLicenseItem(
                    'Flutter SVG',
                    'MIT License',
                    'SVG image support for Flutter',
                  ),
                  
                  // Lucide Icons
                  _buildLicenseItem(
                    'Lucide Icons',
                    'ISC License',
                    'Beautiful & consistent icon toolkit',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // License Information
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        LucideIcons.info,
                        color: Colors.blue.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'License Information',
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This app uses various open-source libraries. Each library maintains its own license terms. We respect and comply with all applicable open-source licenses.',
                    style: AppTheme.bodySmall.copyWith(
                      color: Colors.blue.shade600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Contact Information
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        LucideIcons.mail,
                        color: Colors.green.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'License Questions?',
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Contact us at legal@aircharters.com for any questions about open-source licenses.',
                    style: AppTheme.bodySmall.copyWith(
                      color: Colors.green.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLicenseItem(String name, String license, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.package,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  license,
                  style: AppTheme.caption.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: AppTheme.caption.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
