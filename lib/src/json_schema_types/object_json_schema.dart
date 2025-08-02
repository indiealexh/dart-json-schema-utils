import 'dart:convert';
import '../json_schema.dart';
import '../json_schema_base.dart';
import '../json_type.dart';

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
            if (!_isValidAgainstSchema(value, dependency)) {
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
    return _isValidAgainstSchema(value, schema);
  }

  /// Generic method to check if a value is valid against a schema
  bool _isValidAgainstSchema(dynamic value, JsonSchemaBase schema) {
    // If value is null, it's valid unless the schema explicitly requires a non-null value
    if (value == null) {
      // If schema type is explicitly set to null, then null is valid
      if (schema.type == JsonType.nullValue) {
        return true;
      }

      // If schema type is a list that includes null, then null is valid
      if (schema.type is List && schema.type.contains(JsonType.nullValue)) {
        return true;
      }

      // If schema has no type constraint, null is valid
      if (schema.type == null) {
        return true;
      }

      // Otherwise, null is not valid
      return false;
    }

    // Check type constraint
    if (schema.type != null) {
      if (schema.type is JsonType) {
        if (!_matchesType(value, schema.type)) {
          return false;
        }
      } else if (schema.type is List) {
        bool matchesAnyType = false;
        for (var type in schema.type) {
          if (_matchesType(value, type)) {
            matchesAnyType = true;
            break;
          }
        }
        if (!matchesAnyType) {
          return false;
        }
      }
    }

    // Check const constraint
    if (schema.constValue != null) {
      if (!_deepEquals(value, schema.constValue)) {
        return false;
      }
      return true; // If it matches const, no need to check other constraints
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
        return false;
      }
      return true; // If it's in enum, no need to check other constraints
    }

    // Type-specific validations
    if (value is String) {
      // String validations
      if (schema.minLength != null && value.length < schema.minLength!) {
        return false;
      }

      if (schema.maxLength != null && value.length > schema.maxLength!) {
        return false;
      }

      if (schema.pattern != null) {
        RegExp regex = RegExp(schema.pattern!);
        if (!regex.hasMatch(value)) {
          return false;
        }
      }
    } else if (value is num) {
      // Number validations
      if (schema.minimum != null && value < schema.minimum!) {
        return false;
      }

      if (schema.exclusiveMinimum != null &&
          value <= schema.exclusiveMinimum!) {
        return false;
      }

      if (schema.maximum != null && value > schema.maximum!) {
        return false;
      }

      if (schema.exclusiveMaximum != null &&
          value >= schema.exclusiveMaximum!) {
        return false;
      }

      if (schema.multipleOf != null) {
        if ((value / schema.multipleOf!).truncateToDouble() !=
            value / schema.multipleOf!) {
          return false;
        }
      }
    } else if (value is List) {
      // Array validations
      if (schema.minItems != null && value.length < schema.minItems!) {
        return false;
      }

      if (schema.maxItems != null && value.length > schema.maxItems!) {
        return false;
      }

      if (schema.uniqueItems == true) {
        Set uniqueItems = {};
        for (var item in value) {
          String serialized = json.encode(item);
          if (uniqueItems.contains(serialized)) {
            return false;
          }
          uniqueItems.add(serialized);
        }
      }

      // TODO: Add validation for items, additionalItems, and contains if needed
    } else if (value is Map) {
      // Object validations
      if (schema.minProperties != null &&
          value.length < schema.minProperties!) {
        return false;
      }

      if (schema.maxProperties != null &&
          value.length > schema.maxProperties!) {
        return false;
      }

      if (schema.required != null) {
        for (var propName in schema.required!) {
          if (!value.containsKey(propName)) {
            return false;
          }
        }
      }

      // TODO: Add validation for properties, patternProperties, additionalProperties if needed
    }

    return true;
  }

  /// Helper method to check if a value matches a specific JSON type
  bool _matchesType(dynamic value, JsonType type) {
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

  /// Deep equality check for objects
  bool _deepEquals(dynamic a, dynamic b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;

    if (a is Map && b is Map) {
      if (a.length != b.length) return false;

      for (var key in a.keys) {
        if (!b.containsKey(key) || !_deepEquals(a[key], b[key])) {
          return false;
        }
      }

      return true;
    } else if (a is List && b is List) {
      if (a.length != b.length) return false;

      for (int i = 0; i < a.length; i++) {
        if (!_deepEquals(a[i], b[i])) return false;
      }

      return true;
    } else {
      return a == b;
    }
  }
}
