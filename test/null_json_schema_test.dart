import 'package:json_schema_utils/json_schema_utils.dart';
import 'package:test/test.dart';

void main() {
  group('NullJsonSchema tests', () {
    late NullJsonSchema schema;

    setUp(() {
      schema = NullJsonSchema();
    });

    test('type is initialized to Null', () {
      expect(schema.type, equals(JsonType.nullValue));
    });

    test('setting type to non-Null throws exception', () {
      expect(() => schema.type = JsonType.string, throwsFormatException);
      expect(() => schema.type = JsonType.number, throwsFormatException);
      expect(() => schema.type = JsonType.integer, throwsFormatException);
      expect(() => schema.type = JsonType.object, throwsFormatException);
      expect(() => schema.type = JsonType.array, throwsFormatException);
      expect(() => schema.type = JsonType.boolean, throwsFormatException);
      expect(
        () => schema.type = [JsonType.nullValue, JsonType.string],
        throwsFormatException,
      );
    });

    test('setting type to Null or [Null] is allowed', () {
      // Should not throw
      schema.type = JsonType.nullValue;
      schema.type = [JsonType.nullValue];
    });

    test('defaultValue must be null', () {
      // Should not throw
      schema.defaultValue = null;

      // Should throw
      expect(() => schema.defaultValue = 123, throwsFormatException);
      expect(() => schema.defaultValue = 'test', throwsFormatException);
      expect(() => schema.defaultValue = true, throwsFormatException);
      expect(() => schema.defaultValue = [1, 2, 3], throwsFormatException);
      expect(
        () => schema.defaultValue = {'key': 'value'},
        throwsFormatException,
      );
    });

    test('constValue must be null', () {
      // Should not throw
      schema.constValue = null;

      // Should throw
      expect(() => schema.constValue = 123, throwsFormatException);
      expect(() => schema.constValue = 'test', throwsFormatException);
      expect(() => schema.constValue = true, throwsFormatException);
      expect(() => schema.constValue = [1, 2, 3], throwsFormatException);
      expect(() => schema.constValue = {'key': 'value'}, throwsFormatException);
    });

    test('enumValues must contain only null values', () {
      // Should not throw
      schema.enumValues = [null];
      schema.enumValues = null;

      // Should throw
      expect(() => schema.enumValues = [123], throwsFormatException);
      expect(() => schema.enumValues = ['test'], throwsFormatException);
      expect(() => schema.enumValues = [true], throwsFormatException);
      expect(
        () => schema.enumValues = [
          [1, 2, 3],
        ],
        throwsFormatException,
      );
      expect(
        () => schema.enumValues = [
          {'key': 'value'},
        ],
        throwsFormatException,
      );
      expect(() => schema.enumValues = [null, 123], throwsFormatException);
    });

    group('Null validation tests', () {
      test('validateNull with valid values', () {
        // Valid
        expect(schema.validateNull(null), isTrue);
      });

      test('validateNull with invalid values', () {
        // Invalid
        expect(schema.validateNull(123), isFalse);
        expect(schema.validateNull('test'), isFalse);
        expect(schema.validateNull(true), isFalse);
        expect(schema.validateNull([1, 2, 3]), isFalse);
        expect(schema.validateNull({'key': 'value'}), isFalse);
      });

      test('validateNullWithExceptions throws appropriate exceptions', () {
        // Should not throw
        schema.validateNullWithExceptions(null);

        // Should throw with appropriate messages
        expect(
          () => schema.validateNullWithExceptions(123),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              contains('must be null'),
            ),
          ),
        );

        expect(
          () => schema.validateNullWithExceptions('test'),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              contains('must be null'),
            ),
          ),
        );
      });

      // For null type, enum and const constraints are less meaningful since there's only one possible value (null)
      // But we'll test them for completeness

      test('validateNull with enum constraint', () {
        schema.enumValues = [null];

        // Valid
        expect(schema.validateNull(null), isTrue);

        // Invalid
        expect(schema.validateNull(123), isFalse);
      });

      test('validateNull with const constraint', () {
        schema.constValue = null;

        // Valid
        expect(schema.validateNull(null), isTrue);

        // Invalid
        expect(schema.validateNull(123), isFalse);
      });
    });
  });
}
