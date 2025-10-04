import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'dart:typed_data';
import '../../../config/theme/app_theme.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

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
          'Terms of Service',
          style: AppTheme.heading3.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // PDF Viewer Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border(
                bottom: BorderSide(color: Colors.blue.shade200),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.fileText,
                  size: 20,
                  color: Colors.blue.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  'Terms of Service',
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                ),
                const Spacer(),
                // Download Button
                IconButton(
                  onPressed: () => _downloadPDF(context),
                  icon: Icon(
                    LucideIcons.download,
                    size: 18,
                    color: Colors.blue.shade600,
                  ),
                  tooltip: 'Download PDF',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.blue.shade100,
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ],
            ),
          ),
          
          // PDF Content Area (Full Screen)
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.white,
              child: FutureBuilder<Uint8List>(
                future: _generateSamplePDF(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.alertCircle,
                            size: 48,
                            color: Colors.red.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading PDF',
                            style: AppTheme.bodyMedium.copyWith(
                              color: Colors.red.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            snapshot.error.toString(),
                            style: AppTheme.caption.copyWith(
                              color: Colors.red.shade500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  } else {
                    return PdfPreview(
                      build: (format) => snapshot.data!,
                      allowPrinting: false,
                      allowSharing: false,
                      canChangePageFormat: false,
                      canChangeOrientation: false,
                      canDebug: false,
                      initialPageFormat: PdfPageFormat.a4,
                      pdfFileName: 'Terms_of_Service_${DateTime.now().millisecondsSinceEpoch}.pdf',
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }



  void _downloadPDF(BuildContext context) async {
    try {
      // Generate a sample PDF for demonstration
      final pdf = await _generateSamplePDF();
      
      // Get the documents directory
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'Terms_of_Service_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory.path}/$fileName');
      
      // Save the PDF
      await file.writeAsBytes(pdf);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF saved to: ${file.path}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<Uint8List> _generateSamplePDF() async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Terms of Service',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Air Charters Terms of Service',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Last updated: ${DateTime.now().toString().split(' ')[0]}',
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                '1. Acceptance of Terms',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'By accessing and using the Air Charters mobile application, you accept and agree to be bound by the terms and provision of this agreement.',
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 15),
              pw.Text(
                '2. Use License',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Permission is granted to temporarily download one copy of the materials on Air Charters for personal, non-commercial transitory viewing only.',
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 15),
              pw.Text(
                '3. Disclaimer',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'The materials on Air Charters are provided on an "as is" basis. Air Charters makes no warranties, expressed or implied, and hereby disclaims and negates all other warranties.',
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 15),
              pw.Text(
                '4. Limitations',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'In no event shall Air Charters or its suppliers be liable for any damages arising out of the use or inability to use the materials on Air Charters.',
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.Spacer(),
              pw.Text(
                'For questions about these terms, contact us at legal@aircharters.com',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ],
          );
        },
      ),
    );
    
    return pdf.save();
  }
}
