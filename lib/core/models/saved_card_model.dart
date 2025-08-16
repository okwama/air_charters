class SavedCardModel {
  final String? id;
  final String cardNumber;
  final String expiryMonth;
  final String expiryYear;
  final String cvc;
  final String cardholderName;
  final String? billingZip;
  final String cardType; // 'visa', 'mastercard', etc.
  final bool isDefault;

  const SavedCardModel({
    this.id,
    required this.cardNumber,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cvc,
    required this.cardholderName,
    this.billingZip,
    required this.cardType,
    this.isDefault = false,
  });

  factory SavedCardModel.fromJson(Map<String, dynamic> json) {
    return SavedCardModel(
      id: json['id']?.toString(),
      cardNumber: json['cardNumber']?.toString() ?? '',
      expiryMonth: json['expiryMonth']?.toString() ?? '',
      expiryYear: json['expiryYear']?.toString() ?? '',
      cvc: json['cvc']?.toString() ?? '',
      cardholderName: json['cardholderName']?.toString() ?? '',
      billingZip: json['billingZip']?.toString(),
      cardType: json['cardType']?.toString() ?? 'unknown',
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'cardNumber': cardNumber,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'cvc': cvc,
      'cardholderName': cardholderName,
      if (billingZip != null) 'billingZip': billingZip,
      'cardType': cardType,
      'isDefault': isDefault,
    };
  }

  // Create a masked version for display
  String get maskedCardNumber {
    if (cardNumber.length < 4) return cardNumber;
    return '•••• •••• •••• ${cardNumber.substring(cardNumber.length - 4)}';
  }

  // Get expiry display
  String get expiryDisplay => '$expiryMonth/$expiryYear';

  // Get card type display
  String get cardTypeDisplay {
    switch (cardType.toLowerCase()) {
      case 'visa':
        return 'Visa';
      case 'mastercard':
        return 'Mastercard';
      case 'amex':
        return 'American Express';
      case 'discover':
        return 'Discover';
      default:
        return 'Card';
    }
  }

  // Check if card is valid
  bool get isValid {
    return cardNumber.length >= 13 &&
        expiryMonth.isNotEmpty &&
        expiryYear.isNotEmpty &&
        cvc.length >= 3 &&
        cardholderName.isNotEmpty;
  }

  // Create a copy with updated values
  SavedCardModel copyWith({
    String? id,
    String? cardNumber,
    String? expiryMonth,
    String? expiryYear,
    String? cvc,
    String? cardholderName,
    String? billingZip,
    String? cardType,
    bool? isDefault,
  }) {
    return SavedCardModel(
      id: id ?? this.id,
      cardNumber: cardNumber ?? this.cardNumber,
      expiryMonth: expiryMonth ?? this.expiryMonth,
      expiryYear: expiryYear ?? this.expiryYear,
      cvc: cvc ?? this.cvc,
      cardholderName: cardholderName ?? this.cardholderName,
      billingZip: billingZip ?? this.billingZip,
      cardType: cardType ?? this.cardType,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  String toString() {
    return 'SavedCardModel{id: $id, cardType: $cardType, maskedNumber: $maskedCardNumber, expiry: $expiryDisplay}';
  }
}
