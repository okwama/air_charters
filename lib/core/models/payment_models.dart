class PaymentIntentModel {
  final String id;
  final String clientSecret;
  final String status;
  final double amount;
  final String currency;
  final bool requiresAction;
  final Map<String, dynamic>? nextAction;

  PaymentIntentModel({
    required this.id,
    required this.clientSecret,
    required this.status,
    required this.amount,
    required this.currency,
    this.requiresAction = false,
    this.nextAction,
  });

  factory PaymentIntentModel.fromJson(Map<String, dynamic> json) {
    return PaymentIntentModel(
      id: json['id'] ?? '',
      clientSecret: json['clientSecret'] ?? '',
      status: json['status'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'USD',
      requiresAction: json['requiresAction'] ?? false,
      nextAction: json['nextAction'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientSecret': clientSecret,
      'status': status,
      'amount': amount,
      'currency': currency,
      'requiresAction': requiresAction,
      'nextAction': nextAction,
    };
  }
}

class PaymentMethodModel {
  final String id;
  final String type;
  final String? brand;
  final String? last4;
  final int? expiryMonth;
  final int? expiryYear;

  PaymentMethodModel({
    required this.id,
    required this.type,
    this.brand,
    this.last4,
    this.expiryMonth,
    this.expiryYear,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      brand: json['brand'],
      last4: json['last4'],
      expiryMonth: json['expiryMonth'],
      expiryYear: json['expiryYear'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'brand': brand,
      'last4': last4,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
    };
  }
}

class PaymentConfirmationModel {
  final String id;
  final String status;
  final double amount;
  final String currency;
  final String transactionId;
  final String paymentMethod;

  PaymentConfirmationModel({
    required this.id,
    required this.status,
    required this.amount,
    required this.currency,
    required this.transactionId,
    required this.paymentMethod,
  });

  factory PaymentConfirmationModel.fromJson(Map<String, dynamic> json) {
    return PaymentConfirmationModel(
      id: json['id'] ?? '',
      status: json['status'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'USD',
      transactionId: json['transactionId'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'amount': amount,
      'currency': currency,
      'transactionId': transactionId,
      'paymentMethod': paymentMethod,
    };
  }
}

class BillingDetailsModel {
  final String? name;
  final String? email;
  final String? phone;
  final AddressModel? address;

  BillingDetailsModel({
    this.name,
    this.email,
    this.phone,
    this.address,
  });

  factory BillingDetailsModel.fromJson(Map<String, dynamic> json) {
    return BillingDetailsModel(
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'] != null
          ? AddressModel.fromJson(json['address'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address?.toJson(),
    };
  }
}

class AddressModel {
  final String? line1;
  final String? line2;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;

  AddressModel({
    this.line1,
    this.line2,
    this.city,
    this.state,
    this.postalCode,
    this.country,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      line1: json['line1'],
      line2: json['line2'],
      city: json['city'],
      state: json['state'],
      postalCode: json['postalCode'],
      country: json['country'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'line1': line1,
      'line2': line2,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
    };
  }
}
