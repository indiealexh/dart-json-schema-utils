import 'package:json_schema_utils/json_schema_utils.dart';
import 'package:test/test.dart';

void main() {
  group('JsonSchema', () {
    test('should create a basic schema', () {
      final schema = JsonSchema(
        title: 'Test Schema',
        description: 'A schema for testing',
        type: [JsonType.object],
      );

      expect(schema.title, equals('Test Schema'));
      expect(schema.description, equals('A schema for testing'));
      expect(schema.type, equals([JsonType.object]));
    });

    test('should convert to and from JSON', () {
      final schema = JsonSchema(
        title: 'Test Schema',
        description: 'A schema for testing',
        type: [JsonType.object],
      );

      final json = schema.toJson();
      expect(json['title'], equals('Test Schema'));
      expect(json['description'], equals('A schema for testing'));
      expect(json['type'], equals('object'));

      final parsedSchema = JsonSchema.fromJson(json);
      expect(parsedSchema.title, equals('Test Schema'));
      expect(parsedSchema.description, equals('A schema for testing'));
      expect(parsedSchema.type, equals([JsonType.object]));
    });

    test('should handle complex schemas', () {
      final schema = JsonSchema(
        title: 'Complex Schema',
        description: 'A complex schema for testing',
        type: [JsonType.object],
        allOf: [
          JsonSchema(type: [JsonType.object], title: 'Sub-schema 1'),
          JsonSchema(type: [JsonType.object], title: 'Sub-schema 2'),
        ],
        anyOf: [
          JsonSchema(type: [JsonType.string], title: 'String Schema'),
          JsonSchema(type: [JsonType.number], title: 'Number Schema'),
        ],
      );

      expect(schema.title, equals('Complex Schema'));
      expect(schema.allOf?.length, equals(2));
      expect(schema.anyOf?.length, equals(2));

      final json = schema.toJson();
      expect(json['title'], equals('Complex Schema'));
      expect(json['allOf'].length, equals(2));
      expect(json['anyOf'].length, equals(2));

      final parsedSchema = JsonSchema.fromJson(json);
      expect(parsedSchema.title, equals('Complex Schema'));
      expect(parsedSchema.allOf?.length, equals(2));
      expect(parsedSchema.anyOf?.length, equals(2));
    });
  });
}
