import 'dart:convert';
import '../json_schema.dart';
import '../json_schema_base.dart';
import '../json_type.dart';
import '../cross_type_validator.dart';

/// A specialized JSON Schema class that only supports the Object type.
///
/// This class extends the base JsonSchema but restricts the type to Object only
/// and provides validations specific to Object types according to JSON Schema draft-07.
class ObjectJsonSchema extends JsonSchema {
  ObjectJsonSchema() {
    // Initialize with Object type
    super.type = JsonType.object;
  }

  @override
  set type(dynamic value) {
    // Only allow Object type
    if (value != JsonType.object &&
        !(value is List && value.length == 1 && value[0] == JsonType.object)) {
      throw FormatException('ObjectJsonSchema only supports Object type');
    }
    super.type = JsonType.object;
  }

  @override
  set defaultValue(dynamic value) {
    if (value != null && value is! Map) {
      throw FormatException('defaultValue must be an object or null');
    }
    super.defaultValue = value;
  }

  @override
  set constValue(dynamic value) {
    if (value != null && value is! Map) {
      throw FormatException('constValue must be an object or null');
    }
    super.constValue = value;
  }

  @override
  set enumValues(List<dynamic>? values) {
    if (values != null) {
      if (values.isEmpty) {
        throw FormatException('enum must have at least one value');
      }

      // Ensure all enum values are objects
      for (var value in values) {
        if (value is! Map) {
          throw FormatException('All enum values must be objects');
        }
      }
    }
    super.enumValues = values;
  }

