import 'dart:convert';

import 'json_schema_base.dart';
import 'json_type.dart';

class JsonSchema extends JsonSchemaBase {
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
