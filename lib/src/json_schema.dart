import 'json_schema_validator.dart';
import 'json_type_enum.dart';
import 'string_format_enum.dart';

/// A base class representing a JSON Schema.
///
/// This class contains keywords that can be applied to any instance type.
class JsonSchema {
  /// From `$schema`: The URI identifying the dialect of the schema.
  final Uri? schemaVersion;

  /// From `$id`: A URI for the schema, used for identification and resolution.
  final Uri? id;

  /// From `title`: A short, descriptive title for the schema.
  final String? title;

  /// From `description`: A more detailed explanation of the schema's purpose.
  final String? description;

  /// From `$ref`: A URI reference to another schema.
  final Uri? ref;

  /// From `$comment`: A comment for schema authors. Ignored by validators.
  final String? comment;

  /// From `type`: The required primitive type(s) for the instance.
  final List<JsonType>? type;

  /// From `enum`: A fixed set of allowed values for the instance.
  final List<dynamic>? enumValues;

  /// From `const`: The exact value the instance must have.
  final dynamic constValue;

  /// From `default`: A default value for the instance.
  final dynamic defaultValue;

  /// From `examples`: An array of example values that are valid against the schema.
  final List<dynamic>? examples;

  /// From `definitions`: A location for defining reusable subschemas.
  final Map<String, JsonSchema>? definitions;

  /// From `if`: If the instance validates against this schema...
  final JsonSchema? ifSchema;

  /// From `then`: ...it must also validate against this schema.
  final JsonSchema? thenSchema;

  /// From `else`: ...otherwise, it must validate against this schema.
  final JsonSchema? elseSchema;

  /// From `allOf`: The instance must be valid against all of these schemas.
  final List<JsonSchema>? allOf;

  /// From `anyOf`: The instance must be valid against at least one of these schemas.
  final List<JsonSchema>? anyOf;

  /// From `oneOf`: The instance must be valid against exactly one of these schemas.
  final List<JsonSchema>? oneOf;

  /// From `not`: The instance must NOT be valid against this schema.
  final JsonSchema? notSchema;

  /// From `readOnly`: Indicates that the instance value should not be modified.
  final bool? readOnly;

  /// From `writeOnly`: Indicates the value is for writing only and should not be returned.
  final bool? writeOnly;

  JsonSchema({
    this.schemaVersion,
    this.id,
    this.ref,
    this.comment,
    this.title,
    this.description,
    this.type,
    this.enumValues,
    this.constValue,
    this.defaultValue,
    this.examples,
    this.definitions,
    this.ifSchema,
    this.thenSchema,
    this.elseSchema,
    this.allOf,
    this.anyOf,
    this.oneOf,
    this.notSchema,
    this.readOnly,
    this.writeOnly,
  }) {
    _validateSchema();
  }

  /// Validates the schema and throws an exception if validation fails.
  /// This method should be called by subclass constructors after initialization.
  void _validateSchema() {
    final errors = JsonSchemaValidator.validate(this);
    if (errors.isNotEmpty) {
      throw JsonSchemaValidationException(errors);
    }
  }

  /// Creates a JsonSchema instance from a JSON map.
  /// This factory method will delegate to the correct subclass if specific keywords are found.
  factory JsonSchema.fromJson(Map<String, dynamic> json) {
    // Determine the type from the 'type' keyword or by inspecting other keywords.
    final typeValue = json['type'];
    JsonType? primaryType;
    if (typeValue is String) {
      primaryType = _parseJsonType(typeValue);
    } else if (typeValue is List && typeValue.isNotEmpty) {
      primaryType = _parseJsonType(typeValue.first);
    }

    // Heuristically determine type if not explicitly defined
    if (primaryType == null) {
      if (json.containsKey('properties') || json.containsKey('maxProperties')) {
        primaryType = JsonType.object;
      } else if (json.containsKey('items') || json.containsKey('maxItems')) {
        primaryType = JsonType.array;
      } else if (json.containsKey('maxLength') || json.containsKey('pattern')) {
        primaryType = JsonType.string;
      } else if (json.containsKey('multipleOf') ||
          json.containsKey('maximum')) {
        primaryType = JsonType.number;
      }
    }

    switch (primaryType) {
      case JsonType.object:
        return ObjectSchema.fromJson(json);
      case JsonType.array:
        return ArraySchema.fromJson(json);
      case JsonType.string:
        return StringSchema.fromJson(json);
      case JsonType.number:
      case JsonType.integer:
        return NumberSchema.fromJson(json);
      default:
        return JsonSchema._fromJson(json);
    }
  }

