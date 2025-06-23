// Base exception class
abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, [this.code]);

  @override
  String toString() => message;
}

// Network exceptions
class NetworkException extends AppException {
  const NetworkException(super.message, [super.code]);
}

class TimeoutException extends AppException {
  const TimeoutException(super.message, [super.code]);
}

// Server exceptions
class ServerException extends AppException {
  const ServerException(super.message, [super.code]);
}

// Authentication exceptions
class AuthException extends AppException {
  const AuthException(super.message, [super.code]);
}

class TokenExpiredException extends AppException {
  const TokenExpiredException(super.message, [super.code]);
}

// Validation exceptions
class ValidationException extends AppException {
  const ValidationException(super.message, [super.code]);
}

// Business logic exceptions
class BookingException extends AppException {
  const BookingException(super.message, [super.code]);
}

class PaymentException extends AppException {
  const PaymentException(super.message, [super.code]);
}

// Storage exceptions
class StorageException extends AppException {
  const StorageException(super.message, [super.code]);
}
