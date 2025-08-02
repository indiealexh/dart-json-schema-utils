import 'dart:convert';

/// A utility class for validating string formats according to JSON Schema Draft-07.
///
/// This class provides static methods to validate strings against various formats
/// defined in the JSON Schema specification, such as date-time, email, URI, etc.
class FormatValidator {
  /// Validates a string against a specific format.
  ///
  /// This method checks if the string conforms to the specified format
  /// as defined in JSON Schema specification.
  ///
  /// Supported formats: date-time, date, time, duration, email, hostname,
  /// ipv4, ipv6, uri, uri-reference, uuid, json-pointer, regex
  ///
  /// Returns true if the string is valid for the given format, false otherwise.
  static bool isValidFormat(String value, String format) {
    try {
      validateFormat(value, format);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Validates a string against a specific format and throws a FormatException if invalid.
  ///
  /// This method checks if the string conforms to the specified format
  /// as defined in JSON Schema specification.
  ///
  /// Supported formats: date-time, date, time, duration, email, hostname,
  /// ipv4, ipv6, uri, uri-reference, uuid, json-pointer, regex
  static void validateFormat(String value, String format) {
    switch (format) {
      case 'date-time':
        _validateDateTime(value);
        break;

      case 'date':
        _validateDate(value);
        break;

      case 'time':
        _validateTime(value);
        break;

      case 'duration':
        _validateDuration(value);
        break;

      case 'uuid':
        _validateUuid(value);
        break;

      case 'json-pointer':
        _validateJsonPointer(value);
        break;

      case 'regex':
        _validateRegex(value);
        break;

      case 'email':
        _validateEmail(value);
        break;

      case 'hostname':
        _validateHostname(value);
        break;

      case 'ipv4':
        _validateIpv4(value);
        break;

      case 'ipv6':
        _validateIpv6(value);
        break;

      case 'uri':
        _validateUri(value, requireAbsolute: true);
        break;

      case 'uri-reference':
        _validateUri(value, requireAbsolute: false);
        break;

      case 'uri-template':
        _validateUriTemplate(value);
        break;

      case 'json':
        _validateJson(value);
        break;

      default:
        // Unknown format - not validating
        break;
    }
  }

  /// Validates a string as a date-time according to RFC 3339.
  static void _validateDateTime(String value) {
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
        throw FormatException('Date-time format does not conform to RFC 3339');
      }
    } catch (e) {
      throw FormatException('Invalid date-time format: ${e.toString()}');
    }
  }

  /// Validates a string as a date according to RFC 3339.
  static void _validateDate(String value) {
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
  }

  /// Validates a string as a time according to RFC 3339.
  static void _validateTime(String value) {
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
  }

  /// Validates a string as a duration according to ISO 8601.
  static void _validateDuration(String value) {
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
  }

  /// Validates a string as a UUID according to RFC 4122.
  static void _validateUuid(String value) {
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
  }

