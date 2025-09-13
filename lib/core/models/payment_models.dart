import 'booking_model.dart';

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

/// Unified Payment System Models

class UnifiedPaymentRequest {
  final String bookingId;
  final String paymentIntentId;
  final String? paymentMethodId;
  final Map<String, dynamic>? metadata;

  UnifiedPaymentRequest({
    required this.bookingId,
    required this.paymentIntentId,
    this.paymentMethodId,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'paymentIntentId': paymentIntentId,
      if (paymentMethodId != null) 'paymentMethodId': paymentMethodId,
      if (metadata != null) 'metadata': metadata,
    };
  }
}

class UnifiedPaymentResponse {
  final bool success;
  final String transactionId;
  final String status;
  final double totalAmount;
  final double platformFee;
  final double companyAmount;
  final String currency;
  final String paymentProvider;
  final String? companyId;
  final String? companyName;
  final List<TransactionLedgerEntry> ledgerEntries;
  final BookingModel? booking;
  final String? errorMessage;

  UnifiedPaymentResponse({
    required this.success,
    required this.transactionId,
    required this.status,
    required this.totalAmount,
    required this.platformFee,
    required this.companyAmount,
    required this.currency,
    required this.paymentProvider,
    this.companyId,
    this.companyName,
    required this.ledgerEntries,
    this.booking,
    this.errorMessage,
  });

  factory UnifiedPaymentResponse.fromJson(Map<String, dynamic> json) {
    return UnifiedPaymentResponse(
      success: json['success'] ?? false,
      transactionId: json['transactionId'] ?? '',
      status: json['status'] ?? '',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      platformFee: (json['platformFee'] ?? 0).toDouble(),
      companyAmount: (json['companyAmount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'USD',
      paymentProvider: json['paymentProvider'] ?? '',
      companyId: json['companyId'],
      companyName: json['companyName'],
      ledgerEntries: (json['ledgerEntries'] as List<dynamic>?)
              ?.map((entry) => TransactionLedgerEntry.fromJson(entry))
              .toList() ??
          [],
      booking: json['booking'] != null
          ? BookingModel.fromJson(json['booking'])
          : null,
      errorMessage: json['errorMessage'],
    );
  }
}

class TransactionLedgerEntry {
  final String id;
  final String transactionId;
  final String? parentTransactionId;
  final String? companyId;
  final String userId;
  final String bookingId;
  final String transactionType;
  final String paymentProvider;
  final double amount;
  final String currency;
  final double baseAmount;
  final double fee;
  final double tax;
  final double netAmount;
  final String status;
  final String description;
  final Map<String, dynamic>? metadata;
  final Map<String, dynamic>? providerMetadata;
  final String? errorMessage;
  final DateTime createdAt;

  TransactionLedgerEntry({
    required this.id,
    required this.transactionId,
    this.parentTransactionId,
    this.companyId,
    required this.userId,
    required this.bookingId,
    required this.transactionType,
    required this.paymentProvider,
    required this.amount,
    required this.currency,
    required this.baseAmount,
    required this.fee,
    required this.tax,
    required this.netAmount,
    required this.status,
    required this.description,
    this.metadata,
    this.providerMetadata,
    this.errorMessage,
    required this.createdAt,
  });

  factory TransactionLedgerEntry.fromJson(Map<String, dynamic> json) {
    return TransactionLedgerEntry(
      id: json['id'] ?? '',
      transactionId: json['transactionId'] ?? '',
      parentTransactionId: json['parentTransactionId'],
      companyId: json['companyId'],
      userId: json['userId'] ?? '',
      bookingId: json['bookingId'] ?? '',
      transactionType: json['transactionType'] ?? '',
      paymentProvider: json['paymentProvider'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'USD',
      baseAmount: (json['baseAmount'] ?? 0).toDouble(),
      fee: (json['fee'] ?? 0).toDouble(),
      tax: (json['tax'] ?? 0).toDouble(),
      netAmount: (json['netAmount'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      description: json['description'] ?? '',
      metadata: json['metadata'],
      providerMetadata: json['providerMetadata'],
      errorMessage: json['errorMessage'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class CompanyPaymentAccount {
  final String id;
  final String companyId;
  final String companyName;
  final String provider;
  final bool isActive;
  final Map<String, dynamic>? providerConfig;
  final DateTime createdAt;
  final DateTime updatedAt;

  CompanyPaymentAccount({
    required this.id,
    required this.companyId,
    required this.companyName,
    required this.provider,
    required this.isActive,
    this.providerConfig,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CompanyPaymentAccount.fromJson(Map<String, dynamic> json) {
    return CompanyPaymentAccount(
      id: json['id'] ?? '',
      companyId: json['companyId'] ?? '',
      companyName: json['companyName'] ?? '',
      provider: json['provider'] ?? '',
      isActive: json['isActive'] ?? false,
      providerConfig: json['providerConfig'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class PaymentProviderInfo {
  final String name;
  final String type;
  final bool isAvailable;
  final Map<String, dynamic>? config;

  PaymentProviderInfo({
    required this.name,
    required this.type,
    required this.isAvailable,
    this.config,
  });

  factory PaymentProviderInfo.fromJson(Map<String, dynamic> json) {
    return PaymentProviderInfo(
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      isAvailable: json['isAvailable'] ?? false,
      config: json['config'],
    );
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