  /// Internal fromJson constructor used by the factory and subclasses.
  JsonSchema._fromJson(Map<String, dynamic> json)
    : schemaVersion = json.containsKey(r'$schema')
          ? Uri.parse(json[r'$schema'])
          : null,
      id = json.containsKey(r'$id') ? Uri.parse(json[r'$id']) : null,
      ref = json.containsKey(r'$ref') ? Uri.parse(json[r'$ref']) : null,
      comment = json[r'$comment'],
      title = json['title'],
      description = json['description'],
      type = json.containsKey('type')
          ? (json['type'] is List
                ? (json['type'] as List).map((t) => _parseJsonType(t)).toList()
                : [_parseJsonType(json['type'])])
          : null,
      enumValues = json['enum'],
      constValue = json['const'],
      defaultValue = json['default'],
      examples = json['examples'],
      definitions = json.containsKey('definitions')
          ? (json['definitions'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(
                key,
                value is bool
                    ? BooleanSchema(value)
                    : JsonSchema.fromJson(value),
              ),
            )
          : null,
      ifSchema = json.containsKey('if')
          ? (json['if'] is bool
                ? BooleanSchema(json['if'] as bool)
                : JsonSchema.fromJson(json['if']))
          : null,
      thenSchema = json.containsKey('then')
          ? (json['then'] is bool
                ? BooleanSchema(json['then'] as bool)
                : JsonSchema.fromJson(json['then']))
          : null,
      elseSchema = json.containsKey('else')
          ? (json['else'] is bool
                ? BooleanSchema(json['else'] as bool)
                : JsonSchema.fromJson(json['else']))
          : null,
      allOf = json.containsKey('allOf')
          ? (json['allOf'] as List)
                .map(
                  (s) => s is bool ? BooleanSchema(s) : JsonSchema.fromJson(s),
                )
                .toList()
          : null,
      anyOf = json.containsKey('anyOf')
          ? (json['anyOf'] as List)
                .map(
                  (s) => s is bool ? BooleanSchema(s) : JsonSchema.fromJson(s),
                )
                .toList()
          : null,
      oneOf = json.containsKey('oneOf')
          ? (json['oneOf'] as List)
                .map(
                  (s) => s is bool ? BooleanSchema(s) : JsonSchema.fromJson(s),
                )
                .toList()
          : null,
      notSchema = json.containsKey('not')
          ? (json['not'] is bool
                ? BooleanSchema(json['not'] as bool)
                : JsonSchema.fromJson(json['not']))
          : null,
      readOnly = json['readOnly'],
      writeOnly = json['writeOnly'];

  static JsonType _parseJsonType(String typeString) {
    return JsonType.byTypeValue(typeString);
  }

  static String _jsonTypeToString(JsonType jsonType) {
    return jsonType.typeValue;
  }

  /// Converts this JsonSchema instance to a JSON map.
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (schemaVersion != null) json[r'$schema'] = schemaVersion.toString();
    if (id != null) json[r'$id'] = id.toString();
    if (ref != null) json[r'$ref'] = ref.toString();
    if (comment != null) json[r'$comment'] = comment;
    if (title != null) json['title'] = title;
    if (description != null) json['description'] = description;
    if (type != null) {
      if (type!.length == 1) {
        json['type'] = _jsonTypeToString(type!.first);
      } else {
        json['type'] = type!.map(_jsonTypeToString).toList();
      }
    }
    if (enumValues != null) json['enum'] = enumValues;
    if (constValue != null) json['const'] = constValue;
    if (defaultValue != null) json['default'] = defaultValue;
    if (examples != null) json['examples'] = examples;
    if (definitions != null) {
      json['definitions'] = definitions!.map(
        (key, value) => MapEntry(
          key,
          value is BooleanSchema
              ? (value).value
              : value.toJson(),
        ),
      );
    }
    if (ifSchema != null) {
      json['if'] = ifSchema is BooleanSchema
          ? (ifSchema as BooleanSchema).value
          : ifSchema!.toJson();
    }
    if (thenSchema != null) {
      json['then'] = thenSchema is BooleanSchema
          ? (thenSchema as BooleanSchema).value
          : thenSchema!.toJson();
    }
    if (elseSchema != null) {
      json['else'] = elseSchema is BooleanSchema
          ? (elseSchema as BooleanSchema).value
          : elseSchema!.toJson();
    }
    if (allOf != null) {
      json['allOf'] = allOf!
          .map((s) => s is BooleanSchema ? (s).value : s.toJson())
          .toList();
    }
    if (anyOf != null) {
      json['anyOf'] = anyOf!
          .map(
            (s) => s is BooleanSchema ? (s).value : s.toJson(),
          )
          .toList();
    }
    if (oneOf != null) {
      json['oneOf'] = oneOf!
          .map(
            (s) => s is BooleanSchema ? (s).value : s.toJson(),
          )
          .toList();
    }
    if (notSchema != null) {
      json['not'] = notSchema is BooleanSchema
          ? (notSchema as BooleanSchema).value
          : notSchema!.toJson();
    }
    if (readOnly != null) json['readOnly'] = readOnly;
    if (writeOnly != null) json['writeOnly'] = writeOnly;
    return json;
  }
}

