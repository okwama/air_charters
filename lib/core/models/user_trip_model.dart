import 'booking_model.dart';

enum UserTripStatus {
  pending,
  upcoming,
  completed,
  cancelled,
}

class UserTripModel {
  final String id;
  final String? userId; // Make userId optional
  final String bookingId;
  final UserTripStatus status;
  final int? rating;
  final String? review;
  final DateTime? reviewDate;
  final String? photos;
  final String? videos;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;

  // Related booking data (populated from relations)
  final BookingModel? booking;

  const UserTripModel({
    required this.id,
    this.userId, // Make userId optional
    required this.bookingId,
    required this.status,
    this.rating,
    this.review,
    this.reviewDate,
    this.photos,
    this.videos,
    required this.createdAt,
    this.completedAt,
    this.cancelledAt,
    this.booking,
  });

  factory UserTripModel.fromJson(Map<String, dynamic> json) {
    try {
      return UserTripModel(
        id: json['id']?.toString() ?? '',
        userId: json['userId']?.toString(), // Allow null userId
        bookingId: json['bookingId']?.toString() ?? '',
        status: _parseUserTripStatus(json['status']?.toString()),
        rating: _parseNullableInt(json['rating']),
        review: _parseNullableString(json['review']),
        reviewDate: _parseNullableDateTime(json['reviewDate']),
        photos: _parseNullableString(json['photos']),
        videos: _parseNullableString(json['videos']),
        createdAt: _parseDateTime(json['createdAt']),
        completedAt: _parseNullableDateTime(json['completedAt']),
        cancelledAt: _parseNullableDateTime(json['cancelledAt']),
        booking: json['booking'] != null
            ? BookingModel.fromJson(json['booking'] as Map<String, dynamic>)
            : null,
      );
    } catch (e) {
      print('Error parsing UserTripModel: $e');
      print('JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (userId != null) 'userId': userId,
      'bookingId': bookingId,
      'status': status.name,
      if (rating != null) 'rating': rating,
      if (review != null) 'review': review,
      if (reviewDate != null) 'reviewDate': reviewDate!.toIso8601String(),
      if (photos != null) 'photos': photos,
      if (videos != null) 'videos': videos,
      'createdAt': createdAt.toIso8601String(),
      if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
      if (cancelledAt != null) 'cancelledAt': cancelledAt!.toIso8601String(),
      if (booking != null) 'booking': booking!.toJson(),
    };
  }

  // Create JSON for trip creation (without server-generated fields)
  Map<String, dynamic> toCreateJson() {
    return {
      if (userId != null) 'userId': userId,
      'bookingId': bookingId,
      'status': status.name,
      // Only include optional fields if they have values
      if (rating != null && rating! > 0) 'rating': rating,
      if (review != null && review!.isNotEmpty) 'review': review,
      if (photos != null && photos!.isNotEmpty) 'photos': photos,
      if (videos != null && videos!.isNotEmpty) 'videos': videos,
    };
  }

  UserTripModel copyWith({
    String? id,
    String? userId,
    String? bookingId,
    UserTripStatus? status,
    int? rating,
    String? review,
    DateTime? reviewDate,
    String? photos,
    String? videos,
    DateTime? createdAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    BookingModel? booking,
  }) {
    return UserTripModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bookingId: bookingId ?? this.bookingId,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      reviewDate: reviewDate ?? this.reviewDate,
      photos: photos ?? this.photos,
      videos: videos ?? this.videos,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      booking: booking ?? this.booking,
    );
  }

  static UserTripStatus _parseUserTripStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return UserTripStatus.pending;
      case 'upcoming':
        return UserTripStatus.upcoming;
      case 'completed':
        return UserTripStatus.completed;
      case 'cancelled':
        return UserTripStatus.cancelled;
      default:
        return UserTripStatus.upcoming;
    }
  }

  // Helper method to safely parse nullable string
  static String? _parseNullableString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  // Helper method to safely parse nullable int
  static int? _parseNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed;
    }
    if (value is double) return value.toInt();
    return null;
  }

  // Helper method to safely parse DateTime (required field)
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        print('Error parsing DateTime: $value');
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  // Helper method to safely parse nullable DateTime
  static DateTime? _parseNullableDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        print('Error parsing nullable DateTime: $value');
        return null;
      }
    }
    return null;
  }

  // Convenience getters for nullable fields
  bool get hasRating => rating != null && rating! > 0;
  bool get hasReview => review != null && review!.isNotEmpty;
  bool get hasPhotos => photos != null && photos!.isNotEmpty;
  bool get hasVideos => videos != null && videos!.isNotEmpty;
  bool get isCompleted => completedAt != null;
  bool get isCancelled => cancelledAt != null;

  // Display helpers
  String get ratingDisplay => hasRating ? '$rating/5' : 'No rating';
  String get reviewDisplay => hasReview ? review! : 'No review';
  String get statusDisplay => status.name.toUpperCase();

  @override
  String toString() {
    return 'UserTripModel(id: $id, userId: $userId, bookingId: $bookingId, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserTripModel &&
        other.id == id &&
        other.userId == userId &&
        other.bookingId == bookingId &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        (userId?.hashCode ?? 0) ^
        bookingId.hashCode ^
        status.hashCode;
  }
}
