import 'package:json_schema_utils/json_schema_utils.dart';

void main() {
  // Part 1: General JsonSchema example
  print('=== General JsonSchema Example ===');
  generalJsonSchemaExample();

  // Part 2: StringJsonSchema example
  print('\n\n=== StringJsonSchema Example ===');
  stringJsonSchemaExample();

  // Part 3: BooleanJsonSchema example
  print('\n\n=== BooleanJsonSchema Example ===');
  booleanJsonSchemaExample();

  // Part 4: NumberJsonSchema example
  print('\n\n=== NumberJsonSchema Example ===');
  numberJsonSchemaExample();
}

void generalJsonSchemaExample() {
  // Create a basic schema document
  var schema = JsonSchemaDocument(
    "https://indiealexh.dev/schema/vehicle",
    "Vehicle Schema",
    "A Schema to describe a vehicle",
  );

  try {
    // Test basic properties
    print('Testing basic properties...');
    schema
      ..id = "https://example.com/schemas/vehicle"
      ..comment = "This is a comment"
      ..defaultValue = {"type": "sedan"}
      ..examples = [
        {"type": "sedan"},
        {"type": "suv"},
      ]
      ..readOnly = true
      ..writeOnly = false;

    // Test type property
    print('Testing type property...');
    schema.type = JsonType.object;

    // Test numeric validation
    print('Testing numeric validation...');
    schema.multipleOf = 2;
    schema.maximum = 100;
    schema.exclusiveMaximum = 99;
    schema.minimum = 1;
    schema.exclusiveMinimum = 2;

    // Test string validation
    print('Testing string validation...');
    schema.maxLength = 50;
    schema.minLength = 1;
    schema.pattern = r"^[a-zA-Z0-9]+$";

    // Test array validation
    print('Testing array validation...');
    schema.maxItems = 10;
    schema.minItems = 1;
    schema.uniqueItems = true;

    // Test object validation
    print('Testing object validation...');
    schema.maxProperties = 20;
    schema.minProperties = 1;
    schema.required = ["type", "make", "model"];

    // Test format
    print('Testing format...');
    schema.format = "email";
    schema.contentMediaType = "application/json";
    schema.contentEncoding = "utf-8";

    // Print the final schema
    print('Final schema: ${schema.toJson()}');
    print('All tests passed successfully!');
  } catch (e) {
    print('Error: $e');
  }

  // Test validation errors
  print('\nTesting validation errors...');

  // Test multipleOf validation
  try {
    schema.multipleOf = 0;
    print('Failed: multipleOf should not accept 0');
  } catch (e) {
    print('Success: multipleOf validation works - $e');
  }

  // Test maxLength validation
  try {
    schema.maxLength = -1;
    print('Failed: maxLength should not accept negative values');
  } catch (e) {
    print('Success: maxLength validation works - $e');
  }

  // Test minLength validation
  try {
    schema.minLength = -1;
    print('Failed: minLength should not accept negative values');
  } catch (e) {
    print('Success: minLength validation works - $e');
  }

  // Test pattern validation
  try {
    schema.pattern = "["; // Invalid regex
    print('Failed: pattern should not accept invalid regex');
  } catch (e) {
    print('Success: pattern validation works - $e');
  }

  // Test required validation
  try {
    schema.required = []; // Empty array
    print('Failed: required should not accept empty array');
  } catch (e) {
    print('Success: required validation works - $e');
  }

  // Test allOf validation
  try {
    schema.allOf = []; // Empty array
    print('Failed: allOf should not accept empty array');
  } catch (e) {
    print('Success: allOf validation works - $e');
  }
}

