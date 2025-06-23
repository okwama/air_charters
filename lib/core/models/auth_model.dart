import 'user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthModel {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final DateTime expiresAt;
  final UserModel user;

  const AuthModel({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.expiresAt,
    required this.user,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    try {
      final expiresIn = json['expires_in'] ?? 3600; // Default 1 hour
      final expiresAt = DateTime.now().add(Duration(seconds: expiresIn));

      return AuthModel(
        accessToken: json['access_token']?.toString() ?? '',
        refreshToken: json['refresh_token']?.toString() ?? '',
        tokenType: json['token_type']?.toString() ?? 'Bearer',
        expiresIn: expiresIn,
        expiresAt: expiresAt,
        user: UserModel.fromJson(json['user'] ?? {}),
      );
    } catch (e) {
      // Return a default auth model if parsing fails
      return AuthModel(
        accessToken: json['access_token']?.toString() ?? '',
        refreshToken: json['refresh_token']?.toString() ?? '',
        tokenType: 'Bearer',
        expiresIn: 3600,
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
        user: UserModel.fromJson(json['user'] ?? {}),
      );
    }
  }

  factory AuthModel.fromBackendJson(dynamic data) {
    // If backend accidentally wraps response in a list, take the first element.
    final json = (data is List && data.isNotEmpty) ? data.first : data;

    if (json is! Map<String, dynamic>) {
      throw ArgumentError(
          'Invalid auth json: expected Map or List containing Map');
    }

    // The backend token doesn't have an explicit expiry, so we manage it.
    // We'll use the 'expiresIn' from the original Firebase logic (1 hour).
    final expiresIn = 3600;
    final expiresAt = DateTime.now().add(Duration(seconds: expiresIn));

    return AuthModel(
      accessToken: json['token']?.toString() ?? '',
      // Backend doesn't provide a refresh token in this response,
      // as we re-authenticate with the firebase token.
      refreshToken: json['token']?.toString() ?? '',
      tokenType: 'Bearer',
      expiresIn: expiresIn,
      expiresAt: expiresAt,
      user: UserModel.fromJson(json['user'] ?? {}),
    );
  }

  factory AuthModel.fromFirebase(IdTokenResult idTokenResult, UserModel user) {
    final claims = idTokenResult.claims ?? {};
    final expiresIn = (claims['exp'] as int) -
        (claims['iat'] as int); // exp and iat are in seconds
    return AuthModel(
      accessToken: idTokenResult.token!,
      refreshToken: '', // Firebase SDK handles refresh
      tokenType: 'Bearer',
      expiresIn: expiresIn,
      expiresAt: idTokenResult.expirationTime!,
      user: user,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
      'expires_at': expiresAt.toIso8601String(),
      'user': user.toJson(),
    };
  }

  bool get isExpired {
    return DateTime.now().isAfter(expiresAt);
  }

  bool get willExpireSoon {
    // Check if token expires in next 5 minutes
    return DateTime.now()
        .isAfter(expiresAt.subtract(const Duration(minutes: 5)));
  }

  String get authorizationHeader {
    return '$tokenType $accessToken';
  }

  AuthModel copyWith({
    String? accessToken,
    String? refreshToken,
    String? tokenType,
    int? expiresIn,
    DateTime? expiresAt,
    UserModel? user,
  }) {
    return AuthModel(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenType: tokenType ?? this.tokenType,
      expiresIn: expiresIn ?? this.expiresIn,
      expiresAt: expiresAt ?? this.expiresAt,
      user: user ?? this.user,
    );
  }

  @override
  String toString() {
    return 'AuthModel(accessToken: ${accessToken.substring(0, 10)}..., user: ${user.fullName})';
  }
}
