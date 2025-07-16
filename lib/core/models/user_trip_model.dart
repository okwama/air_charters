import 'booking_model.dart';

enum UserTripStatus {
  upcoming,
  completed,
  cancelled,
}

class UserTripModel {
  final String id;
  final String userId;
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
    required this.userId,
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
    return UserTripModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      bookingId: json['bookingId'] as String,
      status: _parseUserTripStatus(json['status'] as String),
      rating: json['rating'] as int?,
      review: json['review'] as String?,
      reviewDate: json['reviewDate'] != null
          ? DateTime.parse(json['reviewDate'] as String)
          : null,
      photos: json['photos'] as String?,
      videos: json['videos'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.parse(json['cancelledAt'] as String)
          : null,
      booking: json['booking'] != null
          ? BookingModel.fromJson(json['booking'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
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
      'bookingId': bookingId,
      'status': status.name,
      if (rating != null) 'rating': rating,
      if (review != null) 'review': review,
      if (photos != null) 'photos': photos,
      if (videos != null) 'videos': videos,
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
    return id.hashCode ^ userId.hashCode ^ bookingId.hashCode ^ status.hashCode;
  }
}
