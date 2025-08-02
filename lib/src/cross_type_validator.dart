import 'dart:convert';

import 'json_schema_base.dart';
import 'json_type.dart';
import 'validation_error.dart';
import 'format_validator.dart';

/// A utility class for validating values against schemas across different types.
///
/// This class provides methods to validate values against schemas regardless of
/// their type, ensuring consistent validation behavior across all schema types.
/// It eliminates the need for duplicate validation logic in different schema classes.
class CrossTypeValidator {
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
      final result = validate(value, schema, '$path/allOf/$i');

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
      final result = validate(value, schema, '$path/anyOf/$i');

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
    int validIndex = -1;

    for (int i = 0; i < schemas.length; i++) {
      final schema = schemas[i];
      final result = validate(value, schema, '$path/oneOf/$i');

      if (result.isValid) {
        validCount++;
        validIndex = i;
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
    final result = validate(value, schema, '$path/not');

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

    final ifResult = validate(value, ifSchema, '$path/if');

    if (ifResult.isValid) {
      // If matches, then validate against thenSchema if present
      if (thenSchema != null) {
        final thenResult = validate(value, thenSchema, '$path/then');
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
        final elseResult = validate(value, elseSchema, '$path/else');
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

  /// Validates a value against a schema.
  ///
  /// This method checks if the value satisfies all constraints defined in the schema,
  /// including type constraints, format constraints, and nested schema constraints.
  ///
  /// Returns a ValidationResult with success if valid, or with errors if invalid.
  static ValidationResult validate(
    dynamic value,
    JsonSchemaBase schema,
    String path,
  ) {
    List<ValidationError> errors = [];

    // If value is null, it's valid unless the schema explicitly requires a non-null value
    if (value == null) {
      // If schema type is explicitly set to null, then null is valid
      if (schema.type == JsonType.nullValue) {
        return ValidationResult.success();
      }

      // If schema type is a list that includes null, then null is valid
      if (schema.type is List && schema.type.contains(JsonType.nullValue)) {
        return ValidationResult.success();
      }

      // If schema has no type constraint, null is valid
      if (schema.type == null) {
        return ValidationResult.success();
      }

      // Otherwise, null is not valid
      errors.add(
        ValidationError.typeMismatch(
          path: path,
          expected: schema.type,
          actual: null,
          schema: schema,
        ),
      );
      return ValidationResult.failure(errors);
    }

    // Check type constraint
    if (schema.type != null) {
      if (!_matchesType(value, schema.type)) {
        errors.add(
          ValidationError.typeMismatch(
            path: path,
            expected: schema.type,
            actual: value,
            schema: schema,
          ),
        );
        return ValidationResult.failure(errors);
      }
    }

    // Check const constraint (most restrictive)
    if (schema.constValue != null) {
      if (!_deepEquals(value, schema.constValue)) {
        errors.add(
          ValidationError.constViolation(
            path: path,
            expected: schema.constValue,
            actual: value,
            schema: schema,
          ),
        );
        return ValidationResult.failure(errors);
      }
      return ValidationResult.success(); // If it matches const, no need to check other constraints
    }

    // Check enum constraint
    if (schema.enumValues != null) {
      bool foundMatch = false;
      for (var enumValue in schema.enumValues!) {
        if (_deepEquals(value, enumValue)) {
          foundMatch = true;
          break;
        }
      }
      if (!foundMatch) {
        errors.add(
          ValidationError.enumViolation(
            path: path,
            expected: schema.enumValues!,
            actual: value,
            schema: schema,
          ),
        );
        return ValidationResult.failure(errors);
      }
      return ValidationResult.success(); // If it's in enum, no need to check other constraints
    }

    // Validate schema composition keywords
    if (schema.allOf != null) {
      final result = validateAllOf(value, schema.allOf!, path, schema);
      if (!result.isValid) {
        errors.addAll(result.errors);
      }
    }

    if (schema.anyOf != null) {
      final result = validateAnyOf(value, schema.anyOf!, path, schema);
      if (!result.isValid) {
        errors.addAll(result.errors);
      }
    }

    if (schema.oneOf != null) {
      final result = validateOneOf(value, schema.oneOf!, path, schema);
      if (!result.isValid) {
        errors.addAll(result.errors);
      }
    }

    if (schema.not != null) {
      final result = validateNot(value, schema.not!, path, schema);
      if (!result.isValid) {
        errors.addAll(result.errors);
      }
    }

    // Validate conditional keywords
    if (schema.ifSchema != null) {
      final result = validateConditional(
        value,
        schema.ifSchema,
        schema.thenSchema,
        schema.elseSchema,
        path,
        schema,
      );
      if (!result.isValid) {
        errors.addAll(result.errors);
      }
    }

    // Type-specific validations
    if (value is String) {
      errors.addAll(_validateString(value, schema, path).errors);
    } else if (value is num) {
      errors.addAll(_validateNumber(value, schema, path).errors);
    } else if (value is List) {
      errors.addAll(_validateArray(value, schema, path).errors);
    } else if (value is Map) {
      errors.addAll(_validateObject(value, schema, path).errors);
    }

    return errors.isEmpty
        ? ValidationResult.success()
        : ValidationResult.failure(errors);
  }

  /// Validates a string value against a schema.
  static ValidationResult _validateString(
    String value,
    JsonSchemaBase schema,
    String path,
  ) {
    List<ValidationError> errors = [];

    // Check minLength constraint
    if (schema.minLength != null) {
      if (value.length < schema.minLength!) {
        errors.add(
          ValidationError.minLengthViolation(
            path: path,
            expected: schema.minLength!,
            actual: value,
            schema: schema,
          ),
        );
      }
    }

    // Check maxLength constraint
    if (schema.maxLength != null) {
      if (value.length > schema.maxLength!) {
        errors.add(
          ValidationError.maxLengthViolation(
            path: path,
            expected: schema.maxLength!,
            actual: value,
            schema: schema,
          ),
        );
      }
    }

    // Check pattern constraint
    if (schema.pattern != null) {
      RegExp regex = RegExp(schema.pattern!);
      if (!regex.hasMatch(value)) {
        errors.add(
          ValidationError.patternViolation(
            path: path,
            pattern: schema.pattern!,
            actual: value,
            schema: schema,
          ),
        );
      }
    }

    // Check format constraint
    if (schema.format != null) {
      try {
        FormatValidator.validateFormat(value, schema.format!);
      } catch (e) {
        errors.add(
          ValidationError.formatViolation(
            path: path,
            format: schema.format!,
            actual: value,
            details: e.toString().replaceAll('FormatException: ', ''),
            schema: schema,
          ),
        );
      }
    }

    // Check content encoding and media type
    if (schema.contentEncoding != null) {
      if (schema.contentEncoding == 'base64') {
        if (!FormatValidator.isBase64(value)) {
          errors.add(
            ValidationError.generic(
              path: path,
              keyword: 'contentEncoding',
              expected: schema.contentEncoding!,
              actual: value,
              message: 'String is not valid base64 encoding',
              schema: schema,
            ),
          );
        } else if (schema.contentMediaType != null) {
          // If it's valid base64, decode it and check the media type
          try {
            final decoded = base64.decode(value);
            final decodedString = utf8.decode(decoded);

            if (schema.contentMediaType == 'application/json') {
              try {
                json.decode(decodedString);
              } catch (e) {
                errors.add(
                  ValidationError.generic(
                    path: path,
                    keyword: 'contentMediaType',
                    expected: schema.contentMediaType!,
                    actual: value,
                    message: 'Decoded content is not valid JSON',
                    schema: schema,
                  ),
                );
              }
            }
            // Add more media type validations as needed
          } catch (e) {
            errors.add(
              ValidationError.generic(
                path: path,
                keyword: 'contentEncoding',
                expected: schema.contentEncoding!,
                actual: value,
                message: 'Failed to decode base64 content: ${e.toString()}',
                schema: schema,
              ),
            );
          }
        }
      }
      // Add more encoding validations as needed
    } else if (schema.contentMediaType != null) {
      // If contentEncoding is not specified but contentMediaType is
      if (schema.contentMediaType == 'application/json') {
        try {
          json.decode(value);
        } catch (e) {
          errors.add(
            ValidationError.generic(
              path: path,
              keyword: 'contentMediaType',
              expected: schema.contentMediaType!,
              actual: value,
              message: 'Content is not valid JSON',
              schema: schema,
            ),
          );
        }
      }
      // Add more media type validations as needed
    }

    return errors.isEmpty
        ? ValidationResult.success()
        : ValidationResult.failure(errors);
  }

  /// Validates a numeric value against a schema.
  static ValidationResult _validateNumber(
    num value,
    JsonSchemaBase schema,
    String path,
  ) {
    List<ValidationError> errors = [];

    // Check minimum constraint
    if (schema.minimum != null) {
      if (value < schema.minimum!) {
        errors.add(
          ValidationError.minimumViolation(
            path: path,
            expected: schema.minimum!,
            actual: value,
            schema: schema,
          ),
        );
      }
    }

    // Check exclusiveMinimum constraint
    if (schema.exclusiveMinimum != null) {
      if (value <= schema.exclusiveMinimum!) {
        errors.add(
          ValidationError.minimumViolation(
            path: path,
            expected: schema.exclusiveMinimum!,
            actual: value,
            schema: schema,
            exclusive: true,
          ),
        );
      }
    }

    // Check maximum constraint
    if (schema.maximum != null) {
      if (value > schema.maximum!) {
        errors.add(
          ValidationError.maximumViolation(
            path: path,
            expected: schema.maximum!,
            actual: value,
            schema: schema,
          ),
        );
      }
    }

    // Check exclusiveMaximum constraint
    if (schema.exclusiveMaximum != null) {
      if (value >= schema.exclusiveMaximum!) {
        errors.add(
          ValidationError.maximumViolation(
            path: path,
            expected: schema.exclusiveMaximum!,
            actual: value,
            schema: schema,
            exclusive: true,
          ),
        );
      }
    }

    // Check multipleOf constraint
    if (schema.multipleOf != null) {
      if ((value / schema.multipleOf!).truncateToDouble() !=
          value / schema.multipleOf!) {
        errors.add(
          ValidationError.multipleOfViolation(
            path: path,
            divisor: schema.multipleOf!,
            actual: value,
            schema: schema,
          ),
        );
      }
    }

    return errors.isEmpty
        ? ValidationResult.success()
        : ValidationResult.failure(errors);
  }

  /// Validates an array value against a schema.
  static ValidationResult _validateArray(
    List value,
    JsonSchemaBase schema,
    String path,
  ) {
    List<ValidationError> errors = [];

    // Check minItems constraint
    if (schema.minItems != null) {
      if (value.length < schema.minItems!) {
        errors.add(
          ValidationError.minItemsViolation(
            path: path,
            expected: schema.minItems!,
            actual: value,
            schema: schema,
          ),
        );
      }
    }

    // Check maxItems constraint
    if (schema.maxItems != null) {
      if (value.length > schema.maxItems!) {
        errors.add(
          ValidationError.maxItemsViolation(
            path: path,
            expected: schema.maxItems!,
            actual: value,
            schema: schema,
          ),
        );
      }
    }

    // Check uniqueItems constraint
    if (schema.uniqueItems == true) {
      Set<String> uniqueItems = {};
      for (int i = 0; i < value.length; i++) {
        String serialized = json.encode(value[i]);
        if (uniqueItems.contains(serialized)) {
          // Find the first duplicate
          int duplicateIndex = -1;
          for (int j = 0; j < i; j++) {
            if (json.encode(value[j]) == serialized) {
              duplicateIndex = j;
              break;
            }
          }

          errors.add(
            ValidationError.uniqueItemsViolation(
              path: path,
              actual: value,
              duplicateIndex1: duplicateIndex,
              duplicateIndex2: i,
              schema: schema,
            ),
          );
          break;
        }
        uniqueItems.add(serialized);
      }
    }

    // Check items constraint
    if (schema.items != null) {
      if (schema.items is JsonSchemaBase) {
        // Single schema for all items
        JsonSchemaBase itemSchema = schema.items as JsonSchemaBase;
        for (int i = 0; i < value.length; i++) {
          final result = validate(value[i], itemSchema, '$path/$i');
          if (!result.isValid) {
            errors.addAll(result.errors);
          }
        }
      } else if (schema.items is List) {
        // Array of schemas for positional validation
        List<JsonSchemaBase> itemSchemas = schema.items as List<JsonSchemaBase>;

        // Validate items against corresponding schemas
        for (int i = 0; i < itemSchemas.length && i < value.length; i++) {
          final result = validate(value[i], itemSchemas[i], '$path/$i');
          if (!result.isValid) {
            errors.addAll(result.errors);
          }
        }

        // Check additionalItems for items beyond the schema array length
        if (value.length > itemSchemas.length &&
            schema.additionalItems != null) {
          if (schema.additionalItems is bool) {
            if (schema.additionalItems == false &&
                value.length > itemSchemas.length) {
              errors.add(
                ValidationError.generic(
                  path: path,
                  keyword: 'additionalItems',
                  expected: itemSchemas.length,
                  actual: value.length,
                  message:
                      'Array has ${value.length} items, but only ${itemSchemas.length} are allowed by items schema',
                  schema: schema,
                ),
              );
            }
          } else if (schema.additionalItems is JsonSchemaBase) {
            JsonSchemaBase additionalItemSchema =
                schema.additionalItems as JsonSchemaBase;
            for (int i = itemSchemas.length; i < value.length; i++) {
              final result = validate(
                value[i],
                additionalItemSchema,
                '$path/$i',
              );
              if (!result.isValid) {
                errors.addAll(result.errors);
              }
            }
          }
        }
      }
    }

    // Check contains constraint
    if (schema.contains != null) {
      bool foundMatch = false;
      for (int i = 0; i < value.length; i++) {
        final result = validate(value[i], schema.contains!, '$path/$i');
        if (result.isValid) {
          foundMatch = true;
          break;
        }
      }
      if (!foundMatch) {
        errors.add(
          ValidationError.containsViolation(
            path: path,
            actual: value,
            schema: schema,
          ),
        );
      }
    }

    return errors.isEmpty
        ? ValidationResult.success()
        : ValidationResult.failure(errors);
  }

  /// Validates an object value against a schema.
  static ValidationResult _validateObject(
    Map<dynamic, dynamic> value,
    JsonSchemaBase schema,
    String path,
  ) {
    List<ValidationError> errors = [];

    // Check minProperties constraint
    if (schema.minProperties != null) {
      if (value.length < schema.minProperties!) {
        errors.add(
          ValidationError.minPropertiesViolation(
            path: path,
            expected: schema.minProperties!,
            actual: value,
            schema: schema,
          ),
        );
      }
    }

    // Check maxProperties constraint
    if (schema.maxProperties != null) {
      if (value.length > schema.maxProperties!) {
        errors.add(
          ValidationError.maxPropertiesViolation(
            path: path,
            expected: schema.maxProperties!,
            actual: value,
            schema: schema,
          ),
        );
      }
    }

    // Check required properties
    if (schema.required != null) {
      for (var propName in schema.required!) {
        if (!value.containsKey(propName)) {
          errors.add(
            ValidationError.requiredPropertyViolation(
              path: path,
              propertyName: propName,
              schema: schema,
            ),
          );
        }
      }
    }

    // Check property names
    if (schema.propertyNames != null) {
      for (var propName in value.keys) {
        if (propName is! String) {
          errors.add(
            ValidationError.generic(
              path: path,
              keyword: 'propertyNames',
              expected: 'string property names',
              actual: propName.runtimeType,
              message: 'Property names must be strings',
              schema: schema,
            ),
          );
          continue;
        }

        final result = validate(
          propName,
          schema.propertyNames!,
          '$path/propertyNames',
        );
        if (!result.isValid) {
          errors.add(
            ValidationError.generic(
              path: '$path/$propName',
              keyword: 'propertyNames',
              expected: 'property name matching schema',
              actual: propName,
              message:
                  'Property name "$propName" does not match propertyNames schema',
              schema: schema,
            ),
          );
        }
      }
    }

    // Check properties
    if (schema.properties != null) {
      for (var propName in schema.properties!.keys) {
        if (value.containsKey(propName)) {
          var propSchema = schema.properties![propName];
          var propValue = value[propName];

          final result = validate(propValue, propSchema!, '$path/$propName');
          if (!result.isValid) {
            errors.addAll(result.errors);
          }
        }
      }
    }

    // Check patternProperties
    if (schema.patternProperties != null) {
      for (var pattern in schema.patternProperties!.keys) {
        var regex = RegExp(pattern);
        var propSchema = schema.patternProperties![pattern];

        for (var propName in value.keys) {
          if (propName is String && regex.hasMatch(propName)) {
            var propValue = value[propName];

            final result = validate(propValue, propSchema!, '$path/$propName');
            if (!result.isValid) {
              errors.addAll(result.errors);
            }
          }
        }
      }
    }

    // Check additionalProperties
    if (schema.additionalProperties != null) {
      // Find properties not covered by properties or patternProperties
      for (var propName in value.keys) {
        if (propName is! String) continue;

        // Skip if property is defined in properties
        if (schema.properties != null &&
            schema.properties!.containsKey(propName)) {
          continue;
        }

        // Skip if property matches any pattern in patternProperties
        bool matchesPattern = false;
        if (schema.patternProperties != null) {
          for (var pattern in schema.patternProperties!.keys) {
            var regex = RegExp(pattern);
            if (regex.hasMatch(propName)) {
              matchesPattern = true;
              break;
            }
          }
        }

        if (!matchesPattern) {
          // This is an additional property
          if (schema.additionalProperties is bool) {
            if (schema.additionalProperties == false) {
              errors.add(
                ValidationError.generic(
                  path: '$path/$propName',
                  keyword: 'additionalProperties',
                  expected: false,
                  actual: true,
                  message: 'Additional property "$propName" is not allowed',
                  schema: schema,
                ),
              );
            }
          } else if (schema.additionalProperties is JsonSchemaBase) {
            var propValue = value[propName];
            final result = validate(
              propValue,
              schema.additionalProperties as JsonSchemaBase,
              '$path/$propName',
            );
            if (!result.isValid) {
              errors.addAll(result.errors);
            }
          }
        }
      }
    }

    // Check dependencies
    if (schema.dependencies != null) {
      for (var propName in schema.dependencies!.keys) {
        // Only check if the property exists in the object
        if (value.containsKey(propName)) {
          var dependency = schema.dependencies![propName];

          if (dependency is List) {
            // Property dependency
            for (var depPropName in dependency) {
              if (!value.containsKey(depPropName)) {
                errors.add(
                  ValidationError.generic(
                    path: path,
                    keyword: 'dependencies',
                    expected: 'property $depPropName when $propName is present',
                    actual: 'property $depPropName is missing',
                    message:
                        'Property "$propName" depends on property "$depPropName", which is missing',
                    schema: schema,
                  ),
                );
              }
            }
          } else if (dependency is JsonSchemaBase) {
            // Schema dependency
            final result = validate(value, dependency, path);
            if (!result.isValid) {
              errors.add(
                ValidationError.generic(
                  path: path,
                  keyword: 'dependencies',
                  expected:
                      'object with property "$propName" to match dependency schema',
                  actual: 'object does not match dependency schema',
                  message:
                      'Object with property "$propName" does not match its dependency schema',
                  schema: schema,
                ),
              );
              errors.addAll(result.errors);
            }
          }
        }
      }
    }

    return errors.isEmpty
        ? ValidationResult.success()
        : ValidationResult.failure(errors);
  }

  /// Helper method to check if a value matches a specific JSON type.
  static bool _matchesType(dynamic value, dynamic type) {
    if (type is JsonType) {
      return _matchesSingleType(value, type);
    } else if (type is List) {
      for (var t in type) {
        if (_matchesSingleType(value, t)) {
          return true;
        }
      }
      return false;
    }
    return false;
  }

  /// Helper method to check if a value matches a single JSON type.
  static bool _matchesSingleType(dynamic value, JsonType type) {
    switch (type) {
      case JsonType.string:
        return value is String;
      case JsonType.number:
        return value is num;
      case JsonType.integer:
        return value is int ||
            (value is num && value.truncateToDouble() == value);
      case JsonType.object:
        return value is Map;
      case JsonType.array:
        return value is List;
      case JsonType.boolean:
        return value is bool;
      case JsonType.nullValue:
        return value == null;
    }
  }

  /// Deep equality check for JSON values.
  static bool _deepEquals(dynamic a, dynamic b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;

    if (a is List && b is List) {
      if (a.length != b.length) return false;
      for (int i = 0; i < a.length; i++) {
        if (!_deepEquals(a[i], b[i])) return false;
      }
      return true;
    } else if (a is Map && b is Map) {
      if (a.length != b.length) return false;
      for (var key in a.keys) {
        if (!b.containsKey(key) || !_deepEquals(a[key], b[key])) {
          return false;
        }
      }
      return true;
    } else {
      return a == b;
    }
  }
}
