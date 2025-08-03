import '../cross_type_validator.dart';
import '../json_schema.dart';
import '../json_type.dart';
import '../validation_error.dart';

/// A specialized JSON Schema class that only supports the Boolean type.
///
/// This class extends the base JsonSchema but restricts the type to Boolean only
/// and provides validations specific to Boolean types according to JSON Schema draft-07.
class BooleanJsonSchema extends JsonSchema {
  BooleanJsonSchema() {
    // Initialize with Boolean type
    super.type = JsonType.boolean;
  }

  @override
  set type(dynamic value) {
    // Only allow Boolean type
    if (value != JsonType.boolean &&
        !(value is List && value.length == 1 && value[0] == JsonType.boolean)) {
      throw FormatException('BooleanJsonSchema only supports Boolean type');
    }
    super.type = JsonType.boolean;
  }

  @override
  set defaultValue(dynamic value) {
    if (value != null && value is! bool) {
      throw FormatException('defaultValue must be a boolean or null');
    }
    super.defaultValue = value;
  }

  @override
  set constValue(dynamic value) {
    if (value != null && value is! bool) {
      throw FormatException('constValue must be a boolean or null');
    }
    super.constValue = value;
  }

  @override
  set enumValues(List<dynamic>? values) {
    if (values != null) {
      if (values.isEmpty) {
        throw FormatException('enum must have at least one value');
      }

      // Ensure all enum values are booleans
      for (var value in values) {
        if (value is! bool) {
          throw FormatException('All enum values must be booleans');
        }
      }
    }
    super.enumValues = values;
  }

  /// Validates a boolean value against this schema.
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

  /// Validates a boolean value against this schema.
  ///
  /// This method checks if the provided value is a valid boolean and satisfies
  /// all constraints defined in this schema (enum, const).
  ///
  /// Returns true if the value is valid, false otherwise.
  bool validateBoolean(dynamic value) {
    return validate(value).isValid;
  }

  /// Validates a boolean value against this schema and throws a FormatException if invalid.
  ///
  /// This method is similar to validateBoolean but throws exceptions with detailed
  /// error messages instead of returning a boolean.
  void validateBooleanWithExceptions(dynamic value) {
    ValidationResult result = validate(value);
    if (!result.isValid) {
      // For backward compatibility with existing tests
      if (result.errors.first.keyword == 'type') {
        throw FormatException('Value must be a boolean');
      } else {
        throw FormatException(result.errors.first.message);
      }
    }
  }
}