/// A lightweight schema representing a boolean JSON Schema form (true/false).
class BooleanSchema extends JsonSchema {
  final bool value;
  BooleanSchema(this.value);
}

/// Represents a JSON Schema for an `object` type.
class ObjectSchema extends JsonSchema {
  /// From `maxProperties`: The maximum number of properties allowed.
  final int? maxProperties;

  /// From `minProperties`: The minimum number of properties required.
  final int? minProperties;

  /// From `required`: A list of property names that must be present.
  final List<String>? required;

  /// From `properties`: Schemas for specific properties.
  final Map<String, JsonSchema>? properties;

  /// From `patternProperties`: Schemas for properties matching a regex pattern.
  final Map<String, JsonSchema>? patternProperties;

  /// From `additionalProperties`: Schema for properties not covered by `properties` or `patternProperties`.
  /// Can be a JsonSchema or a boolean (true/false) per JSON Schema spec.
  final dynamic additionalProperties; // bool | JsonSchema

  /// From `dependencies`: Property-based dependencies.
  final Map<String, dynamic>?
  dependencies; // Map<String, List<String> | bool | JsonSchema>

  /// From `propertyNames`: A schema that all property names must validate against.
  /// Can be a JsonSchema or a boolean.
  final dynamic propertyNames; // bool | JsonSchema

  ObjectSchema({
    super.schemaVersion,
    super.id,
    super.ref,
    super.comment,
    super.title,
    super.description,
    super.type,
    super.enumValues,
    super.constValue,
    super.defaultValue,
    super.examples,
    super.definitions,
    super.ifSchema,
    super.thenSchema,
    super.elseSchema,
    super.allOf,
    super.anyOf,
    super.oneOf,
    super.notSchema,
    super.readOnly,
    super.writeOnly,
    this.maxProperties,
    this.minProperties,
    this.required,
    this.properties,
    this.patternProperties,
    this.additionalProperties,
    this.dependencies,
    this.propertyNames,
  }) {
    _validateSchema();
  }

  /// Creates an ObjectSchema from a JSON map.
  factory ObjectSchema.fromJson(Map<String, dynamic> json) {
    return ObjectSchema._fromJson(json);
  }

