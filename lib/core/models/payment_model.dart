enum PaymentMethod {
  card,
  mpesa,
  wallet,
}

enum PaymentStatus {
  pending,
  completed,
  failed,
  refunded,
}

class PaymentModel {
  final String id;
  final String bookingId;
  final String userId;
  final int companyId;
  final PaymentMethod paymentMethod;
  final double totalAmount;
  final double platformFee;
  final double companyAmount;
  final String currency;
  final String? transactionId;
  final PaymentStatus paymentStatus;
  final Map<String, dynamic>? paymentGatewayResponse;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PaymentModel({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.companyId,
    required this.paymentMethod,
    required this.totalAmount,
    required this.platformFee,
    required this.companyAmount,
    required this.currency,
    this.transactionId,
    required this.paymentStatus,
    this.paymentGatewayResponse,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] ?? '',
      bookingId: json['bookingId'] ?? json['booking_id'] ?? '',
      userId: json['userId'] ?? json['user_id'] ?? '',
      companyId: json['companyId'] ?? json['company_id'] ?? 0,
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == (json['paymentMethod'] ?? json['payment_method']),
        orElse: () => PaymentMethod.card,
      ),
      totalAmount: double.tryParse(json['totalAmount']?.toString() ??
              json['total_amount']?.toString() ??
              '0') ??
          0.0,
      platformFee: double.tryParse(json['platformFee']?.toString() ??
              json['platform_fee']?.toString() ??
              '0') ??
          0.0,
      companyAmount: double.tryParse(json['companyAmount']?.toString() ??
              json['company_amount']?.toString() ??
              '0') ??
          0.0,
      currency: json['currency'] ?? 'USD',
      transactionId: json['transactionId'] ?? json['transaction_id'],
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == (json['paymentStatus'] ?? json['payment_status']),
        orElse: () => PaymentStatus.pending,
      ),
      paymentGatewayResponse:
          json['paymentGatewayResponse'] ?? json['payment_gateway_response'],
      createdAt:
          DateTime.tryParse(json['createdAt'] ?? json['created_at'] ?? '') ??
              DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt'] ?? json['updated_at'] ?? '') ??
              DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'userId': userId,
      'companyId': companyId,
      'paymentMethod': paymentMethod.name,
      'totalAmount': totalAmount,
      'platformFee': platformFee,
      'companyAmount': companyAmount,
      'currency': currency,
      'transactionId': transactionId,
      'paymentStatus': paymentStatus.name,
      'paymentGatewayResponse': paymentGatewayResponse,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Helper methods
  String get formattedAmount => '$currency ${totalAmount.toStringAsFixed(2)}';

  bool get isCompleted => paymentStatus == PaymentStatus.completed;

  bool get canBeRefunded => paymentStatus == PaymentStatus.completed;

  String get statusDisplayText {
    switch (paymentStatus) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.completed:
        return 'Completed';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }

  String get methodDisplayText {
    switch (paymentMethod) {
      case PaymentMethod.card:
        return 'Credit/Debit Card';
      case PaymentMethod.mpesa:
        return 'M-Pesa';
      case PaymentMethod.wallet:
        return 'Wallet';
    }
  }
}
