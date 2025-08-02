import 'package:json_schema_utils/json_schema_utils.dart';
import 'package:test/test.dart';

void main() {
  group('BooleanJsonSchema tests', () {
    late BooleanJsonSchema schema;

    setUp(() {
      schema = BooleanJsonSchema();
    });

    test('type is initialized to Boolean', () {
      expect(schema.type, equals(JsonType.boolean));
    });

    test('setting type to non-Boolean throws exception', () {
      expect(() => schema.type = JsonType.string, throwsFormatException);
      expect(() => schema.type = JsonType.number, throwsFormatException);
      expect(() => schema.type = JsonType.integer, throwsFormatException);
      expect(() => schema.type = JsonType.object, throwsFormatException);
      expect(() => schema.type = JsonType.array, throwsFormatException);
      expect(() => schema.type = JsonType.nullValue, throwsFormatException);
      expect(
        () => schema.type = [JsonType.boolean, JsonType.string],
        throwsFormatException,
      );
    });

    test('setting type to Boolean or [Boolean] is allowed', () {
      // Should not throw
      schema.type = JsonType.boolean;
      schema.type = [JsonType.boolean];
    });

    test('defaultValue must be a boolean or null', () {
      // Should not throw
      schema.defaultValue = true;
      schema.defaultValue = false;
      schema.defaultValue = null;

      // Should throw
      expect(() => schema.defaultValue = 123, throwsFormatException);
      expect(() => schema.defaultValue = 'test', throwsFormatException);
      expect(() => schema.defaultValue = [1, 2, 3], throwsFormatException);
      expect(
        () => schema.defaultValue = {'key': 'value'},
        throwsFormatException,
      );
    });

    test('constValue must be a boolean or null', () {
      // Should not throw
      schema.constValue = true;
      schema.constValue = false;
      schema.constValue = null;

      // Should throw
      expect(() => schema.constValue = 123, throwsFormatException);
      expect(() => schema.constValue = 'test', throwsFormatException);
      expect(() => schema.constValue = [1, 2, 3], throwsFormatException);
      expect(() => schema.constValue = {'key': 'value'}, throwsFormatException);
    });

    test('enumValues must contain only booleans', () {
      // Should not throw
      schema.enumValues = [true, false];
      schema.enumValues = [true];
      schema.enumValues = [false];
      schema.enumValues = null;

      // Should throw
      expect(() => schema.enumValues = [123, true], throwsFormatException);
      expect(() => schema.enumValues = ['test', false], throwsFormatException);
      expect(
        () => schema.enumValues = [
          true,
          [1, 2, 3],
        ],
        throwsFormatException,
      );
      expect(
        () => schema.enumValues = [
          false,
          {'key': 'value'},
        ],
        throwsFormatException,
      );
    });

    group('Boolean validation tests', () {
      test('validateBoolean with valid values', () {
        // Valid
        expect(schema.validateBoolean(true), isTrue);
        expect(schema.validateBoolean(false), isTrue);
        expect(schema.validateBoolean(null), isTrue);
      });

      test('validateBoolean with invalid values', () {
        // Invalid
        expect(schema.validateBoolean(123), isFalse);
        expect(schema.validateBoolean('test'), isFalse);
        expect(schema.validateBoolean([1, 2, 3]), isFalse);
        expect(schema.validateBoolean({'key': 'value'}), isFalse);
      });

      test('validateBooleanWithExceptions throws appropriate exceptions', () {
        // Should not throw
        schema.validateBooleanWithExceptions(true);
        schema.validateBooleanWithExceptions(false);
        schema.validateBooleanWithExceptions(null);

        // Should throw with appropriate messages
        expect(
          () => schema.validateBooleanWithExceptions(123),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              contains('must be a boolean'),
            ),
          ),
        );

        expect(
          () => schema.validateBooleanWithExceptions('test'),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              contains('must be a boolean'),
            ),
          ),
        );
      });

      test('validateBoolean with enum constraint', () {
        schema.enumValues = [true];

        // Valid
        expect(schema.validateBoolean(true), isTrue);

        // Invalid - not in enum
        expect(schema.validateBoolean(false), isFalse);

        // Setting defaultValue to a value not in enum should throw
        expect(() => schema.defaultValue = false, throwsFormatException);
      });

      test('validateBoolean with const constraint', () {
        schema.constValue = false;

        // Valid
        expect(schema.validateBoolean(false), isTrue);

        // Invalid - not equal to const
        expect(schema.validateBoolean(true), isFalse);

        // Setting defaultValue to a value not equal to const should throw
        expect(() => schema.defaultValue = true, throwsFormatException);
      });
    });
  });
}
