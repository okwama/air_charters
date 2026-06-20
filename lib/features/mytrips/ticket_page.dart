import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart' as pwlib;
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../../core/models/booking_model.dart';

class TicketPage extends StatefulWidget {
  final BookingModel booking;

  const TicketPage({super.key, required this.booking});

  @override
  State<TicketPage> createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> with TickerProviderStateMixin {
  final GlobalKey _ticketKey = GlobalKey();
  late AnimationController _fadeController;
  ui.Image? _logoImage;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeController.forward();
    _loadLogo();
  }

  Future<void> _loadLogo() async {
    try {
      final ByteData data = await rootBundle.load('assets/logo/logo.png');
      final Uint8List bytes = data.buffer.asUint8List();
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frame = await codec.getNextFrame();
      setState(() {
        _logoImage = frame.image;
      });
    } catch (e) {
      // Logo loading failed, continue without it
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  String _displayOr(String? value, String fallback) {
    if (value == null) return fallback;
    final s = value.trim();
    return s.isEmpty ? fallback : s;
  }

  String get _qrPayload {
    final ref = widget.booking.referenceNumber ?? '';
    final id = widget.booking.id ?? '';
    final uid = widget.booking.userId;
    final dt = widget.booking.departureDate?.toIso8601String();
    return 'AC-TICKET|bid=$id|ref=$ref|uid=$uid|dt=$dt';
  }

  Widget _compactInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 16, color: Colors.black),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _simpleDashedDivider() {
    return SizedBox(
      height: 20,
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: CustomPaint(
                painter: DashedLinePainter(),
              ),
            ),
          ),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _backgroundWatermark() {
    if (_logoImage == null) return const SizedBox.shrink();

    return Positioned.fill(
      child: Opacity(
        opacity:
            0.08, // Slightly increased opacity for better visibility in exports
        child: Center(
          child: Transform.rotate(
            angle: -0.3, // Slight rotation for watermark effect
            child: FutureBuilder<ByteData?>(
              future: _logoImage!.toByteData(format: ui.ImageByteFormat.png),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  return Image.memory(
                    snapshot.data!.buffer.asUint8List(),
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _compactQRSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'BOARDING PASS',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.black,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: QrImageView(
              data: _qrPayload,
              version: QrVersions.auto,
              size: 140,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Colors.black,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              _displayOr(
                  widget.booking.referenceNumber, widget.booking.id ?? 'N/A'),
              style: GoogleFonts.jetBrainsMono(
                letterSpacing: 2,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // PDF helper methods remain the same
  pw.Widget _pdfInfoRow(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label,
            style: pw.TextStyle(fontSize: 10, color: pwlib.PdfColors.grey600)),
        pw.SizedBox(height: 2),
        pw.Text(value,
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  Future<void> _saveAsImage() async {
    try {
      // Wait a bit to ensure all widgets are fully rendered
      await Future.delayed(const Duration(milliseconds: 100));

      final boundary = _ticketKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      // Force a repaint to ensure watermark is rendered
      boundary.markNeedsPaint();
      await Future.delayed(const Duration(milliseconds: 50));

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final pngBytes = byteData.buffer.asUint8List();

      final dir = await getTemporaryDirectory();
      final file = File(
          '${dir.path}/ticket_${widget.booking.referenceNumber ?? widget.booking.id}.png');
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles([XFile(file.path)],
          text: 'My AirCharters ticket');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ticket saved and ready to share!'),
          backgroundColor: Colors.black,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save ticket'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveAsPdf() async {
    try {
      final doc = pw.Document();

      pw.MemoryImage? logoImage;
      try {
        final logoData = await rootBundle.load('assets/logo/logo.png');
        logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
      } catch (_) {
        logoImage = null;
      }

      final qrPng = await QrPainter(
        data: _qrPayload,
        version: QrVersions.auto,
        gapless: true,
      ).toImageData(800);

      doc.addPage(
        pw.Page(
          pageFormat: pwlib.PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Container(
                  decoration: pw.BoxDecoration(
                    color: pwlib.PdfColors.black,
                    borderRadius: pw.BorderRadius.circular(10),
                  ),
                  padding: const pw.EdgeInsets.all(16),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          if (logoImage != null)
                            pw.Container(
                              width: 28,
                              height: 28,
                              margin: const pw.EdgeInsets.only(right: 8),
                              child: pw.Image(logoImage),
                            ),
                          pw.Text('AirCharters',
                              style: pw.TextStyle(
                                  color: pwlib.PdfColors.white,
                                  fontSize: 14,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.Spacer(),
                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: pw.BoxDecoration(
                              color: pwlib.PdfColors.white,
                              borderRadius: pw.BorderRadius.circular(20),
                            ),
                            child: pw.Text('CONFIRMED',
                                style: pw.TextStyle(
                                    color: pwlib.PdfColors.black,
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold)),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 8),
                      pw.Row(
                        children: [
                          pw.Text(
                              _displayOr(widget.booking.departure, 'N/A')
                                  .toUpperCase(),
                              style: pw.TextStyle(
                                  color: pwlib.PdfColors.white,
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.Text(' → ',
                              style: pw.TextStyle(
                                  color: pwlib.PdfColors.white, fontSize: 16)),
                          pw.Text(
                              _displayOr(widget.booking.destination, 'N/A')
                                  .toUpperCase(),
                              style: pw.TextStyle(
                                  color: pwlib.PdfColors.white,
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                          '${widget.booking.departureDateDisplay} • ${_displayOr(widget.booking.departureTime, 'TBA')} • Ref: ${_displayOr(widget.booking.referenceNumber, '-')}',
                          style: const pw.TextStyle(
                              color: pwlib.PdfColors.white, fontSize: 10)),
                    ],
                  ),
                ),

                pw.SizedBox(height: 16),

                // Info rows
                pw.Row(
                  children: [
                    pw.Expanded(
                        child: _pdfInfoRow('Departure',
                            _displayOr(widget.booking.departure, 'N/A'))),
                    pw.SizedBox(width: 12),
                    pw.Expanded(
                        child: _pdfInfoRow('Destination',
                            _displayOr(widget.booking.destination, 'N/A'))),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  children: [
                    pw.Expanded(
                        child: _pdfInfoRow('Time',
                            _displayOr(widget.booking.departureTime, 'TBA'))),
                    pw.SizedBox(width: 12),
                    pw.Expanded(
                        child: _pdfInfoRow(
                            'Date', widget.booking.departureDateDisplay)),
                  ],
                ),
                if (widget.booking.paymentTransactionId != null) ...[
                  pw.SizedBox(height: 8),
                  _pdfInfoRow(
                      'Payment Ref', widget.booking.paymentTransactionId!),
                ],

                pw.SizedBox(height: 16),
                pw.Divider(color: pwlib.PdfColors.grey300),
                pw.SizedBox(height: 16),

                if (qrPng != null)
                  pw.Center(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(
                            color: pwlib.PdfColors.black, width: 2),
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Image(
                          pw.MemoryImage(qrPng.buffer.asUint8List()),
                          width: 200,
                          height: 200),
                    ),
                  ),
                pw.SizedBox(height: 8),
                pw.Center(
                  child: pw.Text(
                    widget.booking.referenceNumber ?? widget.booking.id ?? '',
                    style: pw.TextStyle(
                        letterSpacing: 1.5,
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(onLayout: (format) async => doc.save());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to generate PDF'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        title: Text(
          'Boarding Pass',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: _saveAsImage,
            icon: const Icon(Icons.image, color: Colors.black),
          ),
          IconButton(
            onPressed: _saveAsPdf,
            icon: const Icon(Icons.picture_as_pdf, color: Colors.black),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: FadeTransition(
          opacity: _fadeController,
          child: RepaintBoundary(
            key: _ticketKey,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      // Compact header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'AirCharters',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Spacer(),
                                if (_logoImage != null)
                                  Container(
                                    width: 32,
                                    height: 32,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: FutureBuilder<ByteData?>(
                                        future: _logoImage!.toByteData(
                                            format: ui.ImageByteFormat.png),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData &&
                                              snapshot.data != null) {
                                            return Image.memory(
                                              snapshot.data!.buffer
                                                  .asUint8List(),
                                              fit: BoxFit.contain,
                                            );
                                          }
                                          return const SizedBox.shrink();
                                        },
                                      ),
                                    ),
                                  ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'CONFIRMED',
                                    style: GoogleFonts.inter(
                                      color: Colors.black,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    _displayOr(widget.booking.departure, 'N/A')
                                        .toUpperCase(),
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                    ),
                                    overflow: TextOverflow.visible,
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: const Icon(Icons.arrow_forward,
                                      color: Colors.white, size: 20),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    _displayOr(
                                            widget.booking.destination, 'N/A')
                                        .toUpperCase(),
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    overflow: TextOverflow.visible,
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${widget.booking.departureDateDisplay} • ${_displayOr(widget.booking.departureTime, 'TBA')} • ${_displayOr(widget.booking.referenceNumber, 'REF')}',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),

                      // Compact details section
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _compactInfoRow(
                                    icon: Icons.flight_takeoff,
                                    label: 'From',
                                    value: _displayOr(
                                        widget.booking.departure, 'N/A'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _compactInfoRow(
                                    icon: Icons.flight_land,
                                    label: 'To',
                                    value: _displayOr(
                                        widget.booking.destination, 'N/A'),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: _compactInfoRow(
                                    icon: Icons.access_time,
                                    label: 'Time',
                                    value: _displayOr(
                                        widget.booking.departureTime, 'TBA'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _compactInfoRow(
                                    icon: Icons.calendar_today,
                                    label: 'Date',
                                    value: widget.booking.departureDateDisplay,
                                  ),
                                ),
                              ],
                            ),

                            if (widget.booking.paymentTransactionId != null)
                              _compactInfoRow(
                                icon: Icons.receipt,
                                label: 'Payment Ref',
                                value: widget.booking.paymentTransactionId!,
                              ),

                            const SizedBox(height: 16),
                            _simpleDashedDivider(),
                            const SizedBox(height: 16),

                            _compactQRSection(),

                            const SizedBox(height: 16),

                            // Compact boarding notice
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.black, width: 1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.info_outline,
                                      color: Colors.black, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Arrive 45-60 minutes for check-in before departure. Have boarding pass and ID ready. the designated check-in area is aero club lounge.',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                _backgroundWatermark(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom painter for dashed line
class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1;

    const dashWidth = 4.0;
    const dashSpace = 4.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

extension on BookingModel {
  String get departureDateDisplay {
    final d = departureDate;
    if (d == null) return 'Date TBA';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
