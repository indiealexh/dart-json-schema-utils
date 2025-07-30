import 'dart:convert';

import '../json_schema_utils.dart';
import 'json_type.dart';

/// Defines a comprehensive interface for a JSON Schema, based on Draft-07.
///
/// This abstract class outlines all the possible keywords and their corresponding
/// Dart types. Implement this class to create a JSON Schema parser, validator,
/// or code generator.
///
/// See: https://json-schema.org/draft-07/draft-handrews-json-schema-01
abstract class JsonSchemaBase {
  // --- Core & Metadata Keywords ---

  /// The `$id` keyword defines a URI for the schema, which can be used as a
  /// base URI for resolving relative references.
  /// JSON key: `$id`
  /// See: https://json-schema.org/draft-07/draft-handrews-json-schema-01#section-8.2
  String? get id;

  /// The `$schema` keyword specifies which draft of the JSON Schema standard the
  /// schema adheres to.
  /// JSON key: `$schema`
  /// See: https://json-schema.org/draft-07/draft-handrews-json-schema-01#section-7.1
  String? get schema;

  /// The `$ref` keyword is used to reference another schema. This allows for
  /// reusable schema definitions. The value is a URI-reference.
  /// JSON key: `$ref`
  /// See: https://json-schema.org/draft-07/draft-handrews-json-schema-01#section-8.1
  String? get ref;

  /// The `$comment` keyword is strictly for adding comments to a schema and
  /// has no validation effect.
  /// JSON key: `$comment`
  /// See: https://json-schema.org/draft-07/draft-handrews-json-schema-01#section-9
  String? get comment;

  // --- Annotations ---

  /// A descriptive title for the schema.
  /// See: https://json-schema.org/draft-07/draft-handrews-json-schema-01#section-10.1
  String? get title;

  /// A detailed explanation of the purpose of the data described by the schema.
  /// See: https://json-schema.org/draft-07/draft-handrews-json-schema-01#section-10.1
  String? get description;

  /// The `default` keyword specifies a default value. This value should be
  /// valid against the schema but is not used for validation.
  /// See: https://json-schema.org/draft-07/draft-handrews-json-schema-01#section-10.2
  dynamic get defaultValue;

  /// Provides example values that are valid against the schema.
  /// See: https://json-schema.org/draft-07/draft-handrews-json-schema-01#section-10.4
  List<dynamic>? get examples;

  /// If `true`, indicates that the value is read-only.
  /// See: https://json-schema.org/draft-07/draft-handrews-json-schema-01#section-10.3
  bool? get readOnly;

  /// If `true`, indicates that the value is write-only.
  /// See: https://json-schema.org/draft-07/draft-handrews-json-schema-01#section-10.3
  bool? get writeOnly;

  // --- Validation Keywords for Any Instance Type ---

  /// The `type` keyword defines the data type for an instance. It can be a
  /// single type or a list of types.
  ///
  /// The underlying value in JSON can be a string or an array of strings.
  /// This dynamic type should be parsed into a `JsonType` or `List<JsonType>`.
  /// See: https://json-schema.org/draft-07/draft-handrews-json-schema-01#section-6.1.1
  dynamic get type; // Should resolve to `JsonType` or `List<JsonType>`

  /// An instance is valid if it is equal to one of the elements in this array.
  /// See: https://json-schema.org/draft-07/draft-handrews-json-schema-01#section-6.1.2
  List<dynamic>? get enumValues;

  /// An instance is valid if it is equal to this value.
  /// See: https://json-schema.org/draft-07/draft-handrews-json-schema-01#section-6.1.3
  dynamic get constValue;

  // --- Validation Keywords for Numeric Instances (number and integer) ---

  /// A numeric instance is valid only if it is a multiple of this value.
  /// See: https://json-schema.org/draft-07/draft-handrews-json-schema-01#section-6.2.1
  num? get multipleOf;

  /// The maximum allowed value for a numeric instance.
  /// See: https://json-schema.org/draft-07/draft-handrews-json-schema-01#section-6.2.2
  num? get maximum;

  /// If `maximum` is defined, this boolean indicates if the instance is
  /// allowed to be equal to the `maximum` value.
  /// In Draft-07, this is a number, not a boolean. The boolean form is from older drafts.
  /// For exclusivity, use `exclusiveMaximum`.
  num? get exclusiveMaximum;

  /// The minimum allowed value for a numeric instance.
  /// See: https://json-schema.org/draft-07/draft-handrews-json-schema-01#section-6.2.4
  num? get minimum;

  /// If `minimum` is defined, this boolean indicates if the instance is
  /// allowed to be equal to the `minimum` value.
  /// In Draft-07, this is a number. See `exclusiveMinimum`.
  num? get exclusiveMinimum;

