import 'passenger_model.dart';

enum BookingStatus {
  pending,
  confirmed,
  paid,
  cancelled,
  completed,
}

enum PaymentStatus {
  pending,
  paid,
  failed,
  refunded,
}

class BookingModel {
  final int? id;
  final String? bookingReference;
  final String departure;
  final String destination;
  final DateTime departureDate;
  final String departureTime;
  final String aircraft;
  final int totalPassengers;
  final String duration;
  final double basePrice;
  final double totalPrice;
  final BookingStatus bookingStatus;
  final PaymentStatus paymentStatus;
  final bool onboardDining;
  final bool groundTransportation;
  final String? specialRequirements;
  final String? billingRegion;
  final String? paymentMethod;
  final List<PassengerModel> passengers;
  final DateTime? createdAt;

  const BookingModel({
    this.id,
    this.bookingReference,
    required this.departure,
    required this.destination,
    required this.departureDate,
    required this.departureTime,
    required this.aircraft,
    required this.totalPassengers,
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
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as int?,
      bookingReference: json['bookingReference'] as String?,
      departure: json['departure'] as String,
      destination: json['destination'] as String,
      departureDate: DateTime.parse(json['departureDate'] as String),
      departureTime: json['departureTime'] as String,
      aircraft: json['aircraft'] as String,
      totalPassengers: json['totalPassengers'] as int,
      duration: json['duration'] as String,
      basePrice: double.tryParse(json['basePrice'].toString()) ?? 0.0,
      totalPrice: double.tryParse(json['totalPrice'].toString()) ?? 0.0,
      bookingStatus: _parseBookingStatus(json['bookingStatus'] as String?),
      paymentStatus: _parsePaymentStatus(json['paymentStatus'] as String?),
      onboardDining: json['onboardDining'] as bool? ?? false,
      groundTransportation: json['groundTransportation'] as bool? ?? false,
      specialRequirements: json['specialRequirements'] as String?,
      billingRegion: json['billingRegion'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
      passengers: (json['passengers'] as List<dynamic>?)
              ?.map((p) => PassengerModel.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (bookingReference != null) 'bookingReference': bookingReference,
      'departure': departure,
      'destination': destination,
      'departureDate': departureDate.toIso8601String(),
      'departureTime': departureTime,
      'aircraft': aircraft,
      'totalPassengers': totalPassengers,
      'duration': duration,
      'basePrice': basePrice,
      'totalPrice': totalPrice,
      'bookingStatus': bookingStatus.name,
      'paymentStatus': paymentStatus.name,
      'onboardDining': onboardDining,
      'groundTransportation': groundTransportation,
      if (specialRequirements != null) 'specialRequirements': specialRequirements,
      if (billingRegion != null) 'billingRegion': billingRegion,
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
      'passengers': passengers.map((p) => p.toCreateJson()).toList(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

  // Create JSON for booking creation (without backend-generated fields)
  Map<String, dynamic> toCreateJson() {
    return {
      'departure': departure,
      'destination': destination,
      'departureDate': departureDate.toIso8601String(),
      'departureTime': departureTime,
      'aircraft': aircraft,
      'totalPassengers': totalPassengers,
      'duration': duration,
      'basePrice': basePrice,
      'totalPrice': totalPrice,
      'onboardDining': onboardDining,
      'groundTransportation': groundTransportation,
      if (specialRequirements != null) 'specialRequirements': specialRequirements,
      if (billingRegion != null) 'billingRegion': billingRegion,
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
      'passengers': passengers.map((p) => p.toCreateJson()).toList(),
    };
  }

  BookingModel copyWith({
    int? id,
    String? bookingReference,
    String? departure,
    String? destination,
    DateTime? departureDate,
    String? departureTime,
    String? aircraft,
    int? totalPassengers,
    String? duration,
    double? basePrice,
    double? totalPrice,
    BookingStatus? bookingStatus,
    PaymentStatus? paymentStatus,
    bool? onboardDining,
    bool? groundTransportation,
    String? specialRequirements,
    String? billingRegion,
    String? paymentMethod,
    List<PassengerModel>? passengers,
    DateTime? createdAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      bookingReference: bookingReference ?? this.bookingReference,
      departure: departure ?? this.departure,
      destination: destination ?? this.destination,
      departureDate: departureDate ?? this.departureDate,
      departureTime: departureTime ?? this.departureTime,
      aircraft: aircraft ?? this.aircraft,
      totalPassengers: totalPassengers ?? this.totalPassengers,
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
    );
  }

  // Helper methods
  String get formattedPrice => '\$${totalPrice.toFixed(2)}';
  
  String get formattedDate => '${departureDate.day}/${departureDate.month}/${departureDate.year}';
  
  bool get isConfirmed => 
      bookingStatus == BookingStatus.confirmed || 
      bookingStatus == BookingStatus.paid ||
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
      case BookingStatus.paid:
        return 'Paid';
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
      case 'paid':
        return BookingStatus.paid;
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
}

extension DoubleExtension on double {
  String toFixed(int places) {
    return toStringAsFixed(places);
  }
} 