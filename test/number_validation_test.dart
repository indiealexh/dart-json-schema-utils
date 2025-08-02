import 'package:json_schema_utils/json_schema_utils.dart';
import 'package:test/test.dart';

void main() {
  group('NumberJsonSchema validation tests', () {
    late NumberJsonSchema schema;

    setUp(() {
      schema = NumberJsonSchema();
    });

    test('validate returns success for valid number', () {
      schema.minimum = 0;
      schema.maximum = 100;
      schema.multipleOf = 5;

      final result = schema.validate(25);

      expect(result.isValid, isTrue);
      expect(result.errors, isEmpty);
    });

    test('validate returns success for null value', () {
      schema.minimum = 0;
      schema.maximum = 100;
      schema.multipleOf = 5;

      final result = schema.validate(null);

      expect(result.isValid, isTrue);
      expect(result.errors, isEmpty);
    });

    test('validate reports type mismatch for non-number value', () {
      final result = schema.validate('not a number');

      expect(result.isValid, isFalse);
      expect(result.errors, hasLength(1));
      expect(result.errors[0].keyword, equals('type'));
      expect(result.errors[0].expected, equals(JsonType.number));
      expect(result.errors[0].actual, equals('not a number'));
      expect(result.errors[0].message, contains('Expected number but got'));
    });

    test('validate reports minimum violation', () {
      schema.minimum = 10;

      final result = schema.validate(5);

      expect(result.isValid, isFalse);
      expect(result.errors, hasLength(1));
      expect(result.errors[0].keyword, equals('minimum'));
      expect(result.errors[0].expected, equals(10));
      expect(result.errors[0].actual, equals(5));
      expect(
        result.errors[0].message,
        contains('must be greater than or equal to'),
      );
    });

    test('validate reports exclusiveMinimum violation', () {
      schema.exclusiveMinimum = 10;

      final result = schema.validate(10);

      expect(result.isValid, isFalse);
      expect(result.errors, hasLength(1));
      expect(result.errors[0].keyword, equals('exclusiveMinimum'));
      expect(result.errors[0].expected, equals(10));
      expect(result.errors[0].actual, equals(10));
      expect(result.errors[0].message, contains('must be greater than'));
    });

    test('validate reports maximum violation', () {
      schema.maximum = 10;

      final result = schema.validate(15);

      expect(result.isValid, isFalse);
      expect(result.errors, hasLength(1));
      expect(result.errors[0].keyword, equals('maximum'));
      expect(result.errors[0].expected, equals(10));
      expect(result.errors[0].actual, equals(15));
      expect(
        result.errors[0].message,
        contains('must be less than or equal to'),
      );
    });

    test('validate reports exclusiveMaximum violation', () {
      schema.exclusiveMaximum = 10;

      final result = schema.validate(10);

      expect(result.isValid, isFalse);
      expect(result.errors, hasLength(1));
      expect(result.errors[0].keyword, equals('exclusiveMaximum'));
      expect(result.errors[0].expected, equals(10));
      expect(result.errors[0].actual, equals(10));
      expect(result.errors[0].message, contains('must be less than'));
    });

    test('validate reports multipleOf violation', () {
      schema.multipleOf = 5;

      final result = schema.validate(12);

      expect(result.isValid, isFalse);
      expect(result.errors, hasLength(1));
      expect(result.errors[0].keyword, equals('multipleOf'));
      expect(result.errors[0].expected, equals(5));
      expect(result.errors[0].actual, equals(12));
      expect(result.errors[0].message, contains('must be a multiple of'));
    });

    test('validate reports multiple violations', () {
      schema.minimum = 10;
      schema.maximum = 100;
      schema.multipleOf = 5;

      final result = schema.validate(3);

      expect(result.isValid, isFalse);
      expect(
        result.errors,
        hasLength(2),
      ); // Both minimum and multipleOf violations

      // Check for minimum violation
      expect(result.errors.any((e) => e.keyword == 'minimum'), isTrue);

      // Check for multipleOf violation
      expect(result.errors.any((e) => e.keyword == 'multipleOf'), isTrue);
    });

    test('validate reports const violation', () {
      schema.constValue = 42;

      final result = schema.validate(7);

      expect(result.isValid, isFalse);
      expect(result.errors, hasLength(1));
      expect(result.errors[0].keyword, equals('const'));
      expect(result.errors[0].expected, equals(42));
      expect(result.errors[0].actual, equals(7));
      expect(result.errors[0].message, contains('must be equal to'));
    });

    test('validate reports enum violation', () {
      schema.enumValues = [10, 20, 30];

      final result = schema.validate(15);

      expect(result.isValid, isFalse);
      expect(result.errors, hasLength(1));
      expect(result.errors[0].keyword, equals('enum'));
      expect(result.errors[0].expected, equals([10, 20, 30]));
      expect(result.errors[0].actual, equals(15));
      expect(result.errors[0].message, contains('must be one of'));
    });

    test('validate includes path in error', () {
      schema.minimum = 10;

      final result = schema.validate(5, '/properties/age');

      expect(result.isValid, isFalse);
      expect(result.errors, hasLength(1));
      expect(result.errors[0].path, equals('/properties/age'));
    });

    test('validate stops after const violation', () {
      schema.constValue = 42;
      schema.minimum = 100; // This would normally cause a violation

      final result = schema.validate(7);

      expect(result.isValid, isFalse);
      expect(result.errors, hasLength(1));
      expect(result.errors[0].keyword, equals('const'));
      // No minimum error because validation stops after const violation
    });

    test('validate stops after enum violation', () {
      schema.enumValues = [10, 20, 30];
      schema.minimum = 100; // This would normally cause a violation

      final result = schema.validate(15);

      expect(result.isValid, isFalse);
      expect(result.errors, hasLength(1));
      expect(result.errors[0].keyword, equals('enum'));
      // No minimum error because validation stops after enum violation
    });

    test('validateNumber returns correct boolean result', () {
      schema.minimum = 10;

      expect(schema.validateNumber(15), isTrue);
      expect(schema.validateNumber(5), isFalse);
    });

    test(
      'validateNumberWithExceptions throws exception with error message',
      () {
        schema.minimum = 10;

        // Should not throw
        schema.validateNumberWithExceptions(15);

        // Should throw with the first error message
        expect(
          () => schema.validateNumberWithExceptions(5),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              contains('must be greater than or equal to'),
            ),
          ),
        );
      },
    );

    test('validate handles decimal numbers correctly', () {
      schema.multipleOf = 0.5;
      schema.minimum = 1.5;
      schema.maximum = 5.5;

      // Valid
      expect(schema.validate(2.5).isValid, isTrue);

      // Invalid - not a multiple of 0.5
      final result1 = schema.validate(2.75);
      expect(result1.isValid, isFalse);
      expect(result1.errors[0].keyword, equals('multipleOf'));

      // Invalid - below minimum
      final result2 = schema.validate(1.0);
      expect(result2.isValid, isFalse);
      expect(result2.errors[0].keyword, equals('minimum'));

      // Invalid - above maximum
      final result3 = schema.validate(6.0);
      expect(result3.isValid, isFalse);
      expect(result3.errors[0].keyword, equals('maximum'));
    });
  });
}
