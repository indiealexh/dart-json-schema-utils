import 'json_schema.dart';
import 'json_type.dart';
import 'validation_error.dart';

/// A specialized JSON Schema class that only supports the String type.
///
/// This class extends the base JsonSchema but restricts the type to String only
/// and provides validations specific to String types according to JSON Schema draft-07.
class StringJsonSchema extends JsonSchema {
  StringJsonSchema() {
    // Initialize with String type
    super.type = JsonType.string;
  }

  @override
  set type(dynamic value) {
    // Only allow String type
    if (value != JsonType.string &&
        !(value is List && value.length == 1 && value[0] == JsonType.string)) {
      throw FormatException('StringJsonSchema only supports String type');
    }
    super.type = JsonType.string;
  }

  @override
  set defaultValue(dynamic value) {
    if (value != null && value is! String) {
      throw FormatException('defaultValue must be a string or null');
    }
    super.defaultValue = value;
  }

  @override
  set constValue(dynamic value) {
    if (value != null && value is! String) {
      throw FormatException('constValue must be a string or null');
    }
    super.constValue = value;
  }

  @override
  set enumValues(List<dynamic>? values) {
    if (values != null) {
      if (values.isEmpty) {
        throw FormatException('enum must have at least one value');
      }

      // Ensure all enum values are strings
      for (var value in values) {
        if (value is! String) {
          throw FormatException('All enum values must be strings');
        }
      }
    }
    super.enumValues = values;
  }

  /// Validates a string value against this schema.
  ///
  /// This method returns a [ValidationResult] object that contains detailed
  /// information about any validation errors that occurred.
  ///
  /// The [path] parameter specifies the JSON pointer path to the value being
  /// validated, which is used in error messages.
  ValidationResult validate(String? value, [String path = ""]) {
    if (value == null) {
      return ValidationResult.success(); // null is always valid unless specified otherwise
    }

    List<ValidationError> errors = [];

    // Check against const value (most restrictive)
    if (constValue != null) {
      if (value != constValue) {
        errors.add(
          ValidationError.constViolation(
            path: path,
            expected: constValue,
            actual: value,
            schema: this,
          ),
        );
        return ValidationResult.failure(errors);
      }
      return ValidationResult.success(); // If it matches const, no need to check other constraints
    }

    // Check against enum values
    if (enumValues != null) {
      bool foundMatch = false;
      for (var enumValue in enumValues!) {
        if (value == enumValue) {
          foundMatch = true;
          break;
        }
      }
      if (!foundMatch) {
        errors.add(
          ValidationError.enumViolation(
            path: path,
            expected: enumValues!,
            actual: value,
            schema: this,
          ),
        );
        return ValidationResult.failure(errors);
      }
      return ValidationResult.success(); // If it's in enum, no need to check other constraints
    }

    // Check minLength constraint
    if (minLength != null) {
      if (value.length < minLength!) {
        errors.add(
          ValidationError.minLengthViolation(
            path: path,
            expected: minLength!,
            actual: value,
            schema: this,
          ),
        );
      }
    }

    // Check maxLength constraint
    if (maxLength != null) {
      if (value.length > maxLength!) {
        errors.add(
          ValidationError.maxLengthViolation(
            path: path,
            expected: maxLength!,
            actual: value,
            schema: this,
          ),
        );
      }
    }

    // Check pattern constraint
    if (pattern != null) {
      RegExp regex = RegExp(pattern!);
      if (!regex.hasMatch(value)) {
        errors.add(
          ValidationError.patternViolation(
            path: path,
            pattern: pattern!,
            actual: value,
            schema: this,
          ),
        );
      }
    }

    // Check format constraint if implemented
    if (format != null) {
      try {
        validateFormat(value, format!);
      } catch (e) {
        errors.add(
          ValidationError.formatViolation(
            path: path,
            format: format!,
            actual: value,
            details: e.toString().replaceAll('FormatException: ', ''),
            schema: this,
          ),
        );
      }
    }

    return errors.isEmpty
        ? ValidationResult.success()
        : ValidationResult.failure(errors);
  }

  /// Validates a string value against this schema.
  ///
  /// This method checks if the provided string value satisfies all the
  /// constraints defined in this schema (minLength, maxLength, pattern).
  ///
  /// Returns true if the value is valid, false otherwise.
  bool validateString(String? value) {
    return validate(value).isValid;
  }

  /// Validates a string value against this schema and throws a FormatException if invalid.
  ///
  /// This method is similar to validateString but throws exceptions with detailed
  /// error messages instead of returning a boolean.
  void validateStringWithExceptions(String? value) {
    ValidationResult result = validate(value);
    if (!result.isValid) {
      throw FormatException(result.errors.first.message);
    }
  }

