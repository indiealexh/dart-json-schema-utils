import 'json_schema.dart';
import 'json_type.dart';

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
  /// This method checks if the provided value is null and satisfies
  /// all constraints defined in this schema.
  ///
  /// Returns true if the value is valid, false otherwise.
  bool validateNull(dynamic value) {
    try {
      validateNullWithExceptions(value);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Validates a null value against this schema and throws a FormatException if invalid.
  ///
  /// This method is similar to validateNull but throws exceptions with detailed
  /// error messages instead of returning a boolean.
  void validateNullWithExceptions(dynamic value) {
    // Check type
    if (value != null) {
      throw FormatException('Value must be null');
    }

    // For null type, there's no need to check against const or enum values
    // since there's only one possible value (null), and we've already verified
    // that the value is null. Additionally, constValue and enumValues can only
    // contain null values for this schema type.
  }
}
