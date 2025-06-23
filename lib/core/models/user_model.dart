import 'package:cloud_firestore/cloud_firestore.dart';

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
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory UserModel.fromJson(dynamic data) {
    final json = (data is List && data.isNotEmpty) ? data.first : data;
    if (json is! Map<String, dynamic>) {
      throw ArgumentError(
          'Invalid user json: expected Map or List containing Map');
    }
    try {
      return UserModel(
        id: json['id'] as String,
        email: json['email']?.toString(),
        phoneNumber: json['phone_number']?.toString(),
        firstName: json['first_name']?.toString(),
        lastName: json['last_name']?.toString(),
        countryCode: json['country_code']?.toString(),
        profileImageUrl: json['profile_image_url']?.toString(),
        loyaltyPoints: json['loyalty_points'] ?? 0,
        walletBalance: (json['wallet_balance'] ?? 0.0).toDouble(),
        isActive: json['is_active'] ?? true,
        emailVerified: json['email_verified'] ?? false,
        phoneVerified: json['phone_verified'] ?? false,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'].toString())
            : DateTime.now(),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'].toString())
            : DateTime.now(),
      );
    } catch (e) {
      // Return a default user model if parsing fails
      return UserModel(
        id: json['id']?.toString() ?? 'unknown',
        email: json['email']?.toString(),
        phoneNumber: json['phone_number']?.toString(),
        firstName: json['first_name']?.toString(),
        lastName: json['last_name']?.toString(),
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
      // 'loyalty_points': loyaltyPoints,
      'wallet_balance': walletBalance,
      'is_active': isActive,
      'email_verified': emailVerified,
      'phone_verified': phoneVerified,
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
