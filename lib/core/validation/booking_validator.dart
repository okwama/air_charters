import '../models/location_model.dart';
import '../models/passenger_model.dart';
import 'base_validator.dart';

/// Validation result for booking inputs (extends base validation result)
class ValidationResult extends BaseValidationResult {
  ValidationResult({
    required super.isValid,
    super.errors = const [],
    super.warnings = const [],
    super.metadata = const {},
  });

  factory ValidationResult.success([Map<String, dynamic> metadata = const {}]) {
    return ValidationResult(
      isValid: true,
      metadata: metadata,
    );
  }

  factory ValidationResult.failure(
    List<String> errors, {
    List<String> warnings = const [],
    Map<String, dynamic> metadata = const {},
  }) {
    return ValidationResult(
      isValid: false,
      errors: errors,
      warnings: warnings,
      metadata: metadata,
    );
  }

  /// Add an error to the result
  @override
  ValidationResult addError(String error, {String? field}) {
    final fieldError = field != null ? '$field: $error' : error;
    return ValidationResult(
      isValid: false,
      errors: [...errors, fieldError],
      warnings: warnings,
      metadata: metadata,
    );
  }

  /// Add a warning to the result
  @override
  ValidationResult addWarning(String warning, {String? field}) {
    final fieldWarning = field != null ? '$field: $warning' : warning;
    return ValidationResult(
      isValid: isValid,
      errors: errors,
      warnings: [...warnings, fieldWarning],
      metadata: metadata,
    );
  }

  /// Combine multiple validation results
  @override
  ValidationResult combine(BaseValidationResult other) {
    return ValidationResult(
      isValid: isValid && other.isValid,
      errors: [...errors, ...other.errors],
      warnings: [...warnings, ...other.warnings],
      metadata: {...metadata, ...other.metadata},
    );
  }

  /// Get all errors for a specific field
  @override
  List<String> getErrorsForField(String field) {
    return errors.where((error) => error.startsWith('$field:')).toList();
  }

  /// Get all warnings for a specific field
  @override
  List<String> getWarningsForField(String field) {
    return warnings.where((warning) => warning.startsWith('$field:')).toList();
  }

  /// Check if a specific field has errors
  @override
  bool hasErrorForField(String field) {
    return errors.any((error) => error.startsWith('$field:'));
  }

  /// Check if a specific field has warnings
  @override
  bool hasWarningForField(String field) {
    return warnings.any((warning) => warning.startsWith('$field:'));
  }
}

/// Comprehensive booking validation service
class BookingValidator extends BaseValidator {
  static final BookingValidator _instance = BookingValidator._internal();
  factory BookingValidator() => _instance;
  BookingValidator._internal();

  // Validation constants
  static const int maxPassengers = 20;
  static const int maxStops = 5;
  static const int maxSpecialRequirementsLength = 1000;
  static const int minPassportIdLength = 5;
  static const int maxPhoneDigits = 15;
  static const int minPhoneDigits = 10;

  /// Validate direct charter booking inputs
  ValidationResult validateDirectCharterBooking({
    required LocationModel? origin,
    required LocationModel? destination,
    required DateTime? departureDate,
    required DateTime? returnDate,
    required int passengerCount,
    required bool isRoundTrip,
    List<LocationModel>? stops,
    String? specialRequirements,
  }) {
    ValidationResult result = ValidationResult.success();

    // Validate origin
    result = result.combine(_validateLocation(origin, 'Origin'));

    // Validate destination
    result = result.combine(_validateLocation(destination, 'Destination'));

    // Validate departure date
    result = result.combine(_validateDepartureDate(departureDate));

    // Validate return date if round trip
    if (isRoundTrip) {
      result = result.combine(_validateReturnDate(returnDate, departureDate));
    }

    // Validate passenger count
    result = result.combine(_validatePassengerCount(passengerCount));

    // Validate stops
    if (stops != null && stops.isNotEmpty) {
      result = result.combine(_validateStops(stops));
    }

    // Validate special requirements
    if (specialRequirements != null && specialRequirements.isNotEmpty) {
      result =
          result.combine(_validateSpecialRequirements(specialRequirements));
    }

    return result;
  }

