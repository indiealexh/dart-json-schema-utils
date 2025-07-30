import 'dart:convert';

/// Represents an Opinionated JSON Schema Document (i.e. A Root Json Schema object)
///
/// This class requires $schema, $id, title and description to be set
class JsonSchemaDocument extends JsonSchema with JsonSchemaIdRequired {
  @override
  final String schema = "http://json-schema.org/draft-07/schema#";
  @override
  final String id;
  @override
  final String title;
  @override
  final String description;

  ///
  /// [FormatException] is thrown.
  factory JsonSchemaDocument(String id, String title, String description) {
    if (id.isEmpty) {
      throw "id is empty";
    }
    var _id = Uri.parse(id);
    if (title.isEmpty) {
      throw "Title is empty";
    }
    if (description.isEmpty) {
      throw "Description is empty";
    }

    return JsonSchemaDocument._internal(_id.toString(), title, description);
  }

  JsonSchemaDocument._internal(this.id, this.title, this.description);
}

// class JsonSchema extends JsonSchemaBase {
// }

mixin JsonSchemaIdRequired {
  String get schema;

  String get id;

  String get title;

  String get description;
}

// class JsonSchemaBase {
//   Uri? $ref;
//   String? $comment;
//   String? title;
//   String? description;
//   /*
//         "default": true,
//         "readOnly": {
//             "type": "boolean",
//             "default": false
//         },
//         "writeOnly": {
//             "type": "boolean",
//             "default": false
//         },
//         "examples": {
//             "type": "array",
//             "items": true
//         },
//         "multipleOf": {
//             "type": "number",
//             "exclusiveMinimum": 0
//         },
//         "maximum": {
//             "type": "number"
//         },
//         "exclusiveMaximum": {
//             "type": "number"
//         },
//         "minimum": {
//             "type": "number"
//         },
//         "exclusiveMinimum": {
//             "type": "number"
//         },
//         "maxLength": { "$ref": "#/definitions/nonNegativeInteger" },
//         "minLength": { "$ref": "#/definitions/nonNegativeIntegerDefault0" },
//         "pattern": {
//             "type": "string",
//             "format": "regex"
//         },
//         "additionalItems": { "$ref": "#" },
//         "items": {
//             "anyOf": [
//                 { "$ref": "#" },
//                 { "$ref": "#/definitions/schemaArray" }
//             ],
//             "default": true
//         },
//         "maxItems": { "$ref": "#/definitions/nonNegativeInteger" },
//         "minItems": { "$ref": "#/definitions/nonNegativeIntegerDefault0" },
//         "uniqueItems": {
//             "type": "boolean",
//             "default": false
//         },
//         "contains": { "$ref": "#" },
//         "maxProperties": { "$ref": "#/definitions/nonNegativeInteger" },
//         "minProperties": { "$ref": "#/definitions/nonNegativeIntegerDefault0" },
//         "required": { "$ref": "#/definitions/stringArray" },
//         "additionalProperties": { "$ref": "#" },
//         "definitions": {
//             "type": "object",
//             "additionalProperties": { "$ref": "#" },
//             "default": {}
//         },
//         "properties": {
//             "type": "object",
//             "additionalProperties": { "$ref": "#" },
//             "default": {}
//         },
//         "patternProperties": {
//             "type": "object",
//             "additionalProperties": { "$ref": "#" },
//             "propertyNames": { "format": "regex" },
//             "default": {}
//         },
//         "dependencies": {
//             "type": "object",
//             "additionalProperties": {
//                 "anyOf": [
//                     { "$ref": "#" },
//                     { "$ref": "#/definitions/stringArray" }
//                 ]
//             }
//         },
//         "propertyNames": { "$ref": "#" },
//         "const": true,
//         "enum": {
//             "type": "array",
//             "items": true,
//             "minItems": 1,
//             "uniqueItems": true
//         },
//         "type": {
//             "anyOf": [
//                 { "$ref": "#/definitions/simpleTypes" },
//                 {
//                     "type": "array",
//                     "items": { "$ref": "#/definitions/simpleTypes" },
//                     "minItems": 1,
//                     "uniqueItems": true
//                 }
//             ]
//         },
//         "format": { "type": "string" },
//         "contentMediaType": { "type": "string" },
//         "contentEncoding": { "type": "string" },
//         "if": { "$ref": "#" },
//         "then": { "$ref": "#" },
//         "else": { "$ref": "#" },
//         "allOf": { "$ref": "#/definitions/schemaArray" },
//         "anyOf": { "$ref": "#/definitions/schemaArray" },
//         "oneOf": { "$ref": "#/definitions/schemaArray" },
//         "not": { "$ref": "#" }
//    */
// }

