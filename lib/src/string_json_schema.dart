import 'json_schema.dart';
import 'json_type.dart';

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
  /// This method checks if the provided string value satisfies all the
  /// constraints defined in this schema (minLength, maxLength, pattern).
  ///
  /// Returns true if the value is valid, false otherwise.
  bool validateString(String? value) {
    if (value == null) {
      return true; // null is always valid unless specified otherwise
    }

    try {
      validateStringWithExceptions(value);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Validates a string value against this schema and throws a FormatException if invalid.
  ///
  /// This method is similar to validateString but throws exceptions with detailed
  /// error messages instead of returning a boolean.
  void validateStringWithExceptions(String? value) {
    if (value == null) {
      return; // null is always valid unless specified otherwise
    }

    // Check minLength constraint
    if (minLength != null) {
      if (value.length < minLength!) {
        throw FormatException(
          'String length ${value.length} is less than minimum length $minLength',
        );
      }
    }

    // Check maxLength constraint
    if (maxLength != null) {
      if (value.length > maxLength!) {
        throw FormatException(
          'String length ${value.length} exceeds maximum length $maxLength',
        );
      }
    }

    // Check pattern constraint
    if (pattern != null) {
      RegExp regex = RegExp(pattern!);
      if (!regex.hasMatch(value)) {
        throw FormatException('String does not match pattern: $pattern');
      }
    }

    // Check format constraint if implemented
    if (format != null) {
      validateFormat(value, format!);
    }
  }

  /// Validates a string against a specific format.
  ///
  /// This method checks if the string conforms to the specified format
  /// as defined in JSON Schema specification.
  ///
  /// Supported formats: date-time, email, hostname, ipv4, ipv6, uri, uri-reference
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
