import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../config/theme/app_theme.dart';
import '../../core/models/location_model.dart';
import '../../core/models/aircraft_availability_model.dart';

/// Modal shown when aircraft is not available for selected time period
class AircraftUnavailableModal extends StatefulWidget {
  final String title;
  final String message;
  final String? subMessage;
  final AvailableAircraft? aircraft;
  final LocationModel? origin;
  final LocationModel? destination;
  final DateTime? departureDate;
  final DateTime? returnDate;
  final int? passengerCount;
  final bool isRoundTrip;
  final VoidCallback? onClose;

  const AircraftUnavailableModal({
    super.key,
    required this.title,
    required this.message,
    this.subMessage,
    this.aircraft,
    this.origin,
    this.destination,
    this.departureDate,
    this.returnDate,
    this.passengerCount,
    this.isRoundTrip = false,
    this.onClose,
  });

  @override
  State<AircraftUnavailableModal> createState() =>
      _AircraftUnavailableModalState();
}

class _AircraftUnavailableModalState extends State<AircraftUnavailableModal> {
  bool _isCreatingInquiry = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 24),

          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              LucideIcons.clock,
              size: 40,
              color: Colors.orange[600],
            ),
          ),

          const SizedBox(height: 24),

          // Title
          Text(
            widget.title,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Message
          Text(
            widget.message,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),

          if (widget.subMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.subMessage!,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],

          const SizedBox(height: 32),

          // Action buttons
          Row(
            children: [
              // Send Inquiry button
              Expanded(
                child: ElevatedButton(
                  onPressed: _canSendInquiry() ? _sendInquiry : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isCreatingInquiry
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Send Inquiry',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(width: 12),

              // Close button
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onClose?.call();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    'Close',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  bool _canSendInquiry() {
    return widget.aircraft != null &&
        widget.origin != null &&
        widget.destination != null &&
        widget.departureDate != null &&
        widget.passengerCount != null &&
        widget.passengerCount! > 0;
  }

  Future<void> _sendInquiry() async {
    if (!_canSendInquiry()) return;

    setState(() {
      _isCreatingInquiry = true;
    });

    try {
      // TODO: Get auth token from provider
      // For now, we'll show a success message
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        Navigator.pop(context);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  LucideIcons.checkCircle,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Inquiry sent successfully! We\'ll contact you soon.',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to send inquiry. Please try again.',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingInquiry = false;
        });
      }
    }
  }
}

/// Helper function to show aircraft unavailable modal
void showAircraftUnavailableModal({
  required BuildContext context,
  required String title,
  required String message,
  String? subMessage,
  AvailableAircraft? aircraft,
  LocationModel? origin,
  LocationModel? destination,
  DateTime? departureDate,
  DateTime? returnDate,
  int? passengerCount,
  bool isRoundTrip = false,
  VoidCallback? onClose,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: true,
    builder: (context) => AircraftUnavailableModal(
      title: title,
      message: message,
      subMessage: subMessage,
      aircraft: aircraft,
      origin: origin,
      destination: destination,
      departureDate: departureDate,
      returnDate: returnDate,
      passengerCount: passengerCount,
      isRoundTrip: isRoundTrip,
      onClose: onClose,
    ),
  );
}