/// Represents the possible data types that a JSON schema can define.
/// See: https://json-schema.org/draft-07/draft-handrews-json-schema-01#section-6.1.1
enum JsonType {
  string,
  number,
  integer,
  object,
  array,
  boolean,

  /// Represents the JSON `null` type.
  nullValue,
}

abstract class JsonSchema extends JsonSchemaBase {
  String? _id;
  String? _schema;
  String? _ref;
  String? _comment;
  String? _title;
  String? _description;
  dynamic _defaultValue;
  List<dynamic>? _examples;
  bool? _readOnly;
  bool? _writeOnly;
  dynamic _type;
  List<dynamic>? _enumValues;
  dynamic _constValue;
  num? _multipleOf;
  num? _maximum;
  num? _exclusiveMaximum;
  num? _minimum;
  num? _exclusiveMinimum;
  int? _maxLength;
  int? _minLength;
  String? _pattern;
  dynamic _items;
  dynamic _additionalItems;
  int? _maxItems;
  int? _minItems;
  bool? _uniqueItems;
  JsonSchemaBase? _contains;
  int? _maxProperties;
  int? _minProperties;
  List<String>? _required;
  Map<String, JsonSchemaBase>? _properties;
  Map<String, JsonSchemaBase>? _patternProperties;
  dynamic _additionalProperties;
  Map<String, dynamic>? _dependencies;
  JsonSchemaBase? _propertyNames;
  Map<String, JsonSchemaBase>? _definitions;
  List<JsonSchemaBase>? _allOf;
  List<JsonSchemaBase>? _anyOf;
  List<JsonSchemaBase>? _oneOf;
  JsonSchemaBase? _not;
  JsonSchemaBase? _ifSchema;
  JsonSchemaBase? _thenSchema;
  JsonSchemaBase? _elseSchema;
  String? _format;
  String? _contentMediaType;
  String? _contentEncoding;

  @override
  String? get id => _id;

  set id(String? id) {
    if (id == null || id.isEmpty) {
      _id = null;
      return;
    }
    _id = Uri.parse(id).toString();
  }

  @override
  String? get comment => _comment;

  set comment(String? comment) {
    _comment = comment;
  }

  @override
  String? get title => _title;

  set title(String? title) {
    _title = title;
  }

  @override
  String? get description => _description;

  set description(String? description) {
    _description = description;
  }

  @override
  dynamic get defaultValue => _defaultValue;

  set defaultValue(dynamic value) {
    _validateDefaultValue(value);
    _defaultValue = value;
  }

  /// Validates that the default value matches the schema constraints.
  /// Throws a [FormatException] if the default value is invalid.
  void _validateDefaultValue(dynamic value) {
    if (value == null) {
      return; // null is always valid as a default value
    }

    // Check against const value first (most restrictive)
    if (_constValue != null) {
      bool isEqual = _deepEquals(value, _constValue);
      if (!isEqual) {
        throw FormatException('default value must be equal to const value');
      }
      return; // If it matches const, no need to check other constraints
    }

    // Check against enum values
    if (_enumValues != null) {
      bool foundMatch = false;
      for (var enumValue in _enumValues!) {
        if (_deepEquals(value, enumValue)) {
          foundMatch = true;
          break;
        }
      }
      if (!foundMatch) {
        throw FormatException('default value must be one of the enum values');
      }
      return; // If it's in enum, no need to check other constraints
    }

    // Check type constraints
    if (_type != null) {
      _validateTypeConstraint(value, _type);
    }

    // Type-specific validations
    if (value is num) {
      _validateNumericConstraints(value);
    } else if (value is String) {
      _validateStringConstraints(value);
    } else if (value is List) {
      _validateArrayConstraints(value);
    } else if (value is Map) {
      _validateObjectConstraints(value);
    }
  }

