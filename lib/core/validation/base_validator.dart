import '../logging/app_logger.dart';

/// Base validation result that can be extended for specific use cases
abstract class BaseValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  final Map<String, dynamic> metadata;

  const BaseValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
    this.metadata = const {},
  });

  /// Create a successful result
  factory BaseValidationResult.success(
      [Map<String, dynamic> metadata = const {}]) {
    return _ConcreteValidationResult(
      isValid: true,
      metadata: metadata,
    );
  }

  /// Create a failed result
  factory BaseValidationResult.failure(
    List<String> errors, {
    List<String> warnings = const [],
    Map<String, dynamic> metadata = const {},
  }) {
    return _ConcreteValidationResult(
      isValid: false,
      errors: errors,
      warnings: warnings,
      metadata: metadata,
    );
  }

  /// Add an error to the result
  BaseValidationResult addError(String error, {String? field});

  /// Add a warning to the result
  BaseValidationResult addWarning(String warning, {String? field});

  /// Combine multiple validation results
  BaseValidationResult combine(BaseValidationResult other);

  /// Get all errors for a specific field
  List<String> getErrorsForField(String field);

  /// Get all warnings for a specific field
  List<String> getWarningsForField(String field);

  /// Check if a specific field has errors
  bool hasErrorForField(String field);

  /// Check if a specific field has warnings
  bool hasWarningForField(String field);
}

/// Concrete implementation of BaseValidationResult
class _ConcreteValidationResult extends BaseValidationResult {
  const _ConcreteValidationResult({
    required super.isValid,
    super.errors = const [],
    super.warnings = const [],
    super.metadata = const {},
  });

  @override
  BaseValidationResult addError(String error, {String? field}) {
    final fieldErrors = field != null ? '$field: $error' : error;
    return _ConcreteValidationResult(
      isValid: false,
      errors: [...errors, fieldErrors],
      warnings: warnings,
      metadata: metadata,
    );
  }

  @override
  BaseValidationResult addWarning(String warning, {String? field}) {
    final fieldWarning = field != null ? '$field: $warning' : warning;
    return _ConcreteValidationResult(
      isValid: isValid,
      errors: errors,
      warnings: [...warnings, fieldWarning],
      metadata: metadata,
    );
  }

  @override
  BaseValidationResult combine(BaseValidationResult other) {
    return _ConcreteValidationResult(
      isValid: isValid && other.isValid,
      errors: [...errors, ...other.errors],
      warnings: [...warnings, ...other.warnings],
      metadata: {...metadata, ...other.metadata},
    );
  }

  @override
  List<String> getErrorsForField(String field) {
    return errors.where((error) => error.startsWith('$field:')).toList();
  }

  @override
  List<String> getWarningsForField(String field) {
    return warnings.where((warning) => warning.startsWith('$field:')).toList();
  }

  @override
  bool hasErrorForField(String field) {
    return errors.any((error) => error.startsWith('$field:'));
  }

  @override
  bool hasWarningForField(String field) {
    return warnings.any((warning) => warning.startsWith('$field:'));
  }
}

/// Base validator class with common validation utilities
abstract class BaseValidator {
  static final AppLogger _logger = AppLogger();

  /// Validate required field
  BaseValidationResult validateRequired(
    dynamic value,
    String fieldName, {
    String? customMessage,
  }) {
    if (value == null || (value is String && value.isEmpty)) {
      final message = customMessage ?? '$fieldName is required';
      _logValidationError(fieldName, message);
      return BaseValidationResult.failure([message]);
    }
    return BaseValidationResult.success();
  }

  /// Validate string length
  BaseValidationResult validateStringLength(
    String? value,
    String fieldName, {
    int? minLength,
    int? maxLength,
    bool required = true,
  }) {
    if (value == null || value.isEmpty) {
      if (required) {
        return validateRequired(value, fieldName);
      }
      return BaseValidationResult.success();
    }

    if (minLength != null && value.length < minLength) {
      final message = '$fieldName must be at least $minLength characters';
      _logValidationError(fieldName, message);
      return BaseValidationResult.failure([message]);
    }

    if (maxLength != null && value.length > maxLength) {
      final message = '$fieldName cannot exceed $maxLength characters';
      _logValidationError(fieldName, message);
      return BaseValidationResult.failure([message]);
    }

    return BaseValidationResult.success();
  }

