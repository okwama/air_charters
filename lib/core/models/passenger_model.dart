class PassengerModel {
  final int? id;
  final int? bookingId;
  final String firstName;
  final String lastName;
  final int? age;
  final String? nationality;
  final String? idPassportNumber;
  final bool isUser;

  const PassengerModel({
    this.id,
    this.bookingId,
    required this.firstName,
    required this.lastName,
    this.age,
    this.nationality,
    this.idPassportNumber,
    this.isUser = false,
  });

  // Create passenger from user data
  factory PassengerModel.fromUser({
    int? id,
    int? bookingId,
    required String firstName,
    required String lastName,
    required int age,
    required String nationality,
    String? idPassportNumber,
  }) {
    return PassengerModel(
      id: id,
      bookingId: bookingId,
      firstName: firstName,
      lastName: lastName,
      age: age,
      nationality: nationality,
      idPassportNumber: idPassportNumber,
      isUser: true,
    );
  }

  // Create empty passenger for additional passengers
  factory PassengerModel.empty() {
    return const PassengerModel(
      firstName: '',
      lastName: '',
      age: 25,
      nationality: 'Kenyan',
      idPassportNumber: null,
      isUser: false,
    );
  }

  // Copy with modifications
  PassengerModel copyWith({
    int? id,
    int? bookingId,
    String? firstName,
    String? lastName,
    int? age,
    String? nationality,
    String? idPassportNumber,
    bool? isUser,
  }) {
    return PassengerModel(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      age: age ?? this.age,
      nationality: nationality ?? this.nationality,
      idPassportNumber: idPassportNumber ?? this.idPassportNumber,
      isUser: isUser ?? this.isUser,
    );
  }

  // Convert to JSON for API calls
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'firstName': firstName,
      'lastName': lastName,
      'age': age,
      'nationality': nationality,
      'idPassportNumber': idPassportNumber,
      'isUser': isUser,
    };
  }

  // Convert to JSON for creating new passengers (without IDs)
  Map<String, dynamic> toCreateJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'age': age,
      'nationality': (nationality ?? '').toString(),
      'idPassportNumber': idPassportNumber?.toString(),
      'isUser': isUser,
    };
  }

  // Convert to JSON for updating existing passengers
  Map<String, dynamic> toUpdateJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'age': age,
      'nationality': (nationality ?? '').toString(),
      'idPassportNumber': idPassportNumber?.toString(),
      'isUser': isUser,
    };
  }

  // Create from JSON
  factory PassengerModel.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is String) {
        final parsed = int.tryParse(v);
        return parsed;
      }
      return null;
    }

    return PassengerModel(
      id: parseInt(json['id']),
      bookingId: parseInt(json['bookingId']),
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      age: parseInt(json['age']) ?? 25,
      nationality: (json['nationality'] as String?) ?? 'Kenyan',
      idPassportNumber: json['idPassportNumber'] as String?,
      isUser: (json['isUser'] as bool?) ?? false,
    );
  }

  // Validation methods
  bool get isValid {
    return firstName.isNotEmpty &&
        lastName.isNotEmpty &&
        (age ?? 0) > 0 &&
        (nationality?.isNotEmpty ?? false);
  }

  bool isValidForInternationalFlight() {
    return isValid &&
        idPassportNumber != null &&
        idPassportNumber!.isNotEmpty;
  }

  // Display name
  String get fullName => '$firstName $lastName'.trim();
  String get displayName => fullName; // Alias for compatibility

  // Age category
  String get ageCategory {
    final a = age ?? 0;
    if (a < 2) return 'Infant';
    if (a < 12) return 'Child';
    return 'Adult';
  }

  // Additional getters for compatibility
  String get initials {
    final firstInitial = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final lastInitial = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$firstInitial$lastInitial';
  }

  String get ageDisplay => age != null ? '$age years old' : 'Age N/A';

  String get documentDisplay {
    if (idPassportNumber != null && idPassportNumber!.isNotEmpty) {
      return idPassportNumber!;
    }
    return 'No document';
  }

  // Validation errors
  List<String> getValidationErrors({bool isInternationalFlight = false}) {
    final errors = <String>[];
    
    if (firstName.isEmpty) errors.add('First name is required');
    if (lastName.isEmpty) errors.add('Last name is required');
    if ((age ?? 0) <= 0) errors.add('Valid age is required');
    if ((nationality == null) || nationality!.isEmpty) {
      errors.add('Nationality is required');
    }
    
    if (isInternationalFlight && 
        (idPassportNumber == null || idPassportNumber!.isEmpty)) {
      errors.add('Passport/ID number is required for international flights');
    }
    
    return errors;
  }

  @override
  String toString() {
    return 'PassengerModel(firstName: $firstName, lastName: $lastName, age: $age, nationality: $nationality, isUser: $isUser)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PassengerModel &&
        other.id == id &&
        other.bookingId == bookingId &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.age == age &&
        other.nationality == nationality &&
        other.idPassportNumber == idPassportNumber &&
        other.isUser == isUser;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      bookingId,
      firstName,
      lastName,
      age,
      nationality,
      idPassportNumber,
      isUser,
    );
  }
}

// Helper class for passenger validation
class PassengerValidationHelper {
  static const List<String> commonNationalities = [
    'Kenyan',
    'Ugandan',
    'Tanzanian',
    'Ethiopian',
    'South African',
    'Nigerian',
    'American',
    'British',
    'German',
    'French',
    'Canadian',
    'Australian',
    'Indian',
    'Chinese',
    'Other',
  ];

  static bool isInternationalFlight(String origin, String destination) {
    // List of domestic airports in Kenya
    const domesticAirports = [
      'Jomo Kenyatta International Airport',
      'Wilson Airport',
      'Moi International Airport',
      'Kisumu Airport',
      'Eldoret Airport',
      'Malindi Airport',
      'Lamu Airport',
      'Ukunda Airport',
      'Diani Airport',
      'Nairobi',
      'Mombasa',
      'Kisumu',
      'Eldoret',
      'Malindi',
      'Lamu',
      'Diani',
    ];

    // Check if both origin and destination are domestic
    final isOriginDomestic = domesticAirports.any((airport) => 
        origin.toLowerCase().contains(airport.toLowerCase()));
    final isDestinationDomestic = domesticAirports.any((airport) => 
        destination.toLowerCase().contains(airport.toLowerCase()));

    return !(isOriginDomestic && isDestinationDomestic);
  }

  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    
    return age;
  }
}