void stringJsonSchemaExample() {
  print('Creating a StringJsonSchema for email validation...');

  // Create a StringJsonSchema for email validation
  var emailSchema = StringJsonSchema()
    ..title = "Email Schema"
    ..description = "A schema for validating email addresses"
    ..format = "email"
    ..minLength = 5
    ..maxLength = 100
    ..pattern = r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$";

  print('Schema created: ${emailSchema.toJson()}');

  // Test valid emails
  print('\nValidating valid email addresses:');
  var validEmails = [
    'user@example.com',
    'john.doe@company.co.uk',
    'info@test-site.org',
  ];

  for (var email in validEmails) {
    bool isValid = emailSchema.validateString(email);
    print('  $email: ${isValid ? 'Valid' : 'Invalid'}');
  }

  // Test invalid emails
  print('\nValidating invalid email addresses:');
  var invalidEmails = [
    'not-an-email',
    'missing@domain',
    '@missing-username.com',
    'too.short@a.b', // Too short
    'a' * 101 + '@example.com', // Too long
  ];

  for (var email in invalidEmails) {
    bool isValid = emailSchema.validateString(email);
    print('  $email: ${isValid ? 'Valid' : 'Invalid'}');
  }

  // Demonstrate type restriction
  print('\nDemonstrating type restriction:');
  try {
    print('  Attempting to set type to number...');
    emailSchema.type = JsonType.number;
    print('  Failed: Should not allow setting type to number');
  } catch (e) {
    print('  Success: ${e.toString()}');
  }

  // Demonstrate defaultValue restriction
  print('\nDemonstrating defaultValue restriction:');
  try {
    print('  Setting defaultValue to a valid string...');
    emailSchema.defaultValue = 'default@example.com';
    print('  Success: defaultValue set to ${emailSchema.defaultValue}');

    print('  Attempting to set defaultValue to a number...');
    emailSchema.defaultValue = 123;
    print('  Failed: Should not allow setting defaultValue to a number');
  } catch (e) {
    print('  Success: ${e.toString()}');
  }

  // Create a password schema
  print('\nCreating a StringJsonSchema for password validation...');
  var passwordSchema = StringJsonSchema()
    ..title = "Password Schema"
    ..description = "A schema for validating passwords"
    ..minLength = 8
    ..maxLength = 64
    ..pattern =
        r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]+$";

  print('Schema created: ${passwordSchema.toJson()}');

  // Test valid and invalid passwords
  print('\nValidating passwords:');
  var passwords = [
    'Abcd1234!', // Valid
    'weakpassword', // Invalid - no uppercase, digits or special chars
    'Short1!', // Invalid - too short
  ];

  for (var password in passwords) {
    bool isValid = passwordSchema.validateString(password);
    print('  "${password}": ${isValid ? 'Valid' : 'Invalid'}');
  }
}

void booleanJsonSchemaExample() {
  print('Creating a BooleanJsonSchema for feature flag validation...');

  // Create a BooleanJsonSchema for feature flag validation
  var featureFlagSchema = BooleanJsonSchema()
    ..title = "Feature Flag Schema"
    ..description = "A schema for validating feature flag values"
    ..defaultValue = false;

  print('Schema created: ${featureFlagSchema.toJson()}');

  // Test valid boolean values
  print('\nValidating valid boolean values:');
  var validBooleans = [true, false];

  for (var value in validBooleans) {
    bool isValid = featureFlagSchema.validateBoolean(value);
    print('  $value: ${isValid ? 'Valid' : 'Invalid'}');
  }

  // Test invalid boolean values
  print('\nValidating invalid boolean values:');
  var invalidValues = [
    'true', // String, not boolean
    1, // Number, not boolean
    0, // Number, not boolean
    {}, // Object, not boolean
    [], // Array, not boolean
  ];

  for (var value in invalidValues) {
    bool isValid = featureFlagSchema.validateBoolean(value);
    print('  $value: ${isValid ? 'Valid' : 'Invalid'}');
  }

  // Demonstrate type restriction
  print('\nDemonstrating type restriction:');
  try {
    print('  Attempting to set type to string...');
    featureFlagSchema.type = JsonType.string;
    print('  Failed: Should not allow setting type to string');
  } catch (e) {
    print('  Success: ${e.toString()}');
  }

  // Demonstrate defaultValue restriction
  print('\nDemonstrating defaultValue restriction:');
  try {
    print('  Setting defaultValue to a valid boolean...');
    featureFlagSchema.defaultValue = true;
    print('  Success: defaultValue set to ${featureFlagSchema.defaultValue}');

    print('  Attempting to set defaultValue to a string...');
    featureFlagSchema.defaultValue = 'true';
    print('  Failed: Should not allow setting defaultValue to a string');
  } catch (e) {
    print('  Success: ${e.toString()}');
  }

  // Create a schema with enum constraint
  print('\nCreating a BooleanJsonSchema with enum constraint...');
  var adminFlagSchema = BooleanJsonSchema()
    ..title = "Admin Flag Schema"
    ..description = "A schema for validating admin flag values"
    ..enumValues =
        [true] // Only true is allowed
    ..defaultValue = true;

  print('Schema created: ${adminFlagSchema.toJson()}');

  // Test enum constraint
  print('\nTesting enum constraint:');
  print(
    '  true: ${adminFlagSchema.validateBoolean(true) ? 'Valid' : 'Invalid'}',
  );
  print(
    '  false: ${adminFlagSchema.validateBoolean(false) ? 'Valid' : 'Invalid'}',
  );

  // Demonstrate const constraint
  print('\nDemonstrating const constraint:');
  var readOnlySchema = BooleanJsonSchema()
    ..title = "Read-Only Flag Schema"
    ..description = "A schema for a read-only flag that is always true"
    ..constValue = true;

  print('Schema created: ${readOnlySchema.toJson()}');
  print(
    '  true: ${readOnlySchema.validateBoolean(true) ? 'Valid' : 'Invalid'}',
  );
  print(
    '  false: ${readOnlySchema.validateBoolean(false) ? 'Valid' : 'Invalid'}',
  );
}

