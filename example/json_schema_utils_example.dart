import 'package:json_schema_utils/json_schema_utils.dart';

void main() {
  // Part 1: General JsonSchema example
  print('=== General JsonSchema Example ===');
  generalJsonSchemaExample();

  // Part 2: StringJsonSchema example
  print('\n\n=== StringJsonSchema Example ===');
  stringJsonSchemaExample();
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
