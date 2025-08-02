import 'package:json_schema_utils/json_schema_utils.dart';
import 'package:test/test.dart';

void main() {
  group('NumberJsonSchema tests', () {
    late NumberJsonSchema schema;

    setUp(() {
      schema = NumberJsonSchema();
    });

    test('type is initialized to Number', () {
      expect(schema.type, equals(JsonType.number));
    });

    test('setting type to non-Number throws exception', () {
      expect(() => schema.type = JsonType.string, throwsFormatException);
      expect(() => schema.type = JsonType.integer, throwsFormatException);
      expect(() => schema.type = JsonType.object, throwsFormatException);
      expect(() => schema.type = JsonType.array, throwsFormatException);
      expect(() => schema.type = JsonType.boolean, throwsFormatException);
      expect(() => schema.type = JsonType.nullValue, throwsFormatException);
      expect(
        () => schema.type = [JsonType.number, JsonType.string],
        throwsFormatException,
      );
    });

    test('setting type to Number or [Number] is allowed', () {
      // Should not throw
      schema.type = JsonType.number;
      schema.type = [JsonType.number];
    });

    test('defaultValue must be a number or null', () {
      // Should not throw
      schema.defaultValue = 42;
      schema.defaultValue = 3.14;
      schema.defaultValue = null;

      // Should throw
      expect(() => schema.defaultValue = 'test', throwsFormatException);
      expect(() => schema.defaultValue = true, throwsFormatException);
      expect(() => schema.defaultValue = [1, 2, 3], throwsFormatException);
      expect(
        () => schema.defaultValue = {'key': 'value'},
        throwsFormatException,
      );
    });

    test('constValue must be a number or null', () {
      // Should not throw
      schema.constValue = 42;
      schema.constValue = 3.14;
      schema.constValue = null;

      // Should throw
      expect(() => schema.constValue = 'test', throwsFormatException);
      expect(() => schema.constValue = true, throwsFormatException);
      expect(() => schema.constValue = [1, 2, 3], throwsFormatException);
      expect(() => schema.constValue = {'key': 'value'}, throwsFormatException);
    });

    test('enumValues must contain only numbers', () {
      // Should not throw
      schema.enumValues = [1, 2, 3];
      schema.enumValues = [3.14, 2.71];
      schema.enumValues = [42];
      schema.enumValues = null;

      // Should throw
      expect(() => schema.enumValues = [123, 'test'], throwsFormatException);
      expect(() => schema.enumValues = [true, 456], throwsFormatException);
      expect(
        () => schema.enumValues = [
          1,
          [1, 2, 3],
        ],
        throwsFormatException,
      );
      expect(
        () => schema.enumValues = [
          2,
          {'key': 'value'},
        ],
        throwsFormatException,
      );
    });

    group('Number validation tests', () {
      test('validateNumber with valid values', () {
        // Valid
        expect(schema.validateNumber(42), isTrue);
        expect(schema.validateNumber(3.14), isTrue);
        expect(schema.validateNumber(0), isTrue);
        expect(schema.validateNumber(-10), isTrue);
        expect(schema.validateNumber(null), isTrue);
      });

      test('validateNumber with invalid values', () {
        // Invalid
        expect(schema.validateNumber('test'), isFalse);
        expect(schema.validateNumber(true), isFalse);
        expect(schema.validateNumber([1, 2, 3]), isFalse);
        expect(schema.validateNumber({'key': 'value'}), isFalse);
      });

      test('validateNumberWithExceptions throws appropriate exceptions', () {
        // Should not throw
        schema.validateNumberWithExceptions(42);
        schema.validateNumberWithExceptions(3.14);
        schema.validateNumberWithExceptions(null);

        // Should throw with appropriate messages
        expect(
          () => schema.validateNumberWithExceptions('test'),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              contains('must be a number'),
            ),
          ),
        );

        expect(
          () => schema.validateNumberWithExceptions(true),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              contains('must be a number'),
            ),
          ),
        );
      });

      test('validateNumber with multipleOf constraint', () {
        schema.multipleOf = 5;

        // Valid
        expect(schema.validateNumber(0), isTrue);
        expect(schema.validateNumber(5), isTrue);
        expect(schema.validateNumber(10), isTrue);
        expect(schema.validateNumber(-5), isTrue);

        // Invalid
        expect(schema.validateNumber(3), isFalse);
        expect(schema.validateNumber(7), isFalse);
      });

      test('validateNumber with minimum constraint', () {
        schema.minimum = 5;

        // Valid
        expect(schema.validateNumber(5), isTrue);
        expect(schema.validateNumber(10), isTrue);

        // Invalid
        expect(schema.validateNumber(4), isFalse);
        expect(schema.validateNumber(0), isFalse);
        expect(schema.validateNumber(-5), isFalse);
      });

      test('validateNumber with exclusiveMinimum constraint', () {
        schema.exclusiveMinimum = 5;

        // Valid
        expect(schema.validateNumber(6), isTrue);
        expect(schema.validateNumber(10), isTrue);

        // Invalid
        expect(schema.validateNumber(5), isFalse);
        expect(schema.validateNumber(4), isFalse);
        expect(schema.validateNumber(0), isFalse);
      });

      test('validateNumber with maximum constraint', () {
        schema.maximum = 10;

        // Valid
        expect(schema.validateNumber(10), isTrue);
        expect(schema.validateNumber(5), isTrue);
        expect(schema.validateNumber(0), isTrue);

        // Invalid
        expect(schema.validateNumber(11), isFalse);
        expect(schema.validateNumber(20), isFalse);
      });

      test('validateNumber with exclusiveMaximum constraint', () {
        schema.exclusiveMaximum = 10;

        // Valid
        expect(schema.validateNumber(9), isTrue);
        expect(schema.validateNumber(5), isTrue);
        expect(schema.validateNumber(0), isTrue);

        // Invalid
        expect(schema.validateNumber(10), isFalse);
        expect(schema.validateNumber(11), isFalse);
      });

      test('validateNumber with multiple constraints', () {
        schema.minimum = 5;
        schema.maximum = 20;
        schema.multipleOf = 5;

        // Valid
        expect(schema.validateNumber(5), isTrue);
        expect(schema.validateNumber(10), isTrue);
        expect(schema.validateNumber(15), isTrue);
        expect(schema.validateNumber(20), isTrue);

        // Invalid - below minimum
        expect(schema.validateNumber(0), isFalse);
        // Invalid - above maximum
        expect(schema.validateNumber(25), isFalse);
        // Invalid - not multiple of 5
        expect(schema.validateNumber(7), isFalse);
      });

      test('validateNumber with enum constraint', () {
        schema.enumValues = [10, 20, 30];

        // Valid
        expect(schema.validateNumber(10), isTrue);
        expect(schema.validateNumber(20), isTrue);
        expect(schema.validateNumber(30), isTrue);

        // Invalid - not in enum
        expect(schema.validateNumber(15), isFalse);
        expect(schema.validateNumber(0), isFalse);

        // Setting defaultValue to a value not in enum should throw
        expect(() => schema.defaultValue = 15, throwsFormatException);
      });

      test('validateNumber with const constraint', () {
        schema.constValue = 42;

        // Valid
        expect(schema.validateNumber(42), isTrue);

        // Invalid - not equal to const
        expect(schema.validateNumber(10), isFalse);

        // Setting defaultValue to a value not equal to const should throw
        expect(() => schema.defaultValue = 10, throwsFormatException);
      });
    });
  });
}
