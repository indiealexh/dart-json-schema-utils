import '../cross_type_validator.dart';
import '../json_schema.dart';
import '../json_type.dart';
import '../validation_error.dart';

/// A specialized JSON Schema class that only supports the Object type.
///
/// This class extends the base JsonSchema but restricts the type to Object only
/// and provides validations specific to Object types according to JSON Schema draft-07.
class ObjectJsonSchema extends JsonSchema {
  ObjectJsonSchema() {
    // Initialize with Object type
    super.type = JsonType.object;
  }

  @override
  set type(dynamic value) {
    // Only allow Object type
    if (value != JsonType.object &&
        !(value is List && value.length == 1 && value[0] == JsonType.object)) {
      throw FormatException('ObjectJsonSchema only supports Object type');
    }
    super.type = JsonType.object;
  }

  @override
  set defaultValue(dynamic value) {
    if (value != null && value is! Map) {
      throw FormatException('defaultValue must be an object or null');
    }
    super.defaultValue = value;
  }

  @override
  set constValue(dynamic value) {
    if (value != null && value is! Map) {
      throw FormatException('constValue must be an object or null');
    }
    super.constValue = value;
  }

  @override
  set enumValues(List<dynamic>? values) {
    if (values != null) {
      if (values.isEmpty) {
        throw FormatException('enum must have at least one value');
      }

      // Ensure all enum values are objects
      for (var value in values) {
        if (value is! Map) {
          throw FormatException('All enum values must be objects');
        }
      }
    }
    super.enumValues = values;
  }

  /// Validates an object value against this schema.
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

  /// Validates an object value against this schema.
  ///
  /// This method checks if the provided value is a valid object and satisfies
  /// all constraints defined in this schema (properties, required, etc.).
  ///
  /// Returns true if the value is valid, false otherwise.
  bool validateObject(dynamic value) {
    return validate(value).isValid;
  }

  /// Validates an object value against this schema and throws a FormatException if invalid.
  ///
  /// This method is similar to validateObject but throws exceptions with detailed
  /// error messages instead of returning a boolean.
  void validateObjectWithExceptions(dynamic value) {
    ValidationResult result = validate(value);
    if (!result.isValid) {
      // For backward compatibility with existing tests
      if (result.errors.first.keyword == 'type') {
        throw FormatException('Value must be an object');
      } else {
        throw FormatException(result.errors.first.message);
      }
    }
  }
}
