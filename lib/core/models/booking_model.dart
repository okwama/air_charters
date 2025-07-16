import 'passenger_model.dart';

enum BookingStatus {
  pending,
  confirmed,
  cancelled,
  completed,
}

enum PaymentStatus {
  pending,
  paid,
  failed,
  refunded,
}

enum PaymentMethod {
  card,
  mpesa,
  wallet,
}

class BookingModel {
  final String? id;
  final String? referenceNumber;
  final String userId;
  final int dealId;
  final int? companyId; // Added: Company ID from backend
  final double totalPrice;
  final BookingStatus bookingStatus;
  final PaymentStatus paymentStatus;
  final bool onboardDining;
  final bool groundTransportation;
  final String? specialRequirements;
  final String? billingRegion;
  final PaymentMethod? paymentMethod;
  final String? paymentTransactionId; // Added: Payment transaction ID
  final int loyaltyPointsEarned; // Added: Loyalty points earned
  final int loyaltyPointsRedeemed; // Added: Loyalty points redeemed
  final double walletAmountUsed; // Added: Wallet amount used
  final List<PassengerModel> passengers;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Deal-related data (populated from backend relations)
  final String? departure;
  final String? destination;
  final DateTime? departureDate;
  final String? departureTime;
  final int? duration;
  final double? basePrice;
  final String? aircraftName;
  final String? companyName;

