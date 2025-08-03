import '../cross_type_validator.dart';
import '../json_schema.dart';
import '../json_type.dart';
import '../validation_error.dart';

/// A specialized JSON Schema class that only supports the Number type.
///
/// This class extends the base JsonSchema but restricts the type to Number only
/// and provides validations specific to Number types according to JSON Schema draft-07.
class NumberJsonSchema extends JsonSchema {
  NumberJsonSchema() {
    // Initialize with Number type
    super.type = JsonType.number;
  }

  @override
  set type(dynamic value) {
    // Only allow Number type
    if (value != JsonType.number &&
        !(value is List && value.length == 1 && value[0] == JsonType.number)) {
      throw FormatException('NumberJsonSchema only supports Number type');
    }
    super.type = JsonType.number;
  }

  @override
  set defaultValue(dynamic value) {
    if (value != null && value is! num) {
      throw FormatException('defaultValue must be a number or null');
    }
    super.defaultValue = value;
  }

  @override
  set constValue(dynamic value) {
    if (value != null && value is! num) {
      throw FormatException('constValue must be a number or null');
    }
    super.constValue = value;
  }

  @override
  set enumValues(List<dynamic>? values) {
    if (values != null) {
      if (values.isEmpty) {
        throw FormatException('enum must have at least one value');
      }

      // Ensure all enum values are numbers
      for (var value in values) {
        if (value is! num) {
          throw FormatException('All enum values must be numbers');
        }
      }
    }
    super.enumValues = values;
  }

  /// Validates a numeric value against this schema.
  ///
  /// This method returns a [ValidationResult] object that contains detailed
  /// information about any validation errors that occurred.
  ///
  /// The [path] parameter specifies the JSON pointer path to the value being
  /// validated, which is used in error messages.
  ValidationResult validate(dynamic value, [String path = ""]) {
    // For backward compatibility, null is always valid
    if (value == null) {
      return ValidationResult.success();
    }
    return CrossTypeValidator.validate(value, this, path);
  }

  /// Validates a numeric value against this schema.
  ///
  /// This method checks if the provided value is a valid number and satisfies
  /// all constraints defined in this schema (multipleOf, minimum, maximum, etc.).
  ///
  /// Returns true if the value is valid, false otherwise.
  bool validateNumber(dynamic value) {
    return validate(value).isValid;
  }

  /// Validates a numeric value against this schema and throws a FormatException if invalid.
  ///
  /// This method is similar to validateNumber but throws exceptions with detailed
  /// error messages instead of returning a boolean.
  void validateNumberWithExceptions(dynamic value) {
    ValidationResult result = validate(value);
    if (!result.isValid) {
      // For backward compatibility with existing tests
      if (result.errors.first.keyword == 'type') {
        throw FormatException('Value must be a number');
      } else {
        throw FormatException(result.errors.first.message);
      }
    }
  }
}
