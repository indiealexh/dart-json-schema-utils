import 'package:json_schema_utils/json_schema_utils.dart';
import 'package:test/test.dart';

void main() {
  group('ArraySchema', () {
    test('should create a basic array schema', () {
      final schema = ArraySchema(
        title: 'Array Schema',
        description: 'A schema for testing arrays',
        type: [JsonType.array],
        items: StringSchema(
          type: [JsonType.string],
          description: 'An array of strings',
        ),
        maxItems: 10,
        minItems: 1,
        uniqueItems: true,
      );

      expect(schema.title, equals('Array Schema'));
      expect(schema.items, isA<StringSchema>());
      expect(schema.maxItems, equals(10));
      expect(schema.minItems, equals(1));
      expect(schema.uniqueItems, isTrue);
    });

    test('should convert to and from JSON', () {
      final schema = ArraySchema(
        title: 'Array Schema',
        description: 'A schema for testing arrays',
        type: [JsonType.array],
        items: StringSchema(
          type: [JsonType.string],
          description: 'An array of strings',
        ),
        maxItems: 10,
        minItems: 1,
        uniqueItems: true,
      );

      final json = schema.toJson();
      expect(json['title'], equals('Array Schema'));
      expect(json['type'], equals('array'));
      expect(json['items'], isA<Map>());
      expect(json['items']['type'], equals('string'));
      expect(json['maxItems'], equals(10));
      expect(json['minItems'], equals(1));
      expect(json['uniqueItems'], isTrue);

      final parsedSchema = JsonSchema.fromJson(json);
      expect(parsedSchema, isA<ArraySchema>());
      expect(parsedSchema.title, equals('Array Schema'));

      final arraySchema = parsedSchema as ArraySchema;
      expect(arraySchema.items, isA<StringSchema>());
      expect(arraySchema.maxItems, equals(10));
      expect(arraySchema.minItems, equals(1));
      expect(arraySchema.uniqueItems, isTrue);
    });

    test('should handle array of schemas for items', () {
      final schema = ArraySchema(
        type: [JsonType.array],
        items: [
          StringSchema(type: [JsonType.string]),
          NumberSchema(type: [JsonType.number]),
          JsonSchema(type: [JsonType.boolean]),
        ],
      );

      expect(schema.items, isA<List>());
      final itemsList = schema.items as List<JsonSchema>;
      expect(itemsList.length, equals(3));
      expect(itemsList[0], isA<StringSchema>());
      expect(itemsList[1], isA<NumberSchema>());
      expect(itemsList[2], isA<JsonSchema>());

      final json = schema.toJson();
      expect(json['items'], isA<List>());
      expect(json['items'].length, equals(3));

      final parsedSchema = JsonSchema.fromJson(json) as ArraySchema;
      expect(parsedSchema.items, isA<List>());
      final parsedItemsList = parsedSchema.items as List<JsonSchema>;
      expect(parsedItemsList.length, equals(3));
      expect(parsedItemsList[0], isA<StringSchema>());
      expect(parsedItemsList[1], isA<NumberSchema>());
      expect(parsedItemsList[2], isA<JsonSchema>());
    });

    test('should handle additionalItems', () {
      final schema = ArraySchema(
        type: [JsonType.array],
        items: [
          StringSchema(type: [JsonType.string]),
          NumberSchema(type: [JsonType.number]),
        ],
        additionalItems: JsonSchema(type: [JsonType.boolean]),
      );

      expect(schema.additionalItems, isNotNull);
      expect(schema.additionalItems?.type, equals([JsonType.boolean]));

      final json = schema.toJson();
      expect(json['additionalItems'], isA<Map>());
      expect(json['additionalItems']['type'], equals('boolean'));

      final parsedSchema = JsonSchema.fromJson(json) as ArraySchema;
      expect(parsedSchema.additionalItems, isNotNull);
      expect(parsedSchema.additionalItems, isA<JsonSchema>());
      expect(parsedSchema.additionalItems?.type, equals([JsonType.boolean]));
    });

    test('should handle contains', () {
      final schema = ArraySchema(
        type: [JsonType.array],
        contains: StringSchema(type: [JsonType.string], pattern: r'^test'),
      );

      expect(schema.contains, isNotNull);
      expect(schema.contains, isA<StringSchema>());
      expect((schema.contains as StringSchema).pattern, equals(r'^test'));

      final json = schema.toJson();
      expect(json['contains'], isA<Map>());
      expect(json['contains']['type'], equals('string'));
      expect(json['contains']['pattern'], equals(r'^test'));

      final parsedSchema = JsonSchema.fromJson(json) as ArraySchema;
      expect(parsedSchema.contains, isNotNull);
      expect(parsedSchema.contains, isA<StringSchema>());
      expect((parsedSchema.contains as StringSchema).pattern, equals(r'^test'));
    });
  });
}
