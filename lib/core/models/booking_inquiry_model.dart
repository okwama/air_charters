import 'package:json_annotation/json_annotation.dart';

part 'booking_inquiry_model.g.dart';

@JsonSerializable()
class BookingInquiryModel {
  final int? id;
  final String userId;
  final int aircraftId;
  final int companyId;
  final String inquiryStatus;
  final int requestedSeats;
  final String? specialRequirements;
  final bool onboardDining;
  final bool groundTransportation;
  final String? billingRegion;
  final double? proposedPrice;
  final String? proposedPriceType;
  final String? adminNotes;
  final String? userNotes;
  final String referenceNumber;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? pricedAt;
  final DateTime? confirmedAt;
  final DateTime? cancelledAt;
  final List<InquiryStopModel> stops;
  final AircraftModel? aircraft;
  final UserModel? user;

  BookingInquiryModel({
    this.id,
    required this.userId,
    required this.aircraftId,
    required this.companyId,
    required this.inquiryStatus,
    required this.requestedSeats,
    this.specialRequirements,
    required this.onboardDining,
    required this.groundTransportation,
    this.billingRegion,
    this.proposedPrice,
    this.proposedPriceType,
    this.adminNotes,
    this.userNotes,
    required this.referenceNumber,
    required this.createdAt,
    required this.updatedAt,
    this.pricedAt,
    this.confirmedAt,
    this.cancelledAt,
    required this.stops,
    this.aircraft,
    this.user,
  });

  factory BookingInquiryModel.fromJson(Map<String, dynamic> json) =>
      _$BookingInquiryModelFromJson(json);

  Map<String, dynamic> toJson() => _$BookingInquiryModelToJson(this);

  BookingInquiryModel copyWith({
    int? id,
    String? userId,
    int? aircraftId,
    int? companyId,
    String? inquiryStatus,
    int? requestedSeats,
    String? specialRequirements,
    bool? onboardDining,
    bool? groundTransportation,
    String? billingRegion,
    double? proposedPrice,
    String? proposedPriceType,
    String? adminNotes,
    String? userNotes,
    String? referenceNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? pricedAt,
    DateTime? confirmedAt,
    DateTime? cancelledAt,
    List<InquiryStopModel>? stops,
    AircraftModel? aircraft,
    UserModel? user,
  }) {
    return BookingInquiryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      aircraftId: aircraftId ?? this.aircraftId,
      companyId: companyId ?? this.companyId,
      inquiryStatus: inquiryStatus ?? this.inquiryStatus,
      requestedSeats: requestedSeats ?? this.requestedSeats,
      specialRequirements: specialRequirements ?? this.specialRequirements,
      onboardDining: onboardDining ?? this.onboardDining,
      groundTransportation: groundTransportation ?? this.groundTransportation,
      billingRegion: billingRegion ?? this.billingRegion,
      proposedPrice: proposedPrice ?? this.proposedPrice,
      proposedPriceType: proposedPriceType ?? this.proposedPriceType,
      adminNotes: adminNotes ?? this.adminNotes,
      userNotes: userNotes ?? this.userNotes,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      pricedAt: pricedAt ?? this.pricedAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      stops: stops ?? this.stops,
      aircraft: aircraft ?? this.aircraft,
      user: user ?? this.user,
    );
  }
}

@JsonSerializable()
class InquiryStopModel {
  final int? id;
  final int bookingInquiryId;
  final String stopName;
  final double longitude;
  final double latitude;
  final double? price;
  final DateTime? datetime;
  final int stopOrder;
  final String locationType;
  final String? locationCode;
  final DateTime createdAt;
  final DateTime updatedAt;

  InquiryStopModel({
    this.id,
    required this.bookingInquiryId,
    required this.stopName,
    required this.longitude,
    required this.latitude,
    this.price,
    this.datetime,
    required this.stopOrder,
    required this.locationType,
    this.locationCode,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InquiryStopModel.fromJson(Map<String, dynamic> json) =>
      _$InquiryStopModelFromJson(json);

  Map<String, dynamic> toJson() => _$InquiryStopModelToJson(this);
}

@JsonSerializable()
class AircraftModel {
  final int id;
  final int companyId;
  final String name;
  final String registrationNumber;
  final String type;
  final String? model;
  final String? manufacturer;
  final int? yearManufactured;
  final int capacity;
  final double? pricePerHour;
  final bool isAvailable;
  final String maintenanceStatus;
  final String? baseAirport;
  final String? baseCity;
  final DateTime createdAt;
  final DateTime updatedAt;

  AircraftModel({
    required this.id,
    required this.companyId,
    required this.name,
    required this.registrationNumber,
    required this.type,
    this.model,
    this.manufacturer,
    this.yearManufactured,
    required this.capacity,
    this.pricePerHour,
    required this.isAvailable,
    required this.maintenanceStatus,
    this.baseAirport,
    this.baseCity,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AircraftModel.fromJson(Map<String, dynamic> json) =>
      _$AircraftModelFromJson(json);

  Map<String, dynamic> toJson() => _$AircraftModelToJson(this);
}

@JsonSerializable()
class UserModel {
  final String id;
  final String email;
  final String? phoneNumber;
  final String? firstName;
  final String? lastName;
  final String? countryCode;
  final String? language;
  final String? currency;
  final String? timezone;
  final String? theme;
  final String? profileImageUrl;
  final int loyaltyPoints;
  final String loyaltyTier;
  final double walletBalance;
  final bool isActive;
  final bool emailVerified;
  final bool phoneVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.email,
    this.phoneNumber,
    this.firstName,
    this.lastName,
    this.countryCode,
    this.language,
    this.currency,
    this.timezone,
    this.theme,
    this.profileImageUrl,
    required this.loyaltyPoints,
    required this.loyaltyTier,
    required this.walletBalance,
    required this.isActive,
    required this.emailVerified,
    required this.phoneVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}

// Create Inquiry Request Model
@JsonSerializable()
class CreateBookingInquiryRequest {
  final int aircraftId;
  final int requestedSeats;
  final String? specialRequirements;
  final bool onboardDining;
  final bool groundTransportation;
  final String? billingRegion;
  final String? userNotes;
  final List<CreateInquiryStopRequest> stops;

  CreateBookingInquiryRequest({
    required this.aircraftId,
    required this.requestedSeats,
    this.specialRequirements,
    required this.onboardDining,
    required this.groundTransportation,
    this.billingRegion,
    this.userNotes,
    required this.stops,
  });

  factory CreateBookingInquiryRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateBookingInquiryRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateBookingInquiryRequestToJson(this);
}

@JsonSerializable()
class CreateInquiryStopRequest {
  final String stopName;
  final double longitude;
  final double latitude;
  final double? price;
  final DateTime? datetime;
  final int stopOrder;
  final String? locationCode;

  CreateInquiryStopRequest({
    required this.stopName,
    required this.longitude,
    required this.latitude,
    this.price,
    this.datetime,
    required this.stopOrder,
    this.locationCode,
  });

  factory CreateInquiryStopRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateInquiryStopRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateInquiryStopRequestToJson(this);
}
