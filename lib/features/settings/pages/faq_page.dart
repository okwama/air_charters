import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class FAQPage extends StatefulWidget {
  const FAQPage({super.key});

  @override
  State<FAQPage> createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  final List<FAQItem> _faqItems = [
    FAQItem(
      question: 'How do I book a charter flight?',
      answer:
          'To book a charter flight, navigate to the "Direct Charter" tab, select your origin and destination, choose your dates, and browse available aircraft. You can then select your preferred option and proceed with the booking.',
    ),
    FAQItem(
      question: 'What payment methods do you accept?',
      answer:
          'We accept all major credit cards (Visa, MasterCard, American Express), debit cards, and digital wallets. Payment is processed securely through our payment partners.',
    ),
    FAQItem(
      question: 'Can I cancel or modify my booking?',
      answer:
          'Yes, you can modify or cancel your booking up to 24 hours before departure. Cancellation fees may apply depending on the airline and fare type. Check your booking confirmation for specific terms.',
    ),
    FAQItem(
      question: 'What happens if my flight is delayed or cancelled?',
      answer:
          'In case of delays or cancellations, we will notify you immediately and work to rebook you on the next available flight. Compensation may be available depending on the circumstances.',
    ),
    FAQItem(
      question: 'Do you offer group bookings?',
      answer:
          'Yes, we offer group bookings for corporate events, family trips, and special occasions. Contact our support team for group booking inquiries and special rates.',
    ),
    FAQItem(
      question: 'What documents do I need to travel?',
      answer:
          'You will need a valid government-issued photo ID (passport for international flights). Additional documents may be required depending on your destination. Check with your airline for specific requirements.',
    ),
    FAQItem(
      question: 'Is luggage included in the price?',
      answer:
          'Luggage allowance varies by aircraft type and route. Standard allowance is typically 1-2 checked bags per passenger. Additional luggage can be purchased if needed.',
    ),
    FAQItem(
      question: 'Can I bring pets on board?',
      answer:
          'Pet policies vary by aircraft and route. Some aircraft allow pets in carriers, while others may have restrictions. Please contact us in advance to arrange pet travel.',
    ),
    FAQItem(
      question: 'How far in advance should I book?',
      answer:
          'We recommend booking at least 48-72 hours in advance for domestic flights and 1-2 weeks for international flights. Last-minute bookings are available but may have limited options.',
    ),
    FAQItem(
      question: 'Do you offer loyalty rewards?',
      answer:
          'Yes, we have a loyalty program that rewards frequent flyers with points, discounts, and exclusive benefits. Points can be earned on every booking and redeemed for future flights.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Frequently Asked Questions',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  LucideIcons.helpCircle,
                  size: 48,
                  color: Colors.blue.shade600,
                ),
                const SizedBox(height: 16),
                Text(
                  'Need Help?',
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Find answers to common questions about our services',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // FAQ List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _faqItems.length,
              itemBuilder: (context, index) {
                return _buildFAQItem(_faqItems[index]);
              },
            ),
          ),

          // Contact Support Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: ElevatedButton(
              onPressed: () {
                // Navigate to contact support
                Navigator.pop(context);
                // You can add navigation to contact support here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.messageCircle, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Still Need Help? Contact Support',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(FAQItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Text(
          item.question,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        iconColor: Colors.blue.shade600,
        collapsedIconColor: Colors.grey.shade600,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              item.answer,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({
    required this.question,
    required this.answer,
  });
}
