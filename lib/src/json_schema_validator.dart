import 'dart:core';
import 'json_schema.dart';
import 'json_type_enum.dart';

/// A class for validating JsonSchema objects according to the JSON Schema draft-07 specification.
///
/// This validator checks that the properties set in JsonSchema objects are valid
/// according to the JSON Schema specification. It does not validate JSON data against
/// the schema, but rather validates the schema itself.
class JsonSchemaValidator {
  /// Validates a JsonSchema object and returns a list of validation errors.
  ///
  /// If the schema is valid, an empty list is returned.
  /// If the schema is invalid, a list of validation errors is returned.
  ///
  /// @param schema The JsonSchema object to validate.
  /// @return A list of validation errors, or an empty list if the schema is valid.
  static List<String> validate(JsonSchema schema) {
    final errors = <String>[];

    // Validate common properties
    _validateCommonProperties(schema, errors);

    // Validate specific schema types
    if (schema is ObjectSchema) {
      _validateObjectSchema(schema, errors);
    } else if (schema is ArraySchema) {
      _validateArraySchema(schema, errors);
    } else if (schema is StringSchema) {
      _validateStringSchema(schema, errors);
    } else if (schema is NumberSchema) {
      _validateNumberSchema(schema, errors);
    }

    // Validate nested schemas
    _validateNestedSchemas(schema, errors);

    return errors;
  }

  /// Validates properties common to all schema types.
  static void _validateCommonProperties(
    JsonSchema schema,
    List<String> errors,
  ) {
    // Validate $schema
    if (schema.schemaVersion != null) {
      final schemaVersionStr = schema.schemaVersion.toString();
      if (!schemaVersionStr.startsWith('http://json-schema.org/') &&
          !schemaVersionStr.startsWith('https://json-schema.org/')) {
        errors.add(
          'Invalid \$schema: $schemaVersionStr. Must be a URI from json-schema.org.',
        );
      }
    }

    // Validate type
    if (schema.type != null) {
      if (schema.type!.isEmpty) {
        errors.add('Type array must not be empty.');
      }

      // Check for duplicate types
      final typeSet = <JsonType>{};
      for (final type in schema.type!) {
        if (typeSet.contains(type)) {
          errors.add('Duplicate type: ${type.typeValue}');
        }
        typeSet.add(type);
      }
    }

    // Validate enum
    if (schema.enumValues != null) {
      if (schema.enumValues!.isEmpty) {
        errors.add('Enum array should not be empty.');
      } else {
        // Check for duplicate enum values
        for (int i = 0; i < schema.enumValues!.length; i++) {
          for (int j = i + 1; j < schema.enumValues!.length; j++) {
            if (_deepEquals(schema.enumValues![i], schema.enumValues![j])) {
              errors.add('Duplicate enum value at indices $i and $j');
            }
          }
        }
      }
    }

    // Validate logical operators
    if (schema.allOf != null) {
      if (schema.allOf!.isEmpty) {
        errors.add('allOf array must not be empty.');
      }
    }

    if (schema.anyOf != null) {
      if (schema.anyOf!.isEmpty) {
        errors.add('anyOf array must not be empty.');
      }
    }

    if (schema.oneOf != null) {
      if (schema.oneOf!.isEmpty) {
        errors.add('oneOf array must not be empty.');
      }
    }

    // Validate conditional schemas
    if (schema.thenSchema != null && schema.ifSchema == null) {
      errors.add('thenSchema requires ifSchema to be present.');
    }

    if (schema.elseSchema != null && schema.ifSchema == null) {
      errors.add('elseSchema requires ifSchema to be present.');
    }
  }

