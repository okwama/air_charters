import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/saved_card_model.dart';

class CardInputWidget extends StatefulWidget {
  final SavedCardModel? initialCard;
  final Function(SavedCardModel) onCardSaved;
  final bool showSaveCardOption;
  final bool isRequired;

  const CardInputWidget({
    Key? key,
    this.initialCard,
    required this.onCardSaved,
    this.showSaveCardOption = true,
    this.isRequired = true,
  }) : super(key: key);

  @override
  State<CardInputWidget> createState() => _CardInputWidgetState();
}

class _CardInputWidgetState extends State<CardInputWidget> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvcController = TextEditingController();
  final _cardholderNameController = TextEditingController();
  final _billingZipController = TextEditingController();

  bool _saveCard = false;
  String _cardType = 'unknown';
  bool _isCardValid = false;

  @override
  void initState() {
    super.initState();
    _initializeCard();
    _addListeners();
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    _cardholderNameController.dispose();
    _billingZipController.dispose();
    super.dispose();
  }

  void _initializeCard() {
    if (widget.initialCard != null) {
      final card = widget.initialCard!;
      _cardNumberController.text = card.cardNumber;
      _expiryController.text = card.expiryDisplay;
      _cvcController.text = card.cvc;
      _cardholderNameController.text = card.cardholderName;
      _billingZipController.text = card.billingZip ?? '';
      _cardType = card.cardType;
      _saveCard = card.isDefault;
    }
  }

  void _addListeners() {
    _cardNumberController.addListener(_validateCard);
    _expiryController.addListener(_validateCard);
    _cvcController.addListener(_validateCard);
    _cardholderNameController.addListener(_validateCard);
  }

  void _validateCard() {
    final cardNumber = _cardNumberController.text.replaceAll(RegExp(r'\s'), '');
    final expiry = _expiryController.text;
    final cvc = _cvcController.text;
    final cardholderName = _cardholderNameController.text.trim();

    // Detect card type
    _cardType = _detectCardType(cardNumber);

    // Validate card
    final isValid = cardNumber.length >= 13 &&
        expiry.length >= 5 &&
        cvc.length >= 3 &&
        cardholderName.isNotEmpty;

    if (_isCardValid != isValid) {
      setState(() {
        _isCardValid = isValid;
      });
    }
  }

  String _detectCardType(String cardNumber) {
    if (cardNumber.startsWith('4')) return 'visa';
    if (cardNumber.startsWith('5')) return 'mastercard';
    if (cardNumber.startsWith('3')) return 'amex';
    if (cardNumber.startsWith('6')) return 'discover';
    return 'unknown';
  }

  void _formatCardNumber(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    final formatted = digits
        .replaceAllMapped(
          RegExp(r'(\d{4})'),
          (match) => '${match.group(1)} ',
        )
        .trim();

    if (formatted != value) {
      _cardNumberController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  void _formatExpiry(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    String formatted = digits;

    if (digits.length >= 2) {
      formatted = '${digits.substring(0, 2)}/${digits.substring(2)}';
    }

    if (formatted != value) {
      _expiryController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  SavedCardModel _getCardData() {
    final expiry = _expiryController.text.split('/');
    final month = expiry.isNotEmpty ? expiry[0] : '';
    final year = expiry.length > 1 ? expiry[1] : '';

    return SavedCardModel(
      cardNumber: _cardNumberController.text.replaceAll(RegExp(r'\s'), ''),
      expiryMonth: month,
      expiryYear: year,
      cvc: _cvcController.text,
      cardholderName: _cardholderNameController.text.trim(),
      billingZip: _billingZipController.text.trim(),
      cardType: _cardType,
      isDefault: _saveCard,
    );
  }

  void _saveCardData() {
    if (_formKey.currentState!.validate()) {
      final cardData = _getCardData();
      widget.onCardSaved(cardData);
    }
  }

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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.credit_card, color: Colors.grey.shade600, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Card Details',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                if (widget.isRequired)
                  const Text(
                    ' *',
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Card Number
            TextFormField(
              controller: _cardNumberController,
              decoration: InputDecoration(
                labelText: 'Card Number',
                hintText: '1234 5678 9012 3456',
                prefixIcon: _getCardTypeIcon(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.black),
                ),
              ),
              keyboardType: TextInputType.number,
              onChanged: _formatCardNumber,
              validator: (value) {
                if (widget.isRequired &&
                    (value == null || value.trim().isEmpty)) {
                  return 'Card number is required';
                }
                final digits = value?.replaceAll(RegExp(r'\s'), '') ?? '';
                if (widget.isRequired && digits.length < 13) {
                  return 'Please enter a valid card number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Expiry and CVC Row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _expiryController,
                    decoration: InputDecoration(
                      labelText: 'Expiry Date',
                      hintText: 'MM/YY',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: _formatExpiry,
                    validator: (value) {
                      if (widget.isRequired &&
                          (value == null || value.trim().isEmpty)) {
                        return 'Expiry is required';
                      }
                      if (widget.isRequired && value!.length < 5) {
                        return 'MM/YY';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _cvcController,
                    decoration: InputDecoration(
                      labelText: 'CVC',
                      hintText: '123',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (widget.isRequired &&
                          (value == null || value.trim().isEmpty)) {
                        return 'CVC is required';
                      }
                      if (widget.isRequired && value!.length < 3) {
                        return '3 digits';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Cardholder Name
            TextFormField(
              controller: _cardholderNameController,
              decoration: InputDecoration(
                labelText: 'Cardholder Name',
                hintText: 'John Doe',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.black),
                ),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (widget.isRequired &&
                    (value == null || value.trim().isEmpty)) {
                  return 'Cardholder name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Billing ZIP (Optional)
            TextFormField(
              controller: _billingZipController,
              decoration: InputDecoration(
                labelText: 'Billing ZIP Code (Optional)',
                hintText: '12345',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.black),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Save Card Option
            if (widget.showSaveCardOption)
              Row(
                children: [
                  Checkbox(
                    value: _saveCard,
                    onChanged: (value) {
                      setState(() {
                        _saveCard = value ?? false;
                      });
                    },
                    activeColor: Colors.black,
                  ),
                  Expanded(
                    child: Text(
                      'Save this card for future payments',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),

            // Card Validation Status
            if (kDebugMode)
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color:
                      _isCardValid ? Colors.green.shade50 : Colors.red.shade50,
                  border: Border.all(
                    color: _isCardValid
                        ? Colors.green.shade200
                        : Colors.red.shade200,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isCardValid ? Icons.check_circle : Icons.error,
                      color: _isCardValid ? Colors.green : Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isCardValid
                          ? 'Card details are valid'
                          : 'Please complete all required fields',
                      style: TextStyle(
                        fontSize: 12,
                        color: _isCardValid
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _getCardTypeIcon() {
    switch (_cardType) {
      case 'visa':
        return Icon(Icons.credit_card, color: Colors.blue.shade600);
      case 'mastercard':
        return Icon(Icons.credit_card, color: Colors.orange.shade600);
      case 'amex':
        return Icon(Icons.credit_card, color: Colors.green.shade600);
      case 'discover':
        return Icon(Icons.credit_card, color: Colors.red.shade600);
      default:
        return Icon(Icons.credit_card, color: Colors.grey.shade600);
    }
  }
}