void numberJsonSchemaExample() {
  print('Creating a NumberJsonSchema for price validation...');

  // Create a NumberJsonSchema for price validation
  var priceSchema = NumberJsonSchema()
    ..title = "Price Schema"
    ..description = "A schema for validating price values"
    ..minimum = 0
    ..multipleOf =
        0.01 // Ensure prices have at most 2 decimal places
    ..defaultValue = 9.99;

  print('Schema created: ${priceSchema.toJson()}');

  // Test valid numeric values
  print('\nValidating valid numeric values:');
  var validNumbers = [0, 9.99, 10.50, 100, 123.45];

  for (var value in validNumbers) {
    bool isValid = priceSchema.validateNumber(value);
    print('  $value: ${isValid ? 'Valid' : 'Invalid'}');
  }

  // Test invalid numeric values
  print('\nValidating invalid numeric values:');
  var invalidValues = [
    -1, // Below minimum
    9.999, // Not a multiple of 0.01
    'price', // String, not number
    true, // Boolean, not number
    [10, 20], // Array, not number
    {'price': 10}, // Object, not number
  ];

  for (var value in invalidValues) {
    bool isValid = priceSchema.validateNumber(value);
    print('  $value: ${isValid ? 'Valid' : 'Invalid'}');
  }

  // Demonstrate type restriction
  print('\nDemonstrating type restriction:');
  try {
    print('  Attempting to set type to string...');
    priceSchema.type = JsonType.string;
    print('  Failed: Should not allow setting type to string');
  } catch (e) {
    print('  Success: ${e.toString()}');
  }

  // Demonstrate defaultValue restriction
  print('\nDemonstrating defaultValue restriction:');
  try {
    print('  Setting defaultValue to a valid number...');
    priceSchema.defaultValue = 19.99;
    print('  Success: defaultValue set to ${priceSchema.defaultValue}');

    print('  Attempting to set defaultValue to a string...');
    priceSchema.defaultValue = 'price';
    print('  Failed: Should not allow setting defaultValue to a string');
  } catch (e) {
    print('  Success: ${e.toString()}');
  }

  // Create a schema with range constraints
  print('\nCreating a NumberJsonSchema for age validation...');
  var ageSchema = NumberJsonSchema()
    ..title = "Age Schema"
    ..description = "A schema for validating age values"
    ..minimum = 0
    ..maximum = 120
    ..multipleOf =
        1 // Integer values only
    ..defaultValue = 18;

  print('Schema created: ${ageSchema.toJson()}');

  // Test range constraints
  print('\nTesting range constraints:');
  var ageValues = [0, 18, 65, 120, -1, 121, 18.5];
  for (var age in ageValues) {
    bool isValid = ageSchema.validateNumber(age);
    print('  $age: ${isValid ? 'Valid' : 'Invalid'}');
  }

  // Create a schema with enum constraint
  print('\nCreating a NumberJsonSchema with enum constraint...');
  var ratingSchema = NumberJsonSchema()
    ..title = "Rating Schema"
    ..description = "A schema for validating rating values (1-5 stars)"
    ..enumValues = [1, 2, 3, 4, 5]
    ..defaultValue = 5;

  print('Schema created: ${ratingSchema.toJson()}');

  // Test enum constraint
  print('\nTesting enum constraint:');
  var ratingValues = [1, 3, 5, 0, 2.5, 6];
  for (var rating in ratingValues) {
    bool isValid = ratingSchema.validateNumber(rating);
    print('  $rating: ${isValid ? 'Valid' : 'Invalid'}');
  }

  // Demonstrate const constraint
  print('\nDemonstrating const constraint:');
  var piSchema = NumberJsonSchema()
    ..title = "Pi Schema"
    ..description = "A schema for the mathematical constant pi"
    ..constValue = 3.14159;

  print('Schema created: ${piSchema.toJson()}');

  var piValues = [3.14159, 3.14, 3];
  for (var value in piValues) {
    bool isValid = piSchema.validateNumber(value);
    print('  $value: ${isValid ? 'Valid' : 'Invalid'}');
  }
}