  /// Validates properties specific to ObjectSchema.
  static void _validateObjectSchema(ObjectSchema schema, List<String> errors) {
    // Validate maxProperties
    if (schema.maxProperties != null && schema.maxProperties! < 0) {
      errors.add('maxProperties must be a non-negative integer.');
    }

    // Validate minProperties
    if (schema.minProperties != null && schema.minProperties! < 0) {
      errors.add('minProperties must be a non-negative integer.');
    }

    // Validate maxProperties and minProperties relationship
    if (schema.maxProperties != null && schema.minProperties != null) {
      if (schema.maxProperties! < schema.minProperties!) {
        errors.add(
          'maxProperties must be greater than or equal to minProperties.',
        );
      }
    }

    // Validate required
    if (schema.required != null) {
      // Check for duplicate required properties
      final requiredSet = <String>{};
      for (final prop in schema.required!) {
        if (requiredSet.contains(prop)) {
          errors.add('Duplicate required property: $prop');
        }
        requiredSet.add(prop);
      }

      // Check that required properties exist in properties
      if (schema.properties != null) {
        for (final prop in schema.required!) {
          if (!schema.properties!.containsKey(prop)) {
            // This is just a warning, not an error
            // errors.add('Required property $prop is not defined in properties.');
          }
        }
      }
    }

    // Validate dependencies
    if (schema.dependencies != null) {
      for (final entry in schema.dependencies!.entries) {
        final key = entry.key;
        final value = entry.value;

        if (value is List) {
          // Property dependency
          if (value.isEmpty) {
            errors.add('Property dependency array for $key must not be empty.');
          }

          // Check for duplicate dependencies
          final depSet = <String>{};
          for (final dep in value) {
            if (depSet.contains(dep)) {
              errors.add(
                'Duplicate dependency in property dependency array for $key: $dep',
              );
            }
            depSet.add(dep);
          }
        }
        // Schema dependency is validated in _validateNestedSchemas
      }
    }

    // Validate patternProperties
    if (schema.patternProperties != null) {
      for (final pattern in schema.patternProperties!.keys) {
        try {
          RegExp(pattern);
        } catch (e) {
          errors.add(
            'Invalid regular expression in patternProperties: $pattern',
          );
        }
      }
    }
  }

  /// Validates properties specific to ArraySchema.
  static void _validateArraySchema(ArraySchema schema, List<String> errors) {
    // Validate maxItems
    if (schema.maxItems != null && schema.maxItems! < 0) {
      errors.add('maxItems must be a non-negative integer.');
    }

    // Validate minItems
    if (schema.minItems != null && schema.minItems! < 0) {
      errors.add('minItems must be a non-negative integer.');
    }

    // Validate maxItems and minItems relationship
    if (schema.maxItems != null && schema.minItems != null) {
      if (schema.maxItems! < schema.minItems!) {
        errors.add('maxItems must be greater than or equal to minItems.');
      }
    }

    // Validate items and additionalItems
    if (schema.items != null && schema.items is List<JsonSchema>) {
      if ((schema.items as List<JsonSchema>).isEmpty) {
        errors.add('items array must not be empty.');
      }

      // additionalItems is only meaningful when items is an array
      // No validation needed for additionalItems itself
    } else if (schema.additionalItems != null && schema.items is! List) {
      // This is just a warning, not an error
      // errors.add('additionalItems is ignored when items is not an array.');
    }
  }

