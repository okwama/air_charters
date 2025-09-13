class ExperienceBookingModel {
  final int experienceId;
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

class ExperiencePassenger {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? passportNumber;
  final DateTime? dateOfBirth;
  final String? specialRequirements;

  ExperiencePassenger({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.passportNumber,
    this.dateOfBirth,
    this.specialRequirements,
  });

  String get fullName => '$firstName $lastName';

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'passportNumber': passportNumber,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'specialRequirements': specialRequirements,
    };
  }

  factory ExperiencePassenger.fromJson(Map<String, dynamic> json) {
    return ExperiencePassenger(
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phone: json['phone'],
      passportNumber: json['passportNumber'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      specialRequirements: json['specialRequirements'],
    );
  }

  ExperiencePassenger copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? passportNumber,
    DateTime? dateOfBirth,
    String? specialRequirements,
  }) {
    return ExperiencePassenger(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      passportNumber: passportNumber ?? this.passportNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      specialRequirements: specialRequirements ?? this.specialRequirements,
    );
  }
}
