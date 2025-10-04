enum BookingStatus {
  pending,
  priced,
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

enum BookingType {
  direct,
  deal,
  experience,
}

class BookingInquiry {
  final int id;
  final String userId;
  final int companyId;
  final int? aircraftId;
  final BookingType bookingType;
  final int? dealId;
  final int? experienceScheduleId;
  final double? totalPrice;
  final String? taxType;
  final double? taxAmount;
  final double? subtotal;
  final BookingStatus bookingStatus;
  final PaymentStatus paymentStatus;
  final String referenceNumber;
  final String? specialRequirements;
  final String? adminNotes;
  final String? originName;
  final double? originLatitude;
  final double? originLongitude;
  final String? destinationName;
  final double? destinationLatitude;
  final double? destinationLongitude;
  final DateTime? departureDateTime;
  final double? estimatedFlightHours;
  final DateTime? estimatedArrivalTime;
  final DateTime createdAt;
  final int totalAdults;
  final int totalChildren;
  final bool onboardDining;
  final DateTime updatedAt;
  final List<BookingStop> stops;

  // Related data
  final String? aircraftName;
  final String? companyName;
  final String? aircraftType;

  const BookingInquiry({
    required this.id,
    required this.userId,
    required this.companyId,
    this.aircraftId,
    required this.bookingType,
    this.dealId,
    this.experienceScheduleId,
    this.totalPrice,
    this.taxType,
    this.taxAmount,
    this.subtotal,
    required this.bookingStatus,
    required this.paymentStatus,
    required this.referenceNumber,
    this.specialRequirements,
    this.adminNotes,
    this.originName,
    this.originLatitude,
    this.originLongitude,
    this.destinationName,
    this.destinationLatitude,
    this.destinationLongitude,
    this.departureDateTime,
    this.estimatedFlightHours,
    this.estimatedArrivalTime,
    required this.createdAt,
    required this.totalAdults,
    required this.totalChildren,
    required this.onboardDining,
    required this.updatedAt,
    required this.stops,
    this.aircraftName,
    this.companyName,
    this.aircraftType,
  });

  factory BookingInquiry.fromJson(Map<String, dynamic> json) {
    return BookingInquiry(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? '',
      companyId: json['companyId'] ?? 0,
      aircraftId: json['aircraftId'],
      bookingType: _parseBookingType(json['bookingType']),
      dealId: json['dealId'],
      experienceScheduleId: json['experienceScheduleId'],
      totalPrice: json['totalPrice']?.toDouble(),
      taxType: json['taxType'],
      taxAmount: json['taxAmount']?.toDouble(),
      subtotal: json['subtotal']?.toDouble(),
      bookingStatus: _parseBookingStatus(json['bookingStatus']),
      paymentStatus: _parsePaymentStatus(json['paymentStatus']),
      referenceNumber: json['referenceNumber'] ?? '',
      specialRequirements: json['specialRequirements'],
      adminNotes: json['adminNotes'],
      originName: json['originName'],
      originLatitude: json['originLatitude']?.toDouble(),
      originLongitude: json['originLongitude']?.toDouble(),
      destinationName: json['destinationName'],
      destinationLatitude: json['destinationLatitude']?.toDouble(),
      destinationLongitude: json['destinationLongitude']?.toDouble(),
      departureDateTime: json['departureDateTime'] != null
          ? DateTime.parse(json['departureDateTime'])
          : null,
      estimatedFlightHours: json['estimatedFlightHours']?.toDouble(),
      estimatedArrivalTime: json['estimatedArrivalTime'] != null
          ? DateTime.parse(json['estimatedArrivalTime'])
          : null,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      totalAdults: json['totalAdults'] ?? 0,
      totalChildren: json['totalChildren'] ?? 0,
      onboardDining: json['onboardDining'] ?? false,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      stops: json['stops'] != null
          ? (json['stops'] as List)
              .map((stop) => BookingStop.fromJson(stop))
              .toList()
          : [],
      aircraftName: json['aircraft']?['name'],
      companyName: json['company']?['name'],
      aircraftType: json['aircraft']?['aircraftType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'companyId': companyId,
      'aircraftId': aircraftId,
      'bookingType': bookingType.name,
      'dealId': dealId,
      'experienceScheduleId': experienceScheduleId,
      'totalPrice': totalPrice,
      'taxType': taxType,
      'taxAmount': taxAmount,
      'subtotal': subtotal,
      'bookingStatus': bookingStatus.name,
      'paymentStatus': paymentStatus.name,
      'referenceNumber': referenceNumber,
      'specialRequirements': specialRequirements,
      'adminNotes': adminNotes,
      'originName': originName,
      'originLatitude': originLatitude,
      'originLongitude': originLongitude,
      'destinationName': destinationName,
      'destinationLatitude': destinationLatitude,
      'destinationLongitude': destinationLongitude,
      'departureDateTime': departureDateTime?.toIso8601String(),
      'estimatedFlightHours': estimatedFlightHours,
      'estimatedArrivalTime': estimatedArrivalTime?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'totalAdults': totalAdults,
      'totalChildren': totalChildren,
      'onboardDining': onboardDining,
      'updatedAt': updatedAt.toIso8601String(),
      'stops': stops.map((stop) => stop.toJson()).toList(),
    };
  }

  static BookingStatus _parseBookingStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return BookingStatus.pending;
      case 'priced':
        return BookingStatus.priced;
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
      case 'pending':
        return PaymentStatus.pending;
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

  static BookingType _parseBookingType(String? type) {
    switch (type?.toLowerCase()) {
      case 'direct':
        return BookingType.direct;
      case 'deal':
        return BookingType.deal;
      case 'experience':
        return BookingType.experience;
      default:
        return BookingType.direct;
    }
  }

  /// Get formatted status
  String get formattedStatus {
    switch (bookingStatus) {
      case BookingStatus.pending:
        return 'Pending Review';
      case BookingStatus.priced:
        return 'Price Available';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.completed:
        return 'Completed';
    }
  }

  /// Get formatted total price
  String get formattedTotalPrice {
    if (totalPrice == null) return 'TBD';
    return '\$${totalPrice!.toStringAsFixed(0)}';
  }

  /// Check if booking can be confirmed
  bool get canConfirm => bookingStatus == BookingStatus.priced;

  /// Check if booking can be cancelled
  bool get canCancel =>
      bookingStatus == BookingStatus.pending ||
      bookingStatus == BookingStatus.priced;

  /// Check if booking is paid
  bool get isPaid => paymentStatus == PaymentStatus.paid;

  /// Check if booking is pending (inquiry state)
  bool get isPending =>
      bookingStatus == BookingStatus.pending ||
      bookingStatus == BookingStatus.priced;
}

class BookingStop {
  final int id;
  final int bookingId;
  final String stopName;
  final double longitude;
  final double latitude;
  final DateTime? datetime;
  final int stopOrder;
  final String locationType;
  final String? locationCode;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BookingStop({
    required this.id,
    required this.bookingId,
    required this.stopName,
    required this.longitude,
    required this.latitude,
    this.datetime,
    required this.stopOrder,
    required this.locationType,
    this.locationCode,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookingStop.fromJson(Map<String, dynamic> json) {
    return BookingStop(
      id: json['id'] ?? 0,
      bookingId: json['booking_id'] ?? json['bookingId'] ?? 0,
      stopName: json['stop_name'] ?? json['stopName'] ?? '',
      longitude: json['longitude']?.toDouble() ?? 0.0,
      latitude: json['latitude']?.toDouble() ?? 0.0,
      datetime:
          json['datetime'] != null ? DateTime.parse(json['datetime']) : null,
      stopOrder: json['stop_order'] ?? json['stopOrder'] ?? 0,
      locationType: json['location_type'] ?? json['locationType'] ?? 'custom',
      locationCode: json['location_code'] ?? json['locationCode'],
      createdAt: DateTime.parse(json['created_at'] ?? json['createdAt']),
      updatedAt: DateTime.parse(json['updated_at'] ?? json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'stop_name': stopName,
      'longitude': longitude,
      'latitude': latitude,
      'datetime': datetime?.toIso8601String(),
      'stop_order': stopOrder,
      'location_type': locationType,
      'location_code': locationCode,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Get formatted datetime
  String get formattedDateTime {
    if (datetime == null) return 'TBD';

    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    final month = months[datetime!.month - 1];
    final day = datetime!.day.toString().padLeft(2, '0');
    final year = datetime!.year;
    final hour = datetime!.hour.toString().padLeft(2, '0');
    final minute = datetime!.minute.toString().padLeft(2, '0');

    return '$month $day, $year • $hour:$minute';
  }
}

// DTOs for creating booking inquiries
class CreateBookingInquiryRequest {
  final int aircraftId;
  final int requestedSeats;
  final String? specialRequirements;
  final bool onboardDining;
  final bool groundTransportation;
  final String? billingRegion;
  final String? userNotes;
  final List<CreateBookingStopRequest> stops;

  const CreateBookingInquiryRequest({
    required this.aircraftId,
    required this.requestedSeats,
    this.specialRequirements,
    required this.onboardDining,
    required this.groundTransportation,
    this.billingRegion,
    this.userNotes,
    required this.stops,
  });

  Map<String, dynamic> toJson() {
    return {
      'aircraftId': aircraftId,
      'requestedSeats': requestedSeats,
      'specialRequirements': specialRequirements,
      'onboardDining': onboardDining,
      'groundTransportation': groundTransportation,
      'billingRegion': billingRegion,
      'userNotes': userNotes,
      'stops': stops.map((stop) => stop.toJson()).toList(),
    };
  }
}

class CreateBookingStopRequest {
  final String stopName;
  final double longitude;
  final double latitude;
  final String datetime;
  final int stopOrder;
  final String? locationCode;

  const CreateBookingStopRequest({
    required this.stopName,
    required this.longitude,
    required this.latitude,
    required this.datetime,
    required this.stopOrder,
    this.locationCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'stopName': stopName,
      'longitude': longitude,
      'latitude': latitude,
      'datetime': datetime,
      'stopOrder': stopOrder,
      'locationCode': locationCode,
    };
  }
}