  /// Validates properties specific to StringSchema.
  static void _validateStringSchema(StringSchema schema, List<String> errors) {
    // Validate maxLength
    if (schema.maxLength != null && schema.maxLength! < 0) {
      errors.add('maxLength must be a non-negative integer.');
    }

    // Validate minLength
    if (schema.minLength != null && schema.minLength! < 0) {
      errors.add('minLength must be a non-negative integer.');
    }

    // Validate maxLength and minLength relationship
    if (schema.maxLength != null && schema.minLength != null) {
      if (schema.maxLength! < schema.minLength!) {
        errors.add('maxLength must be greater than or equal to minLength.');
      }
    }

    // Validate pattern
    if (schema.pattern != null) {
      try {
        RegExp(schema.pattern!);
      } catch (e) {
        errors.add('Invalid regular expression in pattern: ${schema.pattern}');
      }
    }

    // Validate contentEncoding
    if (schema.contentEncoding != null) {
      final validEncodings = [
        '7bit',
        '8bit',
        'binary',
        'quoted-printable',
        'base16',
        'base32',
        'base64',
      ];
      if (!validEncodings.contains(schema.contentEncoding!.toLowerCase())) {
        errors.add(
          'Invalid contentEncoding: ${schema.contentEncoding}. Must be one of: ${validEncodings.join(', ')}',
        );
      }
    }

    // Validate contentMediaType
    if (schema.contentMediaType != null) {
      final mediaTypeParts = schema.contentMediaType!.split('/');
      if (mediaTypeParts.length != 2) {
        errors.add(
          'Invalid contentMediaType: ${schema.contentMediaType}. Must be in format "type/subtype".',
        );
      }
    }
  }

  /// Validates properties specific to NumberSchema.
  static void _validateNumberSchema(NumberSchema schema, List<String> errors) {
    // Validate multipleOf
    if (schema.multipleOf != null && schema.multipleOf! <= 0) {
      errors.add('multipleOf must be greater than 0.');
    }

    // Validate maximum and exclusiveMaximum relationship
    if (schema.maximum != null && schema.exclusiveMaximum != null) {
      if (schema.maximum! < schema.exclusiveMaximum!) {
        // This is just a warning, not an error
        // errors.add('maximum is redundant when less than exclusiveMaximum.');
      }
    }

    // Validate minimum and exclusiveMinimum relationship
    if (schema.minimum != null && schema.exclusiveMinimum != null) {
      if (schema.minimum! > schema.exclusiveMinimum!) {
        // This is just a warning, not an error
        // errors.add('minimum is redundant when greater than exclusiveMinimum.');
      }
    }

    // Validate maximum and minimum relationship
    if (schema.maximum != null && schema.minimum != null) {
      if (schema.maximum! < schema.minimum!) {
        errors.add('maximum must be greater than or equal to minimum.');
      }
    }

    // Validate exclusiveMaximum and exclusiveMinimum relationship
    if (schema.exclusiveMaximum != null && schema.exclusiveMinimum != null) {
      if (schema.exclusiveMaximum! <= schema.exclusiveMinimum!) {
        errors.add('exclusiveMaximum must be greater than exclusiveMinimum.');
      }
    }
  }