  /// Validate deal booking inputs
  ValidationResult validateDealBooking({
    required int? dealId,
    required int passengerCount,
    required List<PassengerModel> passengers,
    String? specialRequirements,
  }) {
    ValidationResult result = ValidationResult.success();

    // Validate deal ID
    if (dealId == null || dealId <= 0) {
      result = result.addError('Please select a valid deal');
    }

    // Validate passenger count
    result = result.combine(_validatePassengerCount(passengerCount));

    // Validate passengers
    result = result.combine(_validatePassengers(passengers));

    // Validate passenger count consistency
    if (passengerCount != passengers.length) {
      result = result.addError(
          'Passenger count ($passengerCount) does not match number of passengers (${passengers.length})');
    }

    // Validate special requirements
    if (specialRequirements != null && specialRequirements.isNotEmpty) {
      result =
          result.combine(_validateSpecialRequirements(specialRequirements));
    }

    return result;
  }

  /// Validate passenger information
  ValidationResult validatePassengers(List<PassengerModel> passengers) {
    return _validatePassengers(passengers);
  }

  /// Validate location
  ValidationResult _validateLocation(
      LocationModel? location, String fieldName) {
    if (location == null) {
      return ValidationResult.failure(['$fieldName is required']);
    }

    if (location.name.isEmpty) {
      return ValidationResult.failure(['$fieldName name is required']);
    }

    if (location.latitude == null || location.longitude == null) {
      return ValidationResult.failure(['$fieldName coordinates are required']);
    }

    // Validate coordinate ranges
    if (location.latitude! < -90 || location.latitude! > 90) {
      return ValidationResult.failure(
          ['$fieldName latitude must be between -90 and 90']);
    }

    if (location.longitude! < -180 || location.longitude! > 180) {
      return ValidationResult.failure(
          ['$fieldName longitude must be between -180 and 180']);
    }

    return ValidationResult.success();
  }

