import 'package:json_schema_utils/json_schema_utils.dart';
import 'package:test/test.dart';

void main() {
  group('ValidationError tests', () {
    test(
      'ValidationError constructor creates error with correct properties',
      () {
        final schema = StringJsonSchema();
        final error = ValidationError(
          path: '/properties/name',
          keyword: 'minLength',
          expected: 3,
          actual: 2,
          message: 'String length 2 is less than minimum length 3',
          schema: schema,
        );

        expect(error.path, equals('/properties/name'));
        expect(error.keyword, equals('minLength'));
        expect(error.expected, equals(3));
        expect(error.actual, equals(2));
        expect(
          error.message,
          equals('String length 2 is less than minimum length 3'),
        );
        expect(error.schema, equals(schema));
      },
    );

    test(
      'ValidationError.typeMismatch creates error with correct properties',
      () {
        final schema = StringJsonSchema();
        final error = ValidationError.typeMismatch(
          path: '/properties/name',
          expected: JsonType.string,
          actual: 123,
          schema: schema,
        );

        expect(error.path, equals('/properties/name'));
        expect(error.keyword, equals('type'));
        expect(error.expected, equals(JsonType.string));
        expect(error.actual, equals(123));
        expect(error.message, contains('Expected string but got'));
        expect(error.schema, equals(schema));
      },
    );

    test(
      'ValidationError.minimumViolation creates error with correct properties',
      () {
        final schema = NumberJsonSchema();
        final error = ValidationError.minimumViolation(
          path: '/properties/age',
          expected: 18,
          actual: 16,
          schema: schema,
        );

        expect(error.path, equals('/properties/age'));
        expect(error.keyword, equals('minimum'));
        expect(error.expected, equals(18));
        expect(error.actual, equals(16));
        expect(error.message, contains('must be greater than or equal to'));
        expect(error.schema, equals(schema));
      },
    );

    test(
      'ValidationError.minimumViolation with exclusive=true creates error with correct properties',
      () {
        final schema = NumberJsonSchema();
        final error = ValidationError.minimumViolation(
          path: '/properties/age',
          expected: 18,
          actual: 18,
          schema: schema,
          exclusive: true,
        );

        expect(error.path, equals('/properties/age'));
        expect(error.keyword, equals('exclusiveMinimum'));
        expect(error.expected, equals(18));
        expect(error.actual, equals(18));
        expect(error.message, contains('must be greater than'));
        expect(error.schema, equals(schema));
      },
    );

    test('ValidationError.toString returns formatted error message', () {
      final schema = StringJsonSchema();
      final error = ValidationError(
        path: '/properties/name',
        keyword: 'minLength',
        expected: 3,
        actual: 2,
        message: 'String length 2 is less than minimum length 3',
        schema: schema,
      );

      expect(
        error.toString(),
        equals(
          'ValidationError: String length 2 is less than minimum length 3 (at /properties/name)',
        ),
      );
    });
  });

  group('ValidationResult tests', () {
    test('ValidationResult.success creates valid result with no errors', () {
      final result = ValidationResult.success();

      expect(result.isValid, isTrue);
      expect(result.errors, isEmpty);
    });

    test('ValidationResult.failure creates invalid result with errors', () {
      final schema = StringJsonSchema();
      final errors = [
        ValidationError(
          path: '/properties/name',
          keyword: 'minLength',
          expected: 3,
          actual: 2,
          message: 'String length 2 is less than minimum length 3',
          schema: schema,
        ),
        ValidationError(
          path: '/properties/email',
          keyword: 'format',
          expected: 'email',
          actual: 'not-an-email',
          message: 'Invalid email format',
          schema: schema,
        ),
      ];
      final result = ValidationResult.failure(errors);

      expect(result.isValid, isFalse);
      expect(result.errors, hasLength(2));
      expect(result.errors[0].keyword, equals('minLength'));
      expect(result.errors[1].keyword, equals('format'));
    });

    test(
      'ValidationResult.singleFailure creates invalid result with one error',
      () {
        final schema = StringJsonSchema();
        final error = ValidationError(
          path: '/properties/name',
          keyword: 'minLength',
          expected: 3,
          actual: 2,
          message: 'String length 2 is less than minimum length 3',
          schema: schema,
        );
        final result = ValidationResult.singleFailure(error);

        expect(result.isValid, isFalse);
        expect(result.errors, hasLength(1));
        expect(result.errors[0], equals(error));
      },
    );

    test('ValidationResult.combine combines multiple results', () {
      final schema = StringJsonSchema();
      final result1 = ValidationResult.success();
      final result2 = ValidationResult.singleFailure(
        ValidationError(
          path: '/properties/name',
          keyword: 'minLength',
          expected: 3,
          actual: 2,
          message: 'String length 2 is less than minimum length 3',
          schema: schema,
        ),
      );
      final result3 = ValidationResult.singleFailure(
        ValidationError(
          path: '/properties/email',
          keyword: 'format',
          expected: 'email',
          actual: 'not-an-email',
          message: 'Invalid email format',
          schema: schema,
        ),
      );

      final combined = ValidationResult.combine([result1, result2, result3]);

      expect(combined.isValid, isFalse);
      expect(combined.errors, hasLength(2));
      expect(combined.errors[0].path, equals('/properties/name'));
      expect(combined.errors[1].path, equals('/properties/email'));
    });

    test('ValidationResult.where filters errors by predicate', () {
      final schema = StringJsonSchema();
      final errors = [
        ValidationError(
          path: '/properties/name',
          keyword: 'minLength',
          expected: 3,
          actual: 2,
          message: 'String length 2 is less than minimum length 3',
          schema: schema,
        ),
        ValidationError(
          path: '/properties/email',
          keyword: 'format',
          expected: 'email',
          actual: 'not-an-email',
          message: 'Invalid email format',
          schema: schema,
        ),
      ];
      final result = ValidationResult.failure(errors);

      final filtered = result.where((error) => error.keyword == 'minLength');

      expect(filtered.isValid, isFalse);
      expect(filtered.errors, hasLength(1));
      expect(filtered.errors[0].keyword, equals('minLength'));
    });

    test('ValidationResult.atPath filters errors by path', () {
      final schema = StringJsonSchema();
      final errors = [
        ValidationError(
          path: '/properties/name',
          keyword: 'minLength',
          expected: 3,
          actual: 2,
          message: 'String length 2 is less than minimum length 3',
          schema: schema,
        ),
        ValidationError(
          path: '/properties/email',
          keyword: 'format',
          expected: 'email',
          actual: 'not-an-email',
          message: 'Invalid email format',
          schema: schema,
        ),
      ];
      final result = ValidationResult.failure(errors);

      final filtered = result.atPath('/properties/email');

      expect(filtered.isValid, isFalse);
      expect(filtered.errors, hasLength(1));
      expect(filtered.errors[0].path, equals('/properties/email'));
    });

    test('ValidationResult.forKeyword filters errors by keyword', () {
      final schema = StringJsonSchema();
      final errors = [
        ValidationError(
          path: '/properties/name',
          keyword: 'minLength',
          expected: 3,
          actual: 2,
          message: 'String length 2 is less than minimum length 3',
          schema: schema,
        ),
        ValidationError(
          path: '/properties/email',
          keyword: 'format',
          expected: 'email',
          actual: 'not-an-email',
          message: 'Invalid email format',
          schema: schema,
        ),
      ];
      final result = ValidationResult.failure(errors);

      final filtered = result.forKeyword('format');

      expect(filtered.isValid, isFalse);
      expect(filtered.errors, hasLength(1));
      expect(filtered.errors[0].keyword, equals('format'));
    });

    test('ValidationResult.toString returns formatted result message', () {
      final schema = StringJsonSchema();
      final errors = [
        ValidationError(
          path: '/properties/name',
          keyword: 'minLength',
          expected: 3,
          actual: 2,
          message: 'String length 2 is less than minimum length 3',
          schema: schema,
        ),
      ];
      final result = ValidationResult.failure(errors);

      expect(result.toString(), contains('ValidationResult: Invalid'));
      expect(
        result.toString(),
        contains(
          'ValidationError: String length 2 is less than minimum length 3',
        ),
      );
    });
  });
}
