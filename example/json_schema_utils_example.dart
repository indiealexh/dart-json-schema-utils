import 'package:json_schema_utils/json_schema_utils.dart';

void main() {
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
