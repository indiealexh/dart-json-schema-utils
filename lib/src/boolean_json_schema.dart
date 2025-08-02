import 'json_schema.dart';
import 'json_type.dart';

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
  /// This method checks if the provided value is a valid boolean and satisfies
  /// all constraints defined in this schema (enum, const).
  ///
  /// Returns true if the value is valid, false otherwise.
  bool validateBoolean(dynamic value) {
    if (value == null) {
      return true; // null is always valid unless specified otherwise
    }

    try {
      validateBooleanWithExceptions(value);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Validates a boolean value against this schema and throws a FormatException if invalid.
  ///
  /// This method is similar to validateBoolean but throws exceptions with detailed
  /// error messages instead of returning a boolean.
  void validateBooleanWithExceptions(dynamic value) {
    if (value == null) {
      return; // null is always valid unless specified otherwise
    }

    // Check type
    if (value is! bool) {
      throw FormatException('Value must be a boolean');
    }

    // Check against const value (most restrictive)
    if (constValue != null) {
      if (value != constValue) {
        throw FormatException(
          'Value must be equal to const value: $constValue',
        );
      }
      return; // If it matches const, no need to check other constraints
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
        throw FormatException(
          'Value must be one of the enum values: $enumValues',
        );
      }
    }
  }
}
