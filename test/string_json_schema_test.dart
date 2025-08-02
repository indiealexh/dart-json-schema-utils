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

      test('date format', () {
        schema.format = 'date';

        // Valid
        expect(schema.validateString('2025-08-02'), isTrue);
        expect(schema.validateString('2020-02-29'), isTrue); // Leap year

        // Invalid
        expect(schema.validateString('not a date'), isFalse);
        expect(schema.validateString('2025-13-02'), isFalse); // Invalid month
        expect(schema.validateString('2025/08/02'), isFalse); // Wrong format
        expect(schema.validateString('2021-02-29'), isFalse); // Not a leap year
      });

      test('time format', () {
        schema.format = 'time';

        // Valid
        expect(schema.validateString('11:10:00Z'), isTrue);
        expect(schema.validateString('23:59:59Z'), isTrue);
        expect(schema.validateString('11:10:00.123Z'), isTrue);
        expect(schema.validateString('11:10:00+01:00'), isTrue);

        // Invalid
        expect(schema.validateString('not a time'), isFalse);
        expect(schema.validateString('24:00:00Z'), isFalse); // Invalid hour
        expect(schema.validateString('11:60:00Z'), isFalse); // Invalid minute
        expect(schema.validateString('11:10'), isFalse); // Missing seconds
      });

      test('duration format', () {
        schema.format = 'duration';

        // Valid
        expect(schema.validateString('P1Y'), isTrue);
        expect(schema.validateString('P1M'), isTrue);
        expect(schema.validateString('P1D'), isTrue);
        expect(schema.validateString('PT1H'), isTrue);
        expect(schema.validateString('PT1M'), isTrue);
        expect(schema.validateString('PT1S'), isTrue);
        expect(schema.validateString('P1Y2M3DT4H5M6S'), isTrue);
        expect(schema.validateString('P1W'), isTrue);

        // Invalid
        expect(schema.validateString('not a duration'), isFalse);
        expect(schema.validateString('P'), isFalse); // Empty duration
        expect(schema.validateString('PT'), isFalse); // Empty time duration
        expect(schema.validateString('1Y2M'), isFalse); // Missing P
      });

      test('uuid format', () {
        schema.format = 'uuid';

        // Valid
        expect(
          schema.validateString('123e4567-e89b-12d3-a456-426614174000'),
          isTrue,
        );
        expect(
          schema.validateString('123E4567-E89B-12D3-A456-426614174000'),
          isTrue,
        ); // Case insensitive

        // Invalid
        expect(schema.validateString('not a uuid'), isFalse);
        expect(
          schema.validateString('123e4567-e89b-12d3-a456'),
          isFalse,
        ); // Too short
        expect(
          schema.validateString('123e4567-e89b-62d3-a456-426614174000'),
          isFalse,
        ); // Invalid version
        expect(
          schema.validateString('123e4567-e89b-12d3-e456-426614174000'),
          isFalse,
        ); // Invalid variant
      });

      test('json-pointer format', () {
        schema.format = 'json-pointer';

        // Valid
        expect(schema.validateString(''), isTrue);
        expect(schema.validateString('/foo'), isTrue);
        expect(schema.validateString('/foo/0'), isTrue);
        expect(schema.validateString('/foo/bar'), isTrue);
        expect(schema.validateString('/foo/bar/0'), isTrue);
        expect(schema.validateString('/~0/~1'), isTrue); // Escaped ~ and /

        // Invalid
        expect(schema.validateString('not a json-pointer'), isFalse);
        expect(schema.validateString('foo'), isFalse); // Missing leading /
        expect(schema.validateString('/foo/'), isFalse); // Trailing /
        expect(
          schema.validateString('/foo//bar'),
          isFalse,
        ); // Empty reference token
      });

      test('regex format', () {
        schema.format = 'regex';

        // Valid
        expect(schema.validateString('^[a-z]+\$'), isTrue);
        expect(schema.validateString('\\d{3}-\\d{2}-\\d{4}'), isTrue);
        expect(
          schema.validateString(
            '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}',
          ),
          isTrue,
        );

        // Invalid
        expect(schema.validateString('[unclosed bracket'), isFalse);
        expect(schema.validateString('(unclosed parenthesis'), isFalse);
        expect(schema.validateString('**invalid quantifier'), isFalse);
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
