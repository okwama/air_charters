class PassengerModel {
  final int? id;
  final String bookingId;
  final String firstName;
  final String lastName;
  final int? age;
  final String? nationality;
  final String? idPassportNumber;
  final bool
      isUser; // Added: Flag to identify if this passenger is the booking user
  final DateTime? createdAt;

  const PassengerModel({
    this.id,
    required this.bookingId,
    required this.firstName,
    required this.lastName,
    this.age,
    this.nationality,
    this.idPassportNumber,
    this.isUser = false, // Default to false
    this.createdAt,
  });

  factory PassengerModel.fromJson(Map<String, dynamic> json) {
    return PassengerModel(
      id: json['id'] as int?,
      bookingId:
          json['bookingId']?.toString() ?? json['booking_id']?.toString() ?? '',
      firstName:
          json['firstName']?.toString() ?? json['first_name']?.toString() ?? '',
      lastName:
          json['lastName']?.toString() ?? json['last_name']?.toString() ?? '',
      age: json['age'] as int?,
      nationality: json['nationality']?.toString(),
      idPassportNumber: json['idPassportNumber']?.toString() ??
          json['id_passport_number']?.toString(),
      isUser: json['isUser'] as bool? ?? json['is_user'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'bookingId': bookingId,
      'firstName': firstName,
      'lastName': lastName,
      if (age != null) 'age': age,
      if (nationality != null) 'nationality': nationality,
      if (idPassportNumber != null) 'idPassportNumber': idPassportNumber,
      'isUser': isUser, // Include isUser field
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

  // Create a copy for API requests (without id, bookingId, isUser and createdAt)
  Map<String, dynamic> toCreateJson() {
    print('=== PASSENGER MODEL TO CREATE JSON ===');
    print('First name: $firstName (${firstName.runtimeType})');
    print('Last name: $lastName (${lastName.runtimeType})');
    print('Age: $age (${age.runtimeType})');
    print('Nationality: $nationality (${nationality.runtimeType})');
    print('ID/Passport: $idPassportNumber (${idPassportNumber.runtimeType})');

    final json = {
      'firstName': firstName,
      'lastName': lastName,
      if (age != null) 'age': age,
      if (nationality != null) 'nationality': nationality,
      if (idPassportNumber != null) 'idPassportNumber': idPassportNumber,
      'isUser': isUser, // Add missing isUser field
    };

    print('Passenger JSON: $json');
    return json;
  }

  // Create a copy for API updates (without bookingId, id and createdAt)
  Map<String, dynamic> toUpdateJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      if (age != null) 'age': age,
      if (nationality != null) 'nationality': nationality,
      if (idPassportNumber != null) 'idPassportNumber': idPassportNumber,
      'isUser': isUser, // Include isUser field
    };
  }

  String get fullName => '$firstName $lastName'.trim();

  String get displayName =>
      fullName.isNotEmpty ? fullName : 'Unnamed Passenger';

  String get initials {
    final firstInitial = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final lastInitial = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$firstInitial$lastInitial';
  }

  String get ageDisplay {
    if (age == null) return 'Age not specified';
    return '$age years old';
  }

  String get documentDisplay {
    if (idPassportNumber == null || idPassportNumber!.isEmpty) {
      return 'No document provided';
    }
    return 'ID/Passport: $idPassportNumber';
  }

  // Helper method to check if this is the primary passenger (user)
  bool get isPrimaryPassenger => isUser;

  PassengerModel copyWith({
    int? id,
    String? bookingId,
    String? firstName,
    String? lastName,
    int? age,
    String? nationality,
    String? idPassportNumber,
    bool? isUser,
    DateTime? createdAt,
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
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PassengerModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          bookingId == other.bookingId &&
          firstName == other.firstName &&
          lastName == other.lastName &&
          age == other.age &&
          nationality == other.nationality &&
          idPassportNumber == other.idPassportNumber &&
          isUser == other.isUser;

  @override
  int get hashCode =>
      id.hashCode ^
      bookingId.hashCode ^
      firstName.hashCode ^
      lastName.hashCode ^
      age.hashCode ^
      nationality.hashCode ^
      idPassportNumber.hashCode ^
      isUser.hashCode;

  @override
  String toString() {
    return 'PassengerModel{id: $id, fullName: $fullName, age: $age, nationality: $nationality, isUser: $isUser}';
  }
}
