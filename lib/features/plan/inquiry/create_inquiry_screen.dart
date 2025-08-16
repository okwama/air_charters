import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/models/booking_inquiry_model.dart';
import '../../../core/controllers/booking_inquiry_controller.dart';
import '../../../core/models/aircraft_availability_model.dart';
import '../../../core/models/location_model.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/calendar_selector.dart';
import 'package:provider/provider.dart';

class CreateInquiryScreen extends StatefulWidget {
  final AvailableAircraft? aircraft;
  final LocationModel origin;
  final LocationModel destination;
  final DateTime departureDate;
  final DateTime? returnDate;
  final int passengerCount;
  final bool isRoundTrip;

  const CreateInquiryScreen({
    super.key,
    this.aircraft,
    required this.origin,
    required this.destination,
    required this.departureDate,
    this.returnDate,
    required this.passengerCount,
    this.isRoundTrip = false,
  });

  @override
  State<CreateInquiryScreen> createState() => _CreateInquiryScreenState();
}

class _CreateInquiryScreenState extends State<CreateInquiryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _specialRequirementsController = TextEditingController();
  final _userNotesController = TextEditingController();

  // Inquiry options
  bool _onboardDining = false;
  bool _groundTransportation = false;
  String _billingRegion = '';

  // Stops management
  List<CreateInquiryStopRequest> _stops = [];
  int _nextStopOrder = 1;

  // Form validation
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeStops();
  }

  @override
  void dispose() {
    _specialRequirementsController.dispose();
    _userNotesController.dispose();
    super.dispose();
  }

  void _initializeStops() {
    // Add origin as first stop
    _stops.add(CreateInquiryStopRequest(
      stopName: widget.origin.name,
      longitude: widget.origin.longitude ?? 0.0,
      latitude: widget.origin.latitude ?? 0.0,
      stopOrder: _nextStopOrder++,
      locationCode: widget.origin.iataCode,
    ));

    // Add destination as last stop
    _stops.add(CreateInquiryStopRequest(
      stopName: widget.destination.name,
      longitude: widget.destination.longitude ?? 0.0,
      latitude: widget.destination.latitude ?? 0.0,
      stopOrder: _nextStopOrder++,
      locationCode: widget.destination.iataCode,
    ));
  }

  void _addStop() {
    setState(() {
      _stops.insert(
          _stops.length - 1,
          CreateInquiryStopRequest(
            stopName: '',
            longitude: 0.0,
            latitude: 0.0,
            stopOrder: _nextStopOrder++,
          ));
    });
  }

  void _removeStop(int index) {
    if (index > 0 && index < _stops.length - 1) {
      setState(() {
        _stops.removeAt(index);
        // Reorder stops
        for (int i = 0; i < _stops.length; i++) {
          _stops[i] = CreateInquiryStopRequest(
            stopName: _stops[i].stopName,
            longitude: _stops[i].longitude,
            latitude: _stops[i].latitude,
            price: _stops[i].price,
            datetime: _stops[i].datetime,
            stopOrder: i + 1,
            locationCode: _stops[i].locationCode,
          );
        }
      });
    }
  }

  void _updateStop(int index, CreateInquiryStopRequest updatedStop) {
    setState(() {
      _stops[index] = updatedStop;
    });
  }

  Future<void> _submitInquiry() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final controller =
          Provider.of<BookingInquiryController>(context, listen: false);

      final request = CreateBookingInquiryRequest(
        aircraftId: widget.aircraft?.aircraftId ?? 0,
        requestedSeats: widget.passengerCount,
        specialRequirements: _specialRequirementsController.text.isNotEmpty
            ? _specialRequirementsController.text
            : null,
        onboardDining: _onboardDining,
        groundTransportation: _groundTransportation,
        billingRegion: _billingRegion.isNotEmpty ? _billingRegion : null,
        userNotes: _userNotesController.text.isNotEmpty
            ? _userNotesController.text
            : null,
        stops: _stops,
      );

      final inquiry = await controller.createInquiry(request);

      if (inquiry != null) {
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            '/inquiry-confirmation',
            arguments: inquiry,
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to create inquiry. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Create Inquiry',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Flight Summary
              _buildFlightSummary(),
              const SizedBox(height: 24),

              // Stops Section
              _buildStopsSection(),
              const SizedBox(height: 24),

              // Additional Services
              _buildAdditionalServices(),
              const SizedBox(height: 24),

              // Special Requirements
              _buildSpecialRequirements(),
              const SizedBox(height: 24),

              // Notes
              _buildNotes(),
              const SizedBox(height: 32),

              // Error Message
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: GoogleFonts.inter(
                      color: Colors.red[700],
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Submit Button
              CustomButton(
                text: _isLoading ? 'Creating Inquiry...' : 'Submit Inquiry',
                onPressed: _isLoading ? null : _submitInquiry,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlightSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Flight Summary',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'From',
                  widget.origin.name,
                  Icons.flight_takeoff,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryItem(
                  'To',
                  widget.destination.name,
                  Icons.flight_land,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Date',
                  '${widget.departureDate.day}/${widget.departureDate.month}/${widget.departureDate.year}',
                  Icons.calendar_today,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryItem(
                  'Passengers',
                  '${widget.passengerCount}',
                  Icons.person,
                ),
              ),
            ],
          ),
          if (widget.aircraft != null) ...[
            const SizedBox(height: 12),
            _buildSummaryItem(
              'Aircraft',
              widget.aircraft!.aircraftName,
              Icons.airplanemode_active,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildStopsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Flight Stops',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            TextButton.icon(
              onPressed: _addStop,
              icon: const Icon(LucideIcons.plus, size: 16),
              label: Text(
                'Add Stop',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(_stops.length, (index) {
          final stop = _stops[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    stop.stopName.isNotEmpty
                        ? stop.stopName
                        : 'Select location',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: stop.stopName.isNotEmpty
                          ? Colors.black
                          : Colors.grey[500],
                    ),
                  ),
                ),
                if (index > 0 && index < _stops.length - 1)
                  IconButton(
                    onPressed: () => _removeStop(index),
                    icon: const Icon(Icons.remove_circle_outline, size: 20),
                    color: Colors.red[400],
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAdditionalServices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Services',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        _buildServiceOption(
          'Onboard Dining',
          'Catering and meal services',
          _onboardDining,
          (value) => setState(() => _onboardDining = value ?? false),
        ),
        const SizedBox(height: 8),
        _buildServiceOption(
          'Ground Transportation',
          'Airport transfers and ground transport',
          _groundTransportation,
          (value) => setState(() => _groundTransportation = value ?? false),
        ),
      ],
    );
  }

  Widget _buildServiceOption(String title, String description, bool value,
      ValueChanged<bool?> onChanged) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.black,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialRequirements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Special Requirements',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _specialRequirementsController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Any special requirements or requests...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Notes',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _userNotesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Any additional notes or comments...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }
}
