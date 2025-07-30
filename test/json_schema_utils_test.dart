import 'package:json_schema_utils/json_schema_utils.dart';
import 'package:json_schema_utils/src/json_schema.dart';
import 'package:test/test.dart';

class TestJsonSchema extends JsonSchema {}

void main() {
  group('JsonSchema defaultValue validation tests', () {
    late TestJsonSchema schema;

    setUp(() {
      schema = TestJsonSchema();
    });

    test('defaultValue with no constraints should be valid', () {
      // Should not throw
      schema.defaultValue = 'test';
      schema.defaultValue = 123;
      schema.defaultValue = true;
      schema.defaultValue = [1, 2, 3];
      schema.defaultValue = {'key': 'value'};
      schema.defaultValue = null;
    });

    group('Type constraints', () {
      test('defaultValue should match string type', () {
        schema.type = JsonType.string;

        // Should not throw
        schema.defaultValue = 'test';

        // Should throw
        expect(() => schema.defaultValue = 123, throwsFormatException);
        expect(() => schema.defaultValue = true, throwsFormatException);
        expect(() => schema.defaultValue = [1, 2, 3], throwsFormatException);
        expect(
          () => schema.defaultValue = {'key': 'value'},
          throwsFormatException,
        );
      });

      test('defaultValue should match number type', () {
        schema.type = JsonType.number;

        // Should not throw
        schema.defaultValue = 123;
        schema.defaultValue = 123.45;

        // Should throw
        expect(() => schema.defaultValue = 'test', throwsFormatException);
        expect(() => schema.defaultValue = true, throwsFormatException);
        expect(() => schema.defaultValue = [1, 2, 3], throwsFormatException);
        expect(
          () => schema.defaultValue = {'key': 'value'},
          throwsFormatException,
        );
      });

      test('defaultValue should match integer type', () {
        schema.type = JsonType.integer;

        // Should not throw
        schema.defaultValue = 123;

        // Should throw
        expect(() => schema.defaultValue = 123.45, throwsFormatException);
        expect(() => schema.defaultValue = 'test', throwsFormatException);
        expect(() => schema.defaultValue = true, throwsFormatException);
        expect(() => schema.defaultValue = [1, 2, 3], throwsFormatException);
        expect(
          () => schema.defaultValue = {'key': 'value'},
          throwsFormatException,
        );
      });

      test('defaultValue should match boolean type', () {
        schema.type = JsonType.boolean;

        // Should not throw
        schema.defaultValue = true;
        schema.defaultValue = false;

        // Should throw
        expect(() => schema.defaultValue = 123, throwsFormatException);
        expect(() => schema.defaultValue = 'test', throwsFormatException);
        expect(() => schema.defaultValue = [1, 2, 3], throwsFormatException);
        expect(
          () => schema.defaultValue = {'key': 'value'},
          throwsFormatException,
        );
      });

      test('defaultValue should match array type', () {
        schema.type = JsonType.array;

        // Should not throw
        schema.defaultValue = [1, 2, 3];
        schema.defaultValue = [];

        // Should throw
        expect(() => schema.defaultValue = 123, throwsFormatException);
        expect(() => schema.defaultValue = 'test', throwsFormatException);
        expect(() => schema.defaultValue = true, throwsFormatException);
        expect(
          () => schema.defaultValue = {'key': 'value'},
          throwsFormatException,
        );
      });

      test('defaultValue should match object type', () {
        schema.type = JsonType.object;

        // Should not throw
        schema.defaultValue = {'key': 'value'};
        schema.defaultValue = {};

        // Should throw
        expect(() => schema.defaultValue = 123, throwsFormatException);
        expect(() => schema.defaultValue = 'test', throwsFormatException);
        expect(() => schema.defaultValue = true, throwsFormatException);
        expect(() => schema.defaultValue = [1, 2, 3], throwsFormatException);
      });

      test('defaultValue should match null type', () {
        schema.type = JsonType.nullValue;

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

      test('defaultValue should match one of multiple types', () {
        schema.type = [JsonType.string, JsonType.number];

        // Should not throw
        schema.defaultValue = 'test';
        schema.defaultValue = 123;
        schema.defaultValue = 123.45;

        // Should throw
        expect(() => schema.defaultValue = true, throwsFormatException);
        expect(() => schema.defaultValue = [1, 2, 3], throwsFormatException);
        expect(
          () => schema.defaultValue = {'key': 'value'},
          throwsFormatException,
        );
      });
    });

    group('Enum constraints', () {
      test('defaultValue should be one of the enum values', () {
        schema.enumValues = ['test', 123, true];

        // Should not throw
        schema.defaultValue = 'test';
        schema.defaultValue = 123;
        schema.defaultValue = true;

        // Should throw
        expect(() => schema.defaultValue = 'other', throwsFormatException);
        expect(() => schema.defaultValue = 456, throwsFormatException);
        expect(() => schema.defaultValue = false, throwsFormatException);
      });
    });

    group('Const constraints', () {
      test('defaultValue should match const value', () {
        schema.constValue = 'test';

        // Should not throw
        schema.defaultValue = 'test';

        // Should throw
        expect(() => schema.defaultValue = 'other', throwsFormatException);
      });
    });

    group('Numeric constraints', () {
      test('defaultValue should satisfy multipleOf', () {
        schema.type = JsonType.number;
        schema.multipleOf = 5;

        // Should not throw
        schema.defaultValue = 0;
        schema.defaultValue = 5;
        schema.defaultValue = 10;
        schema.defaultValue = -5;

        // Should throw
        expect(() => schema.defaultValue = 3, throwsFormatException);
        expect(() => schema.defaultValue = 7, throwsFormatException);
      });

      test('defaultValue should satisfy minimum', () {
        schema.type = JsonType.number;
        schema.minimum = 5;

        // Should not throw
        schema.defaultValue = 5;
        schema.defaultValue = 10;

        // Should throw
        expect(() => schema.defaultValue = 4, throwsFormatException);
        expect(() => schema.defaultValue = 0, throwsFormatException);
        expect(() => schema.defaultValue = -5, throwsFormatException);
      });

      test('defaultValue should satisfy exclusiveMinimum', () {
        schema.type = JsonType.number;
        schema.exclusiveMinimum = 5;

        // Should not throw
        schema.defaultValue = 6;
        schema.defaultValue = 10;

        // Should throw
        expect(() => schema.defaultValue = 5, throwsFormatException);
        expect(() => schema.defaultValue = 4, throwsFormatException);
        expect(() => schema.defaultValue = 0, throwsFormatException);
      });

      test('defaultValue should satisfy maximum', () {
        schema.type = JsonType.number;
        schema.maximum = 10;

        // Should not throw
        schema.defaultValue = 10;
        schema.defaultValue = 5;
        schema.defaultValue = 0;

        // Should throw
        expect(() => schema.defaultValue = 11, throwsFormatException);
        expect(() => schema.defaultValue = 20, throwsFormatException);
      });

      test('defaultValue should satisfy exclusiveMaximum', () {
        schema.type = JsonType.number;
        schema.exclusiveMaximum = 10;

        // Should not throw
        schema.defaultValue = 9;
        schema.defaultValue = 5;
        schema.defaultValue = 0;

        // Should throw
        expect(() => schema.defaultValue = 10, throwsFormatException);
        expect(() => schema.defaultValue = 11, throwsFormatException);
      });

      test('defaultValue should satisfy multiple numeric constraints', () {
        schema.type = JsonType.number;
        schema.minimum = 5;
        schema.maximum = 20;
        schema.multipleOf = 5;

        // Should not throw
        schema.defaultValue = 5;
        schema.defaultValue = 10;
        schema.defaultValue = 15;
        schema.defaultValue = 20;

        // Should throw - below minimum
        expect(() => schema.defaultValue = 0, throwsFormatException);
        // Should throw - above maximum
        expect(() => schema.defaultValue = 25, throwsFormatException);
        // Should throw - not multiple of 5
        expect(() => schema.defaultValue = 7, throwsFormatException);
      });
    });

    group('String constraints', () {
      test('defaultValue should satisfy minLength', () {
        schema.type = JsonType.string;
        schema.minLength = 3;

        // Should not throw
        schema.defaultValue = 'abc';
        schema.defaultValue = 'abcd';

        // Should throw
        expect(() => schema.defaultValue = 'ab', throwsFormatException);
        expect(() => schema.defaultValue = '', throwsFormatException);
      });

      test('defaultValue should satisfy maxLength', () {
        schema.type = JsonType.string;
        schema.maxLength = 5;

        // Should not throw
        schema.defaultValue = 'abc';
        schema.defaultValue = 'abcde';

        // Should throw
        expect(() => schema.defaultValue = 'abcdef', throwsFormatException);
      });

      test('defaultValue should satisfy pattern', () {
        schema.type = JsonType.string;
        schema.pattern = r'^[a-z]+$';

        // Should not throw
        schema.defaultValue = 'abc';

        // Should throw
        expect(() => schema.defaultValue = 'ABC', throwsFormatException);
        expect(() => schema.defaultValue = '123', throwsFormatException);
        expect(() => schema.defaultValue = 'abc123', throwsFormatException);
      });

      test('defaultValue should satisfy multiple string constraints', () {
        schema.type = JsonType.string;
        schema.minLength = 3;
        schema.maxLength = 5;
        schema.pattern = r'^[a-z]+$';

        // Should not throw
        schema.defaultValue = 'abc';
        schema.defaultValue = 'abcd';
        schema.defaultValue = 'abcde';

        // Should throw - too short
        expect(() => schema.defaultValue = 'ab', throwsFormatException);
        // Should throw - too long
        expect(() => schema.defaultValue = 'abcdef', throwsFormatException);
        // Should throw - doesn't match pattern
        expect(() => schema.defaultValue = 'ABC', throwsFormatException);
      });
    });

    group('Array constraints', () {
      test('defaultValue should satisfy minItems', () {
        schema.type = JsonType.array;
        schema.minItems = 2;

        // Should not throw
        schema.defaultValue = [1, 2];
        schema.defaultValue = [1, 2, 3];

        // Should throw
        expect(() => schema.defaultValue = [1], throwsFormatException);
        expect(() => schema.defaultValue = [], throwsFormatException);
      });

      test('defaultValue should satisfy maxItems', () {
        schema.type = JsonType.array;
        schema.maxItems = 3;

        // Should not throw
        schema.defaultValue = [];
        schema.defaultValue = [1];
        schema.defaultValue = [1, 2];
        schema.defaultValue = [1, 2, 3];

        // Should throw
        expect(() => schema.defaultValue = [1, 2, 3, 4], throwsFormatException);
      });

      test('defaultValue should satisfy uniqueItems', () {
        schema.type = JsonType.array;
        schema.uniqueItems = true;

        // Should not throw
        schema.defaultValue = [1, 2, 3];
        schema.defaultValue = ['a', 'b', 'c'];

        // Should throw
        expect(() => schema.defaultValue = [1, 2, 1], throwsFormatException);
        expect(
          () => schema.defaultValue = ['a', 'b', 'a'],
          throwsFormatException,
        );
      });

      test('defaultValue should satisfy multiple array constraints', () {
        schema.type = JsonType.array;
        schema.minItems = 2;
        schema.maxItems = 4;
        schema.uniqueItems = true;

        // Should not throw
        schema.defaultValue = [1, 2];
        schema.defaultValue = [1, 2, 3];
        schema.defaultValue = [1, 2, 3, 4];

        // Should throw - too few items
        expect(() => schema.defaultValue = [1], throwsFormatException);
        // Should throw - too many items
        expect(
          () => schema.defaultValue = [1, 2, 3, 4, 5],
          throwsFormatException,
        );
        // Should throw - duplicate items
        expect(() => schema.defaultValue = [1, 2, 1], throwsFormatException);
      });
    });

    group('Object constraints', () {
      test('defaultValue should satisfy minProperties', () {
        schema.type = JsonType.object;
        schema.minProperties = 2;

        // Should not throw
        schema.defaultValue = {'a': 1, 'b': 2};
        schema.defaultValue = {'a': 1, 'b': 2, 'c': 3};

        // Should throw
        expect(() => schema.defaultValue = {'a': 1}, throwsFormatException);
        expect(() => schema.defaultValue = {}, throwsFormatException);
      });

      test('defaultValue should satisfy maxProperties', () {
        schema.type = JsonType.object;
        schema.maxProperties = 3;

        // Should not throw
        schema.defaultValue = {};
        schema.defaultValue = {'a': 1};
        schema.defaultValue = {'a': 1, 'b': 2};
        schema.defaultValue = {'a': 1, 'b': 2, 'c': 3};

        // Should throw
        expect(
          () => schema.defaultValue = {'a': 1, 'b': 2, 'c': 3, 'd': 4},
          throwsFormatException,
        );
      });

      test('defaultValue should satisfy required', () {
        schema.type = JsonType.object;
        schema.required = ['a', 'b'];

        // Should not throw
        schema.defaultValue = {'a': 1, 'b': 2};
        schema.defaultValue = {'a': 1, 'b': 2, 'c': 3};

        // Should throw
        expect(() => schema.defaultValue = {'a': 1}, throwsFormatException);
        expect(() => schema.defaultValue = {'b': 2}, throwsFormatException);
        expect(() => schema.defaultValue = {'c': 3}, throwsFormatException);
        expect(() => schema.defaultValue = {}, throwsFormatException);
      });

      test('defaultValue should satisfy multiple object constraints', () {
        schema.type = JsonType.object;
        schema.minProperties = 2;
        schema.maxProperties = 4;
        schema.required = ['a', 'b'];

        // Should not throw
        schema.defaultValue = {'a': 1, 'b': 2};
        schema.defaultValue = {'a': 1, 'b': 2, 'c': 3};
        schema.defaultValue = {'a': 1, 'b': 2, 'c': 3, 'd': 4};

        // Should throw - too few properties
        expect(() => schema.defaultValue = {'a': 1}, throwsFormatException);
        // Should throw - too many properties
        expect(
          () => schema.defaultValue = {'a': 1, 'b': 2, 'c': 3, 'd': 4, 'e': 5},
          throwsFormatException,
        );
        // Should throw - missing required property
        expect(
          () => schema.defaultValue = {'c': 3, 'd': 4},
          throwsFormatException,
        );
      });
    });

    group('Combined constraints', () {
      test('enum should take precedence over type', () {
        schema.type = JsonType.string;
        schema.enumValues = [123, 456];

        // Should not throw - enum takes precedence
        schema.defaultValue = 123;

        // Should throw - not in enum
        expect(() => schema.defaultValue = 'test', throwsFormatException);
      });

      test('const should take precedence over enum', () {
        schema.constValue = 'test';
        schema.enumValues = [123, 456];

        // Should not throw - const takes precedence
        schema.defaultValue = 'test';

        // Should throw - not equal to const
        expect(() => schema.defaultValue = 123, throwsFormatException);
      });
    });
  });
}
