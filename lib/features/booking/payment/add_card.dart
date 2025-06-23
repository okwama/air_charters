import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AddCardPage extends StatefulWidget {
  const AddCardPage({super.key});

  @override
  State<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _nameController = TextEditingController();
  final _expiryController = TextEditingController();
  final _securityCodeController = TextEditingController();

  final _cardNumberFocus = FocusNode();
  final _nameFocus = FocusNode();
  final _expiryFocus = FocusNode();
  final _securityCodeFocus = FocusNode();

  String _cardType = '';

  @override
  void initState() {
    super.initState();
    _cardNumberController.addListener(_onCardNumberChanged);
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _nameController.dispose();
    _expiryController.dispose();
    _securityCodeController.dispose();
    _cardNumberFocus.dispose();
    _nameFocus.dispose();
    _expiryFocus.dispose();
    _securityCodeFocus.dispose();
    super.dispose();
  }

  void _onCardNumberChanged() {
    final cardNumber = _cardNumberController.text.replaceAll(' ', '');
    String newCardType = '';

    if (cardNumber.startsWith('4')) {
      newCardType = 'Visa';
    } else if (cardNumber.startsWith('5') || cardNumber.startsWith('2')) {
      newCardType = 'Mastercard';
    } else if (cardNumber.startsWith('3')) {
      newCardType = 'American Express';
    }

    if (newCardType != _cardType) {
      setState(() {
        _cardType = newCardType;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with X button and title
            _buildHeader(),

            // Form content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // Card preview
                      _buildCardPreview(),

                      const SizedBox(height: 40),

                      // Card Number field
                      _buildCardNumberField(),

                      const SizedBox(height: 20),

                      // Name on Card field
                      _buildNameField(),

                      const SizedBox(height: 20),

                      // Expiry and Security Code row
                      Row(
                        children: [
                          Expanded(
                            child: _buildExpiryField(),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildSecurityCodeField(),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      // Save Payment button
                      _buildSaveButton(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.close_rounded,
              color: Color(0xFF666666),
              size: 24,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 16),
          Text(
            'Add Card',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardPreview() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1a1a1a),
            Color(0xFF2d2d2d),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card type and logo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _cardType.isEmpty ? 'CARD TYPE' : _cardType.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.8),
                    letterSpacing: 1.2,
                  ),
                ),
                if (_cardType == 'Mastercard')
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEB001B),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.only(left: -8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF79E1B),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            const Spacer(),

            // Card number
            Text(
              _formatCardNumber(_cardNumberController.text),
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: 20),

            // Name and expiry
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CARDHOLDER NAME',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.6),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _nameController.text.isEmpty
                          ? 'FULL NAME'
                          : _nameController.text.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'EXPIRY',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.6),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _expiryController.text.isEmpty
                          ? 'MM/YY'
                          : _expiryController.text,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Card Number',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _cardNumberController,
          focusNode: _cardNumberFocus,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(19),
            _CardNumberInputFormatter(),
          ],
          decoration: InputDecoration(
            hintText: '1234 5678 9012 3456',
            hintStyle: GoogleFonts.inter(
              fontSize: 16,
              color: const Color(0xFF888888),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            suffixIcon: _cardType.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _buildCardTypeIcon(),
                  )
                : null,
          ),
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter card number';
            }
            final cardNumber = value.replaceAll(' ', '');
            if (cardNumber.length < 13 || cardNumber.length > 19) {
              return 'Please enter a valid card number';
            }
            return null;
          },
          onFieldSubmitted: (_) {
            FocusScope.of(context).requestFocus(_nameFocus);
          },
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Name on Card',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          focusNode: _nameFocus,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'John Doe',
            hintStyle: GoogleFonts.inter(
              fontSize: 16,
              color: const Color(0xFF888888),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter name on card';
            }
            if (value.length < 2) {
              return 'Please enter a valid name';
            }
            return null;
          },
          onChanged: (value) {
            setState(() {});
          },
          onFieldSubmitted: (_) {
            FocusScope.of(context).requestFocus(_expiryFocus);
          },
        ),
      ],
    );
  }

  Widget _buildExpiryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Expiry Date',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _expiryController,
          focusNode: _expiryFocus,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
            _ExpiryDateInputFormatter(),
          ],
          decoration: InputDecoration(
            hintText: 'MM/YY',
            hintStyle: GoogleFonts.inter(
              fontSize: 16,
              color: const Color(0xFF888888),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Required';
            }
            if (value.length != 5) {
              return 'Invalid';
            }
            return null;
          },
          onChanged: (value) {
            setState(() {});
          },
          onFieldSubmitted: (_) {
            FocusScope.of(context).requestFocus(_securityCodeFocus);
          },
        ),
      ],
    );
  }

  Widget _buildSecurityCodeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Security Code',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _securityCodeController,
          focusNode: _securityCodeFocus,
          keyboardType: TextInputType.number,
          obscureText: true,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
          ],
          decoration: InputDecoration(
            hintText: '123',
            hintStyle: GoogleFonts.inter(
              fontSize: 16,
              color: const Color(0xFF888888),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Required';
            }
            if (value.length < 3) {
              return 'Invalid';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _savePaymentMethod();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          'Save Payment',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildCardTypeIcon() {
    switch (_cardType) {
      case 'Visa':
        return Container(
          width: 32,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1F71),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              'VISA',
              style: GoogleFonts.inter(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        );
      case 'Mastercard':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: Color(0xFFEB001B),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 16,
              height: 16,
              margin: const EdgeInsets.only(left: -6),
              decoration: const BoxDecoration(
                color: Color(0xFFF79E1B),
                shape: BoxShape.circle,
              ),
            ),
          ],
        );
      case 'American Express':
        return Container(
          width: 32,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFF006FCF),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              'AMEX',
              style: GoogleFonts.inter(
                fontSize: 7,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  String _formatCardNumber(String cardNumber) {
    if (cardNumber.isEmpty) return '**** **** **** ****';

    final formatted = cardNumber.replaceAll(' ', '');
    String result = '';

    for (int i = 0; i < formatted.length; i++) {
      if (i > 0 && i % 4 == 0) {
        result += ' ';
      }
      result += formatted[i];
    }

    // Fill remaining with asterisks
    while (result.replaceAll(' ', '').length < 16) {
      if (result.replaceAll(' ', '').length % 4 == 0 && result.isNotEmpty) {
        result += ' ';
      }
      result += '*';
    }

    return result;
  }

  void _savePaymentMethod() {
    // Show success message and return
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Payment method saved successfully',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );

    // Return to previous screen after a short delay with success result
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
      }
    });
  }
}

// Custom input formatter for card number
class _CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;
    final buffer = StringBuffer();

    for (int i = 0; i < newText.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(newText[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// Custom input formatter for expiry date
class _ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;

    if (newText.length <= 2) {
      return newValue;
    }

    final month = newText.substring(0, 2);
    final year = newText.substring(2);

    return TextEditingValue(
      text: '$month/$year',
      selection: TextSelection.collapsed(offset: '$month/$year'.length),
    );
  }
}