  ObjectSchema._fromJson(super.json)
    : maxProperties = json['maxProperties'],
      minProperties = json['minProperties'],
      required = json.containsKey('required')
          ? List<String>.from(json['required'])
          : null,
      properties = json.containsKey('properties')
          ? (json['properties'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(key, JsonSchema.fromJson(value)),
            )
          : null,
      patternProperties = json.containsKey('patternProperties')
          ? (json['patternProperties'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(key, JsonSchema.fromJson(value)),
            )
          : null,
      additionalProperties = json.containsKey('additionalProperties')
          ? (json['additionalProperties'] is bool
                ? json['additionalProperties']
                : JsonSchema.fromJson(json['additionalProperties']))
          : null,
      dependencies = json.containsKey('dependencies')
          ? (json['dependencies'] as Map<String, dynamic>).map((key, value) {
              if (value is Map<String, dynamic>) {
                return MapEntry(key, JsonSchema.fromJson(value));
              }
              if (value is bool) {
                return MapEntry(key, value);
              }
              return MapEntry(key, List<String>.from(value));
            })
          : null,
      propertyNames = json.containsKey('propertyNames')
          ? (json['propertyNames'] is bool
                ? json['propertyNames']
                : JsonSchema.fromJson(json['propertyNames']))
          : null,
      super._fromJson();

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    if (maxProperties != null) json['maxProperties'] = maxProperties;
    if (minProperties != null) json['minProperties'] = minProperties;
    if (required != null) json['required'] = required;
    if (properties != null) {
      json['properties'] = properties!.map(
        (key, value) => MapEntry(key, value.toJson()),
      );
    }
    if (patternProperties != null) {
      json['patternProperties'] = patternProperties!.map(
        (key, value) => MapEntry(key, value.toJson()),
      );
    }
    if (additionalProperties != null) {
      json['additionalProperties'] = additionalProperties is bool
          ? additionalProperties
          : (additionalProperties as JsonSchema).toJson();
    }
    if (dependencies != null) {
      json['dependencies'] = dependencies!.map((key, value) {
        if (value is JsonSchema) {
          return MapEntry(key, value.toJson());
        }
        return MapEntry(key, value);
      });
    }
    if (propertyNames != null) {
      json['propertyNames'] = propertyNames is bool
          ? propertyNames
          : (propertyNames as JsonSchema).toJson();
    }
    return json;
  }
}

/// Represents a JSON Schema for an `array` type.
class ArraySchema extends JsonSchema {
  /// From `items`: Schema for array items. Can be a single schema or a list of schemas.
  final dynamic items; // JsonSchema or List<JsonSchema>

  /// From `additionalItems`: Schema for extra items when `items` is a list.
  /// Can be a JsonSchema or a boolean.
  final dynamic additionalItems; // bool | JsonSchema

  /// From `maxItems`: The maximum number of items in the array.
  final int? maxItems;

  /// From `minItems`: The minimum number of items in the array.
  final int? minItems;

  /// From `uniqueItems`: If true, all items in the array must be unique.
  final bool? uniqueItems;

  /// From `contains`: At least one item in the array must be valid against this schema.
  /// Can be a JsonSchema or a boolean.
  final dynamic contains; // bool | JsonSchema

  ArraySchema({
    super.schemaVersion,
    super.id,
    super.ref,
    super.comment,
    super.title,
    super.description,
    super.type,
    super.enumValues,
    super.constValue,
    super.defaultValue,
    super.examples,
    super.definitions,
    super.ifSchema,
    super.thenSchema,
    super.elseSchema,
    super.allOf,
    super.anyOf,
    super.oneOf,
    super.notSchema,
    super.readOnly,
    super.writeOnly,
    this.items,
    this.additionalItems,
    this.maxItems,
    this.minItems,
    this.uniqueItems,
    this.contains,
  }) {
    _validateSchema();
  }

  /// Creates an ArraySchema from a JSON map.
  factory ArraySchema.fromJson(Map<String, dynamic> json) {
    return ArraySchema._fromJson(json);
  }

  ArraySchema._fromJson(super.json)
    : items = json.containsKey('items')
          ? (json['items'] is List
                ? (json['items'] as List)
                      .map((i) => JsonSchema.fromJson(i))
                      .toList()
                : JsonSchema.fromJson(json['items']))
          : null,
      additionalItems = json.containsKey('additionalItems')
          ? (json['additionalItems'] is bool
                ? json['additionalItems']
                : JsonSchema.fromJson(json['additionalItems']))
          : null,
      maxItems = json['maxItems'],
      minItems = json['minItems'],
      uniqueItems = json['uniqueItems'],
      contains = json.containsKey('contains')
          ? (json['contains'] is bool
                ? json['contains']
                : JsonSchema.fromJson(json['contains']))
          : null,
      super._fromJson();

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    if (items != null) {
      if (items is JsonSchema) {
        json['items'] = (items as JsonSchema).toJson();
      } else {
        json['items'] = (items as List<JsonSchema>)
            .map((s) => s.toJson())
            .toList();
      }
    }
    if (additionalItems != null) {
      json['additionalItems'] = additionalItems is bool
          ? additionalItems
          : (additionalItems as JsonSchema).toJson();
    }
    if (maxItems != null) json['maxItems'] = maxItems;
    if (minItems != null) json['minItems'] = minItems;
    if (uniqueItems != null) json['uniqueItems'] = uniqueItems;
    if (contains != null) {
      json['contains'] = contains is bool
          ? contains
          : (contains as JsonSchema).toJson();
    }
    return json;
  }
}

