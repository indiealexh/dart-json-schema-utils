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
    if (value == null) {
      return ValidationResult.success(); // null is always valid unless specified otherwise
    }

    List<ValidationError> errors = [];

    // Check type
    if (value is! num) {
      errors.add(
        ValidationError.typeMismatch(
          path: path,
          expected: JsonType.number,
          actual: value,
          schema: this,
        ),
      );
      return ValidationResult.failure(errors);
    }

    // Check against const value (most restrictive)
    if (constValue != null) {
      if (value != constValue) {
        errors.add(
          ValidationError.constViolation(
            path: path,
            expected: constValue,
            actual: value,
            schema: this,
          ),
        );
        return ValidationResult.failure(errors);
      }
      return ValidationResult.success(); // If it matches const, no need to check other constraints
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
        errors.add(
          ValidationError.enumViolation(
            path: path,
            expected: enumValues!,
            actual: value,
            schema: this,
          ),
        );
        return ValidationResult.failure(errors);
      }
      return ValidationResult.success(); // If it's in enum, no need to check other constraints
    }

    // Check multipleOf constraint
    if (multipleOf != null) {
      if ((value / multipleOf!).truncateToDouble() != value / multipleOf!) {
        errors.add(
          ValidationError.multipleOfViolation(
            path: path,
            divisor: multipleOf!,
            actual: value,
            schema: this,
          ),
        );
      }
    }

    // Check minimum constraints (check minimum before maximum for logical order)
    if (minimum != null) {
      if (value < minimum!) {
        errors.add(
          ValidationError.minimumViolation(
            path: path,
            expected: minimum!,
            actual: value,
            schema: this,
          ),
        );
      }
    }

    if (exclusiveMinimum != null) {
      if (value <= exclusiveMinimum!) {
        errors.add(
          ValidationError.minimumViolation(
            path: path,
            expected: exclusiveMinimum!,
            actual: value,
            schema: this,
            exclusive: true,
          ),
        );
      }
    }

    // Check maximum constraints
    if (maximum != null) {
      if (value > maximum!) {
        errors.add(
          ValidationError.maximumViolation(
            path: path,
            expected: maximum!,
            actual: value,
            schema: this,
          ),
        );
      }
    }

    if (exclusiveMaximum != null) {
      if (value >= exclusiveMaximum!) {
        errors.add(
          ValidationError.maximumViolation(
            path: path,
            expected: exclusiveMaximum!,
            actual: value,
            schema: this,
            exclusive: true,
          ),
        );
      }
    }

    return errors.isEmpty
        ? ValidationResult.success()
        : ValidationResult.failure(errors);
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
