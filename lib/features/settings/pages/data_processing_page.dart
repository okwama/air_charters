import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../config/theme/app_theme.dart';

class DataProcessingPage extends StatelessWidget {
  const DataProcessingPage({super.key});

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
          'Data Processing',
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
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.purple.shade200),
              ),
              child: Column(
                children: [
                  Icon(
                    LucideIcons.database,
                    size: 48,
                    color: Colors.purple.shade600,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Data Processing',
                    style: AppTheme.heading3.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'GDPR & Data Processing Information',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.purple.shade600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // PDF Viewer Section
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
                children: [
                  Icon(
                    LucideIcons.fileText,
                    size: 64,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Data Processing Document',
                    style: AppTheme.heading3.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'View the complete Data Processing document',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  
                  // PDF View Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _viewPDF(context),
                      icon: const Icon(LucideIcons.eye),
                      label: const Text('View PDF Document'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Download Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _downloadPDF(context),
                      icon: const Icon(LucideIcons.download),
                      label: const Text('Download PDF'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.purple.shade600,
                        side: BorderSide(color: Colors.purple.shade600),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quick Summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Data Processing Summary',
                    style: AppTheme.heading3.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryItem(
                    'Legal Basis',
                    'We process your data based on legitimate interests and consent.',
                  ),
                  _buildSummaryItem(
                    'Data Categories',
                    'Personal information, usage data, and technical information.',
                  ),
                  _buildSummaryItem(
                    'Processing Purposes',
                    'Service delivery, communication, and app improvement.',
                  ),
                  _buildSummaryItem(
                    'Data Retention',
                    'We retain data only as long as necessary for the stated purposes.',
                  ),
                  _buildSummaryItem(
                    'Your Rights',
                    'Access, rectification, erasure, and data portability rights.',
                  ),
                  _buildSummaryItem(
                    'Data Transfers',
                    'Data may be transferred to countries with adequate protection.',
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
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.indigo.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        LucideIcons.mail,
                        color: Colors.indigo.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Data Protection Questions?',
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.indigo.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Contact our Data Protection Officer at dpo@aircharters.com for any questions about data processing.',
                    style: AppTheme.bodySmall.copyWith(
                      color: Colors.indigo.shade600,
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

  Widget _buildSummaryItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6, right: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade600,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: AppTheme.caption.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _viewPDF(BuildContext context) {
    // TODO: Implement PDF viewer
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PDF viewer will be implemented here'),
        backgroundColor: Colors.purple,
      ),
    );
  }

  void _downloadPDF(BuildContext context) {
    // TODO: Implement PDF download
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PDF download will be implemented here'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
