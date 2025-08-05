import 'package:json_schema_utils/json_schema_utils.dart';
import 'package:test/test.dart';

void main() {
  group('Conditional Validation', () {
    test('should handle if-then condition', () {
      final schema = JsonSchema(
        title: 'If-Then Schema',
        ifSchema: ObjectSchema(
          type: [JsonType.object],
          properties: {
            'type': StringSchema(type: [JsonType.string], enumValues: ['user']),
          },
          required: ['type'],
        ),
        thenSchema: ObjectSchema(
          type: [JsonType.object],
          properties: {
            'name': StringSchema(type: [JsonType.string]),
            'email': StringSchema(
              type: [JsonType.string],
              format: StringFormat.email,
            ),
          },
          required: ['name', 'email'],
        ),
      );

      expect(schema.title, equals('If-Then Schema'));
      expect(schema.ifSchema, isNotNull);
      expect(schema.thenSchema, isNotNull);
      expect(schema.elseSchema, isNull);

      expect(schema.ifSchema, isA<ObjectSchema>());
      expect(schema.thenSchema, isA<ObjectSchema>());

      expect((schema.ifSchema as ObjectSchema).required, equals(['type']));
      expect(
        (schema.thenSchema as ObjectSchema).required,
        equals(['name', 'email']),
      );

      final json = schema.toJson();
      expect(json['title'], equals('If-Then Schema'));
      expect(json['if'], isA<Map>());
      expect(json['then'], isA<Map>());
      expect(json.containsKey('else'), isFalse);

      expect(json['if']['type'], equals('object'));
      expect(json['if']['required'], equals(['type']));
      expect(json['then']['type'], equals('object'));
      expect(json['then']['required'], equals(['name', 'email']));

      final parsedSchema = JsonSchema.fromJson(json);
      expect(parsedSchema.title, equals('If-Then Schema'));
      expect(parsedSchema.ifSchema, isNotNull);
      expect(parsedSchema.thenSchema, isNotNull);
      expect(parsedSchema.elseSchema, isNull);

      expect(parsedSchema.ifSchema, isA<ObjectSchema>());
      expect(parsedSchema.thenSchema, isA<ObjectSchema>());

      expect(
        (parsedSchema.ifSchema as ObjectSchema).required,
        equals(['type']),
      );
      expect(
        (parsedSchema.thenSchema as ObjectSchema).required,
        equals(['name', 'email']),
      );
    });

    test('should handle if-else condition', () {
      final schema = JsonSchema(
        title: 'If-Else Schema',
        ifSchema: ObjectSchema(
          type: [JsonType.object],
          properties: {
            'type': StringSchema(
              type: [JsonType.string],
              enumValues: ['admin'],
            ),
          },
          required: ['type'],
        ),
        elseSchema: ObjectSchema(
          type: [JsonType.object],
          properties: {
            'access': StringSchema(
              type: [JsonType.string],
              enumValues: ['read', 'write'],
            ),
          },
          required: ['access'],
        ),
      );

      expect(schema.title, equals('If-Else Schema'));
      expect(schema.ifSchema, isNotNull);
      expect(schema.thenSchema, isNull);
      expect(schema.elseSchema, isNotNull);

      expect(schema.ifSchema, isA<ObjectSchema>());
      expect(schema.elseSchema, isA<ObjectSchema>());

      expect((schema.ifSchema as ObjectSchema).required, equals(['type']));
      expect((schema.elseSchema as ObjectSchema).required, equals(['access']));

      final json = schema.toJson();
      expect(json['title'], equals('If-Else Schema'));
      expect(json['if'], isA<Map>());
      expect(json.containsKey('then'), isFalse);
      expect(json['else'], isA<Map>());

      expect(json['if']['type'], equals('object'));
      expect(json['if']['required'], equals(['type']));
      expect(json['else']['type'], equals('object'));
      expect(json['else']['required'], equals(['access']));

      final parsedSchema = JsonSchema.fromJson(json);
      expect(parsedSchema.title, equals('If-Else Schema'));
      expect(parsedSchema.ifSchema, isNotNull);
      expect(parsedSchema.thenSchema, isNull);
      expect(parsedSchema.elseSchema, isNotNull);

      expect(parsedSchema.ifSchema, isA<ObjectSchema>());
      expect(parsedSchema.elseSchema, isA<ObjectSchema>());

      expect(
        (parsedSchema.ifSchema as ObjectSchema).required,
        equals(['type']),
      );
      expect(
        (parsedSchema.elseSchema as ObjectSchema).required,
        equals(['access']),
      );
    });

    test('should handle if-then-else condition', () {
      final schema = JsonSchema(
        title: 'If-Then-Else Schema',
        ifSchema: ObjectSchema(
          type: [JsonType.object],
          properties: {
            'role': StringSchema(
              type: [JsonType.string],
              enumValues: ['admin'],
            ),
          },
          required: ['role'],
        ),
        thenSchema: ObjectSchema(
          type: [JsonType.object],
          properties: {
            'permissions': ArraySchema(
              type: [JsonType.array],
              items: StringSchema(
                type: [JsonType.string],
                enumValues: ['read', 'write', 'delete'],
              ),
              minItems: 1,
            ),
          },
          required: ['permissions'],
        ),
        elseSchema: ObjectSchema(
          type: [JsonType.object],
          properties: {
            'permissions': ArraySchema(
              type: [JsonType.array],
              items: StringSchema(
                type: [JsonType.string],
                enumValues: ['read'],
              ),
              maxItems: 1,
            ),
          },
          required: ['permissions'],
        ),
      );

      expect(schema.title, equals('If-Then-Else Schema'));
      expect(schema.ifSchema, isNotNull);
      expect(schema.thenSchema, isNotNull);
      expect(schema.elseSchema, isNotNull);

      expect(schema.ifSchema, isA<ObjectSchema>());
      expect(schema.thenSchema, isA<ObjectSchema>());
      expect(schema.elseSchema, isA<ObjectSchema>());

      expect((schema.ifSchema as ObjectSchema).required, equals(['role']));
      expect(
        (schema.thenSchema as ObjectSchema).required,
        equals(['permissions']),
      );
      expect(
        (schema.elseSchema as ObjectSchema).required,
        equals(['permissions']),
      );

      final json = schema.toJson();
      expect(json['title'], equals('If-Then-Else Schema'));
      expect(json['if'], isA<Map>());
      expect(json['then'], isA<Map>());
      expect(json['else'], isA<Map>());

      expect(json['if']['type'], equals('object'));
      expect(json['if']['required'], equals(['role']));
      expect(json['then']['type'], equals('object'));
      expect(json['then']['required'], equals(['permissions']));
      expect(json['else']['type'], equals('object'));
      expect(json['else']['required'], equals(['permissions']));

      final parsedSchema = JsonSchema.fromJson(json);
      expect(parsedSchema.title, equals('If-Then-Else Schema'));
      expect(parsedSchema.ifSchema, isNotNull);
      expect(parsedSchema.thenSchema, isNotNull);
      expect(parsedSchema.elseSchema, isNotNull);

      expect(parsedSchema.ifSchema, isA<ObjectSchema>());
      expect(parsedSchema.thenSchema, isA<ObjectSchema>());
      expect(parsedSchema.elseSchema, isA<ObjectSchema>());

      expect(
        (parsedSchema.ifSchema as ObjectSchema).required,
        equals(['role']),
      );
      expect(
        (parsedSchema.thenSchema as ObjectSchema).required,
        equals(['permissions']),
      );
      expect(
        (parsedSchema.elseSchema as ObjectSchema).required,
        equals(['permissions']),
      );
    });

    test('should handle nested conditional validation', () {
      final schema = JsonSchema(
        title: 'Nested Conditional Validation',
        ifSchema: ObjectSchema(
          type: [JsonType.object],
          properties: {
            'type': StringSchema(type: [JsonType.string], enumValues: ['user']),
          },
          required: ['type'],
        ),
        thenSchema: JsonSchema(
          ifSchema: ObjectSchema(
            type: [JsonType.object],
            properties: {
              'status': StringSchema(
                type: [JsonType.string],
                enumValues: ['active'],
              ),
            },
            required: ['status'],
          ),
          thenSchema: ObjectSchema(
            type: [JsonType.object],
            properties: {
              'access': StringSchema(
                type: [JsonType.string],
                enumValues: ['full'],
              ),
            },
            required: ['access'],
          ),
        ),
      );

      expect(schema.title, equals('Nested Conditional Validation'));
      expect(schema.ifSchema, isNotNull);
      expect(schema.thenSchema, isNotNull);
      expect(schema.thenSchema?.ifSchema, isNotNull);
      expect(schema.thenSchema?.thenSchema, isNotNull);

      final json = schema.toJson();
      expect(json['title'], equals('Nested Conditional Validation'));
      expect(json['if'], isA<Map>());
      expect(json['then'], isA<Map>());
      expect(json['then']['if'], isA<Map>());
      expect(json['then']['then'], isA<Map>());

      final parsedSchema = JsonSchema.fromJson(json);
      expect(parsedSchema.title, equals('Nested Conditional Validation'));
      expect(parsedSchema.ifSchema, isNotNull);
      expect(parsedSchema.thenSchema, isNotNull);
      expect(parsedSchema.thenSchema?.ifSchema, isNotNull);
      expect(parsedSchema.thenSchema?.thenSchema, isNotNull);
    });
  });
}
