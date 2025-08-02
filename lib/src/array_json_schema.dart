import 'dart:convert';
import 'json_schema.dart';
import 'json_schema_base.dart';
import 'json_type.dart';

/// A specialized JSON Schema class that only supports the Array type.
///
/// This class extends the base JsonSchema but restricts the type to Array only
/// and provides validations specific to Array types according to JSON Schema draft-07.
class ArrayJsonSchema extends JsonSchema {
  ArrayJsonSchema() {
    // Initialize with Array type
    super.type = JsonType.array;
  }

  @override
  set type(dynamic value) {
    // Only allow Array type
    if (value != JsonType.array &&
        !(value is List && value.length == 1 && value[0] == JsonType.array)) {
      throw FormatException('ArrayJsonSchema only supports Array type');
    }
    super.type = JsonType.array;
  }

  @override
  set defaultValue(dynamic value) {
    if (value != null && value is! List) {
      throw FormatException('defaultValue must be an array or null');
    }
    super.defaultValue = value;
  }

  @override
  set constValue(dynamic value) {
    if (value != null && value is! List) {
      throw FormatException('constValue must be an array or null');
    }
    super.constValue = value;
  }

  @override
  set enumValues(List<dynamic>? values) {
    if (values != null) {
      if (values.isEmpty) {
        throw FormatException('enum must have at least one value');
      }

      // Ensure all enum values are arrays
      for (var value in values) {
        if (value is! List) {
          throw FormatException('All enum values must be arrays');
        }
      }
    }
    super.enumValues = values;
  }

  /// Validates an array value against this schema.
  ///
  /// This method checks if the provided value is a valid array and satisfies
  /// all constraints defined in this schema (items, maxItems, minItems, etc.).
  ///
  /// Returns true if the value is valid, false otherwise.
  bool validateArray(dynamic value) {
    if (value == null) {
      return true; // null is always valid unless specified otherwise
    }

    try {
      validateArrayWithExceptions(value);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Validates an array value against this schema and throws a FormatException if invalid.
  ///
  /// This method is similar to validateArray but throws exceptions with detailed
  /// error messages instead of returning a boolean.
  void validateArrayWithExceptions(dynamic value) {
    if (value == null) {
      return; // null is always valid unless specified otherwise
    }

    // Check type
    if (value is! List) {
      throw FormatException('Value must be an array');
    }

    // Check against const value (most restrictive)
    if (constValue != null) {
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

    // Check minItems constraint
    if (minItems != null) {
      if (value.length < minItems!) {
        throw FormatException(
          'Array must have at least $minItems items, but has ${value.length}',
        );
      }
    }

    // Check maxItems constraint
    if (maxItems != null) {
      if (value.length > maxItems!) {
        throw FormatException(
          'Array must have at most $maxItems items, but has ${value.length}',
        );
      }
    }

    // Check uniqueItems constraint
    if (uniqueItems == true) {
      Set<String> uniqueItemsSet = {};
      for (var item in value) {
        String serialized = json.encode(item);
        if (uniqueItemsSet.contains(serialized)) {
          throw FormatException('Array items must be unique');
        }
        uniqueItemsSet.add(serialized);
      }
    }

    // Check items constraint
    if (items != null) {
      if (items is JsonSchemaBase) {
        // Single schema for all items
        for (int i = 0; i < value.length; i++) {
          if (!_isValidAgainstSchema(value[i], items as JsonSchemaBase)) {
            throw FormatException(
              'Array item at index $i does not match items schema',
            );
          }
        }
      } else if (items is List) {
        // Array of schemas for positional validation
        List<JsonSchemaBase> itemSchemas = items as List<JsonSchemaBase>;

        // Validate items against corresponding schemas
        for (int i = 0; i < itemSchemas.length && i < value.length; i++) {
          if (!_isValidAgainstSchema(value[i], itemSchemas[i])) {
            throw FormatException(
              'Array item at index $i does not match schema at position $i',
            );
          }
        }

        // Check additionalItems for items beyond the schema array length
        if (value.length > itemSchemas.length && additionalItems != null) {
          if (additionalItems is bool) {
            if (additionalItems == false && value.length > itemSchemas.length) {
              throw FormatException(
                'Array has ${value.length} items, but only ${itemSchemas.length} are allowed by items schema',
              );
            }
          } else if (additionalItems is JsonSchemaBase) {
            for (int i = itemSchemas.length; i < value.length; i++) {
              if (!_isValidAgainstSchema(
                value[i],
                additionalItems as JsonSchemaBase,
              )) {
                throw FormatException(
                  'Additional array item at index $i does not match additionalItems schema',
                );
              }
            }
          }
        }
      }
    }

    // Check contains constraint
    if (contains != null) {
      bool foundMatch = false;
      for (var item in value) {
        if (_isValidAgainstSchema(item, contains!)) {
          foundMatch = true;
          break;
        }
      }
      if (!foundMatch) {
        throw FormatException(
          'Array does not contain any item matching the contains schema',
        );
      }
    }
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

  /// Deep equality check for arrays
  bool _deepEquals(dynamic a, dynamic b) {
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