  const BookingModel({
    this.id,
    this.referenceNumber,
    required this.userId,
    required this.dealId,
    this.companyId,
    required this.totalPrice,
    this.bookingStatus = BookingStatus.pending,
    this.paymentStatus = PaymentStatus.pending,
    this.onboardDining = false,
    this.groundTransportation = false,
    this.specialRequirements,
    this.billingRegion,
    this.paymentMethod,
    this.paymentTransactionId,
    this.loyaltyPointsEarned = 0,
    this.loyaltyPointsRedeemed = 0,
    this.walletAmountUsed = 0.0,
    this.passengers = const [],
    this.createdAt,
    this.updatedAt,
    // Deal-related data
    this.departure,
    this.destination,
    this.departureDate,
    this.departureTime,
    this.duration,
    this.basePrice,
    this.aircraftName,
    this.companyName,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String?,
      referenceNumber: json['referenceNumber'] as String?,
      userId: json['userId'] as String? ?? '',
      dealId: json['dealId'] as int? ?? 0,
      companyId: json['companyId'] as int?, // Parse company ID
      totalPrice: double.tryParse(json['totalPrice']?.toString() ?? '0') ?? 0.0,
      bookingStatus: _parseBookingStatus(json['bookingStatus'] as String?),
      paymentStatus: _parsePaymentStatus(json['paymentStatus'] as String?),
      onboardDining: json['onboardDining'] as bool? ?? false,
      groundTransportation: json['groundTransportation'] as bool? ?? false,
      specialRequirements: json['specialRequirements'] as String?,
      billingRegion: json['billingRegion'] as String?,
      paymentMethod: _parsePaymentMethod(json['paymentMethod'] as String?),
      paymentTransactionId: json['paymentTransactionId']
          as String?, // Parse payment transaction ID
      loyaltyPointsEarned: json['loyaltyPointsEarned'] as int? ??
          0, // Parse loyalty points earned
      loyaltyPointsRedeemed: json['loyaltyPointsRedeemed'] as int? ??
          0, // Parse loyalty points redeemed
      walletAmountUsed:
          double.tryParse(json['walletAmountUsed']?.toString() ?? '0') ??
              0.0, // Parse wallet amount
      passengers: (json['passengers'] as List<dynamic>?)
              ?.map((p) => PassengerModel.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      // Deal-related data (from relations)
      departure: json['departure'] as String?,
      destination: json['destination'] as String?,
      departureDate: json['departureDate'] != null
          ? DateTime.parse(json['departureDate'] as String)
          : null,
      departureTime: json['departureTime'] as String?,
      duration: json['duration'] as int?,
      basePrice: double.tryParse(json['basePrice']?.toString() ?? '0') ?? 0.0,
      aircraftName: json['aircraftName'] as String?,
      companyName: json['companyName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (referenceNumber != null) 'referenceNumber': referenceNumber,
      'userId': userId,
      'dealId': dealId,
      if (companyId != null) 'companyId': companyId,
      'totalPrice': totalPrice,
      'bookingStatus': bookingStatus.name,
      'paymentStatus': paymentStatus.name,
      'onboardDining': onboardDining,
      'groundTransportation': groundTransportation,
      if (specialRequirements != null)
        'specialRequirements': specialRequirements,
      if (billingRegion != null) 'billingRegion': billingRegion,
      if (paymentMethod != null) 'paymentMethod': paymentMethod!.name,
      if (paymentTransactionId != null)
        'paymentTransactionId': paymentTransactionId,
      'loyaltyPointsEarned': loyaltyPointsEarned,
      'loyaltyPointsRedeemed': loyaltyPointsRedeemed,
      'walletAmountUsed': walletAmountUsed,
      'passengers': passengers.map((p) => p.toCreateJson()).toList(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  // Create JSON for booking creation (without server-generated fields)
  Map<String, dynamic> toCreateJson() {
    return {
      'dealId': dealId,
      'totalPrice': totalPrice,
      'onboardDining': onboardDining,
      'groundTransportation': groundTransportation,
      if (specialRequirements != null)
        'specialRequirements': specialRequirements,
      if (billingRegion != null) 'billingRegion': billingRegion,
      if (paymentMethod != null) 'paymentMethod': paymentMethod!.name,
      'passengers': passengers.map((p) => p.toCreateJson()).toList(),
    };
  }

  BookingModel copyWith({
    String? id,
    String? referenceNumber,
    String? userId,
    int? dealId,
    int? companyId,
    double? totalPrice,
    BookingStatus? bookingStatus,
    PaymentStatus? paymentStatus,
    bool? onboardDining,
    bool? groundTransportation,
    String? specialRequirements,
    String? billingRegion,
    PaymentMethod? paymentMethod,
    String? paymentTransactionId,
    int? loyaltyPointsEarned,
    int? loyaltyPointsRedeemed,
    double? walletAmountUsed,
    List<PassengerModel>? passengers,
    DateTime? createdAt,
    DateTime? updatedAt,
    // Deal-related data
    String? departure,
    String? destination,
    DateTime? departureDate,
    String? departureTime,
    int? duration,
    double? basePrice,
    String? aircraftName,
    String? companyName,
  }) {
    return BookingModel(
      id: id ?? this.id,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      userId: userId ?? this.userId,
      dealId: dealId ?? this.dealId,
      companyId: companyId ?? this.companyId,
      totalPrice: totalPrice ?? this.totalPrice,
      bookingStatus: bookingStatus ?? this.bookingStatus,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      onboardDining: onboardDining ?? this.onboardDining,
      groundTransportation: groundTransportation ?? this.groundTransportation,
      specialRequirements: specialRequirements ?? this.specialRequirements,
      billingRegion: billingRegion ?? this.billingRegion,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentTransactionId: paymentTransactionId ?? this.paymentTransactionId,
      loyaltyPointsEarned: loyaltyPointsEarned ?? this.loyaltyPointsEarned,
      loyaltyPointsRedeemed:
          loyaltyPointsRedeemed ?? this.loyaltyPointsRedeemed,
      walletAmountUsed: walletAmountUsed ?? this.walletAmountUsed,
      passengers: passengers ?? this.passengers,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      // Deal-related data
      departure: departure ?? this.departure,
      destination: destination ?? this.destination,
      departureDate: departureDate ?? this.departureDate,
      departureTime: departureTime ?? this.departureTime,
      duration: duration ?? this.duration,
      basePrice: basePrice ?? this.basePrice,
      aircraftName: aircraftName ?? this.aircraftName,
      companyName: companyName ?? this.companyName,
    );
  }

  // Helper methods
  String get formattedPrice => '\$${totalPrice.toFixed(2)}';

  String get formattedDate =>
      '${departureDate?.day}/${departureDate?.month}/${departureDate?.year}';

  bool get isConfirmed =>
      bookingStatus == BookingStatus.confirmed ||
      bookingStatus == BookingStatus.completed;

  bool get isPaid => paymentStatus == PaymentStatus.paid;

  bool get canBeCancelled =>
      bookingStatus == BookingStatus.pending ||
      bookingStatus == BookingStatus.confirmed;

  // Computed properties for UI display
  int get totalPassengers => passengers.length;

  String get aircraft => aircraftName ?? 'Aircraft #$dealId';

  String? get bookingReference => referenceNumber;

  // New computed properties for loyalty and wallet
  double get netAmount => totalPrice - walletAmountUsed;

  int get netLoyaltyPoints => loyaltyPointsEarned - loyaltyPointsRedeemed;

  bool get hasLoyaltyPoints =>
      loyaltyPointsEarned > 0 || loyaltyPointsRedeemed > 0;

  bool get hasWalletUsage => walletAmountUsed > 0;

  String get statusDisplayText {
    switch (bookingStatus) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.completed:
        return 'Completed';
    }
  }

  String get paymentStatusDisplayText {
    switch (paymentStatus) {
      case PaymentStatus.pending:
        return 'Payment Pending';
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.failed:
        return 'Payment Failed';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }

  // Helper method to get primary passenger (user)
  PassengerModel? get primaryPassenger {
    try {
      return passengers.firstWhere(
        (p) => p.isUser == true,
      );
    } catch (e) {
      return null;
    }
  }

  // Helper method to get additional passengers
  List<PassengerModel> get additionalPassengers {
    return passengers.where((p) => p.isUser != true).toList();
  }

  static BookingStatus _parseBookingStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'completed':
        return BookingStatus.completed;
      default:
        return BookingStatus.pending;
    }
  }

  static PaymentStatus _parsePaymentStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'paid':
        return PaymentStatus.paid;
      case 'failed':
        return PaymentStatus.failed;
      case 'refunded':
        return PaymentStatus.refunded;
      default:
        return PaymentStatus.pending;
    }
  }

  static PaymentMethod? _parsePaymentMethod(String? method) {
    switch (method?.toLowerCase()) {
      case 'card':
        return PaymentMethod.card;
      case 'mpesa':
        return PaymentMethod.mpesa;
      case 'wallet':
        return PaymentMethod.wallet;
      default:
        return null;
    }
  }
}

extension DoubleExtension on double {
  String toFixed(int places) {
    return toStringAsFixed(places);
  }
}
