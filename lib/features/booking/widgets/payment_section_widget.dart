import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentSectionWidget extends StatefulWidget {
  final String selectedPaymentMethod;
  final List<Map<String, dynamic>> savedCards;
  final VoidCallback onChangePaymentMethod;

  const PaymentSectionWidget({
    Key? key,
    required this.selectedPaymentMethod,
    required this.savedCards,
    required this.onChangePaymentMethod,
  }) : super(key: key);

  @override
  State<PaymentSectionWidget> createState() => _PaymentSectionWidgetState();
}

class _PaymentSectionWidgetState extends State<PaymentSectionWidget> {
  @override
  Widget build(BuildContext context) {
    // Find the selected payment method details
    Map<String, dynamic>? selectedCard = widget.savedCards.firstWhere(
      (card) => card['name'] == widget.selectedPaymentMethod,
      orElse: () => {},
    );

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payment Method',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              TextButton(
                onPressed: widget.onChangePaymentMethod,
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Change',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Selected Payment Method Display
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE8E8E8),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFE8E8E8),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    selectedCard.isNotEmpty
                        ? selectedCard['icon']
                        : Icons.credit_card,
                    size: 20,
                    color: const Color(0xFF666666),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.selectedPaymentMethod,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      if (selectedCard.isNotEmpty &&
                          selectedCard['details'] != null)
                        const SizedBox(height: 4),
                      if (selectedCard.isNotEmpty &&
                          selectedCard['details'] != null)
                        Text(
                          selectedCard['details'],
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF666666),
                          ),
                        ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF2E7D32),
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 