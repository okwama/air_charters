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
  final int companyId;
  final int aircraftId;
  final String departure;
  final String destination;
  final DateTime departureDate;
  final String departureTime;
  final int duration;
  final double basePrice;
  final double totalPrice;
  final BookingStatus bookingStatus;
  final PaymentStatus paymentStatus;
  final bool onboardDining;
  final bool groundTransportation;
  final String? specialRequirements;
  final String? billingRegion;
  final PaymentMethod? paymentMethod;
  final List<PassengerModel> passengers;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BookingModel({
    this.id,
    this.referenceNumber,
    required this.userId,
    required this.companyId,
    required this.aircraftId,
    required this.departure,
    required this.destination,
    required this.departureDate,
    required this.departureTime,
    required this.duration,
    required this.basePrice,
    required this.totalPrice,
    this.bookingStatus = BookingStatus.pending,
    this.paymentStatus = PaymentStatus.pending,
    this.onboardDining = false,
    this.groundTransportation = false,
    this.specialRequirements,
    this.billingRegion,
    this.paymentMethod,
    this.passengers = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String?,
      referenceNumber: json['referenceNumber'] as String?,
      userId: json['userId'] as String? ?? '',
      companyId: json['companyId'] as int? ?? 0,
      aircraftId: json['aircraftId'] as int? ?? 0,
      departure: json['departure'] as String? ?? '',
      destination: json['destination'] as String? ?? '',
      departureDate: json['departureDate'] != null
          ? DateTime.parse(json['departureDate'] as String)
          : DateTime.now(),
      departureTime: json['departureTime'] as String? ?? '',
      duration: json['duration'] as int? ?? 0,
      basePrice: double.tryParse(json['basePrice']?.toString() ?? '0') ?? 0.0,
      totalPrice: double.tryParse(json['totalPrice']?.toString() ?? '0') ?? 0.0,
      bookingStatus: _parseBookingStatus(json['bookingStatus'] as String?),
      paymentStatus: _parsePaymentStatus(json['paymentStatus'] as String?),
      onboardDining: json['onboardDining'] as bool? ?? false,
      groundTransportation: json['groundTransportation'] as bool? ?? false,
      specialRequirements: json['specialRequirements'] as String?,
      billingRegion: json['billingRegion'] as String?,
      paymentMethod: _parsePaymentMethod(json['paymentMethod'] as String?),
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (referenceNumber != null) 'referenceNumber': referenceNumber,
      'userId': userId,
      'companyId': companyId,
      'aircraftId': aircraftId,
      'departure': departure,
      'destination': destination,
      'departureDate': departureDate.toIso8601String(),
      'departureTime': departureTime,
      'duration': duration,
      'basePrice': basePrice,
      'totalPrice': totalPrice,
      'bookingStatus': bookingStatus.name,
      'paymentStatus': paymentStatus.name,
      'onboardDining': onboardDining,
      'groundTransportation': groundTransportation,
      if (specialRequirements != null)
        'specialRequirements': specialRequirements,
      if (billingRegion != null) 'billingRegion': billingRegion,
      if (paymentMethod != null) 'paymentMethod': paymentMethod!.name,
      'passengers': passengers.map((p) => p.toCreateJson()).toList(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  // Create JSON for booking creation (without backend-generated fields)
  Map<String, dynamic> toCreateJson() {
    return {
      'companyId': companyId,
      'aircraftId': aircraftId,
      'departure': departure,
      'destination': destination,
      'departureDate': departureDate.toIso8601String(),
      'departureTime': departureTime,
      'duration': duration,
      'basePrice': basePrice,
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
    int? companyId,
    int? aircraftId,
    String? departure,
    String? destination,
    DateTime? departureDate,
    String? departureTime,
    int? duration,
    double? basePrice,
    double? totalPrice,
    BookingStatus? bookingStatus,
    PaymentStatus? paymentStatus,
    bool? onboardDining,
    bool? groundTransportation,
    String? specialRequirements,
    String? billingRegion,
    PaymentMethod? paymentMethod,
    List<PassengerModel>? passengers,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      userId: userId ?? this.userId,
      companyId: companyId ?? this.companyId,
      aircraftId: aircraftId ?? this.aircraftId,
      departure: departure ?? this.departure,
      destination: destination ?? this.destination,
      departureDate: departureDate ?? this.departureDate,
      departureTime: departureTime ?? this.departureTime,
      duration: duration ?? this.duration,
      basePrice: basePrice ?? this.basePrice,
      totalPrice: totalPrice ?? this.totalPrice,
      bookingStatus: bookingStatus ?? this.bookingStatus,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      onboardDining: onboardDining ?? this.onboardDining,
      groundTransportation: groundTransportation ?? this.groundTransportation,
      specialRequirements: specialRequirements ?? this.specialRequirements,
      billingRegion: billingRegion ?? this.billingRegion,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      passengers: passengers ?? this.passengers,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods
  String get formattedPrice => '\$${totalPrice.toFixed(2)}';

  String get formattedDate =>
      '${departureDate.day}/${departureDate.month}/${departureDate.year}';

  bool get isConfirmed =>
      bookingStatus == BookingStatus.confirmed ||
      bookingStatus == BookingStatus.completed;

  bool get isPaid => paymentStatus == PaymentStatus.paid;

  bool get canBeCancelled =>
      bookingStatus == BookingStatus.pending ||
      bookingStatus == BookingStatus.confirmed;

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
