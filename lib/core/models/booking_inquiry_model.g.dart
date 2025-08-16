// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_inquiry_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookingInquiryModel _$BookingInquiryModelFromJson(Map<String, dynamic> json) =>
    BookingInquiryModel(
      id: (json['id'] as num?)?.toInt(),
      userId: json['userId'] as String,
      aircraftId: (json['aircraftId'] as num).toInt(),
      companyId: (json['companyId'] as num).toInt(),
      inquiryStatus: json['inquiryStatus'] as String,
      requestedSeats: (json['requestedSeats'] as num).toInt(),
      specialRequirements: json['specialRequirements'] as String?,
      onboardDining: json['onboardDining'] as bool,
      groundTransportation: json['groundTransportation'] as bool,
      billingRegion: json['billingRegion'] as String?,
      proposedPrice: (json['proposedPrice'] as num?)?.toDouble(),
      proposedPriceType: json['proposedPriceType'] as String?,
      adminNotes: json['adminNotes'] as String?,
      userNotes: json['userNotes'] as String?,
      referenceNumber: json['referenceNumber'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      pricedAt: json['pricedAt'] == null
          ? null
          : DateTime.parse(json['pricedAt'] as String),
      confirmedAt: json['confirmedAt'] == null
          ? null
          : DateTime.parse(json['confirmedAt'] as String),
      cancelledAt: json['cancelledAt'] == null
          ? null
          : DateTime.parse(json['cancelledAt'] as String),
      stops: (json['stops'] as List<dynamic>)
          .map((e) => InquiryStopModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      aircraft: json['aircraft'] == null
          ? null
          : AircraftModel.fromJson(json['aircraft'] as Map<String, dynamic>),
      user: json['user'] == null
          ? null
          : UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BookingInquiryModelToJson(
        BookingInquiryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'aircraftId': instance.aircraftId,
      'companyId': instance.companyId,
      'inquiryStatus': instance.inquiryStatus,
      'requestedSeats': instance.requestedSeats,
      'specialRequirements': instance.specialRequirements,
      'onboardDining': instance.onboardDining,
      'groundTransportation': instance.groundTransportation,
      'billingRegion': instance.billingRegion,
      'proposedPrice': instance.proposedPrice,
      'proposedPriceType': instance.proposedPriceType,
      'adminNotes': instance.adminNotes,
      'userNotes': instance.userNotes,
      'referenceNumber': instance.referenceNumber,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'pricedAt': instance.pricedAt?.toIso8601String(),
      'confirmedAt': instance.confirmedAt?.toIso8601String(),
      'cancelledAt': instance.cancelledAt?.toIso8601String(),
      'stops': instance.stops,
      'aircraft': instance.aircraft,
      'user': instance.user,
    };

InquiryStopModel _$InquiryStopModelFromJson(Map<String, dynamic> json) =>
    InquiryStopModel(
      id: (json['id'] as num?)?.toInt(),
      bookingInquiryId: (json['bookingInquiryId'] as num).toInt(),
      stopName: json['stopName'] as String,
      longitude: (json['longitude'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      price: (json['price'] as num?)?.toDouble(),
      datetime: json['datetime'] == null
          ? null
          : DateTime.parse(json['datetime'] as String),
      stopOrder: (json['stopOrder'] as num).toInt(),
      locationType: json['locationType'] as String,
      locationCode: json['locationCode'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$InquiryStopModelToJson(InquiryStopModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bookingInquiryId': instance.bookingInquiryId,
      'stopName': instance.stopName,
      'longitude': instance.longitude,
      'latitude': instance.latitude,
      'price': instance.price,
      'datetime': instance.datetime?.toIso8601String(),
      'stopOrder': instance.stopOrder,
      'locationType': instance.locationType,
      'locationCode': instance.locationCode,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

AircraftModel _$AircraftModelFromJson(Map<String, dynamic> json) =>
    AircraftModel(
      id: (json['id'] as num).toInt(),
      companyId: (json['companyId'] as num).toInt(),
      name: json['name'] as String,
      registrationNumber: json['registrationNumber'] as String,
      type: json['type'] as String,
      model: json['model'] as String?,
      manufacturer: json['manufacturer'] as String?,
      yearManufactured: (json['yearManufactured'] as num?)?.toInt(),
      capacity: (json['capacity'] as num).toInt(),
      pricePerHour: (json['pricePerHour'] as num?)?.toDouble(),
      isAvailable: json['isAvailable'] as bool,
      maintenanceStatus: json['maintenanceStatus'] as String,
      baseAirport: json['baseAirport'] as String?,
      baseCity: json['baseCity'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$AircraftModelToJson(AircraftModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'companyId': instance.companyId,
      'name': instance.name,
      'registrationNumber': instance.registrationNumber,
      'type': instance.type,
      'model': instance.model,
      'manufacturer': instance.manufacturer,
      'yearManufactured': instance.yearManufactured,
      'capacity': instance.capacity,
      'pricePerHour': instance.pricePerHour,
      'isAvailable': instance.isAvailable,
      'maintenanceStatus': instance.maintenanceStatus,
      'baseAirport': instance.baseAirport,
      'baseCity': instance.baseCity,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      countryCode: json['countryCode'] as String?,
      language: json['language'] as String?,
      currency: json['currency'] as String?,
      timezone: json['timezone'] as String?,
      theme: json['theme'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      loyaltyPoints: (json['loyaltyPoints'] as num).toInt(),
      loyaltyTier: json['loyaltyTier'] as String,
      walletBalance: (json['walletBalance'] as num).toDouble(),
      isActive: json['isActive'] as bool,
      emailVerified: json['emailVerified'] as bool,
      phoneVerified: json['phoneVerified'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'phoneNumber': instance.phoneNumber,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'countryCode': instance.countryCode,
      'language': instance.language,
      'currency': instance.currency,
      'timezone': instance.timezone,
      'theme': instance.theme,
      'profileImageUrl': instance.profileImageUrl,
      'loyaltyPoints': instance.loyaltyPoints,
      'loyaltyTier': instance.loyaltyTier,
      'walletBalance': instance.walletBalance,
      'isActive': instance.isActive,
      'emailVerified': instance.emailVerified,
      'phoneVerified': instance.phoneVerified,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

CreateBookingInquiryRequest _$CreateBookingInquiryRequestFromJson(
        Map<String, dynamic> json) =>
    CreateBookingInquiryRequest(
      aircraftId: (json['aircraftId'] as num).toInt(),
      requestedSeats: (json['requestedSeats'] as num).toInt(),
      specialRequirements: json['specialRequirements'] as String?,
      onboardDining: json['onboardDining'] as bool,
      groundTransportation: json['groundTransportation'] as bool,
      billingRegion: json['billingRegion'] as String?,
      userNotes: json['userNotes'] as String?,
      stops: (json['stops'] as List<dynamic>)
          .map((e) =>
              CreateInquiryStopRequest.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CreateBookingInquiryRequestToJson(
        CreateBookingInquiryRequest instance) =>
    <String, dynamic>{
      'aircraftId': instance.aircraftId,
      'requestedSeats': instance.requestedSeats,
      'specialRequirements': instance.specialRequirements,
      'onboardDining': instance.onboardDining,
      'groundTransportation': instance.groundTransportation,
      'billingRegion': instance.billingRegion,
      'userNotes': instance.userNotes,
      'stops': instance.stops,
    };

CreateInquiryStopRequest _$CreateInquiryStopRequestFromJson(
        Map<String, dynamic> json) =>
    CreateInquiryStopRequest(
      stopName: json['stopName'] as String,
      longitude: (json['longitude'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      price: (json['price'] as num?)?.toDouble(),
      datetime: json['datetime'] == null
          ? null
          : DateTime.parse(json['datetime'] as String),
      stopOrder: (json['stopOrder'] as num).toInt(),
      locationCode: json['locationCode'] as String?,
    );

Map<String, dynamic> _$CreateInquiryStopRequestToJson(
        CreateInquiryStopRequest instance) =>
    <String, dynamic>{
      'stopName': instance.stopName,
      'longitude': instance.longitude,
      'latitude': instance.latitude,
      'price': instance.price,
      'datetime': instance.datetime?.toIso8601String(),
      'stopOrder': instance.stopOrder,
      'locationCode': instance.locationCode,
    };
