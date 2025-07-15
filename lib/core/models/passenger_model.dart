class PassengerModel {
  final int? id;
  final String bookingId;
  final String firstName;
  final String lastName;
  final int? age;
  final String? nationality;
  final String? idPassportNumber;
  final DateTime? createdAt;

  const PassengerModel({
    this.id,
    required this.bookingId,
    required this.firstName,
    required this.lastName,
    this.age,
    this.nationality,
    this.idPassportNumber,
    this.createdAt,
  });

  factory PassengerModel.fromJson(Map<String, dynamic> json) {
    return PassengerModel(
      id: json['id'] as int?,
      bookingId: json['bookingId'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      age: json['age'] as int?,
      nationality: json['nationality'] as String?,
      idPassportNumber: json['idPassportNumber'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
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
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

  // Create a copy for API requests (without id and createdAt)
  Map<String, dynamic> toCreateJson() {
    return {
      'bookingId': bookingId,
      'firstName': firstName,
      'lastName': lastName,
      if (age != null) 'age': age,
      if (nationality != null) 'nationality': nationality,
      if (idPassportNumber != null) 'idPassportNumber': idPassportNumber,
    };
  }

  // Create a copy for API updates (without bookingId, id and createdAt)
  Map<String, dynamic> toUpdateJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      if (age != null) 'age': age,
      if (nationality != null) 'nationality': nationality,
      if (idPassportNumber != null) 'idPassportNumber': idPassportNumber,
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

  PassengerModel copyWith({
    int? id,
    String? bookingId,
    String? firstName,
    String? lastName,
    int? age,
    String? nationality,
    String? idPassportNumber,
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
          idPassportNumber == other.idPassportNumber;

  @override
  int get hashCode =>
      id.hashCode ^
      bookingId.hashCode ^
      firstName.hashCode ^
      lastName.hashCode ^
      age.hashCode ^
      nationality.hashCode ^
      idPassportNumber.hashCode;

  @override
  String toString() {
    return 'PassengerModel{id: $id, fullName: $fullName, age: $age, nationality: $nationality}';
  }
}
