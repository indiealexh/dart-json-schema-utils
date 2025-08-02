import 'package:json_schema_utils/json_schema_utils.dart';
import 'package:test/test.dart';

void main() {
  group('ObjectJsonSchema tests', () {
    late ObjectJsonSchema schema;

    setUp(() {
      schema = ObjectJsonSchema();
    });

    test('type is initialized to Object', () {
      expect(schema.type, equals(JsonType.object));
    });

    test('setting type to non-Object throws exception', () {
      expect(() => schema.type = JsonType.string, throwsFormatException);
      expect(() => schema.type = JsonType.number, throwsFormatException);
      expect(() => schema.type = JsonType.integer, throwsFormatException);
      expect(() => schema.type = JsonType.array, throwsFormatException);
      expect(() => schema.type = JsonType.boolean, throwsFormatException);
      expect(() => schema.type = JsonType.nullValue, throwsFormatException);
      expect(
        () => schema.type = [JsonType.object, JsonType.string],
        throwsFormatException,
      );
    });

    test('setting type to Object or [Object] is allowed', () {
      // Should not throw
      schema.type = JsonType.object;
      schema.type = [JsonType.object];
    });

    test('defaultValue must be an object or null', () {
      // Should not throw
      schema.defaultValue = {'key': 'value'};
      schema.defaultValue = {};
      schema.defaultValue = null;

      // Should throw
      expect(() => schema.defaultValue = 123, throwsFormatException);
      expect(() => schema.defaultValue = 'test', throwsFormatException);
      expect(() => schema.defaultValue = true, throwsFormatException);
      expect(() => schema.defaultValue = [1, 2, 3], throwsFormatException);
    });

    test('constValue must be an object or null', () {
      // Should not throw
      schema.constValue = {'key': 'value'};
      schema.constValue = {};
      schema.constValue = null;

      // Should throw
      expect(() => schema.constValue = 123, throwsFormatException);
      expect(() => schema.constValue = 'test', throwsFormatException);
      expect(() => schema.constValue = true, throwsFormatException);
      expect(() => schema.constValue = [1, 2, 3], throwsFormatException);
    });

    test('enumValues must contain only objects', () {
      // Should not throw
      schema.enumValues = [
        {'key1': 'value1'},
        {'key2': 'value2'},
      ];
      schema.enumValues = [{}];
      schema.enumValues = null;

      // Should throw
      expect(() => schema.enumValues = [123, {}], throwsFormatException);
      expect(() => schema.enumValues = ['test', {}], throwsFormatException);
      expect(() => schema.enumValues = [true, {}], throwsFormatException);
      expect(
        () => schema.enumValues = [
          [1, 2, 3],
          {},
        ],
        throwsFormatException,
      );
    });

    group('Object validation tests', () {
      test('validateObject with valid values', () {
        // Valid
        expect(schema.validateObject({'key': 'value'}), isTrue);
        expect(schema.validateObject({}), isTrue);
        expect(schema.validateObject(null), isTrue);
      });

      test('validateObject with invalid values', () {
        // Invalid
        expect(schema.validateObject('test'), isFalse);
        expect(schema.validateObject(123), isFalse);
        expect(schema.validateObject(true), isFalse);
        expect(schema.validateObject([1, 2, 3]), isFalse);
      });

      test('validateObjectWithExceptions throws appropriate exceptions', () {
        // Should not throw
        schema.validateObjectWithExceptions({'key': 'value'});
        schema.validateObjectWithExceptions({});
        schema.validateObjectWithExceptions(null);

        // Should throw with appropriate messages
        expect(
          () => schema.validateObjectWithExceptions('test'),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              contains('must be an object'),
            ),
          ),
        );

        expect(
          () => schema.validateObjectWithExceptions(123),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              contains('must be an object'),
            ),
          ),
        );
      });

      test('validateObject with minProperties constraint', () {
        schema.minProperties = 2;

        // Valid
        expect(
          schema.validateObject({'key1': 'value1', 'key2': 'value2'}),
          isTrue,
        );
        expect(
          schema.validateObject({
            'key1': 'value1',
            'key2': 'value2',
            'key3': 'value3',
          }),
          isTrue,
        );

        // Invalid
        expect(schema.validateObject({'key1': 'value1'}), isFalse);
        expect(schema.validateObject({}), isFalse);
      });

      test('validateObject with maxProperties constraint', () {
        schema.maxProperties = 2;

        // Valid
        expect(schema.validateObject({}), isTrue);
        expect(schema.validateObject({'key1': 'value1'}), isTrue);
        expect(
          schema.validateObject({'key1': 'value1', 'key2': 'value2'}),
          isTrue,
        );

        // Invalid
        expect(
          schema.validateObject({
            'key1': 'value1',
            'key2': 'value2',
            'key3': 'value3',
          }),
          isFalse,
        );
      });

      test('validateObject with required properties', () {
        schema.required = ['name', 'age'];

        // Valid
        expect(schema.validateObject({'name': 'John', 'age': 30}), isTrue);
        expect(
          schema.validateObject({
            'name': 'John',
            'age': 30,
            'city': 'New York',
          }),
          isTrue,
        );

        // Invalid
        expect(schema.validateObject({'name': 'John'}), isFalse);
        expect(schema.validateObject({'age': 30}), isFalse);
        expect(schema.validateObject({'city': 'New York'}), isFalse);
        expect(schema.validateObject({}), isFalse);
      });

      test('validateObject with properties schema', () {
        var nameSchema = JsonSchema();
        nameSchema.type = JsonType.string;
        nameSchema.minLength = 2;

        var ageSchema = JsonSchema();
        ageSchema.type = JsonType.integer;
        ageSchema.minimum = 0;
        ageSchema.maximum = 120;

        schema.properties = {'name': nameSchema, 'age': ageSchema};

        // Valid
        expect(schema.validateObject({'name': 'John', 'age': 30}), isTrue);
        expect(
          schema.validateObject({
            'name': 'John',
            'age': 30,
            'city': 'New York',
          }),
          isTrue,
        );
        expect(
          schema.validateObject({}),
          isTrue,
        ); // Empty object is valid since no properties are required

        // Invalid - wrong property types
        expect(schema.validateObject({'name': 123, 'age': 30}), isFalse);
        expect(
          schema.validateObject({'name': 'John', 'age': 'thirty'}),
          isFalse,
        );

        // Invalid - property constraints
        expect(
          schema.validateObject({'name': 'J', 'age': 30}),
          isFalse,
        ); // name too short
        expect(
          schema.validateObject({'name': 'John', 'age': -1}),
          isFalse,
        ); // age below minimum
        expect(
          schema.validateObject({'name': 'John', 'age': 121}),
          isFalse,
        ); // age above maximum
      });

      test('validateObject with patternProperties', () {
        var stringSchema = JsonSchema();
        stringSchema.type = JsonType.string;

        var numberSchema = JsonSchema();
        numberSchema.type = JsonType.number;

        schema.patternProperties = {
          '^str_': stringSchema,
          '^num_': numberSchema,
        };

        // Valid
        expect(
          schema.validateObject({
            'str_name': 'John',
            'num_age': 30,
            'other': true,
          }),
          isTrue,
        );

        // Invalid
        expect(
          schema.validateObject({
            'str_name': 123, // Should be string
            'num_age': 30,
          }),
          isFalse,
        );

        expect(
          schema.validateObject({
            'str_name': 'John',
            'num_age': 'thirty', // Should be number
          }),
          isFalse,
        );
      });

      test('validateObject with additionalProperties as boolean', () {
        var nameSchema = JsonSchema();
        nameSchema.type = JsonType.string;

        var ageSchema = JsonSchema();
        ageSchema.type = JsonType.integer;

        schema.properties = {'name': nameSchema, 'age': ageSchema};
        schema.additionalProperties = false;

        // Valid
        expect(schema.validateObject({'name': 'John', 'age': 30}), isTrue);
        expect(schema.validateObject({'name': 'John'}), isTrue);
        expect(schema.validateObject({'age': 30}), isTrue);
        expect(schema.validateObject({}), isTrue);

        // Invalid - has additional properties
        expect(
          schema.validateObject({
            'name': 'John',
            'age': 30,
            'city': 'New York',
          }),
          isFalse,
        );
        expect(schema.validateObject({'city': 'New York'}), isFalse);
      });

      test('validateObject with additionalProperties as schema', () {
        var nameSchema = JsonSchema();
        nameSchema.type = JsonType.string;

        var ageSchema = JsonSchema();
        ageSchema.type = JsonType.integer;

        var stringSchema = JsonSchema();
        stringSchema.type = JsonType.string;

        schema.properties = {'name': nameSchema, 'age': ageSchema};
        schema.additionalProperties = stringSchema;

        // Valid
        expect(schema.validateObject({'name': 'John', 'age': 30}), isTrue);
        expect(
          schema.validateObject({
            'name': 'John',
            'age': 30,
            'city': 'New York',
          }),
          isTrue,
        );
        expect(schema.validateObject({'city': 'New York'}), isTrue);

        // Invalid - additional property not matching schema
        expect(
          schema.validateObject({'name': 'John', 'age': 30, 'score': 100}),
          isFalse,
        );
        expect(schema.validateObject({'score': 100}), isFalse);
      });

      test('validateObject with property dependencies', () {
        schema.dependencies = {
          'credit_card': ['billing_address'],
        };

        // Valid
        expect(schema.validateObject({}), isTrue);
        expect(
          schema.validateObject({'billing_address': '123 Main St'}),
          isTrue,
        );
        expect(
          schema.validateObject({
            'credit_card': '1234-5678-9012-3456',
            'billing_address': '123 Main St',
          }),
          isTrue,
        );

        // Invalid - missing dependent property
        expect(
          schema.validateObject({'credit_card': '1234-5678-9012-3456'}),
          isFalse,
        );
      });

      test('validateObject with schema dependencies', () {
        var addressSchema = JsonSchema();
        addressSchema.required = ['street', 'city', 'state'];

        schema.dependencies = {'credit_card': addressSchema};

        // Valid
        expect(schema.validateObject({}), isTrue);
        expect(
          schema.validateObject({
            'street': '123 Main St',
            'city': 'Anytown',
            'state': 'CA',
          }),
          isTrue,
        );
        expect(
          schema.validateObject({
            'credit_card': '1234-5678-9012-3456',
            'street': '123 Main St',
            'city': 'Anytown',
            'state': 'CA',
          }),
          isTrue,
        );

        // Invalid - missing required properties from schema dependency
        expect(
          schema.validateObject({'credit_card': '1234-5678-9012-3456'}),
          isFalse,
        );
        expect(
          schema.validateObject({
            'credit_card': '1234-5678-9012-3456',
            'street': '123 Main St',
          }),
          isFalse,
        );
      });

      test('validateObject with propertyNames', () {
        var propNameSchema = JsonSchema();
        propNameSchema.type = JsonType.string;
        propNameSchema.pattern = r'^[a-z_]+$';

        schema.propertyNames = propNameSchema;

        // Valid
        expect(schema.validateObject({}), isTrue);
        expect(schema.validateObject({'name': 'John', 'age': 30}), isTrue);
        expect(
          schema.validateObject({'user_name': 'John', 'user_age': 30}),
          isTrue,
        );

        // Invalid - property names don't match pattern
        expect(schema.validateObject({'Name': 'John'}), isFalse);
        expect(schema.validateObject({'user-name': 'John'}), isFalse);
        expect(schema.validateObject({'123': 'John'}), isFalse);
      });

      test('validateObject with multiple constraints', () {
        var nameSchema = JsonSchema();
        nameSchema.type = JsonType.string;
        nameSchema.minLength = 2;

        var ageSchema = JsonSchema();
        ageSchema.type = JsonType.integer;
        ageSchema.minimum = 0;
        ageSchema.maximum = 120;

        schema.properties = {'name': nameSchema, 'age': ageSchema};
        schema.required = ['name', 'age'];
        schema.minProperties = 2;
        schema.maxProperties = 3;
        schema.additionalProperties = false;

        // Valid
        expect(schema.validateObject({'name': 'John', 'age': 30}), isTrue);

        // Invalid - missing required property
        expect(schema.validateObject({'name': 'John'}), isFalse);

        // Invalid - too few properties
        expect(schema.validateObject({}), isFalse);

        // Invalid - too many properties
        expect(
          schema.validateObject({
            'name': 'John',
            'age': 30,
            'city': 'New York',
            'country': 'USA',
          }),
          isFalse,
        );

        // Invalid - additional property not allowed
        expect(
          schema.validateObject({
            'name': 'John',
            'age': 30,
            'city': 'New York',
          }),
          isFalse,
        );

        // Invalid - property doesn't match its schema
        expect(
          schema.validateObject({
            'name': 'J', // too short
            'age': 30,
          }),
          isFalse,
        );
      });

      test('validateObject with enum constraint', () {
        schema.enumValues = [
          {'type': 'person', 'name': 'John'},
          {'type': 'company', 'name': 'Acme Inc'},
        ];

        // Valid
        expect(
          schema.validateObject({'type': 'person', 'name': 'John'}),
          isTrue,
        );
        expect(
          schema.validateObject({'type': 'company', 'name': 'Acme Inc'}),
          isTrue,
        );

        // Invalid - not in enum
        expect(
          schema.validateObject({'type': 'person', 'name': 'Jane'}),
          isFalse,
        );
        expect(
          schema.validateObject({'type': 'organization', 'name': 'Acme Inc'}),
          isFalse,
        );
        expect(schema.validateObject({}), isFalse);

        // Setting defaultValue to a value not in enum should throw
        expect(
          () => schema.defaultValue = {'type': 'person', 'name': 'Jane'},
          throwsFormatException,
        );
      });

      test('validateObject with const constraint', () {
        schema.constValue = {'type': 'config', 'readonly': true};

        // Valid
        expect(
          schema.validateObject({'type': 'config', 'readonly': true}),
          isTrue,
        );

        // Invalid - not equal to const
        expect(
          schema.validateObject({'type': 'config', 'readonly': false}),
          isFalse,
        );
        expect(
          schema.validateObject({'type': 'settings', 'readonly': true}),
          isFalse,
        );
        expect(schema.validateObject({}), isFalse);

        // Setting defaultValue to a value not equal to const should throw
        expect(
          () => schema.defaultValue = {'type': 'config', 'readonly': false},
          throwsFormatException,
        );
      });
    });
  });
}