  // --- Validation Keywords for String Instances ---

  /// The maximum length of a string.
  /// See: https://json-schema.org/draft-07/draft-handrews-json-schema-01#section-6.3.1
  int? get maxLength;

  /// The minimum length of a string.
  /// See: https://json-schema.org/draft-07/draft-handrews-json-schema-01#section-6.3.2
  int? get minLength;

  /// A regular expression that the string instance must match.
  /// See: https://json-schema.org/draft-07/draft-handrews-json-schema-01#section-6.3.3
  String? get pattern;

  // --- Validation Keywords for Array Instances ---

  /// Defines the schema for the items in the array. Can be a single schema
  /// (all items must match) or a list of schemas (tuple validation).
  ///
  /// The underlying value can be a `JsonSchema` or `List<JsonSchema>`.
  /// See: https://json-schema.org/draft-07/draft-handrews-json-schema-01#section-6.4.1
  dynamic get items; // Should resolve to `JsonSchema` or `List<JsonSchema>`

  /// If `items` is a list of schemas, this keyword defines the schema for any
  /// additional items in the array. Can be a boolean or a schema.
  ///
  /// The underlying value can be a `bool` or `JsonSchema`.
  /// See: https://json-schema.org/draft-07/draft-handrews-json-schema-01#section-6.4.2
  dynamic get additionalItems; // Should resolve to `bool` or `JsonSchema`

  /// The maximum number of items in an array.
  /// See: https://json-schema.org/draft-07/draft-handrews-json-schema-01#section-6.4.3
  int? get maxItems;

  /// The minimum number of items in an array.
  /// See: https://json-schema.org/draft-07/draft-handrews-json-schema-01#section-6.4.4
  int? get minItems;

  /// If true, all items in the array must be unique.
  /// See: https://json-schema.org/draft-07/draft-handrews-json-schema-01#section-6.4.5
  bool? get uniqueItems;

  /// An array instance is valid if at least one of its elements is valid
  /// against this schema.
  /// See: https://json-schema.org/draft-07/draft-handrews-json-schema-01#section-6.4.6
  JsonSchemaBase? get contains;

  // --- Validation Keywords for Object Instances ---

  /// The maximum number of properties an object can have.
  /// See: https://json-schema.org/draft-07/draft-handrews-json-schema-01#section-6.5.1
  int? get maxProperties;

  /// The minimum number of properties an object can have.
  /// See: https://json-schema.org/draft-07/draft-handrews-json-schema-01#section-6.5.2
  int? get minProperties;

  /// A list of property names that must be present in the object.
  /// See: https://json-schema.org/draft-07/draft-handrews-json-schema-01#section-6.5.3
  List<String>? get required;

  /// Defines the schemas for an object's properties.
  /// See: https://json-schema.org/draft-07/draft-handrews-json-schema-01#section-6.5.4
  Map<String, JsonSchemaBase>? get properties;

  /// Defines schemas for properties whose names match a regular expression.
  /// See: https://json-schema.org/draft-07/draft-handrews-json-schema-01#section-6.5.5
  Map<String, JsonSchemaBase>? get patternProperties;

  /// Defines how to handle additional properties not specified in `properties`
  /// or `patternProperties`. Can be a boolean or a schema.
  ///
  /// The underlying value can be a `bool` or `JsonSchema`.
  /// See: https://json-schema.org/draft-07/draft-handrews-json-schema-01#section-6.5.6
  dynamic get additionalProperties; // Should resolve to `bool` or `JsonSchema`

  /// Defines dependencies between properties. Can specify that if a certain
  /// property is present, other properties must also be present, or that the
  /// object must be valid against another schema.
  ///
  /// The value of the map can be a `List<String>` or a `JsonSchema`.
  /// See: https://json-schema.org/draft-07/draft-handrews-json-schema-01#section-6.5.7
  Map<String, dynamic>? get dependencies;

  /// Specifies a schema that all property names in the object must be valid against.
  /// See: https://json-schema.org/draft-07/draft-handrews-json-schema-01#section-6.5.8
  JsonSchemaBase? get propertyNames;

  // --- Schema Re-Use with "definitions" ---

  /// Provides a standardized place for schema definitions that can be
  /// referenced using `$ref` elsewhere in the same schema.
  /// See: https://json-schema.org/draft-07/draft-handrews-json-schema-01#section-8.3
  Map<String, JsonSchemaBase>? get definitions;

  // --- Combining Schemas ---

  /// An instance is valid if it is valid against all schemas in this list.
  /// See: https://json-schema.org/draft-07/draft-handrews-json-schema-01#section-6.7.1
  List<JsonSchemaBase>? get allOf;