  /// Validates an object value against this schema.
  ///
  /// This method checks if the provided value is a valid object and satisfies
  /// all constraints defined in this schema (properties, required, etc.).
  ///
  /// Returns true if the value is valid, false otherwise.
  bool validateObject(dynamic value) {
    if (value == null) {
      return true; // null is always valid unless specified otherwise
    }

    try {
      validateObjectWithExceptions(value);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Validates an object value against this schema and throws a FormatException if invalid.
  ///
  /// This method is similar to validateObject but throws exceptions with detailed
  /// error messages instead of returning a boolean.
  void validateObjectWithExceptions(dynamic value) {
    if (value == null) {
      return; // null is always valid unless specified otherwise
    }

    // Check type
    if (value is! Map) {
      throw FormatException('Value must be an object');
    }

    // Check against const value (most restrictive)
    if (constValue != null) {
      // Deep comparison of objects
      if (!_deepEquals(value, constValue)) {
        throw FormatException('Value must be equal to const value');
      }
      return; // If it matches const, no need to check other constraints
    }

    // Check against enum values
    if (enumValues != null) {
      bool foundMatch = false;
      for (var enumValue in enumValues!) {
        if (_deepEquals(value, enumValue)) {
          foundMatch = true;
          break;
        }
      }
      if (!foundMatch) {
        throw FormatException('Value must be one of the enum values');
      }
      return; // If it's in enum, no need to check other constraints
    }

    // Check minProperties constraint
    if (minProperties != null) {
      if (value.length < minProperties!) {
        throw FormatException(
          'Object must have at least $minProperties properties, but has ${value.length}',
        );
      }
    }

    // Check maxProperties constraint
    if (maxProperties != null) {
      if (value.length > maxProperties!) {
        throw FormatException(
          'Object must have at most $maxProperties properties, but has ${value.length}',
        );
      }
    }

    // Check required properties
    if (required != null) {
      for (var propName in required!) {
        if (!value.containsKey(propName)) {
          throw FormatException(
            'Object is missing required property: $propName',
          );
        }
      }
    }

    // Check property names
    if (propertyNames != null) {
      for (var propName in value.keys) {
        if (propName is! String) {
          throw FormatException('Property names must be strings');
        }

        // We can't directly validate with propertyNames schema since it might not have
        // specialized validation methods, so we'll use a generic approach
        if (!_isValidPropertyName(propName, propertyNames!)) {
          throw FormatException(
            'Property name "$propName" does not match propertyNames schema',
          );
        }
      }
    }

    // Check properties
    if (properties != null) {
      for (var propName in properties!.keys) {
        if (value.containsKey(propName)) {
          var propSchema = properties![propName];
          var propValue = value[propName];

          if (!_isValidPropertyValue(propValue, propSchema!)) {
            throw FormatException(
              'Property "$propName" does not match its schema',
            );
          }
        }
      }
    }

    // Check patternProperties
    if (patternProperties != null) {
      for (var pattern in patternProperties!.keys) {
        var regex = RegExp(pattern);
        var propSchema = patternProperties![pattern];

        for (var propName in value.keys) {
          if (propName is String && regex.hasMatch(propName)) {
            var propValue = value[propName];

            if (!_isValidPropertyValue(propValue, propSchema!)) {
              throw FormatException(
                'Property "$propName" matching pattern "$pattern" does not match its schema',
              );
            }
          }
        }
      }
    }

    // Check additionalProperties
    if (additionalProperties != null) {
      // Find properties not covered by properties or patternProperties
      for (var propName in value.keys) {
        if (propName is! String) continue;

        // Skip if property is defined in properties
        if (properties != null && properties!.containsKey(propName)) {
          continue;
        }

        // Skip if property matches any pattern in patternProperties
        bool matchesPattern = false;
        if (patternProperties != null) {
          for (var pattern in patternProperties!.keys) {
            var regex = RegExp(pattern);
            if (regex.hasMatch(propName)) {
              matchesPattern = true;
              break;
            }
          }
        }

        if (!matchesPattern) {
          // This is an additional property
          if (additionalProperties is bool) {
            if (additionalProperties == false) {
              throw FormatException(
                'Additional property "$propName" is not allowed',
              );
            }
          } else if (additionalProperties is JsonSchemaBase) {
            var propValue = value[propName];
            if (!_isValidPropertyValue(
              propValue,
              additionalProperties as JsonSchemaBase,
            )) {
              throw FormatException(
                'Additional property "$propName" does not match additionalProperties schema',
              );
            }
          }
        }
      }
    }

    // Check dependencies
    if (dependencies != null) {
      for (var propName in dependencies!.keys) {
        // Only check if the property exists in the object
        if (value.containsKey(propName)) {
          var dependency = dependencies![propName];

          if (dependency is List) {
            // Property dependency
            for (var depPropName in dependency) {
              if (!value.containsKey(depPropName)) {
                throw FormatException(
                  'Property "$propName" depends on property "$depPropName", which is missing',
                );
              }
            }
          } else if (dependency is JsonSchemaBase) {
            // Schema dependency
            if (!CrossTypeValidator.validate(value, dependency, "").isValid) {
              throw FormatException(
                'Object with property "$propName" does not match its dependency schema',
              );
            }
          }
        }
      }
    }
  }

  /// Helper method to check if a property name is valid against a schema
  bool _isValidPropertyName(String propName, JsonSchemaBase schema) {
    // For property names, we only need to check if it's a valid string
    // according to the schema's constraints

    // If the schema has a type constraint, it should be string
    if (schema.type != null) {
      if (schema.type is JsonType && schema.type != JsonType.string) {
        return false;
      } else if (schema.type is List &&
          !schema.type.contains(JsonType.string)) {
        return false;
      }
    }

    // Check pattern constraint if present
    if (schema.pattern != null) {
      RegExp regex = RegExp(schema.pattern!);
      if (!regex.hasMatch(propName)) {
        return false;
      }
    }

    // Check minLength constraint if present
    if (schema.minLength != null && propName.length < schema.minLength!) {
      return false;
    }

    // Check maxLength constraint if present
    if (schema.maxLength != null && propName.length > schema.maxLength!) {
      return false;
    }

    // Check enum constraint if present
    if (schema.enumValues != null) {
      bool foundMatch = false;
      for (var enumValue in schema.enumValues!) {
        if (propName == enumValue) {
          foundMatch = true;
          break;
        }
      }
      if (!foundMatch) {
        return false;
      }
    }

    // Check const constraint if present
    if (schema.constValue != null && propName != schema.constValue) {
      return false;
    }

    return true;
  }

  /// Helper method to check if a property value is valid against a schema
  bool _isValidPropertyValue(dynamic value, JsonSchemaBase schema) {
    return CrossTypeValidator.validate(value, schema, "").isValid;
  }

  /// Deep equality check for objects using JSON serialization
  bool _deepEquals(dynamic a, dynamic b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;

    try {
      // Convert both values to JSON strings and compare
      return json.encode(a) == json.encode(b);
    } catch (e) {
      // If serialization fails, fall back to direct equality
      return a == b;
    }
  }
}
