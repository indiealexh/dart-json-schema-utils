import 'package:json_schema_utils/json_schema_utils.dart';
import 'package:test/test.dart';

void main() {
  group('ObjectSchema', () {
    test('should create a basic object schema', () {
      final schema = ObjectSchema(
        title: 'Object Schema',
        description: 'A schema for testing objects',
        type: [JsonType.object],
        properties: {
          'name': StringSchema(
            type: [JsonType.string],
            description: 'The name property',
          ),
          'age': NumberSchema(
            type: [JsonType.integer],
            description: 'The age property',
            minimum: 0,
          ),
        },
        required: ['name'],
        maxProperties: 10,
        minProperties: 1,
      );

      expect(schema.title, equals('Object Schema'));
      expect(schema.properties?.length, equals(2));
      expect(schema.properties?['name'], isA<StringSchema>());
      expect(schema.properties?['age'], isA<NumberSchema>());
      expect(schema.required, equals(['name']));
      expect(schema.maxProperties, equals(10));
      expect(schema.minProperties, equals(1));
    });

    test('should convert to and from JSON', () {
      final schema = ObjectSchema(
        title: 'Object Schema',
        description: 'A schema for testing objects',
        type: [JsonType.object],
        properties: {
          'name': StringSchema(
            type: [JsonType.string],
            description: 'The name property',
          ),
          'age': NumberSchema(
            type: [JsonType.integer],
            description: 'The age property',
            minimum: 0,
          ),
        },
        required: ['name'],
        maxProperties: 10,
        minProperties: 1,
      );

      final json = schema.toJson();
      expect(json['title'], equals('Object Schema'));
      expect(json['type'], equals('object'));
      expect(json['properties'], isA<Map>());
      expect(json['properties']['name'], isA<Map>());
      expect(json['properties']['age'], isA<Map>());
      expect(json['required'], equals(['name']));
      expect(json['maxProperties'], equals(10));
      expect(json['minProperties'], equals(1));

      final parsedSchema = JsonSchema.fromJson(json);
      expect(parsedSchema, isA<ObjectSchema>());
      expect(parsedSchema.title, equals('Object Schema'));

      final objectSchema = parsedSchema as ObjectSchema;
      expect(objectSchema.properties?.length, equals(2));
      expect(objectSchema.properties?['name'], isA<StringSchema>());
      expect(objectSchema.properties?['age'], isA<NumberSchema>());
      expect(objectSchema.required, equals(['name']));
      expect(objectSchema.maxProperties, equals(10));
      expect(objectSchema.minProperties, equals(1));
    });

    test('should handle additionalProperties', () {
      final schema = ObjectSchema(
        type: [JsonType.object],
        properties: {
          'name': StringSchema(type: [JsonType.string]),
        },
        additionalProperties: JsonSchema(type: [JsonType.string]),
      );

      expect(schema.additionalProperties, isNotNull);
      expect(schema.additionalProperties?.type, equals([JsonType.string]));

      final json = schema.toJson();
      expect(json['additionalProperties'], isA<Map>());
      expect(json['additionalProperties']['type'], equals('string'));

      final parsedSchema = JsonSchema.fromJson(json) as ObjectSchema;
      expect(parsedSchema.additionalProperties, isNotNull);
      expect(
        parsedSchema.additionalProperties?.type,
        equals([JsonType.string]),
      );
    });

    test('should handle patternProperties', () {
      final schema = ObjectSchema(
        type: [JsonType.object],
        patternProperties: {
          '^S_': StringSchema(type: [JsonType.string]),
          '^I_': NumberSchema(type: [JsonType.integer]),
        },
      );

      expect(schema.patternProperties, isNotNull);
      expect(schema.patternProperties?.length, equals(2));
      expect(schema.patternProperties?['^S_'], isA<StringSchema>());
      expect(schema.patternProperties?['^I_'], isA<NumberSchema>());

      final json = schema.toJson();
      expect(json['patternProperties'], isA<Map>());
      expect(json['patternProperties']['^S_'], isA<Map>());
      expect(json['patternProperties']['^I_'], isA<Map>());

      final parsedSchema = JsonSchema.fromJson(json) as ObjectSchema;
      expect(parsedSchema.patternProperties, isNotNull);
      expect(parsedSchema.patternProperties?.length, equals(2));
      expect(parsedSchema.patternProperties?['^S_'], isA<StringSchema>());
      expect(parsedSchema.patternProperties?['^I_'], isA<NumberSchema>());
    });

    test('should handle propertyNames', () {
      final schema = ObjectSchema(
        type: [JsonType.object],
        propertyNames: StringSchema(
          type: [JsonType.string],
          pattern: r'^[a-zA-Z_][a-zA-Z0-9_]*$',
        ),
      );

      expect(schema.propertyNames, isNotNull);
      expect(schema.propertyNames, isA<StringSchema>());
      expect(
        (schema.propertyNames as StringSchema).pattern,
        equals(r'^[a-zA-Z_][a-zA-Z0-9_]*$'),
      );

      final json = schema.toJson();
      expect(json['propertyNames'], isA<Map>());
      expect(
        json['propertyNames']['pattern'],
        equals(r'^[a-zA-Z_][a-zA-Z0-9_]*$'),
      );

      final parsedSchema = JsonSchema.fromJson(json) as ObjectSchema;
      expect(parsedSchema.propertyNames, isNotNull);
      expect(parsedSchema.propertyNames, isA<StringSchema>());
      expect(
        (parsedSchema.propertyNames as StringSchema).pattern,
        equals(r'^[a-zA-Z_][a-zA-Z0-9_]*$'),
      );
    });
  });
}