  /// Validates a string against a specific format.
  ///
  /// This method checks if the string conforms to the specified format
  /// as defined in JSON Schema specification.
  ///
  /// Supported formats: date-time, date, time, duration, email, hostname, ipv4, ipv6, uri, uri-reference, uuid, json-pointer, regex
  void validateFormat(String value, String format) {
    switch (format) {
      case 'date-time':
        try {
          // First try to parse with DateTime to catch basic format issues
          final dateTime = DateTime.parse(value);

          // Additional validation for date-time format
          // Check if the parsed date has valid month/day values
          // This catches cases like "2025-13-02" (invalid month) that DateTime.parse might accept
          if (dateTime.month < 1 ||
              dateTime.month > 12 ||
              dateTime.day < 1 ||
              dateTime.day > 31) {
            throw FormatException('Invalid date-time values');
          }

          // Validate format with regex to ensure it follows RFC 3339
          final dateTimeRegex = RegExp(
            r'^(\d{4})-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])T([01]\d|2[0-3]):([0-5]\d):([0-5]\d|60)(\.\d+)?(Z|([+-])([01]\d|2[0-3]):([0-5]\d))$',
          );
          if (!dateTimeRegex.hasMatch(value)) {
            throw FormatException(
              'Date-time format does not conform to RFC 3339',
            );
          }
        } catch (e) {
          throw FormatException('Invalid date-time format: ${e.toString()}');
        }
        break;

      case 'date':
        try {
          // Validate format with regex to ensure it follows RFC 3339 full-date
          final dateRegex = RegExp(
            r'^(\d{4})-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])$',
          );
          if (!dateRegex.hasMatch(value)) {
            throw FormatException('Date format does not conform to RFC 3339');
          }

          // Parse to validate the date is valid (e.g., not 2023-02-31)
          final parts = value.split('-');
          final year = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final day = int.parse(parts[2]);

          // Create a DateTime to validate the date
          final date = DateTime(year, month, day);

          // Check if the date is valid by comparing the original components
          if (date.year != year || date.month != month || date.day != day) {
            throw FormatException('Invalid date values');
          }
        } catch (e) {
          throw FormatException('Invalid date format: ${e.toString()}');
        }
        break;

      case 'time':
        try {
          // Validate format with regex to ensure it follows RFC 3339 full-time
          final timeRegex = RegExp(
            r'^([01]\d|2[0-3]):([0-5]\d):([0-5]\d|60)(\.\d+)?(Z|([+-])([01]\d|2[0-3]):([0-5]\d))$',
          );
          if (!timeRegex.hasMatch(value)) {
            throw FormatException('Time format does not conform to RFC 3339');
          }
        } catch (e) {
          throw FormatException('Invalid time format: ${e.toString()}');
        }
        break;

      case 'duration':
        try {
          // ISO 8601 duration format
          // P[n]Y[n]M[n]DT[n]H[n]M[n]S or P[n]W
          final durationRegex = RegExp(
            r'^P(?!$)(\d+Y)?(\d+M)?(\d+D)?(T(?=\d)(\d+H)?(\d+M)?(\d+S)?)?$|^P\d+W$',
          );
          if (!durationRegex.hasMatch(value)) {
            throw FormatException('Invalid duration format');
          }
        } catch (e) {
          throw FormatException('Invalid duration format: ${e.toString()}');
        }
        break;

      case 'uuid':
        try {
          // UUID format according to RFC 4122
          final uuidRegex = RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
            caseSensitive: false,
          );
          if (!uuidRegex.hasMatch(value)) {
            throw FormatException('Invalid UUID format');
          }
        } catch (e) {
          throw FormatException('Invalid UUID format: ${e.toString()}');
        }
        break;

      case 'json-pointer':
        try {
          // JSON Pointer format according to RFC 6901
          // Either empty string or starts with / followed by tokens
          // Empty reference tokens (like //) are not allowed
          if (value.isEmpty) {
            // Empty string is a valid JSON Pointer
            break;
          }

          if (!value.startsWith('/')) {
            throw FormatException('JSON Pointer must start with / or be empty');
          }

          if (value.endsWith('/')) {
            throw FormatException('JSON Pointer must not end with /');
          }

          if (value.contains('//')) {
            throw FormatException(
              'JSON Pointer must not contain empty reference tokens',
            );
          }

          // Check for proper escaping of ~ and /
          final parts = value.split('/').skip(1); // Skip the first empty part
          for (final part in parts) {
            // Check for invalid escape sequences
            if (part.contains('~') &&
                !(part.contains('~0') || part.contains('~1'))) {
              throw FormatException('Invalid escape sequence in JSON Pointer');
            }
          }
        } catch (e) {
          throw FormatException('Invalid JSON Pointer format: ${e.toString()}');
        }
        break;

      case 'regex':
        try {
          // Try to compile the regex to validate it
          RegExp(value);
        } catch (e) {
          throw FormatException('Invalid regular expression: ${e.toString()}');
        }
        break;

      case 'email':
        final emailRegex = RegExp(
          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
        );
        if (!emailRegex.hasMatch(value)) {
          throw FormatException('Invalid email format');
        }
        break;

      case 'hostname':
        final hostnameRegex = RegExp(
          r'^[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$',
        );
        if (!hostnameRegex.hasMatch(value)) {
          throw FormatException('Invalid hostname format');
        }
        break;

      case 'ipv4':
        final ipv4Regex = RegExp(
          r'^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
        );
        if (!ipv4Regex.hasMatch(value)) {
          throw FormatException('Invalid IPv4 format');
        }
        break;

      case 'ipv6':
        // Simplified IPv6 regex (not comprehensive)
        final ipv6Regex = RegExp(
          r'^(?:[A-F0-9]{1,4}:){7}[A-F0-9]{1,4}$',
          caseSensitive: false,
        );
        if (!ipv6Regex.hasMatch(value)) {
          throw FormatException('Invalid IPv6 format');
        }
        break;

      case 'uri':
        try {
          final uri = Uri.parse(value);
          if (!uri.isAbsolute) {
            throw FormatException('URI must be absolute');
          }
        } catch (e) {
          throw FormatException('Invalid URI format');
        }
        break;

      case 'uri-reference':
        try {
          Uri.parse(value);
        } catch (e) {
          throw FormatException('Invalid URI reference format');
        }
        break;

      default:
        // Unknown format - not validating
        break;
    }
  }
}
