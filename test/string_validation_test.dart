import 'package:json_schema_utils/json_schema_utils.dart';
import 'package:test/test.dart';

void main() {
  group('StringJsonSchema validation tests', () {
    late StringJsonSchema schema;

    setUp(() {
      schema = StringJsonSchema();
    });

    test('validate returns success for valid string', () {
      schema.minLength = 3;
      schema.maxLength = 10;
      schema.pattern = r'^[a-z]+$';

      final result = schema.validate('abcde');

      expect(result.isValid, isTrue);
      expect(result.errors, isEmpty);
    });

    test('validate returns success for null value', () {
      schema.minLength = 3;
      schema.maxLength = 10;
      schema.pattern = r'^[a-z]+$';

      final result = schema.validate(null);

      expect(result.isValid, isTrue);
      expect(result.errors, isEmpty);
    });

    test('validate reports minLength violation', () {
      schema.minLength = 3;

      final result = schema.validate('ab');

      expect(result.isValid, isFalse);
      expect(result.errors, hasLength(1));
      expect(result.errors[0].keyword, equals('minLength'));
      expect(result.errors[0].expected, equals(3));
      expect(result.errors[0].actual, equals(2));
      expect(result.errors[0].message, contains('less than minimum length'));
    });

    test('validate reports maxLength violation', () {
      schema.maxLength = 5;

      final result = schema.validate('abcdef');

      expect(result.isValid, isFalse);
      expect(result.errors, hasLength(1));
      expect(result.errors[0].keyword, equals('maxLength'));
      expect(result.errors[0].expected, equals(5));
      expect(result.errors[0].actual, equals(6));
      expect(result.errors[0].message, contains('exceeds maximum length'));
    });

    test('validate reports pattern violation', () {
      schema.pattern = r'^[a-z]+$';

      final result = schema.validate('ABC');

      expect(result.isValid, isFalse);
      expect(result.errors, hasLength(1));
      expect(result.errors[0].keyword, equals('pattern'));
      expect(result.errors[0].expected, equals(r'^[a-z]+$'));
      expect(result.errors[0].actual, equals('ABC'));
      expect(result.errors[0].message, contains('does not match pattern'));
    });

    test('validate reports multiple violations', () {
      schema.minLength = 5;
      schema.maxLength = 10;
      schema.pattern = r'^[a-z]+$';

      final result = schema.validate('AB');

      expect(result.isValid, isFalse);
      expect(
        result.errors,
        hasLength(2),
      ); // Both minLength and pattern violations

      // Check for minLength violation
      expect(result.errors.any((e) => e.keyword == 'minLength'), isTrue);

      // Check for pattern violation
      expect(result.errors.any((e) => e.keyword == 'pattern'), isTrue);
    });

    test('validate reports format violation', () {
      schema.format = 'email';

      final result = schema.validate('not-an-email');

      expect(result.isValid, isFalse);
      expect(result.errors, hasLength(1));
      expect(result.errors[0].keyword, equals('format'));
      expect(result.errors[0].expected, equals('email'));
      expect(result.errors[0].actual, equals('not-an-email'));
      expect(result.errors[0].message, contains('Invalid email format'));
    });

    test('validate reports const violation', () {
      schema.constValue = 'expected-value';

      final result = schema.validate('actual-value');

      expect(result.isValid, isFalse);
      expect(result.errors, hasLength(1));
      expect(result.errors[0].keyword, equals('const'));
      expect(result.errors[0].expected, equals('expected-value'));
      expect(result.errors[0].actual, equals('actual-value'));
      expect(result.errors[0].message, contains('must be equal to'));
    });

    test('validate reports enum violation', () {
      schema.enumValues = ['option1', 'option2', 'option3'];

      final result = schema.validate('option4');

      expect(result.isValid, isFalse);
      expect(result.errors, hasLength(1));
      expect(result.errors[0].keyword, equals('enum'));
      expect(
        result.errors[0].expected,
        equals(['option1', 'option2', 'option3']),
      );
      expect(result.errors[0].actual, equals('option4'));
      expect(result.errors[0].message, contains('must be one of'));
    });

    test('validate includes path in error', () {
      schema.minLength = 3;

      final result = schema.validate('ab', '/properties/name');

      expect(result.isValid, isFalse);
      expect(result.errors, hasLength(1));
      expect(result.errors[0].path, equals('/properties/name'));
    });

    test('validate stops after const violation', () {
      schema.constValue = 'expected-value';
      schema.minLength = 20; // This would normally cause a violation

      final result = schema.validate('actual-value');

      expect(result.isValid, isFalse);
      expect(result.errors, hasLength(1));
      expect(result.errors[0].keyword, equals('const'));
      // No minLength error because validation stops after const violation
    });

    test('validate stops after enum violation', () {
      schema.enumValues = ['option1', 'option2', 'option3'];
      schema.minLength = 20; // This would normally cause a violation

      final result = schema.validate('option4');

      expect(result.isValid, isFalse);
      expect(result.errors, hasLength(1));
      expect(result.errors[0].keyword, equals('enum'));
      // No minLength error because validation stops after enum violation
    });

    test('validateString returns correct boolean result', () {
      schema.minLength = 3;

      expect(schema.validateString('abcd'), isTrue);
      expect(schema.validateString('ab'), isFalse);
    });

    test(
      'validateStringWithExceptions throws exception with error message',
      () {
        schema.minLength = 3;

        // Should not throw
        schema.validateStringWithExceptions('abcd');

        // Should throw with the first error message
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
      },
    );
  });
}
