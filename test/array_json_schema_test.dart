import 'package:json_schema_utils/json_schema_utils.dart';
import 'package:test/test.dart';

void main() {
  group('ArrayJsonSchema tests', () {
    late ArrayJsonSchema schema;

    setUp(() {
      schema = ArrayJsonSchema();
    });

    test('type is initialized to Array', () {
      expect(schema.type, equals(JsonType.array));
    });

    test('setting type to non-Array throws exception', () {
      expect(() => schema.type = JsonType.string, throwsFormatException);
      expect(() => schema.type = JsonType.number, throwsFormatException);
      expect(() => schema.type = JsonType.integer, throwsFormatException);
      expect(() => schema.type = JsonType.object, throwsFormatException);
      expect(() => schema.type = JsonType.boolean, throwsFormatException);
      expect(() => schema.type = JsonType.nullValue, throwsFormatException);
      expect(
        () => schema.type = [JsonType.array, JsonType.string],
        throwsFormatException,
      );
    });

    test('setting type to Array or [Array] is allowed', () {
      // Should not throw
      schema.type = JsonType.array;
      schema.type = [JsonType.array];
    });

    test('defaultValue must be an array or null', () {
      // Should not throw
      schema.defaultValue = [1, 2, 3];
      schema.defaultValue = [];
      schema.defaultValue = null;

      // Should throw
      expect(() => schema.defaultValue = 123, throwsFormatException);
      expect(() => schema.defaultValue = 'test', throwsFormatException);
      expect(() => schema.defaultValue = true, throwsFormatException);
      expect(
        () => schema.defaultValue = {'key': 'value'},
        throwsFormatException,
      );
    });

    test('constValue must be an array or null', () {
      // Should not throw
      schema.constValue = [1, 2, 3];
      schema.constValue = [];
      schema.constValue = null;

      // Should throw
      expect(() => schema.constValue = 123, throwsFormatException);
      expect(() => schema.constValue = 'test', throwsFormatException);
      expect(() => schema.constValue = true, throwsFormatException);
      expect(() => schema.constValue = {'key': 'value'}, throwsFormatException);
    });

    test('enumValues must contain only arrays', () {
      // Should not throw
      schema.enumValues = [
        [1, 2, 3],
        [4, 5, 6],
      ];
      schema.enumValues = [[]];
      schema.enumValues = null;

      // Should throw
      expect(() => schema.enumValues = [123, []], throwsFormatException);
      expect(() => schema.enumValues = ['test', []], throwsFormatException);
      expect(() => schema.enumValues = [true, []], throwsFormatException);
      expect(
        () => schema.enumValues = [
          {'key': 'value'},
          [],
        ],
        throwsFormatException,
      );
    });

    group('Array validation tests', () {
      test('validateArray with minItems', () {
        schema.minItems = 2;

        // Valid
        expect(schema.validateArray([1, 2]), isTrue);
        expect(schema.validateArray([1, 2, 3]), isTrue);
        expect(schema.validateArray(null), isTrue);

        // Invalid
        expect(schema.validateArray([1]), isFalse);
        expect(schema.validateArray([]), isFalse);
      });

      test('validateArray with maxItems', () {
        schema.maxItems = 3;

        // Valid
        expect(schema.validateArray([]), isTrue);
        expect(schema.validateArray([1]), isTrue);
        expect(schema.validateArray([1, 2]), isTrue);
        expect(schema.validateArray([1, 2, 3]), isTrue);
        expect(schema.validateArray(null), isTrue);

        // Invalid
        expect(schema.validateArray([1, 2, 3, 4]), isFalse);
      });

      test('validateArray with uniqueItems', () {
        schema.uniqueItems = true;

        // Valid
        expect(schema.validateArray([1, 2, 3]), isTrue);
        expect(schema.validateArray(['a', 'b', 'c']), isTrue);
        expect(schema.validateArray([]), isTrue);
        expect(schema.validateArray(null), isTrue);

        // Invalid
        expect(schema.validateArray([1, 2, 1]), isFalse);
        expect(schema.validateArray(['a', 'b', 'a']), isFalse);
      });

      test('validateArray with multiple constraints', () {
        schema.minItems = 2;
        schema.maxItems = 4;
        schema.uniqueItems = true;

        // Valid
        expect(schema.validateArray([1, 2]), isTrue);
        expect(schema.validateArray([1, 2, 3]), isTrue);
        expect(schema.validateArray([1, 2, 3, 4]), isTrue);

        // Invalid - too few items
        expect(schema.validateArray([1]), isFalse);
        // Invalid - too many items
        expect(schema.validateArray([1, 2, 3, 4, 5]), isFalse);
        // Invalid - duplicate items
        expect(schema.validateArray([1, 2, 1]), isFalse);
      });

      test('validateArray with items as single schema', () {
        var itemSchema = JsonSchema();
        itemSchema.type = JsonType.number;
        itemSchema.minimum = 0;
        schema.items = itemSchema;

        // Valid
        expect(schema.validateArray([1, 2, 3]), isTrue);
        expect(schema.validateArray([]), isTrue);
        expect(schema.validateArray(null), isTrue);

        // Invalid - item doesn't match schema
        expect(schema.validateArray([1, -1, 3]), isFalse);
        expect(schema.validateArray([1, 'string', 3]), isFalse);
      });

      test('validateArray with items as array of schemas', () {
        var stringSchema = JsonSchema();
        stringSchema.type = JsonType.string;

        var numberSchema = JsonSchema();
        numberSchema.type = JsonType.number;

        var booleanSchema = JsonSchema();
        booleanSchema.type = JsonType.boolean;

        schema.items = [stringSchema, numberSchema, booleanSchema];

        // Valid
        expect(schema.validateArray(['test', 42, true]), isTrue);
        expect(schema.validateArray(['test', 42]), isTrue);
        expect(schema.validateArray(['test']), isTrue);
        expect(schema.validateArray([]), isTrue);
        expect(schema.validateArray(null), isTrue);

        // Invalid - items don't match schemas
        expect(schema.validateArray([42, 'test', true]), isFalse);
        expect(schema.validateArray(['test', 'test', true]), isFalse);
      });

      test('validateArray with additionalItems as schema', () {
        var stringSchema = JsonSchema();
        stringSchema.type = JsonType.string;

        var numberSchema = JsonSchema();
        numberSchema.type = JsonType.number;

        var additionalSchema = JsonSchema();
        additionalSchema.type = JsonType.boolean;

        schema.items = [stringSchema, numberSchema];
        schema.additionalItems = additionalSchema;

        // Valid
        expect(schema.validateArray(['test', 42]), isTrue);
        expect(schema.validateArray(['test', 42, true, false]), isTrue);
        expect(schema.validateArray(['test']), isTrue);
        expect(schema.validateArray([]), isTrue);
        expect(schema.validateArray(null), isTrue);

        // Invalid - additional items don't match schema
        expect(schema.validateArray(['test', 42, 'string']), isFalse);
        expect(schema.validateArray(['test', 42, 123]), isFalse);
      });

      test('validateArray with additionalItems as false', () {
        var stringSchema = JsonSchema();
        stringSchema.type = JsonType.string;

        var numberSchema = JsonSchema();
        numberSchema.type = JsonType.number;

        schema.items = [stringSchema, numberSchema];
        schema.additionalItems = false;

        // Valid
        expect(schema.validateArray(['test', 42]), isTrue);
        expect(schema.validateArray(['test']), isTrue);
        expect(schema.validateArray([]), isTrue);
        expect(schema.validateArray(null), isTrue);

        // Invalid - additional items not allowed
        expect(schema.validateArray(['test', 42, true]), isFalse);
      });

      test('validateArray with contains', () {
        var containsSchema = JsonSchema();
        containsSchema.type = JsonType.number;
        containsSchema.minimum = 10;
        schema.contains = containsSchema;

        // Valid
        expect(schema.validateArray([1, 15, 3]), isTrue);
        expect(schema.validateArray([10, 20, 30]), isTrue);
        expect(schema.validateArray(null), isTrue);

        // Invalid - no item matches contains schema
        expect(schema.validateArray([1, 2, 3]), isFalse);
        expect(schema.validateArray([]), isFalse);
      });

      test('validateArrayWithExceptions throws appropriate exceptions', () {
        schema.minItems = 2;
        schema.maxItems = 4;
        schema.uniqueItems = true;

        // Should not throw
        schema.validateArrayWithExceptions([1, 2]);
        schema.validateArrayWithExceptions([1, 2, 3]);
        schema.validateArrayWithExceptions(null);

        // Should throw with appropriate messages
        expect(
          () => schema.validateArrayWithExceptions([1]),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              contains('must have at least 2 items'),
            ),
          ),
        );

        expect(
          () => schema.validateArrayWithExceptions([1, 2, 3, 4, 5]),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              contains('must have at most 4 items'),
            ),
          ),
        );

        expect(
          () => schema.validateArrayWithExceptions([1, 2, 1]),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              contains('must be unique'),
            ),
          ),
        );
      });

      test('validateArray with enum constraint', () {
        schema.enumValues = [
          [1, 2, 3],
          [4, 5, 6],
        ];

        // Valid
        expect(schema.validateArray([1, 2, 3]), isTrue);
        expect(schema.validateArray([4, 5, 6]), isTrue);

        // Invalid - not in enum
        expect(schema.validateArray([1, 2, 4]), isFalse);
        expect(schema.validateArray([]), isFalse);

        // Setting defaultValue to a value not in enum should throw
        expect(() => schema.defaultValue = [1, 2, 4], throwsFormatException);
      });

      test('validateArray with const constraint', () {
        schema.constValue = [1, 2, 3];

        // Valid
        expect(schema.validateArray([1, 2, 3]), isTrue);

        // Invalid - not equal to const
        expect(schema.validateArray([1, 2, 4]), isFalse);
        expect(schema.validateArray([]), isFalse);

        // Setting defaultValue to a value not equal to const should throw
        expect(() => schema.defaultValue = [1, 2, 4], throwsFormatException);
      });
    });
  });
}
