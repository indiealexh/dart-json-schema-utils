import 'package:json_schema_utils/json_schema_utils.dart';

/// This example demonstrates how to use the json_schema_utils library
/// to create and work with JSON Schema documents.
void main() {
  print('=== JSON Schema Utils Simple Examples ===\n');

  // Basic schema creation
  print('1. Basic Schema Creation:');
  basicSchemaExample();

  // Object schema example
  print('\n2. Object Schema Example:');
  objectSchemaExample();

  // Array schema example
  print('\n3. Array Schema Example:');
  arraySchemaExample();

  // String schema example
  print('\n4. String Schema Example:');
  stringSchemaExample();

  // Number schema example
  print('\n5. Number Schema Example:');
  numberSchemaExample();
}

/// Example of creating a basic schema
void basicSchemaExample() {
  // Create a simple schema
  var schema = JsonSchema(
    title: "Simple Schema",
    description: "A simple schema example",
    type: [JsonType.object],
    readOnly: true,
  );

  print('Simple schema created:');
  print(schema.toJson());
}

/// Example of creating an object schema
void objectSchemaExample() {
  // Create a schema for a person object
  var personSchema = ObjectSchema(
    title: "Person Schema",
    description: "A schema for a person object",
    type: [JsonType.object],
    required: ["name", "email"],
    properties: {
      "name": StringSchema(
        description: "The person's full name",
        minLength: 2,
        maxLength: 100,
      ),
      "email": StringSchema(
        description: "The person's email address",
        format: StringFormat.email,
      ),
      "age": NumberSchema(
        description: "The person's age in years",
        type: [JsonType.integer],
        minimum: 0,
        maximum: 120,
      ),
    },
  );

  print('Person schema created:');
  print(personSchema.toJson());
}

/// Example of creating an array schema
void arraySchemaExample() {
  // Simple array of strings
  var tagsSchema = ArraySchema(
    title: "Tags Schema",
    description: "A schema for an array of tags",
    items: StringSchema(minLength: 1, maxLength: 20),
    uniqueItems: true,
    minItems: 1,
    maxItems: 10,
  );

  print('Tags schema created:');
  print(tagsSchema.toJson());
}

/// Example of creating a string schema
void stringSchemaExample() {
  // Email validation schema
  var emailSchema = StringSchema(
    title: "Email Schema",
    description: "A schema for validating email addresses",
    format: StringFormat.email,
    minLength: 5,
    maxLength: 100,
  );

  print('Email schema created:');
  print(emailSchema.toJson());
}

/// Example of creating a number schema
void numberSchemaExample() {
  // Integer validation schema
  var ageSchema = NumberSchema(
    title: "Age Schema",
    description: "A schema for validating age values",
    type: [JsonType.integer],
    minimum: 0,
    maximum: 120,
  );

  print('Age schema created:');
  print(ageSchema.toJson());
}
