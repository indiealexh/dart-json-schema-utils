import 'package:json_schema_utils/json_schema_utils.dart';
import 'package:test/test.dart';

void main() {
  group('Complex validation scenarios', () {
    test('Nested object validation with path reporting', () {
      // Create a schema for a person with name and age properties
      final personSchema = ObjectJsonSchema();

      // Create schema for name property (string with min length)
      final nameSchema = StringJsonSchema();
      nameSchema.minLength = 3;

      // Create schema for age property (number with minimum)
      final ageSchema = NumberJsonSchema();
      ageSchema.minimum = 18;

      // Add properties to person schema
      personSchema.properties = {'name': nameSchema, 'age': ageSchema};
      personSchema.required = ['name', 'age'];

      // Test with valid data
      final validResult = validateNestedObject(personSchema, {
        'name': 'John',
        'age': 25,
      }, '');
      expect(validResult.isValid, isTrue);

      // Test with invalid name (too short)
      final invalidNameResult = validateNestedObject(personSchema, {
        'name': 'Jo',
        'age': 25,
      }, '');
      expect(invalidNameResult.isValid, isFalse);
      expect(invalidNameResult.errors, hasLength(1));
      expect(invalidNameResult.errors[0].path, equals('/name'));
      expect(invalidNameResult.errors[0].keyword, equals('minLength'));

      // Test with invalid age (too young)
      final invalidAgeResult = validateNestedObject(personSchema, {
        'name': 'John',
        'age': 16,
      }, '');
      expect(invalidAgeResult.isValid, isFalse);
      expect(invalidAgeResult.errors, hasLength(1));
      expect(invalidAgeResult.errors[0].path, equals('/age'));
      expect(invalidAgeResult.errors[0].keyword, equals('minimum'));

      // Test with multiple invalid properties
      final multipleInvalidResult = validateNestedObject(personSchema, {
        'name': 'Jo',
        'age': 16,
      }, '');
      expect(multipleInvalidResult.isValid, isFalse);
      expect(multipleInvalidResult.errors, hasLength(2));

      // Check that we have both name and age errors
      expect(
        multipleInvalidResult.errors.any(
          (e) => e.path == '/name' && e.keyword == 'minLength',
        ),
        isTrue,
      );
      expect(
        multipleInvalidResult.errors.any(
          (e) => e.path == '/age' && e.keyword == 'minimum',
        ),
        isTrue,
      );

      // Test with missing required property
      final missingPropertyResult = validateNestedObject(personSchema, {
        'name': 'John',
      }, '');
      expect(missingPropertyResult.isValid, isFalse);
      expect(missingPropertyResult.errors, hasLength(1));
      expect(missingPropertyResult.errors[0].keyword, equals('required'));
      expect(missingPropertyResult.errors[0].message, contains('age'));
    });

    test('Nested array validation with path reporting', () {
      // Create a schema for an array of numbers
      final arraySchema = ArrayJsonSchema();

      // Create schema for array items (numbers with minimum)
      final itemSchema = NumberJsonSchema();
      itemSchema.minimum = 0;

      // Set items schema
      arraySchema.items = itemSchema;

      // Test with valid data
      final validResult = validateNestedArray(arraySchema, [1, 2, 3, 4, 5], '');
      expect(validResult.isValid, isTrue);

      // Test with one invalid item
      final invalidItemResult = validateNestedArray(arraySchema, [
        1,
        2,
        -3,
        4,
        5,
      ], '');
      expect(invalidItemResult.isValid, isFalse);
      expect(invalidItemResult.errors, hasLength(1));
      expect(invalidItemResult.errors[0].path, equals('/2'));
      expect(invalidItemResult.errors[0].keyword, equals('minimum'));

      // Test with multiple invalid items
      final multipleInvalidResult = validateNestedArray(arraySchema, [
        1,
        -2,
        -3,
        4,
        -5,
      ], '');
      expect(multipleInvalidResult.isValid, isFalse);
      expect(multipleInvalidResult.errors, hasLength(3));

      // Check that we have errors for all invalid items
      expect(
        multipleInvalidResult.errors.any(
          (e) => e.path == '/1' && e.keyword == 'minimum',
        ),
        isTrue,
      );
      expect(
        multipleInvalidResult.errors.any(
          (e) => e.path == '/2' && e.keyword == 'minimum',
        ),
        isTrue,
      );
      expect(
        multipleInvalidResult.errors.any(
          (e) => e.path == '/4' && e.keyword == 'minimum',
        ),
        isTrue,
      );
    });

    test('Complex nested object with arrays validation', () {
      // Create a schema for a user with personal info and a list of posts
      final userSchema = ObjectJsonSchema();

      // Create schema for personal info
      final personalInfoSchema = ObjectJsonSchema();

      final nameSchema = StringJsonSchema();
      nameSchema.minLength = 3;

      final emailSchema = StringJsonSchema();
      emailSchema.format = 'email';

      personalInfoSchema.properties = {
        'name': nameSchema,
        'email': emailSchema,
      };
      personalInfoSchema.required = ['name', 'email'];

      // Create schema for posts array
      final postsSchema = ArrayJsonSchema();

      // Create schema for post object
      final postSchema = ObjectJsonSchema();

      final titleSchema = StringJsonSchema();
      titleSchema.minLength = 5;

      final likesSchema = NumberJsonSchema();
      likesSchema.minimum = 0;

      postSchema.properties = {'title': titleSchema, 'likes': likesSchema};
      postSchema.required = ['title'];

      // Set posts items schema
      postsSchema.items = postSchema;

      // Add properties to user schema
      userSchema.properties = {
        'personalInfo': personalInfoSchema,
        'posts': postsSchema,
      };
      userSchema.required = ['personalInfo'];

      // Test with valid data
      final validUser = {
        'personalInfo': {'name': 'John Doe', 'email': 'john@example.com'},
        'posts': [
          {'title': 'My first post', 'likes': 10},
          {'title': 'Another post', 'likes': 5},
        ],
      };

      final validResult = validateComplexObject(userSchema, validUser, '');
      expect(validResult.isValid, isTrue);

      // Test with invalid personal info
      final invalidPersonalInfo = {
        'personalInfo': {
          'name': 'Jo', // Too short
          'email': 'not-an-email', // Invalid email
        },
        'posts': [
          {'title': 'My first post', 'likes': 10},
          {'title': 'Another post', 'likes': 5},
        ],
      };

      final invalidPersonalInfoResult = validateComplexObject(
        userSchema,
        invalidPersonalInfo,
        '',
      );
      expect(invalidPersonalInfoResult.isValid, isFalse);
      expect(invalidPersonalInfoResult.errors, hasLength(2));

      // Check personal info errors
      expect(
        invalidPersonalInfoResult.errors.any(
          (e) => e.path == '/personalInfo/name' && e.keyword == 'minLength',
        ),
        isTrue,
      );
      expect(
        invalidPersonalInfoResult.errors.any(
          (e) => e.path == '/personalInfo/email' && e.keyword == 'format',
        ),
        isTrue,
      );

      // Test with invalid posts
      final invalidPosts = {
        'personalInfo': {'name': 'John Doe', 'email': 'john@example.com'},
        'posts': [
          {'title': 'My first post', 'likes': 10},
          {'title': 'Hi', 'likes': -5}, // Title too short, negative likes
        ],
      };

      final invalidPostsResult = validateComplexObject(
        userSchema,
        invalidPosts,
        '',
      );
      expect(invalidPostsResult.isValid, isFalse);
      expect(invalidPostsResult.errors, hasLength(2));

      // Check posts errors
      expect(
        invalidPostsResult.errors.any(
          (e) => e.path == '/posts/1/title' && e.keyword == 'minLength',
        ),
        isTrue,
      );
      expect(
        invalidPostsResult.errors.any(
          (e) => e.path == '/posts/1/likes' && e.keyword == 'minimum',
        ),
        isTrue,
      );

      // Test with multiple errors throughout the object
      final multipleErrors = {
        'personalInfo': {
          'name': 'Jo', // Too short
          'email': 'not-an-email', // Invalid email
        },
        'posts': [
          {'title': 'My first post', 'likes': -10}, // Negative likes
          {'title': 'Hi', 'likes': -5}, // Title too short, negative likes
        ],
      };

      final multipleErrorsResult = validateComplexObject(
        userSchema,
        multipleErrors,
        '',
      );
      expect(multipleErrorsResult.isValid, isFalse);
      expect(multipleErrorsResult.errors, hasLength(5));

      // Check all errors
      expect(
        multipleErrorsResult.errors.any(
          (e) => e.path == '/personalInfo/name' && e.keyword == 'minLength',
        ),
        isTrue,
      );
      expect(
        multipleErrorsResult.errors.any(
          (e) => e.path == '/personalInfo/email' && e.keyword == 'format',
        ),
        isTrue,
      );
      expect(
        multipleErrorsResult.errors.any(
          (e) => e.path == '/posts/0/likes' && e.keyword == 'minimum',
        ),
        isTrue,
      );
      expect(
        multipleErrorsResult.errors.any(
          (e) => e.path == '/posts/1/title' && e.keyword == 'minLength',
        ),
        isTrue,
      );
      expect(
        multipleErrorsResult.errors.any(
          (e) => e.path == '/posts/1/likes' && e.keyword == 'minimum',
        ),
        isTrue,
      );
    });
  });
}

