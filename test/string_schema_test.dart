import 'package:json_schema_utils/json_schema_utils.dart';
import 'package:test/test.dart';

void main() {
  group('StringSchema', () {
    test('should create a basic string schema', () {
      final schema = StringSchema(
        title: 'String Schema',
        description: 'A schema for testing strings',
        type: [JsonType.string],
        maxLength: 100,
        minLength: 1,
        pattern: r'^[a-z]+$',
      );

      expect(schema.title, equals('String Schema'));
      expect(schema.description, equals('A schema for testing strings'));
      expect(schema.type, equals([JsonType.string]));
      expect(schema.maxLength, equals(100));
      expect(schema.minLength, equals(1));
      expect(schema.pattern, equals(r'^[a-z]+$'));
    });

    test('should convert to and from JSON', () {
      final schema = StringSchema(
        title: 'String Schema',
        description: 'A schema for testing strings',
        type: [JsonType.string],
        maxLength: 100,
        minLength: 1,
        pattern: r'^[a-z]+$',
      );

      final json = schema.toJson();
      expect(json['title'], equals('String Schema'));
      expect(json['description'], equals('A schema for testing strings'));
      expect(json['type'], equals('string'));
      expect(json['maxLength'], equals(100));
      expect(json['minLength'], equals(1));
      expect(json['pattern'], equals(r'^[a-z]+$'));

      final parsedSchema = JsonSchema.fromJson(json);
      expect(parsedSchema, isA<StringSchema>());
      expect(parsedSchema.title, equals('String Schema'));

      final stringSchema = parsedSchema as StringSchema;
      expect(stringSchema.maxLength, equals(100));
      expect(stringSchema.minLength, equals(1));
      expect(stringSchema.pattern, equals(r'^[a-z]+$'));
    });

    test('should handle string format', () {
      final schema = StringSchema(
        type: [JsonType.string],
        format: StringFormat.email,
      );

      expect(schema.format, equals(StringFormat.email));

      final json = schema.toJson();
      expect(json['format'], equals('email'));

      final parsedSchema = JsonSchema.fromJson(json) as StringSchema;
      expect(parsedSchema.format, equals(StringFormat.email));
    });

    test('should handle content encoding and media type', () {
      final schema = StringSchema(
        type: [JsonType.string],
        contentEncoding: 'base64',
        contentMediaType: 'image/png',
      );

      expect(schema.contentEncoding, equals('base64'));
      expect(schema.contentMediaType, equals('image/png'));

      final json = schema.toJson();
      expect(json['contentEncoding'], equals('base64'));
      expect(json['contentMediaType'], equals('image/png'));

      final parsedSchema = JsonSchema.fromJson(json) as StringSchema;
      expect(parsedSchema.contentEncoding, equals('base64'));
      expect(parsedSchema.contentMediaType, equals('image/png'));
    });

    test('should handle all string formats', () {
      // Test each string format
      for (final format in StringFormat.values) {
        final schema = StringSchema(type: [JsonType.string], format: format);

        expect(schema.format, equals(format));

        final json = schema.toJson();
        expect(json['format'], isNotNull);

        final parsedSchema = JsonSchema.fromJson(json) as StringSchema;
        expect(parsedSchema.format, equals(format));
      }
    });
  });
}
