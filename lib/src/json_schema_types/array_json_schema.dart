import '../cross_type_validator.dart';
import '../json_schema.dart';
import '../json_type.dart';
import '../validation_error.dart';

/// A specialized JSON Schema class that only supports the Array type.
///
/// This class extends the base JsonSchema but restricts the type to Array only
/// and provides validations specific to Array types according to JSON Schema draft-07.
class ArrayJsonSchema extends JsonSchema {
  ArrayJsonSchema() {
    // Initialize with Array type
    super.type = JsonType.array;
  }

  @override
  set type(dynamic value) {
    // Only allow Array type
    if (value != JsonType.array &&
        !(value is List && value.length == 1 && value[0] == JsonType.array)) {
      throw FormatException('ArrayJsonSchema only supports Array type');
    }
    super.type = JsonType.array;
  }

  @override
  set defaultValue(dynamic value) {
    if (value != null && value is! List) {
      throw FormatException('defaultValue must be an array or null');
    }
    super.defaultValue = value;
  }

  @override
  set constValue(dynamic value) {
    if (value != null && value is! List) {
      throw FormatException('constValue must be an array or null');
    }
    super.constValue = value;
  }

  @override
  set enumValues(List<dynamic>? values) {
    if (values != null) {
      if (values.isEmpty) {
        throw FormatException('enum must have at least one value');
      }

      // Ensure all enum values are arrays
      for (var value in values) {
        if (value is! List) {
          throw FormatException('All enum values must be arrays');
        }
      }
    }
    super.enumValues = values;
  }

  /// Validates an array value against this schema.
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

  /// Validates an array value against this schema.
  ///
  /// This method checks if the provided value is a valid array and satisfies
  /// all constraints defined in this schema (items, maxItems, minItems, etc.).
  ///
  /// Returns true if the value is valid, false otherwise.
  bool validateArray(dynamic value) {
    return validate(value).isValid;
  }

  /// Validates an array value against this schema and throws a FormatException if invalid.
  ///
  /// This method is similar to validateArray but throws exceptions with detailed
  /// error messages instead of returning a boolean.
  void validateArrayWithExceptions(dynamic value) {
    ValidationResult result = validate(value);
    if (!result.isValid) {
      // For backward compatibility with existing tests
      if (result.errors.first.keyword == 'type') {
        throw FormatException('Value must be an array');
      } else if (result.errors.first.keyword == 'minItems') {
        throw FormatException(
          'Array must have at least $minItems items, but has ${value.length}',
        );
      } else if (result.errors.first.keyword == 'maxItems') {
        throw FormatException(
          'Array must have at most $maxItems items, but has ${value.length}',
        );
      } else if (result.errors.first.keyword == 'uniqueItems') {
        throw FormatException('Array items must be unique');
      } else {
        throw FormatException(result.errors.first.message);
      }
    }
  }
}
