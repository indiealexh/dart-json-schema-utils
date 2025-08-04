import 'package:json_schema_utils/json_schema_utils.dart';
import 'package:json_schema_utils/src/json_schema_validator.dart';
import 'package:test/test.dart';

void main() {
  group('JsonSchemaValidator', () {
    test('validates a valid basic schema', () {
      // This should not throw an exception
      final schema = JsonSchema(
        title: 'Test Schema',
        description: 'A schema for testing',
        type: [JsonType.object],
      );

      expect(schema, isA<JsonSchema>());
    });

    test('validates a valid object schema', () {
      // This should not throw an exception
      final schema = ObjectSchema(
        title: 'Test Object Schema',
        description: 'A schema for testing objects',
        type: [JsonType.object],
        required: ['name', 'age'],
        properties: {
          'name': StringSchema(type: [JsonType.string], minLength: 1),
          'age': NumberSchema(type: [JsonType.integer], minimum: 0),
        },
        minProperties: 1,
        maxProperties: 10,
      );

      expect(schema, isA<ObjectSchema>());
    });

    test('validates a valid array schema', () {
      // This should not throw an exception
      final schema = ArraySchema(
        title: 'Test Array Schema',
        description: 'A schema for testing arrays',
        type: [JsonType.array],
        items: StringSchema(type: [JsonType.string]),
        minItems: 1,
        maxItems: 10,
        uniqueItems: true,
      );

      expect(schema, isA<ArraySchema>());
    });

    test('validates a valid string schema', () {
      // This should not throw an exception
      final schema = StringSchema(
        title: 'Test String Schema',
        description: 'A schema for testing strings',
        type: [JsonType.string],
        minLength: 1,
        maxLength: 100,
        pattern: r'^[a-zA-Z0-9]+$',
        format: StringFormat.email,
      );

      expect(schema, isA<StringSchema>());
    });

    test('validates a valid number schema', () {
      // This should not throw an exception
      final schema = NumberSchema(
        title: 'Test Number Schema',
        description: 'A schema for testing numbers',
        type: [JsonType.number],
        minimum: 0,
        maximum: 100,
        multipleOf: 0.5,
      );

      expect(schema, isA<NumberSchema>());
    });

    test('throws exception for invalid schema with duplicate type', () {
      expect(
        () => JsonSchema(type: [JsonType.string, JsonType.string]),
        throwsA(isA<JsonSchemaValidationException>()),
      );
    });

    test('throws exception for invalid schema with empty enum', () {
      expect(
        () => JsonSchema(enumValues: []),
        throwsA(isA<JsonSchemaValidationException>()),
      );
    });

    test('throws exception for invalid schema with duplicate enum values', () {
      expect(
        () => JsonSchema(enumValues: ['a', 'b', 'a']),
        throwsA(isA<JsonSchemaValidationException>()),
      );
    });

    test('throws exception for invalid schema with empty allOf', () {
      expect(
        () => JsonSchema(allOf: []),
        throwsA(isA<JsonSchemaValidationException>()),
      );
    });

    test('throws exception for invalid schema with empty anyOf', () {
      expect(
        () => JsonSchema(anyOf: []),
        throwsA(isA<JsonSchemaValidationException>()),
      );
    });

    test('throws exception for invalid schema with empty oneOf', () {
      expect(
        () => JsonSchema(oneOf: []),
        throwsA(isA<JsonSchemaValidationException>()),
      );
    });

    test(
      'throws exception for invalid schema with thenSchema but no ifSchema',
      () {
        expect(
          () => JsonSchema(thenSchema: JsonSchema()),
          throwsA(isA<JsonSchemaValidationException>()),
        );
      },
    );

    test(
      'throws exception for invalid schema with elseSchema but no ifSchema',
      () {
        expect(
          () => JsonSchema(elseSchema: JsonSchema()),
          throwsA(isA<JsonSchemaValidationException>()),
        );
      },
    );

    test(
      'throws exception for invalid object schema with negative maxProperties',
      () {
        expect(
          () => ObjectSchema(maxProperties: -1),
          throwsA(isA<JsonSchemaValidationException>()),
        );
      },
    );

    test(
      'throws exception for invalid object schema with negative minProperties',
      () {
        expect(
          () => ObjectSchema(minProperties: -1),
          throwsA(isA<JsonSchemaValidationException>()),
        );
      },
    );

    test(
      'throws exception for invalid object schema with maxProperties < minProperties',
      () {
        expect(
          () => ObjectSchema(minProperties: 10, maxProperties: 5),
          throwsA(isA<JsonSchemaValidationException>()),
        );
      },
    );

    test(
      'throws exception for invalid object schema with duplicate required properties',
      () {
        expect(
          () => ObjectSchema(required: ['name', 'age', 'name']),
          throwsA(isA<JsonSchemaValidationException>()),
        );
      },
    );

    test(
      'throws exception for invalid object schema with invalid pattern in patternProperties',
      () {
        expect(
          () => ObjectSchema(
            patternProperties: {
              '[': JsonSchema(), // Invalid regex pattern
            },
          ),
          throwsA(isA<JsonSchemaValidationException>()),
        );
      },
    );

    test(
      'throws exception for invalid array schema with negative maxItems',
      () {
        expect(
          () => ArraySchema(maxItems: -1),
          throwsA(isA<JsonSchemaValidationException>()),
        );
      },
    );

    test(
      'throws exception for invalid array schema with negative minItems',
      () {
        expect(
          () => ArraySchema(minItems: -1),
          throwsA(isA<JsonSchemaValidationException>()),
        );
      },
    );

    test(
      'throws exception for invalid array schema with maxItems < minItems',
      () {
        expect(
          () => ArraySchema(minItems: 10, maxItems: 5),
          throwsA(isA<JsonSchemaValidationException>()),
        );
      },
    );

    test(
      'throws exception for invalid string schema with negative maxLength',
      () {
        expect(
          () => StringSchema(maxLength: -1),
          throwsA(isA<JsonSchemaValidationException>()),
        );
      },
    );

    test(
      'throws exception for invalid string schema with negative minLength',
      () {
        expect(
          () => StringSchema(minLength: -1),
          throwsA(isA<JsonSchemaValidationException>()),
        );
      },
    );

    test(
      'throws exception for invalid string schema with maxLength < minLength',
      () {
        expect(
          () => StringSchema(minLength: 10, maxLength: 5),
          throwsA(isA<JsonSchemaValidationException>()),
        );
      },
    );

    test('throws exception for invalid string schema with invalid pattern', () {
      expect(
        () => StringSchema(
          pattern: '[', // Invalid regex pattern
        ),
        throwsA(isA<JsonSchemaValidationException>()),
      );
    });

    test(
      'throws exception for invalid string schema with invalid contentEncoding',
      () {
        expect(
          () => StringSchema(contentEncoding: 'invalid-encoding'),
          throwsA(isA<JsonSchemaValidationException>()),
        );
      },
    );

    test(
      'throws exception for invalid string schema with invalid contentMediaType',
      () {
        expect(
          () => StringSchema(contentMediaType: 'invalid-media-type'),
          throwsA(isA<JsonSchemaValidationException>()),
        );
      },
    );

    test(
      'throws exception for invalid number schema with non-positive multipleOf',
      () {
        expect(
          () => NumberSchema(multipleOf: 0),
          throwsA(isA<JsonSchemaValidationException>()),
        );
      },
    );

    test(
      'throws exception for invalid number schema with maximum < minimum',
      () {
        expect(
          () => NumberSchema(minimum: 10, maximum: 5),
          throwsA(isA<JsonSchemaValidationException>()),
        );
      },
    );

    test(
      'throws exception for invalid number schema with exclusiveMaximum <= exclusiveMinimum',
      () {
        expect(
          () => NumberSchema(exclusiveMinimum: 10, exclusiveMaximum: 10),
          throwsA(isA<JsonSchemaValidationException>()),
        );
      },
    );

    test('validates a complex schema with nested schemas', () {
      // This should not throw an exception
      final schema = ObjectSchema(
        title: 'Complex Schema',
        description: 'A complex schema for testing',
        type: [JsonType.object],
        required: ['name', 'tags', 'settings'],
        properties: {
          'name': StringSchema(type: [JsonType.string], minLength: 1),
          'tags': ArraySchema(
            type: [JsonType.array],
            items: StringSchema(type: [JsonType.string]),
            uniqueItems: true,
          ),
          'settings': ObjectSchema(
            type: [JsonType.object],
            properties: {
              'enabled': JsonSchema(type: [JsonType.boolean]),
              'limit': NumberSchema(type: [JsonType.integer], minimum: 0),
            },
          ),
        },
        additionalProperties: JsonSchema(type: [JsonType.string]),
        patternProperties: {r'^x-': JsonSchema()},
        dependencies: {
          'tags': ['name'],
          'settings': ObjectSchema(required: ['name']),
        },
        propertyNames: StringSchema(pattern: r'^[a-zA-Z0-9_-]+$'),
      );

      expect(schema, isA<ObjectSchema>());
    });
  });
}