  /// Validates that the value matches the type constraint.
  void _validateTypeConstraint(dynamic value, dynamic typeConstraint) {
    if (typeConstraint is JsonType) {
      _validateSingleTypeConstraint(value, typeConstraint);
    } else if (typeConstraint is List) {
      bool validForAny = false;
      for (var type in typeConstraint) {
        try {
          _validateSingleTypeConstraint(value, type);
          validForAny = true;
          break;
        } catch (_) {
          // Continue checking other types
        }
      }
      if (!validForAny) {
        throw FormatException(
          'default value does not match any of the specified types',
        );
      }
    }
  }

  /// Validates that the value matches a single type constraint.
  void _validateSingleTypeConstraint(dynamic value, JsonType type) {
    switch (type) {
      case JsonType.string:
        if (value is! String) {
          throw FormatException('default value must be a string');
        }
        break;
      case JsonType.number:
        if (value is! num) {
          throw FormatException('default value must be a number');
        }
        break;
      case JsonType.integer:
        if (value is! int &&
            (value is! num || value.truncateToDouble() != value)) {
          throw FormatException('default value must be an integer');
        }
        break;
      case JsonType.object:
        if (value is! Map) {
          throw FormatException('default value must be an object');
        }
        break;
      case JsonType.array:
        if (value is! List) {
          throw FormatException('default value must be an array');
        }
        break;
      case JsonType.boolean:
        if (value is! bool) {
          throw FormatException('default value must be a boolean');
        }
        break;
      case JsonType.nullValue:
        if (value != null) {
          throw FormatException('default value must be null');
        }
        break;
    }
  }

  /// Validates numeric constraints for a number value.
  void _validateNumericConstraints(num value) {
    // Check minimum before maximum (logical order)
    if (_minimum != null) {
      if (value < _minimum!) {
        throw FormatException(
          'default value must be greater than or equal to minimum ($minimum)',
        );
      }
    }

    if (_exclusiveMinimum != null) {
      if (value <= _exclusiveMinimum!) {
        throw FormatException(
          'default value must be greater than exclusive minimum ($exclusiveMinimum)',
        );
      }
    }

    if (_maximum != null) {
      if (value > _maximum!) {
        throw FormatException(
          'default value must be less than or equal to maximum ($maximum)',
        );
      }
    }

    if (_exclusiveMaximum != null) {
      if (value >= _exclusiveMaximum!) {
        throw FormatException(
          'default value must be less than exclusive maximum ($exclusiveMaximum)',
        );
      }
    }

    if (_multipleOf != null) {
      // Check if value is a multiple of multipleOf
      if ((value / _multipleOf!).truncateToDouble() != value / _multipleOf!) {
        throw FormatException(
          'default value must be a multiple of $multipleOf',
        );
      }
    }
  }

  /// Validates string constraints for a string value.
  void _validateStringConstraints(String value) {
    // Check minLength before maxLength (logical order)
    if (_minLength != null) {
      if (value.length < _minLength!) {
        throw FormatException(
          'default value length must be at least $minLength',
        );
      }
    }

    if (_maxLength != null) {
      if (value.length > _maxLength!) {
        throw FormatException(
          'default value length must not exceed $maxLength',
        );
      }
    }

    if (_pattern != null) {
      RegExp regex = RegExp(_pattern!);
      if (!regex.hasMatch(value)) {
        throw FormatException(
          'default value must match the pattern: $_pattern',
        );
      }
    }
  }

  /// Validates array constraints for a list value.
  void _validateArrayConstraints(List value) {
    // Check minItems before maxItems (logical order)
    if (_minItems != null) {
      if (value.length < _minItems!) {
        throw FormatException(
          'default value array must have at least $_minItems items',
        );
      }
    }

    if (_maxItems != null) {
      if (value.length > _maxItems!) {
        throw FormatException(
          'default value array must not have more than $_maxItems items',
        );
      }
    }

    if (_uniqueItems == true) {
      // Check for duplicate items
      Set uniqueItems = {};
      for (var item in value) {
        String serialized = json.encode(item);
        if (uniqueItems.contains(serialized)) {
          throw FormatException('default value array must have unique items');
        }
        uniqueItems.add(serialized);
      }
    }

    // TODO: Add validation for items, additionalItems, and contains if needed
  }

