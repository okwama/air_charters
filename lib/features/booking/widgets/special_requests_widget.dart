import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SpecialRequestsWidget extends StatefulWidget {
  final bool onboardDining;
  final bool groundTransportation;
  final Function(bool) onOnboardDiningChanged;
  final Function(bool) onGroundTransportationChanged;

  const SpecialRequestsWidget({
    Key? key,
    required this.onboardDining,
    required this.groundTransportation,
    required this.onOnboardDiningChanged,
    required this.onGroundTransportationChanged,
  }) : super(key: key);

  @override
  State<SpecialRequestsWidget> createState() => _SpecialRequestsWidgetState();
}

class _SpecialRequestsWidgetState extends State<SpecialRequestsWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E5E5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Special Requests',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),

          // Onboard Dining Toggle
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Onboard Dining',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Premium catering service',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: widget.onboardDining,
                onChanged: widget.onOnboardDiningChanged,
                activeColor: Colors.black,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Ground Transportation Toggle
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ground Transportation',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Airport pickup and drop-off',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: widget.groundTransportation,
                onChanged: widget.onGroundTransportationChanged,
                activeColor: Colors.black,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