  /// An instance is valid if it is valid against at least one of the schemas in this list.
  /// See: https://json-schema.org/draft-07/draft-handrews-json-schema-01#section-6.7.2
  List<JsonSchemaBase>? get anyOf;

  /// An instance is valid if it is valid against exactly one of the schemas in this list.
  /// See: https://json-schema.org/draft-07/draft-handrews-json-schema-01#section-6.7.3
  List<JsonSchemaBase>? get oneOf;

  /// An instance is valid if it is not valid against this schema.
  /// See: https://json-schema.org/draft-07/draft-handrews-json-schema-01#section-6.7.4
  JsonSchemaBase? get not;

  // --- Conditional Subschemas ---

  /// If the instance is valid against this schema...
  /// See: https://json-schema.org/draft-07/draft-handrews-json-schema-01#section-6.6
  JsonSchemaBase? get ifSchema;

  /// ...then it must also be valid against this schema.
  /// Used in conjunction with `ifSchema`.
  JsonSchemaBase? get thenSchema;

  /// ...otherwise, it must be valid against this schema.
  /// Used in conjunction with `ifSchema`.
  JsonSchemaBase? get elseSchema;

  // --- Format ---

  /// Specifies a semantic format for a value. This provides a way to validate
  /// common data formats like "date-time", "email", "uri", etc.
  /// See: https://json-schema.org/draft-07/draft-handrews-json-schema-01#section-7.3
  String? get format;

  // --- Content Keywords ---

  /// If the instance is a string, this keyword indicates the media type of the
  /// content, as described by RFC 2046.
  /// See: https://json-schema.org/draft-07/draft-handrews-json-schema-01#section-7.4
  String? get contentMediaType;

  /// If the instance is a string, this keyword indicates the encoding used to
  /// store the contents, as described by RFC 2054.
  /// See: https://json-schema.org/draft-07/draft-handrews-json-schema-01#section-7.4
  String? get contentEncoding;

  Map<String, dynamic> toMap() {
    return {
      r'$schema': schema.toString(),
      r'$id': id.toString(),
      'title': title,
      'description': description,
      r'$ref': ref,
      r'$comment': comment,
      'additionalItems': additionalItems,
      'additionalProperties': additionalProperties,
      'allOf': allOf?.map((schema) => schema.toMap()).toList(),
      'anyOf': anyOf?.map((schema) => schema.toMap()).toList(),
      'const': constValue,
      'contains': contains?.toMap(),
      'contentEncoding': contentEncoding,
      'contentMediaType': contentMediaType,
      'default': defaultValue,
      'definitions': definitions?.map(
        (key, value) => MapEntry(key, value.toMap()),
      ),
      'dependencies': dependencies,
      'else': elseSchema?.toMap(),
      'enum': enumValues,
      'examples': examples,
      'exclusiveMaximum': exclusiveMaximum,
      'exclusiveMinimum': exclusiveMinimum,
      'format': format,
      'if': ifSchema?.toMap(),
      'items': items,
      'maxItems': maxItems,
      'maxLength': maxLength,
      'maxProperties': maxProperties,
      'maximum': maximum,
      'minItems': minItems,
      'minLength': minLength,
      'minProperties': minProperties,
      'minimum': minimum,
      'multipleOf': multipleOf,
      'not': not?.toMap(),
      'oneOf': oneOf?.map((schema) => schema.toMap()).toList(),
      'pattern': pattern,
      'patternProperties': patternProperties?.map(
        (key, value) => MapEntry(key, value.toMap()),
      ),
      'properties': properties?.map(
        (key, value) => MapEntry(key, value.toMap()),
      ),
      'propertyNames': propertyNames?.toMap(),
      'readOnly': readOnly,
      'required': required,
      'then': thenSchema?.toMap(),
      'type': _convertTypeToJson(type),
      'uniqueItems': uniqueItems,
      'writeOnly': writeOnly,
    }..removeWhere((key, value) => value == null);
  }

  String toJson() {
    return json.encode(toMap());
  }

  /// Helper method to convert JsonType to its string representation for JSON serialization
  dynamic _convertTypeToJson(dynamic type) {
    if (type == null) {
      return null;
    }

    if (type is JsonType) {
      // Convert single JsonType to string
      switch (type) {
        case JsonType.string:
          return 'string';
        case JsonType.number:
          return 'number';
        case JsonType.integer:
          return 'integer';
        case JsonType.object:
          return 'object';
        case JsonType.array:
          return 'array';
        case JsonType.boolean:
          return 'boolean';
        case JsonType.nullValue:
          return 'null';
      }
    } else if (type is List) {
      // Convert List<JsonType> to List<String>
      return type.map((t) {
        if (t is JsonType) {
          return _convertTypeToJson(t);
        }
        return t;
      }).toList();
    }

    // Return as is if not a JsonType or List
    return type;
  }
}