  /// Validates a string as a JSON Pointer according to RFC 6901.
  static void _validateJsonPointer(String value) {
    try {
      // JSON Pointer format according to RFC 6901
      // Either empty string or starts with / followed by tokens
      // Empty reference tokens (like //) are not allowed
      if (value.isEmpty) {
        // Empty string is a valid JSON Pointer
        return;
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
  }

  /// Validates a string as a regular expression.
  static void _validateRegex(String value) {
    try {
      // Try to compile the regex to validate it
      RegExp(value);
    } catch (e) {
      throw FormatException('Invalid regular expression: ${e.toString()}');
    }
  }

  /// Validates a string as an email address.
  static void _validateEmail(String value) {
    // Simple email regex that covers most common cases
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      throw FormatException('Invalid email format');
    }
  }

  /// Validates a string as a hostname according to RFC 1034.
  static void _validateHostname(String value) {
    final hostnameRegex = RegExp(
      r'^[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$',
    );
    if (!hostnameRegex.hasMatch(value)) {
      throw FormatException('Invalid hostname format');
    }
  }

  /// Validates a string as an IPv4 address.
  static void _validateIpv4(String value) {
    final ipv4Regex = RegExp(
      r'^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
    );
    if (!ipv4Regex.hasMatch(value)) {
      throw FormatException('Invalid IPv4 format');
    }
  }

  /// Validates a string as an IPv6 address according to RFC 5952.
  static void _validateIpv6(String value) {
    // Comprehensive IPv6 regex based on RFC 5952
    // This handles:
    // - Full IPv6 addresses (8 groups of hexadecimal digits)
    // - Compressed IPv6 addresses (with ::)
    // - IPv4-mapped IPv6 addresses (like ::ffff:192.0.2.128)
    // - IPv4-embedded IPv6 addresses (like 2001:db8::192.0.2.128)
    final ipv6Regex = RegExp(
      r'^(?:(?:[0-9a-fA-F]{1,4}:){6}|(?=(?:[0-9a-fA-F]{0,4}:){0,6}(?:[0-9a-fA-F]{0,4})?::)(?:[0-9a-fA-F]{1,4}:){0,5}|(?:[0-9a-fA-F]{1,4}:){5}:|(?:[0-9a-fA-F]{1,4}:){4}(?::[0-9a-fA-F]{1,4}){0,1}:|(?:[0-9a-fA-F]{1,4}:){3}(?::[0-9a-fA-F]{1,4}){0,2}:|(?:[0-9a-fA-F]{1,4}:){2}(?::[0-9a-fA-F]{1,4}){0,3}:|(?:[0-9a-fA-F]{1,4}:)(?::[0-9a-fA-F]{1,4}){0,4}:|:(?:(?::[0-9a-fA-F]{1,4}){0,5}|(?::[0-9a-fA-F]{1,4}){2,}:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(?:\.(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3})|(?:[0-9a-fA-F]{1,4}:){1,6}:|(?:[0-9a-fA-F]{1,4}:){1,5}(?::[0-9a-fA-F]{1,4}){1}:|(?:[0-9a-fA-F]{1,4}:){1,4}(?::[0-9a-fA-F]{1,4}){1,2}:|(?:[0-9a-fA-F]{1,4}:){1,3}(?::[0-9a-fA-F]{1,4}){1,3}:|(?:[0-9a-fA-F]{1,4}:){1,2}(?::[0-9a-fA-F]{1,4}){1,4}:)(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$|^(?:(?:[0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4})$',
    );
    if (!ipv6Regex.hasMatch(value)) {
      throw FormatException('Invalid IPv6 format');
    }
  }

  /// Validates a string as a URI or URI reference.
  static void _validateUri(String value, {bool requireAbsolute = false}) {
    try {
      final uri = Uri.parse(value);
      if (requireAbsolute && !uri.isAbsolute) {
        throw FormatException('URI must be absolute');
      }
    } catch (e) {
      throw FormatException('Invalid URI format: ${e.toString()}');
    }
  }

  /// Validates a string as a URI template according to RFC 6570.
  static void _validateUriTemplate(String value) {
    try {
      // Basic validation for URI templates
      // This is a simplified check that looks for valid URI template expressions
      final uriTemplateRegex = RegExp(
        r'^(?:[^\{\}]|\{[+#./;?&=,!@|]?(?:[a-zA-Z0-9_]|%[0-9a-fA-F]{2})(?::[1-9][0-9]{0,3}|\*)?(?:,(?:[a-zA-Z0-9_]|%[0-9a-fA-F]{2})(?::[1-9][0-9]{0,3}|\*)?)*\})*$',
      );
      if (!uriTemplateRegex.hasMatch(value)) {
        throw FormatException('Invalid URI template format');
      }
    } catch (e) {
      throw FormatException('Invalid URI template format: ${e.toString()}');
    }
  }

  /// Validates a string as a JSON document.
  static void _validateJson(String value) {
    try {
      json.decode(value);
    } catch (e) {
      throw FormatException('Invalid JSON format: ${e.toString()}');
    }
  }

  /// Validates a string as base64 encoded data.
  static bool isBase64(String value) {
    // Remove any whitespace
    final cleanValue = value.replaceAll(RegExp(r'\s'), '');

    // Check if the length is valid (multiple of 4)
    if (cleanValue.length % 4 != 0) {
      return false;
    }

    // Check if the string contains only valid base64 characters
    final base64Regex = RegExp(r'^[A-Za-z0-9+/]*={0,2}$');
    if (!base64Regex.hasMatch(cleanValue)) {
      return false;
    }

    // Try to decode
    try {
      base64.decode(cleanValue);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Validates a string as base64 encoded data and throws a FormatException if invalid.
  static void validateBase64(String value) {
    if (!isBase64(value)) {
      throw FormatException('Invalid base64 encoding');
    }
  }
}