/// Represents a JSON Schema for a `string` type.
class StringSchema extends JsonSchema {
  /// From `maxLength`: The maximum length of the string.
  final int? maxLength;

  /// From `minLength`: The minimum length of the string.
  final int? minLength;

  /// From `pattern`: A regex pattern the string must match.
  final String? pattern;

  /// From `format`: The semantic format of the string (e.g., 'date-time', 'email').
  final StringFormat? format;

  /// From `contentEncoding`: The encoding of the string's content (e.g., 'base64').
  final String? contentEncoding;

  /// From `contentMediaType`: The media type of the string's content (e.g., 'image/png').
  final String? contentMediaType;

  StringSchema({
    super.schemaVersion,
    super.id,
    super.ref,
    super.comment,
    super.title,
    super.description,
    super.type,
    super.enumValues,
    super.constValue,
    super.defaultValue,
    super.examples,
    super.definitions,
    super.ifSchema,
    super.thenSchema,
    super.elseSchema,
    super.allOf,
    super.anyOf,
    super.oneOf,
    super.notSchema,
    super.readOnly,
    super.writeOnly,
    this.maxLength,
    this.minLength,
    this.pattern,
    this.format,
    this.contentEncoding,
    this.contentMediaType,
  }) {
    _validateSchema();
  }

  /// Creates a StringSchema from a JSON map.
  factory StringSchema.fromJson(Map<String, dynamic> json) {
    return StringSchema._fromJson(json);
  }

  StringSchema._fromJson(super.json)
    : maxLength = json['maxLength'],
      minLength = json['minLength'],
      pattern = json['pattern'],
      format = json.containsKey('format')
          ? StringFormat.byTypeValue(json['format'])
          : null,
      contentEncoding = json['contentEncoding'],
      contentMediaType = json['contentMediaType'],
      super._fromJson();

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    if (maxLength != null) json['maxLength'] = maxLength;
    if (minLength != null) json['minLength'] = minLength;
    if (pattern != null) json['pattern'] = pattern;
    if (format != null) {
      json['format'] = format!.formatValue.replaceAllMapped(
        RegExp(r'([A-Z])'),
        (match) => '-${match.group(1)!.toLowerCase()}',
      );
    }
    if (contentEncoding != null) json['contentEncoding'] = contentEncoding;
    if (contentMediaType != null) json['contentMediaType'] = contentMediaType;
    return json;
  }
}

/// Represents a JSON Schema for a `number` or `integer` type.
class NumberSchema extends JsonSchema {
  /// From `multipleOf`: The number must be a multiple of this value.
  final num? multipleOf;

  /// From `maximum`: The inclusive maximum value.
  final num? maximum;

  /// From `exclusiveMaximum`: The exclusive maximum value.
  final num? exclusiveMaximum;

  /// From `minimum`: The inclusive minimum value.
  final num? minimum;

  /// From `exclusiveMinimum`: The exclusive minimum value.
  final num? exclusiveMinimum;

  NumberSchema({
    super.schemaVersion,
    super.id,
    super.ref,
    super.comment,
    super.title,
    super.description,
    super.type,
    super.enumValues,
    super.constValue,
    super.defaultValue,
    super.examples,
    super.definitions,
    super.ifSchema,
    super.thenSchema,
    super.elseSchema,
    super.allOf,
    super.anyOf,
    super.oneOf,
    super.notSchema,
    super.readOnly,
    super.writeOnly,
    this.multipleOf,
    this.maximum,
    this.exclusiveMaximum,
    this.minimum,
    this.exclusiveMinimum,
  }) {
    _validateSchema();
  }

  /// Creates a NumberSchema from a JSON map.
  factory NumberSchema.fromJson(Map<String, dynamic> json) {
    return NumberSchema._fromJson(json);
  }

  NumberSchema._fromJson(super.json)
    : multipleOf = json['multipleOf'],
      maximum = json['maximum'],
      exclusiveMaximum = json['exclusiveMaximum'],
      minimum = json['minimum'],
      exclusiveMinimum = json['exclusiveMinimum'],
      super._fromJson();

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    if (multipleOf != null) json['multipleOf'] = multipleOf;
    if (maximum != null) json['maximum'] = maximum;
    if (exclusiveMaximum != null) json['exclusiveMaximum'] = exclusiveMaximum;
    if (minimum != null) json['minimum'] = minimum;
    if (exclusiveMinimum != null) json['exclusiveMinimum'] = exclusiveMinimum;
    return json;
  }
}
