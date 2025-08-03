import '../cross_type_validator.dart';
import '../json_schema.dart';
import '../json_type.dart';
import '../validation_error.dart';

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
    // For backward compatibility, null is always valid
    if (value == null) {
      return ValidationResult.success();
    }
    return CrossTypeValidator.validate(value, this, path);
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
}
