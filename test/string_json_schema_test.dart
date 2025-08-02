import 'package:json_schema_utils/json_schema_utils.dart';
import 'package:test/test.dart';

void main() {
  group('StringJsonSchema tests', () {
    late StringJsonSchema schema;

    setUp(() {
      schema = StringJsonSchema();
    });

    test('type is initialized to String', () {
      expect(schema.type, equals(JsonType.string));
    });

    test('setting type to non-String throws exception', () {
      expect(() => schema.type = JsonType.number, throwsFormatException);
      expect(() => schema.type = JsonType.integer, throwsFormatException);
      expect(() => schema.type = JsonType.object, throwsFormatException);
      expect(() => schema.type = JsonType.array, throwsFormatException);
      expect(() => schema.type = JsonType.boolean, throwsFormatException);
      expect(() => schema.type = JsonType.nullValue, throwsFormatException);
      expect(
        () => schema.type = [JsonType.string, JsonType.number],
        throwsFormatException,
      );
    });

    test('setting type to String or [String] is allowed', () {
      // Should not throw
      schema.type = JsonType.string;
      schema.type = [JsonType.string];
    });

    test('defaultValue must be a string or null', () {
      // Should not throw
      schema.defaultValue = 'test';
      schema.defaultValue = null;

      // Should throw
      expect(() => schema.defaultValue = 123, throwsFormatException);
      expect(() => schema.defaultValue = true, throwsFormatException);
      expect(() => schema.defaultValue = [1, 2, 3], throwsFormatException);
      expect(
        () => schema.defaultValue = {'key': 'value'},
        throwsFormatException,
      );
    });

    test('constValue must be a string or null', () {
      // Should not throw
      schema.constValue = 'test';
      schema.constValue = null;

      // Should throw
      expect(() => schema.constValue = 123, throwsFormatException);
      expect(() => schema.constValue = true, throwsFormatException);
      expect(() => schema.constValue = [1, 2, 3], throwsFormatException);
      expect(() => schema.constValue = {'key': 'value'}, throwsFormatException);
    });

    test('enumValues must contain only strings', () {
      // Should not throw
      schema.enumValues = ['test1', 'test2', 'test3'];
      schema.enumValues = null;

      // Should throw
      expect(() => schema.enumValues = [123, 'test'], throwsFormatException);
      expect(() => schema.enumValues = ['test', true], throwsFormatException);
      expect(
        () => schema.enumValues = [
          'test',
          [1, 2, 3],
        ],
        throwsFormatException,
      );
      expect(
        () => schema.enumValues = [
          'test',
          {'key': 'value'},
        ],
        throwsFormatException,
      );
    });

    group('String validation tests', () {
      test('validateString with minLength', () {
        schema.minLength = 3;

        // Valid
        expect(schema.validateString('abc'), isTrue);
        expect(schema.validateString('abcd'), isTrue);
        expect(schema.validateString(null), isTrue);

        // Invalid
        expect(schema.validateString('ab'), isFalse);
        expect(schema.validateString(''), isFalse);
      });

      test('validateString with maxLength', () {
        schema.maxLength = 5;

        // Valid
        expect(schema.validateString(''), isTrue);
        expect(schema.validateString('abc'), isTrue);
        expect(schema.validateString('abcde'), isTrue);
        expect(schema.validateString(null), isTrue);

        // Invalid
        expect(schema.validateString('abcdef'), isFalse);
      });

      test('validateString with pattern', () {
        schema.pattern = r'^[a-z]+$';

        // Valid
        expect(schema.validateString('abc'), isTrue);
        expect(schema.validateString('xyz'), isTrue);
        expect(schema.validateString(null), isTrue);

        // Invalid
        expect(schema.validateString('ABC'), isFalse);
        expect(schema.validateString('123'), isFalse);
        expect(schema.validateString('abc123'), isFalse);
      });

      test('validateString with multiple constraints', () {
        schema.minLength = 3;
        schema.maxLength = 5;
        schema.pattern = r'^[a-z]+$';

        // Valid
        expect(schema.validateString('abc'), isTrue);
        expect(schema.validateString('abcd'), isTrue);
        expect(schema.validateString('abcde'), isTrue);
        expect(schema.validateString(null), isTrue);

        // Invalid - too short
        expect(schema.validateString('ab'), isFalse);
        // Invalid - too long
        expect(schema.validateString('abcdef'), isFalse);
        // Invalid - doesn't match pattern
        expect(schema.validateString('ABC'), isFalse);
      });

      test('validateStringWithExceptions throws appropriate exceptions', () {
        schema.minLength = 3;
        schema.maxLength = 5;
        schema.pattern = r'^[a-z]+$';

        // Should not throw
        schema.validateStringWithExceptions('abc');
        schema.validateStringWithExceptions('abcd');
        schema.validateStringWithExceptions('abcde');
        schema.validateStringWithExceptions(null);

        // Should throw with appropriate messages
        expect(
          () => schema.validateStringWithExceptions('ab'),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              contains('less than minimum length'),
            ),
          ),
        );

        expect(
          () => schema.validateStringWithExceptions('abcdef'),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              contains('exceeds maximum length'),
            ),
          ),
        );

        expect(
          () => schema.validateStringWithExceptions('ABC'),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              contains('does not match pattern'),
            ),
          ),
        );
      });
    });

    group('Format validation tests', () {
      test('date-time format', () {
        schema.format = 'date-time';

        // Valid
        expect(schema.validateString('2025-08-02T11:10:00Z'), isTrue);
        expect(schema.validateString('2025-08-02T11:10:00.123Z'), isTrue);

        // Invalid
        expect(schema.validateString('not a date'), isFalse);
        expect(
          schema.validateString('2025-13-02T11:10:00Z'),
          isFalse,
        ); // Invalid month
      });

      test('email format', () {
        schema.format = 'email';

        // Valid
        expect(schema.validateString('user@example.com'), isTrue);
        expect(schema.validateString('user.name+tag@example.co.uk'), isTrue);

        // Invalid
        expect(schema.validateString('not an email'), isFalse);
        expect(schema.validateString('user@'), isFalse);
        expect(schema.validateString('@example.com'), isFalse);
      });

      test('uri format', () {
        schema.format = 'uri';

        // Valid
        expect(schema.validateString('https://example.com'), isTrue);
        expect(
          schema.validateString('http://example.com/path?query=value'),
          isTrue,
        );

        // Invalid
        expect(schema.validateString('not a uri'), isFalse);
        expect(schema.validateString('example.com'), isFalse); // Missing scheme
      });

      test('ipv4 format', () {
        schema.format = 'ipv4';

        // Valid
        expect(schema.validateString('192.168.0.1'), isTrue);
        expect(schema.validateString('127.0.0.1'), isTrue);

        // Invalid
        expect(schema.validateString('not an ip'), isFalse);
        expect(schema.validateString('256.0.0.1'), isFalse); // Invalid octet
        expect(schema.validateString('192.168.0'), isFalse); // Missing octet
      });
    });
  });
}