  /// Validates object constraints for a map value.
  void _validateObjectConstraints(Map value) {
    // Check minProperties before maxProperties (logical order)
    if (_minProperties != null) {
      if (value.length < _minProperties!) {
        throw FormatException(
          'default value object must have at least $_minProperties properties',
        );
      }
    }

    if (_maxProperties != null) {
      if (value.length > _maxProperties!) {
        throw FormatException(
          'default value object must not have more than $_maxProperties properties',
        );
      }
    }

    if (_required != null) {
      for (var propName in _required!) {
        if (!value.containsKey(propName)) {
          throw FormatException(
            'default value object must have required property: $propName',
          );
        }
      }
    }

    // TODO: Add validation for properties, patternProperties, additionalProperties if needed
  }

  /// Deep equality check for JSON values.
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
        if (!b.containsKey(key) || !_deepEquals(a[key], b[key])) return false;
      }
      return true;
    } else {
      return a == b;
    }
  }

  @override
  List<dynamic>? get examples => _examples;

  set examples(List<dynamic>? examples) {
    _examples = examples;
  }

  @override
  bool? get readOnly => _readOnly;

  set readOnly(bool? value) {
    _readOnly = value;
  }

  @override
  bool? get writeOnly => _writeOnly;

  set writeOnly(bool? value) {
    _writeOnly = value;
  }

  @override
  dynamic get type => _type;

  set type(dynamic value) {
    _type = value;
  }

  @override
  List<dynamic>? get enumValues => _enumValues;

  set enumValues(List<dynamic>? values) {
    if (values != null && values.isEmpty) {
      throw FormatException('enum must have at least one value');
    }
    _enumValues = values;
  }

  @override
  dynamic get constValue => _constValue;

  set constValue(dynamic value) {
    _constValue = value;
  }

  @override
  num? get multipleOf => _multipleOf;

  set multipleOf(num? value) {
    if (value != null && value <= 0) {
      throw FormatException('multipleOf must be greater than 0');
    }
    _multipleOf = value;
  }

  @override
  num? get maximum => _maximum;

  set maximum(num? value) {
    _maximum = value;
  }

  @override
  num? get exclusiveMaximum => _exclusiveMaximum;

  set exclusiveMaximum(num? value) {
    _exclusiveMaximum = value;
  }

  @override
  num? get minimum => _minimum;

  set minimum(num? value) {
    _minimum = value;
  }

  @override
  num? get exclusiveMinimum => _exclusiveMinimum;

  set exclusiveMinimum(num? value) {
    _exclusiveMinimum = value;
  }

  @override
  String? get schema => _schema;

  set schema(String? value) {
    _schema = value;
  }

  @override
  String? get ref => _ref;

  set ref(String? value) {
    if (value == null || value.isEmpty) {
      _ref = null;
      return;
    }
    _ref = Uri.parse(value).toString();
  }

  @override
  int? get maxLength => _maxLength;

  set maxLength(int? value) {
    if (value != null && value < 0) {
      throw FormatException('maxLength must be a non-negative integer');
    }
    _maxLength = value;
  }

  @override
  int? get minLength => _minLength;

  set minLength(int? value) {
    if (value != null && value < 0) {
      throw FormatException('minLength must be a non-negative integer');
    }
    _minLength = value;
  }

  @override
  String? get pattern => _pattern;

  set pattern(String? value) {
    if (value != null) {
      try {
        RegExp(value);
      } catch (e) {
        throw FormatException('pattern must be a valid regular expression: $e');
      }
    }
    _pattern = value;
  }

  @override
  dynamic get items => _items;

  set items(dynamic value) {
    _items = value;
  }

  @override
  dynamic get additionalItems => _additionalItems;

  set additionalItems(dynamic value) {
    _additionalItems = value;
  }

  @override
  int? get maxItems => _maxItems;

  set maxItems(int? value) {
    if (value != null && value < 0) {
      throw FormatException('maxItems must be a non-negative integer');
    }
    _maxItems = value;
  }

  @override
  int? get minItems => _minItems;

  set minItems(int? value) {
    if (value != null && value < 0) {
      throw FormatException('minItems must be a non-negative integer');
    }
    _minItems = value;
  }

  @override
  bool? get uniqueItems => _uniqueItems;

  set uniqueItems(bool? value) {
    _uniqueItems = value;
  }

  @override
  JsonSchemaBase? get contains => _contains;

  set contains(JsonSchemaBase? value) {
    _contains = value;
  }

  @override
  int? get maxProperties => _maxProperties;

  set maxProperties(int? value) {
    if (value != null && value < 0) {
      throw FormatException('maxProperties must be a non-negative integer');
    }
    _maxProperties = value;
  }

  @override
  int? get minProperties => _minProperties;

  set minProperties(int? value) {
    if (value != null && value < 0) {
      throw FormatException('minProperties must be a non-negative integer');
    }
    _minProperties = value;
  }

  @override
  List<String>? get required => _required;

  set required(List<String>? value) {
    if (value != null && value.isEmpty) {
      throw FormatException('required must not be an empty array');
    }
    _required = value;
  }

  @override
  Map<String, JsonSchemaBase>? get properties => _properties;

  set properties(Map<String, JsonSchemaBase>? value) {
    _properties = value;
  }

  @override
  Map<String, JsonSchemaBase>? get patternProperties => _patternProperties;

  set patternProperties(Map<String, JsonSchemaBase>? value) {
    if (value != null) {
      // Validate that all keys are valid regex patterns
      for (final pattern in value.keys) {
        try {
          RegExp(pattern);
        } catch (e) {
          throw FormatException(
            'patternProperties key must be a valid regular expression: $e',
          );
        }
      }
    }
    _patternProperties = value;
  }

  @override
  dynamic get additionalProperties => _additionalProperties;

  set additionalProperties(dynamic value) {
    _additionalProperties = value;
  }

  @override
  Map<String, dynamic>? get dependencies => _dependencies;

  set dependencies(Map<String, dynamic>? value) {
    _dependencies = value;
  }

  @override
  JsonSchemaBase? get propertyNames => _propertyNames;

  set propertyNames(JsonSchemaBase? value) {
    _propertyNames = value;
  }

  @override
  Map<String, JsonSchemaBase>? get definitions => _definitions;

  set definitions(Map<String, JsonSchemaBase>? value) {
    _definitions = value;
  }

  @override
  List<JsonSchemaBase>? get allOf => _allOf;

  set allOf(List<JsonSchemaBase>? value) {
    if (value != null && value.isEmpty) {
      throw FormatException('allOf must not be an empty array');
    }
    _allOf = value;
  }

  @override
  List<JsonSchemaBase>? get anyOf => _anyOf;

  set anyOf(List<JsonSchemaBase>? value) {
    if (value != null && value.isEmpty) {
      throw FormatException('anyOf must not be an empty array');
    }
    _anyOf = value;
  }

  @override
  List<JsonSchemaBase>? get oneOf => _oneOf;

  set oneOf(List<JsonSchemaBase>? value) {
    if (value != null && value.isEmpty) {
      throw FormatException('oneOf must not be an empty array');
    }
    _oneOf = value;
  }

  @override
  JsonSchemaBase? get not => _not;

  set not(JsonSchemaBase? value) {
    _not = value;
  }

  @override
  JsonSchemaBase? get ifSchema => _ifSchema;

  set ifSchema(JsonSchemaBase? value) {
    _ifSchema = value;
  }

  @override
  JsonSchemaBase? get thenSchema => _thenSchema;

  set thenSchema(JsonSchemaBase? value) {
    _thenSchema = value;
  }

  @override
  JsonSchemaBase? get elseSchema => _elseSchema;

  set elseSchema(JsonSchemaBase? value) {
    _elseSchema = value;
  }

  @override
  String? get format => _format;

  set format(String? value) {
    _format = value;
  }

  @override
  String? get contentMediaType => _contentMediaType;

  set contentMediaType(String? value) {
    _contentMediaType = value;
  }

  @override
  String? get contentEncoding => _contentEncoding;

  set contentEncoding(String? value) {
    _contentEncoding = value;
  }
}

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
