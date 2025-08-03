import '../json_schema.dart';
import '../json_type.dart';
import '../validation_error.dart';

/// A specialized JSON Schema class that only supports the Null type.
///
/// This class extends the base JsonSchema but restricts the type to Null only
/// and provides validations specific to Null types according to JSON Schema draft-07.
class NullJsonSchema extends JsonSchema {
  NullJsonSchema() {
    // Initialize with Null type
    super.type = JsonType.nullValue;
  }

  @override
  set type(dynamic value) {
    // Only allow Null type
    if (value != JsonType.nullValue &&
        !(value is List &&
            value.length == 1 &&
            value[0] == JsonType.nullValue)) {
      throw FormatException('NullJsonSchema only supports Null type');
    }
    super.type = JsonType.nullValue;
  }

  @override
  set defaultValue(dynamic value) {
    if (value != null) {
      throw FormatException('defaultValue must be null');
    }
    super.defaultValue = value;
  }

  @override
  set constValue(dynamic value) {
    if (value != null) {
      throw FormatException('constValue must be null');
    }
    super.constValue = value;
  }

  @override
  set enumValues(List<dynamic>? values) {
    if (values != null) {
      if (values.isEmpty) {
        throw FormatException('enum must have at least one value');
      }

      // Ensure all enum values are null
      for (var value in values) {
        if (value != null) {
          throw FormatException('All enum values must be null');
        }
      }
    }
    super.enumValues = values;
  }

  /// Validates a null value against this schema.
  ///
  /// This method returns a [ValidationResult] object that contains detailed
  /// information about any validation errors that occurred.
  ///
  /// The [path] parameter specifies the JSON pointer path to the value being
  /// validated, which is used in error messages.
  ValidationResult validate(dynamic value, [String path = ""]) {
    // For NullJsonSchema, null is always valid and non-null is always invalid
    if (value == null) {
      return ValidationResult.success();
    }
    return ValidationResult.failure([
      ValidationError.typeMismatch(
        path: path,
        expected: JsonType.nullValue,
        actual: value,
        schema: this,
      ),
    ]);
  }

  /// Validates a null value against this schema.
  ///
  /// This method checks if the provided value is null and satisfies
  /// all constraints defined in this schema.
  ///
  /// Returns true if the value is valid, false otherwise.
  bool validateNull(dynamic value) {
    return validate(value).isValid;
  }

  /// Validates a null value against this schema and throws a FormatException if invalid.
  ///
  /// This method is similar to validateNull but throws exceptions with detailed
  /// error messages instead of returning a boolean.
  void validateNullWithExceptions(dynamic value) {
    ValidationResult result = validate(value);
    if (!result.isValid) {
      // For backward compatibility with existing tests
      if (result.errors.first.keyword == 'type') {
        throw FormatException('Value must be null');
      } else {
        throw FormatException(result.errors.first.message);
      }
    }
  }
}
