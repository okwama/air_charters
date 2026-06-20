import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:air_charters/core/providers/auth_provider.dart';
import 'package:air_charters/core/network/api_client.dart';
import 'package:air_charters/features/booking/payment/in_app_checkout_screen.dart';
import 'package:air_charters/config/env/app_config.dart';
import 'package:air_charters/config/theme/app_theme.dart';
import 'package:air_charters/core/routes/app_routes.dart';

class ExperienceBookingConfirmationPage extends StatefulWidget {
  final Map<String, dynamic> bookingData;

  const ExperienceBookingConfirmationPage({
    super.key,
    required this.bookingData,
  });

  @override
  State<ExperienceBookingConfirmationPage> createState() =>
      _ExperienceBookingConfirmationPageState();
}

class _ExperienceBookingConfirmationPageState
    extends State<ExperienceBookingConfirmationPage> {
  bool _isCreatingBooking = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Experience Booking',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _isCreatingBooking
          ? _buildLoadingState()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Success Header
                  _buildSuccessHeader(),
                  const SizedBox(height: 24),

                  // Experience Ticket Card
                  _buildExperienceTicket(),
                  const SizedBox(height: 24),

                  // Booking Details
                  _buildBookingDetails(),
                  const SizedBox(height: 24),

                  // Passenger Details
                  _buildPassengerDetails(),
                  const SizedBox(height: 24),

                  // Payment Summary
                  _buildPaymentSummary(),
                  const SizedBox(height: 24),

                  // Error Message
                  if (_errorMessage != null) ...[
                    _buildErrorMessage(),
                    const SizedBox(height: 24),
                  ],

                  // Action Buttons
                  _buildActionButtons(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppTheme.primaryColor),
          const SizedBox(height: 16),
          Text(
            'Creating your booking...',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withOpacity(0.1),
            AppTheme.primaryColor.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.checkCircle,
              color: Colors.white,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Ready to Book!',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Review your booking details and proceed to payment',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceTicket() {
    final experienceTitle =
        widget.bookingData['experienceTitle'] ?? 'Experience';
    final location = widget.bookingData['location'] ?? '';
    final imageUrl = widget.bookingData['imageUrl'] ?? '';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          // Experience Image
          if (imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: Icon(
                    LucideIcons.image,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Experience Title
                Text(
                  experienceTitle,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),

                // Location
                Row(
                  children: [
                    Icon(
                      LucideIcons.mapPin,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        location,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Divider
                Divider(color: Colors.grey[200]),
                const SizedBox(height: 16),

                // Date & Time
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        icon: LucideIcons.calendar,
                        label: 'Date',
                        value: _formatDate(
                            widget.bookingData['selectedDate'] ?? ''),
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        icon: LucideIcons.clock,
                        label: 'Time',
                        value: widget.bookingData['selectedTime'] ?? '',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            'Booking Details',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
              'Passengers', '${widget.bookingData['passengerCount'] ?? 0}'),
          _buildDetailRow(
              'Adults', '${widget.bookingData['totalAdults'] ?? 0}'),
          if ((widget.bookingData['totalChildren'] ?? 0) > 0)
            _buildDetailRow(
                'Children', '${widget.bookingData['totalChildren']}'),
          if (widget.bookingData['specialRequests'] != null &&
              widget.bookingData['specialRequests'].toString().isNotEmpty) ...[
            const SizedBox(height: 12),
            Divider(color: Colors.grey[200]),
            const SizedBox(height: 12),
            Text(
              'Special Requests',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.bookingData['specialRequests'],
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPassengerDetails() {
    final passengers = widget.bookingData['passengers'] as List<dynamic>? ?? [];

    if (passengers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            'Passenger Information',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          ...passengers.asMap().entries.map((entry) {
            final index = entry.key;
            final passenger = entry.value as Map<String, dynamic>;
            return Column(
              children: [
                if (index > 0) const SizedBox(height: 12),
                if (index > 0) Divider(color: Colors.grey[200]),
                if (index > 0) const SizedBox(height: 12),
                _buildPassengerCard(passenger, index + 1),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPassengerCard(Map<String, dynamic> passenger, int number) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Passenger $number ${passenger['isUser'] == true ? '(You)' : ''}',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        _buildDetailRow(
            'Name', '${passenger['firstName']} ${passenger['lastName']}'),
        _buildDetailRow('Age', '${passenger['age']} years'),
        _buildDetailRow('Nationality', passenger['nationality'] ?? 'N/A'),
      ],
    );
  }

  Widget _buildPaymentSummary() {
    final totalPriceUSD = widget.bookingData['totalPrice'] ?? 0.0;
    final pricePerPersonUSD = widget.bookingData['pricePerPerson'] ?? 0.0;
    final passengerCount = widget.bookingData['passengerCount'] ?? 1;

    // Convert to KES for payment
    final totalPriceKES =
        totalPriceUSD * AppConfig.exchangeRates['USD_TO_KES']!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withOpacity(0.05),
            AppTheme.primaryColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Summary',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          _buildPriceRow('Price per person',
              '\$${pricePerPersonUSD.toStringAsFixed(2)} USD'),
          _buildPriceRow('Number of passengers', '$passengerCount'),
          const SizedBox(height: 12),
          Divider(color: AppTheme.primaryColor.withOpacity(0.3)),
          const SizedBox(height: 12),
          _buildPriceRow(
            'Total (USD)',
            '\$${totalPriceUSD.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 8),
          _buildPriceRow(
            'You Pay (KES)',
            'KES ${totalPriceKES.toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.alertCircle, color: Colors.red[700], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.red[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Proceed to Payment Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isCreatingBooking ? null : _proceedToPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isCreatingBooking
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.creditCard, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Proceed to Payment',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 12),

        // Cancel Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed:
                _isCreatingBooking ? null : () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[700],
              side: BorderSide(color: Colors.grey[300]!),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 6),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: isTotal ? Colors.black : Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
              color: isTotal ? AppTheme.primaryColor : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _proceedToPayment() async {
    setState(() {
      _isCreatingBooking = true;
      _errorMessage = null;
    });

    try {
      print('📤 Creating experience booking...');
      print('   - Experience ID: ${widget.bookingData['experienceId']}');
      print('   - Company ID: ${widget.bookingData['companyId']}');

      // Create the booking directly via API
      final apiClient = ApiClient();
      final response = await apiClient.post('/api/bookings', {
        'bookingType': 'experience',
        'experienceTemplateId': widget.bookingData['experienceId'],
        'companyId': widget.bookingData['companyId'],
        'totalPrice': widget.bookingData['totalPrice'],
        'subtotal': widget.bookingData['totalPrice'],
        'taxType': null,
        'taxAmount': 0,
        'departureDateTime': widget.bookingData['selectedDate'],
        'totalAdults': widget.bookingData['totalAdults'] ?? 1,
        'totalChildren': widget.bookingData['totalChildren'] ?? 0,
        'onboardDining': false,
        'specialRequirements': widget.bookingData['specialRequests'],
        'passengers': widget.bookingData['passengers'],
      });

      // Extract booking ID from response
      final bookingId =
          response['data']?['id'] ?? response['id'] ?? response['bookingId'];

      print('✅ Booking created successfully!');
      print('   - Booking ID: $bookingId');
      print('   - Response: $response');

      if (bookingId == null) {
        throw Exception('Booking created but no ID returned');
      }

      // Get user email
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.currentUser;
      final userEmail = user?.email ?? 'customer@example.com';

      setState(() {
        _isCreatingBooking = false;
      });

      // Convert USD to KES for Paystack (Paystack only supports KES in Kenya)
      final amountUSD = widget.bookingData['totalPrice'] ?? 0.0;
      final amountKES = amountUSD * AppConfig.exchangeRates['USD_TO_KES']!;

      print('🔵 Navigating to payment screen...');
      print('   - Booking ID: $bookingId');
      print('   - Amount (USD): \$${amountUSD.toStringAsFixed(2)}');
      print('   - Amount (KES): KES ${amountKES.toStringAsFixed(2)}');

      // Navigate to payment screen
      if (mounted) {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InAppCheckoutScreen(
              bookingId: bookingId.toString(),
              amount: amountKES, // Convert to KES for Paystack
              currency: AppConfig.paystackCurrency, // Use KES
              email: userEmail,
              companyId: widget.bookingData['companyId'] ?? 1,
              preferredPaymentMethod: 'card',
            ),
          ),
        );

        print('🔵 Payment screen returned with result: $result');

        // Handle payment result (InAppCheckoutScreen returns Map or false)
        if (result != null && result != false && result is Map) {
          final action = result['action'];

          if (action == 'view_ticket') {
            print('✅ Payment successful! Navigating to trips...');
            if (mounted) {
              // Pop all routes and navigate to trips
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.trips,
                (route) => false,
              );
            }
          } else if (action == 'done') {
            print('✅ Payment successful! Navigating to home...');
            if (mounted) {
              // Pop all routes and go to home
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.root,
                (route) => false,
              );

              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Payment successful! Check your trips for details.',
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          }
        } else {
          print('⚠️ Payment not completed or cancelled');
        }
      }
    } catch (e) {
      print('❌ Booking creation error: $e');
      setState(() {
        String errorMessage = e.toString().replaceAll('Exception: ', '');

        // Check for authentication errors
        if (errorMessage.contains('401') ||
            errorMessage.contains('Authentication') ||
            errorMessage.contains('Unauthorized')) {
          errorMessage = 'Your session has expired. Please log in again.';
        } else if (errorMessage.contains('Network error')) {
          errorMessage =
              'Network error. Please check your connection and try again.';
        }

        _errorMessage = errorMessage;
        _isCreatingBooking = false;
      });
    }
  }
}
