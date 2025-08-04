import 'package:json_schema_utils/json_schema_utils.dart';
import 'package:test/test.dart';

void main() {
  group('NumberSchema', () {
    test('should create a basic number schema', () {
      final schema = NumberSchema(
        title: 'Number Schema',
        description: 'A schema for testing numbers',
        type: [JsonType.number],
        minimum: 0,
        maximum: 100,
        exclusiveMinimum: 0,
        exclusiveMaximum: 100,
        multipleOf: 5,
      );

      expect(schema.title, equals('Number Schema'));
      expect(schema.description, equals('A schema for testing numbers'));
      expect(schema.type, equals([JsonType.number]));
      expect(schema.minimum, equals(0));
      expect(schema.maximum, equals(100));
      expect(schema.exclusiveMinimum, equals(0));
      expect(schema.exclusiveMaximum, equals(100));
      expect(schema.multipleOf, equals(5));
    });

    test('should convert to and from JSON', () {
      final schema = NumberSchema(
        title: 'Number Schema',
        description: 'A schema for testing numbers',
        type: [JsonType.number],
        minimum: 0,
        maximum: 100,
        exclusiveMinimum: 0,
        exclusiveMaximum: 100,
        multipleOf: 5,
      );

      final json = schema.toJson();
      expect(json['title'], equals('Number Schema'));
      expect(json['description'], equals('A schema for testing numbers'));
      expect(json['type'], equals('number'));
      expect(json['minimum'], equals(0));
      expect(json['maximum'], equals(100));
      expect(json['exclusiveMinimum'], equals(0));
      expect(json['exclusiveMaximum'], equals(100));
      expect(json['multipleOf'], equals(5));

      final parsedSchema = JsonSchema.fromJson(json);
      expect(parsedSchema, isA<NumberSchema>());
      expect(parsedSchema.title, equals('Number Schema'));

      final numberSchema = parsedSchema as NumberSchema;
      expect(numberSchema.minimum, equals(0));
      expect(numberSchema.maximum, equals(100));
      expect(numberSchema.exclusiveMinimum, equals(0));
      expect(numberSchema.exclusiveMaximum, equals(100));
      expect(numberSchema.multipleOf, equals(5));
    });

    test('should handle integer type', () {
      final schema = NumberSchema(
        type: [JsonType.integer],
        minimum: 1,
        maximum: 10,
      );

      expect(schema.type, equals([JsonType.integer]));
      expect(schema.minimum, equals(1));
      expect(schema.maximum, equals(10));

      final json = schema.toJson();
      expect(json['type'], equals('integer'));

      final parsedSchema = JsonSchema.fromJson(json) as NumberSchema;
      expect(parsedSchema.type, equals([JsonType.integer]));
      expect(parsedSchema.minimum, equals(1));
      expect(parsedSchema.maximum, equals(10));
    });

    test('should handle multipleOf validation', () {
      final schema = NumberSchema(type: [JsonType.number], multipleOf: 0.5);

      expect(schema.multipleOf, equals(0.5));

      final json = schema.toJson();
      expect(json['multipleOf'], equals(0.5));

      final parsedSchema = JsonSchema.fromJson(json) as NumberSchema;
      expect(parsedSchema.multipleOf, equals(0.5));
    });

    test('should handle range validation', () {
      // Test inclusive range
      final inclusiveSchema = NumberSchema(
        type: [JsonType.number],
        minimum: 0,
        maximum: 100,
      );

      expect(inclusiveSchema.minimum, equals(0));
      expect(inclusiveSchema.maximum, equals(100));
      expect(inclusiveSchema.exclusiveMinimum, isNull);
      expect(inclusiveSchema.exclusiveMaximum, isNull);

      final inclusiveJson = inclusiveSchema.toJson();
      expect(inclusiveJson['minimum'], equals(0));
      expect(inclusiveJson['maximum'], equals(100));
      expect(inclusiveJson.containsKey('exclusiveMinimum'), isFalse);
      expect(inclusiveJson.containsKey('exclusiveMaximum'), isFalse);

      // Test exclusive range
      final exclusiveSchema = NumberSchema(
        type: [JsonType.number],
        exclusiveMinimum: 0,
        exclusiveMaximum: 100,
      );

      expect(exclusiveSchema.minimum, isNull);
      expect(exclusiveSchema.maximum, isNull);
      expect(exclusiveSchema.exclusiveMinimum, equals(0));
      expect(exclusiveSchema.exclusiveMaximum, equals(100));

      final exclusiveJson = exclusiveSchema.toJson();
      expect(exclusiveJson.containsKey('minimum'), isFalse);
      expect(exclusiveJson.containsKey('maximum'), isFalse);
      expect(exclusiveJson['exclusiveMinimum'], equals(0));
      expect(exclusiveJson['exclusiveMaximum'], equals(100));
    });
  });
}