// Helper function to validate a nested object
ValidationResult validateNestedObject(
  ObjectJsonSchema schema,
  Map<String, dynamic> data,
  String path,
) {
  // Check required properties
  List<ValidationError> errors = [];

  if (schema.required != null) {
    for (final requiredProp in schema.required!) {
      if (!data.containsKey(requiredProp)) {
        errors.add(
          ValidationError.requiredPropertyViolation(
            path: path,
            propertyName: requiredProp,
            schema: schema,
          ),
        );
      }
    }
  }

  // Validate each property against its schema
  if (schema.properties != null) {
    for (final entry in schema.properties!.entries) {
      final propName = entry.key;
      final propSchema = entry.value;

      if (data.containsKey(propName)) {
        final propValue = data[propName];
        final propPath = path.isEmpty ? '/$propName' : '$path/$propName';

        ValidationResult propResult;

        if (propSchema is StringJsonSchema && propValue is String) {
          propResult = propSchema.validate(propValue, propPath);
        } else if (propSchema is NumberJsonSchema && propValue is num) {
          propResult = propSchema.validate(propValue, propPath);
        } else if (propSchema is ObjectJsonSchema &&
            propValue is Map<String, dynamic>) {
          propResult = validateNestedObject(propSchema, propValue, propPath);
        } else {
          // Type mismatch or unsupported schema type
          propResult = ValidationResult.singleFailure(
            ValidationError.typeMismatch(
              path: propPath,
              expected: propSchema.type,
              actual: propValue,
              schema: propSchema,
            ),
          );
        }

        if (!propResult.isValid) {
          errors.addAll(propResult.errors);
        }
      }
    }
  }

  return errors.isEmpty
      ? ValidationResult.success()
      : ValidationResult.failure(errors);
}