  /// Validate departure date
  ValidationResult _validateDepartureDate(DateTime? departureDate) {
    if (departureDate == null) {
      return ValidationResult.failure(['Departure date is required']);
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (departureDate.isBefore(today)) {
      return ValidationResult.failure(['Departure date cannot be in the past']);
    }

    // Check if departure is too far in the future (1 year limit)
    final maxDate = today.add(const Duration(days: 365));
    if (departureDate.isAfter(maxDate)) {
      return ValidationResult.failure(
          ['Departure date cannot be more than 1 year in the future']);
    }

    return ValidationResult.success();
  }

  /// Validate return date
  ValidationResult _validateReturnDate(
      DateTime? returnDate, DateTime? departureDate) {
    if (returnDate == null) {
      return ValidationResult.failure(
          ['Return date is required for round trip']);
    }

    if (departureDate == null) {
      return ValidationResult.failure(
          ['Departure date is required to validate return date']);
    }

    if (returnDate.isBefore(departureDate)) {
      return ValidationResult.failure(
          ['Return date must be after departure date']);
    }

    // Check if return is too far after departure (30 days limit)
    final maxReturnDate = departureDate.add(const Duration(days: 30));
    if (returnDate.isAfter(maxReturnDate)) {
      return ValidationResult.failure(
          ['Return date cannot be more than 30 days after departure']);
    }

    return ValidationResult.success();
  }

  /// Validate passenger count
  ValidationResult _validatePassengerCount(int passengerCount) {
    if (passengerCount <= 0) {
      return ValidationResult.failure(['At least 1 passenger is required']);
    }

    if (passengerCount > maxPassengers) {
      return ValidationResult.failure(
          ['Maximum $maxPassengers passengers allowed']);
    }

    return ValidationResult.success();
  }

  /// Validate stops
  ValidationResult _validateStops(List<LocationModel> stops) {
    if (stops.length > maxStops) {
      return ValidationResult.failure(['Maximum $maxStops stops allowed']);
    }

    ValidationResult result = ValidationResult.success();
    for (int i = 0; i < stops.length; i++) {
      result = result.combine(_validateLocation(stops[i], 'Stop ${i + 1}'));
    }

    return result;
  }

  /// Validate passengers
  ValidationResult _validatePassengers(List<PassengerModel> passengers) {
    if (passengers.isEmpty) {
      return ValidationResult.failure(['At least 1 passenger is required']);
    }

    ValidationResult result = ValidationResult.success();
    for (int i = 0; i < passengers.length; i++) {
      result = result.combine(_validatePassenger(passengers[i], i + 1));
    }

    return result;
  }

  /// Validate individual passenger
  ValidationResult _validatePassenger(PassengerModel passenger, int index) {
    ValidationResult result = ValidationResult.success();

    // Validate name
    if (passenger.firstName.isEmpty) {
      result = result.addError('Passenger $index: First name is required');
    } else if (passenger.firstName.length < 2) {
      result = result.addError(
          'Passenger $index: First name must be at least 2 characters');
    }

    if (passenger.lastName.isEmpty) {
      result = result.addError('Passenger $index: Last name is required');
    } else if (passenger.lastName.length < 2) {
      result = result.addError(
          'Passenger $index: Last name must be at least 2 characters');
    }

    // Validate age
    if (passenger.age == null) {
      result = result.addError('Passenger $index: Age is required');
    } else if (passenger.age! < 0) {
      result = result.addError('Passenger $index: Age cannot be negative');
    } else if (passenger.age! == 0) {
      result = result.addError(
          'Passenger $index: Age cannot be 0. Please enter a valid age.');
    } else if (passenger.age! > 120) {
      result = result.addError('Passenger $index: Age cannot exceed 120 years');
    } else if (passenger.age! < 2) {
      result = result.addWarning(
          'Passenger $index: Age under 2 years may require special arrangements');
    }

    // Validate nationality
    if (passenger.nationality == null || passenger.nationality!.isEmpty) {
      result = result.addError('Passenger $index: Nationality is required');
    }

    // Validate passport/ID (optional but if provided, should be valid)
    if (passenger.idPassportNumber != null &&
        passenger.idPassportNumber!.isNotEmpty) {
      if (passenger.idPassportNumber!.length < minPassportIdLength) {
        result = result.addError(
            'Passenger $index: Passport/ID number must be at least $minPassportIdLength characters');
      }
    }

    return result;
  }

  /// Validate special requirements
  ValidationResult _validateSpecialRequirements(String specialRequirements) {
    if (specialRequirements.length > maxSpecialRequirementsLength) {
      return ValidationResult.failure([
        'Special requirements cannot exceed $maxSpecialRequirementsLength characters'
      ]);
    }

    // Check for potentially inappropriate content (basic check)
    final inappropriateWords = ['spam', 'test', 'fake'];
    final lowerRequirements = specialRequirements.toLowerCase();

    for (final word in inappropriateWords) {
      if (lowerRequirements.contains(word)) {
        return ValidationResult.failure(
            ['Special requirements contain inappropriate content']);
      }
    }

    return ValidationResult.success();
  }

  /// Validate email format (override base method)
  @override
  BaseValidationResult validateEmail(String? email, {bool required = true}) {
    if (email == null || email.isEmpty) {
      if (required) {
        return ValidationResult.failure(['Email is required']);
      }
      return ValidationResult.success();
    }

    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      return ValidationResult.failure(['Please enter a valid email address']);
    }

    return ValidationResult.success();
  }

  /// Validate phone number format (override base method)
  @override
  BaseValidationResult validatePhoneNumber(
    String? phoneNumber, {
    int minDigits = 10,
    int maxDigits = 15,
    bool required = true,
  }) {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      if (required) {
        return ValidationResult.failure(['Phone number is required']);
      }
      return ValidationResult.success();
    }

    // Remove all non-digit characters
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.length < minDigits) {
      return ValidationResult.failure(
          ['Phone number must be at least $minDigits digits']);
    }

    if (digitsOnly.length > maxDigits) {
      return ValidationResult.failure(
          ['Phone number cannot exceed $maxDigits digits']);
    }

    return ValidationResult.success();
  }

  /// Implement abstract method from BaseValidator
  @override
  BaseValidationResult validate(Map<String, dynamic> data) {
    // This is a generic implementation - specific validators should override
    // the specific validation methods like validateDirectCharterBooking
    return ValidationResult.success();
  }
}
