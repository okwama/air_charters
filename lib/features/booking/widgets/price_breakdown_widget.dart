import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PriceBreakdownWidget extends StatelessWidget {
  final double basePrice;
  final bool onboardDining;
  final bool groundTransportation;

  const PriceBreakdownWidget({
    Key? key,
    required this.basePrice,
    required this.onboardDining,
    required this.groundTransportation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final diningCost = onboardDining ? 150.0 : 0.0;
    final transportationCost = groundTransportation ? 200.0 : 0.0;
    final taxes = (basePrice + diningCost + transportationCost) * 0.12;
    final totalPrice = basePrice + diningCost + transportationCost + taxes;

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
            'Price Breakdown',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          _buildPriceItem('Base Charter Cost', basePrice),
          if (onboardDining) _buildPriceItem('Onboard Dining', diningCost),
          if (groundTransportation)
            _buildPriceItem('Ground Transportation', transportationCost),
          _buildPriceItem('Taxes & Fees', taxes),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFE5E5E5)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              Text(
                '\$${totalPrice.toStringAsFixed(2)}',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceItem(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF666666),
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