// Helper function to validate a nested array
ValidationResult validateNestedArray(
  ArrayJsonSchema schema,
  List<dynamic> data,
  String path,
) {
  List<ValidationError> errors = [];

  // Validate each item against the items schema
  if (schema.items != null && schema.items is JsonSchema) {
    final itemSchema = schema.items as JsonSchema;

    for (int i = 0; i < data.length; i++) {
      final itemValue = data[i];
      final itemPath = path.isEmpty ? '/$i' : '$path/$i';

      ValidationResult itemResult;

      if (itemSchema is StringJsonSchema && itemValue is String) {
        itemResult = itemSchema.validate(itemValue, itemPath);
      } else if (itemSchema is NumberJsonSchema && itemValue is num) {
        itemResult = itemSchema.validate(itemValue, itemPath);
      } else {
        // Type mismatch or unsupported schema type
        itemResult = ValidationResult.singleFailure(
          ValidationError.typeMismatch(
            path: itemPath,
            expected: itemSchema.type,
            actual: itemValue,
            schema: itemSchema,
          ),
        );
      }

      if (!itemResult.isValid) {
        errors.addAll(itemResult.errors);
      }
    }
  }

  return errors.isEmpty
      ? ValidationResult.success()
      : ValidationResult.failure(errors);
}

