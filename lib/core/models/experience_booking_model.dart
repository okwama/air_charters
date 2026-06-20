class ExperienceBookingModel {
  final int experienceId;
  final int? companyId;
  final String experienceTitle;
  final String location;
  final String imageUrl;
  final double price;
  final String priceUnit;
  final int durationMinutes;
  final DateTime selectedDate;
  final String selectedTime;
  final int passengersCount;
  final List<ExperiencePassenger> passengers;
  final String? specialRequests;
  final String status;
  final DateTime createdAt;

  ExperienceBookingModel({
    required this.experienceId,
    this.companyId,
    required this.experienceTitle,
    required this.location,
    required this.imageUrl,
    required this.price,
    required this.priceUnit,
    required this.durationMinutes,
    required this.selectedDate,
    required this.selectedTime,
    required this.passengersCount,
    required this.passengers,
    this.specialRequests,
    required this.status,
    required this.createdAt,
  });

  double get totalPrice => price * passengersCount;

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
  String get formattedTotalPrice => '\$${totalPrice.toStringAsFixed(2)}';
  String get formattedDuration => '$durationMinutes minutes';
  String get formattedDate =>
      '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}';

  Map<String, dynamic> toJson() {
    return {
      'experienceId': experienceId,
      'experienceTitle': experienceTitle,
      'location': location,
      'imageUrl': imageUrl,
      'price': price,
      'priceUnit': priceUnit,
      'durationMinutes': durationMinutes,
      'selectedDate': selectedDate.toIso8601String(),
      'selectedTime': selectedTime,
      'passengersCount': passengersCount,
      'passengers': passengers.map((p) => p.toJson()).toList(),
      'specialRequests': specialRequests,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ExperienceBookingModel.fromJson(Map<String, dynamic> json) {
    return ExperienceBookingModel(
      experienceId: json['experienceId'],
      experienceTitle: json['experienceTitle'],
      location: json['location'],
      imageUrl: json['imageUrl'],
      price: json['price'].toDouble(),
      priceUnit: json['priceUnit'],
      durationMinutes: json['durationMinutes'],
      selectedDate: DateTime.parse(json['selectedDate']),
      selectedTime: json['selectedTime'],
      passengersCount: json['passengersCount'],
      passengers: (json['passengers'] as List)
          .map((p) => ExperiencePassenger.fromJson(p))
          .toList(),
      specialRequests: json['specialRequests'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  ExperienceBookingModel copyWith({
    int? experienceId,
    int? companyId,
    String? experienceTitle,
    String? location,
    String? imageUrl,
    double? price,
    String? priceUnit,
    int? durationMinutes,
    DateTime? selectedDate,
    String? selectedTime,
    int? passengersCount,
    List<ExperiencePassenger>? passengers,
    String? specialRequests,
    String? status,
    DateTime? createdAt,
  }) {
    return ExperienceBookingModel(
      experienceId: experienceId ?? this.experienceId,
      companyId: companyId ?? this.companyId,
      experienceTitle: experienceTitle ?? this.experienceTitle,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      priceUnit: priceUnit ?? this.priceUnit,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      passengersCount: passengersCount ?? this.passengersCount,
      passengers: passengers ?? this.passengers,
      specialRequests: specialRequests ?? this.specialRequests,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum PassengerType { adult, child }

enum ResidencyStatus { resident, foreigner }

// Matches charter_passengers table structure
class ExperiencePassenger {
  final String firstName;
  final String lastName;
  final PassengerType passengerType;
  final ResidencyStatus residencyStatus;
  final String? phoneNumber; // Optional contact number (not in DB table)
  final String? idPassportNumber; // Matches id_passport_number field

  ExperiencePassenger({
    required this.firstName,
    required this.lastName,
    this.passengerType = PassengerType.adult,
    this.residencyStatus = ResidencyStatus.resident,
    this.phoneNumber,
    this.idPassportNumber,
  });

  String get fullName => '$firstName $lastName';
  bool get isAdult => passengerType == PassengerType.adult;
  bool get isChild => passengerType == PassengerType.child;
  bool get isResident => residencyStatus == ResidencyStatus.resident;
  bool get isForeigner => residencyStatus == ResidencyStatus.foreigner;

  // Derived fields for charter_passengers table
  int get age => passengerType == PassengerType.adult ? 30 : 10; // Default ages
  String get nationality =>
      residencyStatus == ResidencyStatus.resident ? 'Kenyan' : 'Foreign';

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'age': age,
      'nationality': nationality,
      'idPassportNumber': idPassportNumber,
      'isUser': false, // Set to true for booking user
    };
  }

  factory ExperiencePassenger.fromJson(Map<String, dynamic> json) {
    // Determine passenger type from age
    PassengerType type = PassengerType.adult;
    if (json['age'] != null && json['age'] < 18) {
      type = PassengerType.child;
    }

    // Determine residency from nationality
    ResidencyStatus residency = ResidencyStatus.resident;
    if (json['nationality'] != null &&
        json['nationality'] != 'Kenyan' &&
        json['nationality'] != 'Kenya') {
      residency = ResidencyStatus.foreigner;
    }

    return ExperiencePassenger(
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      passengerType: type,
      residencyStatus: residency,
      phoneNumber: json['phoneNumber'],
      idPassportNumber: json['idPassportNumber'],
    );
  }

  ExperiencePassenger copyWith({
    String? firstName,
    String? lastName,
    PassengerType? passengerType,
    ResidencyStatus? residencyStatus,
    String? phoneNumber,
    String? idPassportNumber,
  }) {
    return ExperiencePassenger(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      passengerType: passengerType ?? this.passengerType,
      residencyStatus: residencyStatus ?? this.residencyStatus,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      idPassportNumber: idPassportNumber ?? this.idPassportNumber,
    );
  }
}
