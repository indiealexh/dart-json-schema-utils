import 'cross_type_validator.dart';
import 'json_schema_base.dart';
import 'validation_error.dart';

/// A utility class for validating against schema composition and conditional keywords.
///
/// This class provides static methods to validate values against schema composition
/// keywords (allOf, anyOf, oneOf, not) and conditional keywords (if, then, else)
/// defined in JSON Schema Draft-07.
class SchemaValidator {
  /// Validates a value against the allOf keyword.
  ///
  /// The value must be valid against all schemas in the allOf array.
  /// Returns a ValidationResult with success if valid, or with errors if invalid.
  static ValidationResult validateAllOf(
    dynamic value,
    List<JsonSchemaBase> schemas,
    String path,
    JsonSchemaBase parentSchema,
  ) {
    List<ValidationError> errors = [];

    for (int i = 0; i < schemas.length; i++) {
      final schema = schemas[i];
      final result = _validateAgainstSchema(value, schema, '$path/allOf/$i');

      if (!result.isValid) {
        errors.addAll(result.errors);
      }
    }

    return errors.isEmpty
        ? ValidationResult.success()
        : ValidationResult.failure(errors);
  }

  /// Validates a value against the anyOf keyword.
  ///
  /// The value must be valid against at least one schema in the anyOf array.
  /// Returns a ValidationResult with success if valid, or with errors if invalid.
  static ValidationResult validateAnyOf(
    dynamic value,
    List<JsonSchemaBase> schemas,
    String path,
    JsonSchemaBase parentSchema,
  ) {
    List<ValidationError> errors = [];
    bool isValid = false;

    for (int i = 0; i < schemas.length; i++) {
      final schema = schemas[i];
      final result = _validateAgainstSchema(value, schema, '$path/anyOf/$i');

      if (result.isValid) {
        isValid = true;
        break;
      } else {
        errors.addAll(result.errors);
      }
    }

    if (isValid) {
      return ValidationResult.success();
    }

    return ValidationResult.failure([
      ValidationError.anyOfViolation(
        path: path,
        details: 'Value does not match any schema in anyOf',
        schema: parentSchema,
      ),
      ...errors,
    ]);
  }

  /// Validates a value against the oneOf keyword.
  ///
  /// The value must be valid against exactly one schema in the oneOf array.
  /// Returns a ValidationResult with success if valid, or with errors if invalid.
  static ValidationResult validateOneOf(
    dynamic value,
    List<JsonSchemaBase> schemas,
    String path,
    JsonSchemaBase parentSchema,
  ) {
    List<ValidationError> errors = [];
    int validCount = 0;

    for (int i = 0; i < schemas.length; i++) {
      final schema = schemas[i];
      final result = _validateAgainstSchema(value, schema, '$path/oneOf/$i');

      if (result.isValid) {
        validCount++;
      } else {
        errors.addAll(result.errors);
      }
    }

    if (validCount == 1) {
      return ValidationResult.success();
    }

    if (validCount == 0) {
      return ValidationResult.failure([
        ValidationError.oneOfViolation(
          path: path,
          details: 'Value does not match any schema in oneOf',
          schema: parentSchema,
        ),
        ...errors,
      ]);
    }

    return ValidationResult.failure([
      ValidationError.oneOfViolation(
        path: path,
        details: 'Value matches more than one schema in oneOf',
        schema: parentSchema,
      ),
    ]);
  }

  /// Validates a value against the not keyword.
  ///
  /// The value must not be valid against the schema in the not keyword.
  /// Returns a ValidationResult with success if valid, or with errors if invalid.
  static ValidationResult validateNot(
    dynamic value,
    JsonSchemaBase schema,
    String path,
    JsonSchemaBase parentSchema,
  ) {
    final result = _validateAgainstSchema(value, schema, '$path/not');

    if (result.isValid) {
      return ValidationResult.failure([
        ValidationError.notViolation(
          path: path,
          details: 'Value must not be valid against the not schema',
          schema: parentSchema,
        ),
      ]);
    }

    return ValidationResult.success();
  }

  /// Validates a value against conditional keywords (if, then, else).
  ///
  /// If the value is valid against the if schema, it must also be valid against
  /// the then schema (if present). Otherwise, it must be valid against the else
  /// schema (if present).
  ///
  /// Returns a ValidationResult with success if valid, or with errors if invalid.
  static ValidationResult validateConditional(
    dynamic value,
    JsonSchemaBase? ifSchema,
    JsonSchemaBase? thenSchema,
    JsonSchemaBase? elseSchema,
    String path,
    JsonSchemaBase parentSchema,
  ) {
    // If there's no if schema, there's nothing to validate
    if (ifSchema == null) {
      return ValidationResult.success();
    }

    final ifResult = _validateAgainstSchema(value, ifSchema, '$path/if');

    if (ifResult.isValid) {
      // If matches, then validate against thenSchema if present
      if (thenSchema != null) {
        final thenResult = _validateAgainstSchema(
          value,
          thenSchema,
          '$path/then',
        );
        if (!thenResult.isValid) {
          return ValidationResult.failure([
            ValidationError.conditionalViolation(
              path: path,
              details: 'Value matches if schema but not then schema',
              schema: parentSchema,
            ),
            ...thenResult.errors,
          ]);
        }
      }
    } else {
      // If doesn't match, then validate against elseSchema if present
      if (elseSchema != null) {
        final elseResult = _validateAgainstSchema(
          value,
          elseSchema,
          '$path/else',
        );
        if (!elseResult.isValid) {
          return ValidationResult.failure([
            ValidationError.conditionalViolation(
              path: path,
              details:
                  'Value does not match if schema and does not match else schema',
              schema: parentSchema,
            ),
            ...elseResult.errors,
          ]);
        }
      }
    }

    return ValidationResult.success();
  }

  /// Helper method to validate a value against a schema.
  ///
  /// This method delegates to the CrossTypeValidator to validate the value against the schema.
  /// It's used internally by the composition and conditional validation methods.
  static ValidationResult _validateAgainstSchema(
    dynamic value,
    JsonSchemaBase schema,
    String path,
  ) {
    // Use CrossTypeValidator to validate the value against the schema
    return CrossTypeValidator.validate(value, schema, path);
  }
}
