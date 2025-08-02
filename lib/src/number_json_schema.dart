import 'json_schema.dart';
import 'json_type.dart';

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
  /// This method checks if the provided value is a valid number and satisfies
  /// all constraints defined in this schema (multipleOf, minimum, maximum, etc.).
  ///
  /// Returns true if the value is valid, false otherwise.
  bool validateNumber(dynamic value) {
    if (value == null) {
      return true; // null is always valid unless specified otherwise
    }

    try {
      validateNumberWithExceptions(value);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Validates a numeric value against this schema and throws a FormatException if invalid.
  ///
  /// This method is similar to validateNumber but throws exceptions with detailed
  /// error messages instead of returning a boolean.
  void validateNumberWithExceptions(dynamic value) {
    if (value == null) {
      return; // null is always valid unless specified otherwise
    }

    // Check type
    if (value is! num) {
      throw FormatException('Value must be a number');
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
      return; // If it's in enum, no need to check other constraints
    }

    // Check multipleOf constraint
    if (multipleOf != null) {
      if ((value / multipleOf!).truncateToDouble() != value / multipleOf!) {
        throw FormatException('Value must be a multiple of $multipleOf');
      }
    }

    // Check minimum constraints (check minimum before maximum for logical order)
    if (minimum != null) {
      if (value < minimum!) {
        throw FormatException(
          'Value must be greater than or equal to minimum: $minimum',
        );
      }
    }

    if (exclusiveMinimum != null) {
      if (value <= exclusiveMinimum!) {
        throw FormatException(
          'Value must be greater than exclusive minimum: $exclusiveMinimum',
        );
      }
    }

    // Check maximum constraints
    if (maximum != null) {
      if (value > maximum!) {
        throw FormatException(
          'Value must be less than or equal to maximum: $maximum',
        );
      }
    }

    if (exclusiveMaximum != null) {
      if (value >= exclusiveMaximum!) {
        throw FormatException(
          'Value must be less than exclusive maximum: $exclusiveMaximum',
        );
      }
    }
  }
}