// Helper function to validate a complex object with nested arrays and objects
ValidationResult validateComplexObject(
  ObjectJsonSchema schema,
  Map<String, dynamic> data,
  String path,
) {
  // Check required properties
  List<ValidationError> errors = [];

  if (schema.required != null) {
    for (final requiredProp in schema.required!) {
      if (!data.containsKey(requiredProp)) {
        errors.add(
          ValidationError.requiredPropertyViolation(
            path: path,
            propertyName: requiredProp,
            schema: schema,
          ),
        );
      }
    }
  }

  // Validate each property against its schema
  if (schema.properties != null) {
    for (final entry in schema.properties!.entries) {
      final propName = entry.key;
      final propSchema = entry.value;

      if (data.containsKey(propName)) {
        final propValue = data[propName];
        final propPath = path.isEmpty ? '/$propName' : '$path/$propName';

        ValidationResult propResult;

        if (propSchema is StringJsonSchema && propValue is String) {
          propResult = propSchema.validate(propValue, propPath);
        } else if (propSchema is NumberJsonSchema && propValue is num) {
          propResult = propSchema.validate(propValue, propPath);
        } else if (propSchema is ObjectJsonSchema &&
            propValue is Map<String, dynamic>) {
          propResult = validateComplexObject(propSchema, propValue, propPath);
        } else if (propSchema is ArrayJsonSchema && propValue is List) {
          propResult = validateComplexArray(propSchema, propValue, propPath);
        } else {
          // Type mismatch or unsupported schema type
          propResult = ValidationResult.singleFailure(
            ValidationError.typeMismatch(
              path: propPath,
              expected: propSchema.type,
              actual: propValue,
              schema: propSchema,
            ),
          );
        }

        if (!propResult.isValid) {
          errors.addAll(propResult.errors);
        }
      }
    }
  }

  return errors.isEmpty
      ? ValidationResult.success()
      : ValidationResult.failure(errors);
}

// Helper function to validate a complex array with nested objects
ValidationResult validateComplexArray(
  ArrayJsonSchema schema,
  List<dynamic> data,
  String path,
) {
  List<ValidationError> errors = [];

  // Validate each item against the items schema
  if (schema.items != null && schema.items is JsonSchema) {
    final itemSchema = schema.items as JsonSchema;

    for (int i = 0; i < data.length; i++) {
      final itemValue = data[i];
      final itemPath = path.isEmpty ? '/$i' : '$path/$i';

      ValidationResult itemResult;

      if (itemSchema is StringJsonSchema && itemValue is String) {
        itemResult = itemSchema.validate(itemValue, itemPath);
      } else if (itemSchema is NumberJsonSchema && itemValue is num) {
        itemResult = itemSchema.validate(itemValue, itemPath);
      } else if (itemSchema is ObjectJsonSchema &&
          itemValue is Map<String, dynamic>) {
        itemResult = validateComplexObject(itemSchema, itemValue, itemPath);
      } else if (itemSchema is ArrayJsonSchema && itemValue is List) {
        itemResult = validateComplexArray(itemSchema, itemValue, itemPath);
      } else {
        // Type mismatch or unsupported schema type
        itemResult = ValidationResult.singleFailure(
          ValidationError.typeMismatch(
            path: itemPath,
            expected: itemSchema.type,
            actual: itemValue,
            schema: itemSchema,
          ),
        );
      }

      if (!itemResult.isValid) {
        errors.addAll(itemResult.errors);
      }
    }
  }

  return errors.isEmpty
      ? ValidationResult.success()
      : ValidationResult.failure(errors);
}