  /// Validate numeric range
  BaseValidationResult validateNumericRange(
    num? value,
    String fieldName, {
    num? min,
    num? max,
    bool required = true,
  }) {
    if (value == null) {
      if (required) {
        return validateRequired(value, fieldName);
      }
      return BaseValidationResult.success();
    }

    if (min != null && value < min) {
      final message = '$fieldName must be at least $min';
      _logValidationError(fieldName, message);
      return BaseValidationResult.failure([message]);
    }

    if (max != null && value > max) {
      final message = '$fieldName cannot exceed $max';
      _logValidationError(fieldName, message);
      return BaseValidationResult.failure([message]);
    }

    return BaseValidationResult.success();
  }

  /// Validate email format
  BaseValidationResult validateEmail(String? email, {bool required = true}) {
    if (email == null || email.isEmpty) {
      if (required) {
        return validateRequired(email, 'Email');
      }
      return BaseValidationResult.success();
    }

    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      const message = 'Please enter a valid email address';
      _logValidationError('Email', message);
      return BaseValidationResult.failure([message]);
    }

    return BaseValidationResult.success();
  }

  /// Validate phone number
  BaseValidationResult validatePhoneNumber(
    String? phoneNumber, {
    int minDigits = 10,
    int maxDigits = 15,
    bool required = true,
  }) {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      if (required) {
        return validateRequired(phoneNumber, 'Phone number');
      }
      return BaseValidationResult.success();
    }

    final digitsOnly = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.length < minDigits) {
      final message = 'Phone number must be at least $minDigits digits';
      _logValidationError('Phone number', message);
      return BaseValidationResult.failure([message]);
    }

    if (digitsOnly.length > maxDigits) {
      final message = 'Phone number cannot exceed $maxDigits digits';
      _logValidationError('Phone number', message);
      return BaseValidationResult.failure([message]);
    }

    return BaseValidationResult.success();
  }

  /// Validate date range
  BaseValidationResult validateDateRange(
    DateTime? date,
    String fieldName, {
    DateTime? minDate,
    DateTime? maxDate,
    bool required = true,
  }) {
    if (date == null) {
      if (required) {
        return validateRequired(date, fieldName);
      }
      return BaseValidationResult.success();
    }

    if (minDate != null && date.isBefore(minDate)) {
      final message =
          '$fieldName cannot be before ${minDate.toIso8601String().split('T')[0]}';
      _logValidationError(fieldName, message);
      return BaseValidationResult.failure([message]);
    }

    if (maxDate != null && date.isAfter(maxDate)) {
      final message =
          '$fieldName cannot be after ${maxDate.toIso8601String().split('T')[0]}';
      _logValidationError(fieldName, message);
      return BaseValidationResult.failure([message]);
    }

    return BaseValidationResult.success();
  }

  /// Validate list size
  BaseValidationResult validateListSize(
    List? list,
    String fieldName, {
    int? minSize,
    int? maxSize,
    bool required = true,
  }) {
    if (list == null || list.isEmpty) {
      if (required) {
        return validateRequired(list, fieldName);
      }
      return BaseValidationResult.success();
    }

    if (minSize != null && list.length < minSize) {
      final message = '$fieldName must contain at least $minSize items';
      _logValidationError(fieldName, message);
      return BaseValidationResult.failure([message]);
    }

    if (maxSize != null && list.length > maxSize) {
      final message = '$fieldName cannot exceed $maxSize items';
      _logValidationError(fieldName, message);
      return BaseValidationResult.failure([message]);
    }

    return BaseValidationResult.success();
  }

  /// Validate against allowed values
  BaseValidationResult validateAllowedValues(
    dynamic value,
    String fieldName,
    List<dynamic> allowedValues, {
    bool required = true,
  }) {
    if (value == null) {
      if (required) {
        return validateRequired(value, fieldName);
      }
      return BaseValidationResult.success();
    }

    if (!allowedValues.contains(value)) {
      final message = '$fieldName must be one of: ${allowedValues.join(', ')}';
      _logValidationError(fieldName, message);
      return BaseValidationResult.failure([message]);
    }

    return BaseValidationResult.success();
  }

  /// Log validation errors for monitoring
  void _logValidationError(String field, String error) {
    _logger.warning(
      'Validation failed: $field - $error',
    );
  }

  /// Abstract method for specific validators to implement
  BaseValidationResult validate(Map<String, dynamic> data);
}