  /// Validates nested schemas within a schema.
  static void _validateNestedSchemas(JsonSchema schema, List<String> errors) {
    // Validate definitions
    if (schema.definitions != null) {
      for (final entry in schema.definitions!.entries) {
        final nestedErrors = validate(entry.value);
        for (final error in nestedErrors) {
          errors.add('In definition "${entry.key}": $error');
        }
      }
    }

    // Validate logical operators
    if (schema.allOf != null) {
      for (int i = 0; i < schema.allOf!.length; i++) {
        final nestedErrors = validate(schema.allOf![i]);
        for (final error in nestedErrors) {
          errors.add('In allOf[$i]: $error');
        }
      }
    }

    if (schema.anyOf != null) {
      for (int i = 0; i < schema.anyOf!.length; i++) {
        final nestedErrors = validate(schema.anyOf![i]);
        for (final error in nestedErrors) {
          errors.add('In anyOf[$i]: $error');
        }
      }
    }

    if (schema.oneOf != null) {
      for (int i = 0; i < schema.oneOf!.length; i++) {
        final nestedErrors = validate(schema.oneOf![i]);
        for (final error in nestedErrors) {
          errors.add('In oneOf[$i]: $error');
        }
      }
    }

    // Validate not schema
    if (schema.notSchema != null) {
      final nestedErrors = validate(schema.notSchema!);
      for (final error in nestedErrors) {
        errors.add('In not: $error');
      }
    }

    // Validate conditional schemas
    if (schema.ifSchema != null) {
      final nestedErrors = validate(schema.ifSchema!);
      for (final error in nestedErrors) {
        errors.add('In if: $error');
      }
    }

    if (schema.thenSchema != null) {
      final nestedErrors = validate(schema.thenSchema!);
      for (final error in nestedErrors) {
        errors.add('In then: $error');
      }
    }

    if (schema.elseSchema != null) {
      final nestedErrors = validate(schema.elseSchema!);
      for (final error in nestedErrors) {
        errors.add('In else: $error');
      }
    }

    // Validate object-specific nested schemas
    if (schema is ObjectSchema) {
      // Validate properties
      if (schema.properties != null) {
        for (final entry in schema.properties!.entries) {
          final nestedErrors = validate(entry.value);
          for (final error in nestedErrors) {
            errors.add('In property "${entry.key}": $error');
          }
        }
      }

      // Validate patternProperties
      if (schema.patternProperties != null) {
        for (final entry in schema.patternProperties!.entries) {
          final nestedErrors = validate(entry.value);
          for (final error in nestedErrors) {
            errors.add('In patternProperty "${entry.key}": $error');
          }
        }
      }

      // Validate additionalProperties
      if (schema.additionalProperties != null) {
        final nestedErrors = validate(schema.additionalProperties!);
        for (final error in nestedErrors) {
          errors.add('In additionalProperties: $error');
        }
      }

      // Validate propertyNames
      if (schema.propertyNames != null) {
        final nestedErrors = validate(schema.propertyNames!);
        for (final error in nestedErrors) {
          errors.add('In propertyNames: $error');
        }
      }

      // Validate dependencies
      if (schema.dependencies != null) {
        for (final entry in schema.dependencies!.entries) {
          final key = entry.key;
          final value = entry.value;

          if (value is JsonSchema) {
            // Schema dependency
            final nestedErrors = validate(value);
            for (final error in nestedErrors) {
              errors.add('In dependency schema for "$key": $error');
            }
          }
        }
      }
    }

    // Validate array-specific nested schemas
    if (schema is ArraySchema) {
      // Validate items
      if (schema.items != null) {
        if (schema.items is JsonSchema) {
          final nestedErrors = validate(schema.items as JsonSchema);
          for (final error in nestedErrors) {
            errors.add('In items: $error');
          }
        } else if (schema.items is List<JsonSchema>) {
          final itemsList = schema.items as List<JsonSchema>;
          for (int i = 0; i < itemsList.length; i++) {
            final nestedErrors = validate(itemsList[i]);
            for (final error in nestedErrors) {
              errors.add('In items[$i]: $error');
            }
          }
        }
      }

      // Validate additionalItems
      if (schema.additionalItems != null) {
        final nestedErrors = validate(schema.additionalItems!);
        for (final error in nestedErrors) {
          errors.add('In additionalItems: $error');
        }
      }

      // Validate contains
      if (schema.contains != null) {
        final nestedErrors = validate(schema.contains!);
        for (final error in nestedErrors) {
          errors.add('In contains: $error');
        }
      }
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
      for (final key in a.keys) {
        if (!b.containsKey(key) || !_deepEquals(a[key], b[key])) return false;
      }
      return true;
    } else {
      return a == b;
    }
  }
}

/// Exception thrown when a JsonSchema validation fails.
class JsonSchemaValidationException implements Exception {
  final List<String> errors;

  JsonSchemaValidationException(this.errors);

  @override
  String toString() {
    if (errors.isEmpty) {
      return 'JsonSchemaValidationException: Unknown validation error';
    } else if (errors.length == 1) {
      return 'JsonSchemaValidationException: ${errors.first}';
    } else {
      return 'JsonSchemaValidationException: Multiple validation errors:\n- ${errors.join('\n- ')}';
    }
  }
}
