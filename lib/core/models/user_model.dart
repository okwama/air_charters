// Removed unused import: cloud_firestore

class UserModel {
  final String id;
  final String? email;
  final String? phoneNumber;
  final String? firstName;
  final String? lastName;
  final String? countryCode;
  final String? profileImageUrl;
  final int loyaltyPoints;
  final double walletBalance;
  final bool isActive;
  final bool emailVerified;
  final bool phoneVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  // New fields from enhanced database
  final DateTime? dateOfBirth;
  final String? nationality;
  final String? language;
  final String? currency;
  final String? timezone;
  final String? theme;
  final String? loyaltyTier;

  UserModel({
    required this.id,
    this.email,
    this.phoneNumber,
    this.firstName,
    this.lastName,
    this.countryCode,
    this.profileImageUrl,
    this.loyaltyPoints = 0,
    this.walletBalance = 0.0,
    this.isActive = true,
    this.emailVerified = false,
    this.phoneVerified = false,
    this.dateOfBirth,
    this.nationality,
    this.language,
    this.currency,
    this.timezone,
    this.theme,
    this.loyaltyTier,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory UserModel.fromJson(dynamic data) {
    final json = (data is List && data.isNotEmpty) ? data.first : data;
    if (json is! Map<String, dynamic>) {
      throw ArgumentError(
          'Invalid user json: expected Map or List containing Map, got ${json.runtimeType}. Data: $json');
    }

    try {
      return UserModel(
        id: json['id']?.toString() ?? 'unknown',
        email: json['email']?.toString(),
        // Handle both snake_case and camelCase field names
        phoneNumber:
            json['phoneNumber']?.toString() ?? json['phone_number']?.toString(),
        firstName:
            json['firstName']?.toString() ?? json['first_name']?.toString(),
        lastName: json['lastName']?.toString() ?? json['last_name']?.toString(),
        countryCode:
            json['countryCode']?.toString() ?? json['country_code']?.toString(),
        profileImageUrl: json['profileImageUrl']?.toString() ??
            json['profile_image_url']?.toString(),
        loyaltyPoints: json['loyaltyPoints'] ?? json['loyalty_points'] ?? 0,
        walletBalance:
            (json['walletBalance'] ?? json['wallet_balance'] ?? 0.0).toDouble(),
        isActive: json['isActive'] ?? json['is_active'] ?? true,
        emailVerified: json['emailVerified'] ?? json['email_verified'] ?? false,
        phoneVerified: json['phoneVerified'] ?? json['phone_verified'] ?? false,
        dateOfBirth:
            json['dateOfBirth'] != null || json['date_of_birth'] != null
                ? DateTime.parse(
                    (json['dateOfBirth'] ?? json['date_of_birth']).toString())
                : null,
        nationality: json['nationality']?.toString(),
        language: json['language']?.toString(),
        currency: json['currency']?.toString(),
        timezone: json['timezone']?.toString(),
        theme: json['theme']?.toString(),
        loyaltyTier:
            json['loyaltyTier']?.toString() ?? json['loyalty_tier']?.toString(),
        createdAt: json['createdAt'] != null || json['created_at'] != null
            ? DateTime.parse(
                (json['createdAt'] ?? json['created_at']).toString())
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null || json['updated_at'] != null
            ? DateTime.parse(
                (json['updatedAt'] ?? json['updated_at']).toString())
            : DateTime.now(),
      );
    } catch (e) {
      // Return a default user model if parsing fails
      return UserModel(
        id: json['id']?.toString() ?? 'unknown',
        email: json['email']?.toString(),
        phoneNumber:
            json['phoneNumber']?.toString() ?? json['phone_number']?.toString(),
        firstName:
            json['firstName']?.toString() ?? json['first_name']?.toString(),
        lastName: json['lastName']?.toString() ?? json['last_name']?.toString(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  factory UserModel.fromBackendJson(Map<String, dynamic> json) {
    return UserModel.fromJson(json);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone_number': phoneNumber,
      'first_name': firstName,
      'last_name': lastName,
      'country_code': countryCode,
      'profile_image_url': profileImageUrl,
      'loyalty_points': loyaltyPoints,
      'wallet_balance': walletBalance,
      'is_active': isActive,
      'email_verified': emailVerified,
      'phone_verified': phoneVerified,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'nationality': nationality,
      'language': language,
      'currency': currency,
      'timezone': timezone,
      'theme': theme,
      'loyalty_tier': loyaltyTier,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? phoneNumber,
    String? firstName,
    String? lastName,
    String? countryCode,
    String? profileImageUrl,
    int? loyaltyPoints,
    double? walletBalance,
    bool? isActive,
    bool? emailVerified,
    bool? phoneVerified,
    DateTime? dateOfBirth,
    String? nationality,
    String? language,
    String? currency,
    String? timezone,
    String? theme,
    String? loyaltyTier,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      countryCode: countryCode ?? this.countryCode,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      walletBalance: walletBalance ?? this.walletBalance,
      isActive: isActive ?? this.isActive,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      nationality: nationality ?? this.nationality,
      language: language ?? this.language,
      currency: currency ?? this.currency,
      timezone: timezone ?? this.timezone,
      theme: theme ?? this.theme,
      loyaltyTier: loyaltyTier ?? this.loyaltyTier,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    }
    return 'User';
  }

  String get displayName {
    if (firstName != null && lastName != null) {
      return '${firstName![0]}${lastName![0]}'.toUpperCase();
    } else if (firstName != null) {
      return firstName![0].toUpperCase();
    } else if (lastName != null) {
      return lastName![0].toUpperCase();
    }
    return 'U';
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, phoneNumber: $phoneNumber, fullName: $fullName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
