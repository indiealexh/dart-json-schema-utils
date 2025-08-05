import 'package:json_schema_utils/json_schema_utils.dart';

/// This example demonstrates how to use the json_schema_utils library
/// to create and work with JSON Schema documents.
void main() {
  print('=== JSON Schema Utils Examples ===\n');

  // Basic schema creation
  print('1. Basic Schema Creation:');
  basicSchemaExample();

  // Object schema with nested properties
  print('\n2. Object Schema with Nested Properties:');
  objectSchemaExample();

  // Array schema examples
  print('\n3. Array Schema Examples:');
  arraySchemaExample();

  // String schema examples
  print('\n4. String Schema Examples:');
  stringSchemaExample();

  // Number schema examples
  print('\n5. Number Schema Examples:');
  numberSchemaExample();

  // Logical composition examples
  print('\n6. Logical Composition Examples:');
  logicalCompositionExample();

  // Conditional schema examples
  print('\n7. Conditional Schema Examples:');
  conditionalSchemaExample();
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

/// Example of creating an object schema with nested properties
void objectSchemaExample() {
  // Create a schema for a person object
  var personSchema = ObjectSchema(
    title: "Person Schema",
    description: "A schema for a person object",
    type: [JsonType.object],
    required: ["name", "email", "age"],
    properties: {
      "name": StringSchema(
        description: "The person's full name",
        minLength: 2,
        maxLength: 100,
      ),
      "email": StringSchema(
        description: "The person's email address",
        format: StringFormat.email,
        pattern: r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
      ),
      "age": NumberSchema(
        description: "The person's age in years",
        type: [JsonType.integer],
        minimum: 0,
        maximum: 120,
      ),
      "address": ObjectSchema(
        description: "The person's address",
        required: ["street", "city"],
        properties: {
          "street": StringSchema(description: "Street address"),
          "city": StringSchema(description: "City name"),
          "state": StringSchema(description: "State or province"),
          "zipCode": StringSchema(description: "Postal/ZIP code"),
        },
      ),
      "tags": ArraySchema(
        description: "Tags associated with the person",
        items: StringSchema(),
        uniqueItems: true,
      ),
    },
    additionalProperties: JsonSchema(
      constValue: false,
    ), // No additional properties allowed
  );

  print('Person schema created:');
  print(personSchema.toJson());

  // Example of using patternProperties
  var configSchema = ObjectSchema(
    title: "Configuration Schema",
    description: "A schema for configuration objects",
    patternProperties: {
      r"^prefix_": StringSchema(
        description: "Properties starting with 'prefix_'",
      ),
      r".*_suffix$": NumberSchema(
        description: "Properties ending with '_suffix'",
      ),
    },
  );

  print('\nConfiguration schema with pattern properties:');
  print(configSchema.toJson());

  // Example of property dependencies
  var addressSchema = ObjectSchema(
    title: "Address Schema",
    description: "A schema with property dependencies",
    properties: {
      "street": StringSchema(),
      "city": StringSchema(),
      "state": StringSchema(),
      "zipCode": StringSchema(),
    },
    dependencies: {
      "street": [
        "city",
        "state",
        "zipCode",
      ], // If street is present, these must be too
    },
  );

  print('\nAddress schema with dependencies:');
  print(addressSchema.toJson());
}

/// Example of creating array schemas
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

  // Array with tuple validation (fixed structure)
  var coordinateSchema = ArraySchema(
    title: "Coordinate Schema",
    description: "A schema for a coordinate [x, y, z]",
    items: [
      NumberSchema(description: "X coordinate"),
      NumberSchema(description: "Y coordinate"),
      NumberSchema(description: "Z coordinate"),
    ],
    minItems: 3,
    maxItems: 3,
  );

  print('\nCoordinate schema (tuple validation):');
  print(coordinateSchema.toJson());

  // Array with contains constraint
  var containsSchema = ArraySchema(
    title: "Contains Schema",
    description:
        "A schema for an array that must contain at least one even number",
    items: NumberSchema(type: [JsonType.integer]),
    contains: NumberSchema(type: [JsonType.integer], multipleOf: 2),
  );

  print('\nArray schema with contains constraint:');
  print(containsSchema.toJson());
}

/// Example of creating string schemas
void stringSchemaExample() {
  // Email validation schema
  var emailSchema = StringSchema(
    title: "Email Schema",
    description: "A schema for validating email addresses",
    format: StringFormat.email,
    minLength: 5,
    maxLength: 100,
    pattern: r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
  );

  print('Email schema created:');
  print(emailSchema.toJson());

  // Password validation schema
  var passwordSchema = StringSchema(
    title: "Password Schema",
    description: "A schema for validating passwords",
    minLength: 8,
    maxLength: 64,
    pattern:
        r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]+$",
  );

  print('\nPassword schema created:');
  print(passwordSchema.toJson());

  // Date-time validation schema
  var dateTimeSchema = StringSchema(
    title: "Date-Time Schema",
    description: "A schema for validating ISO 8601 date-time strings",
    format: StringFormat.dateTime,
  );

  print('\nDate-time schema created:');
  print(dateTimeSchema.toJson());

  // URI validation schema
  var uriSchema = StringSchema(
    title: "URI Schema",
    description: "A schema for validating URIs",
    format: StringFormat.uri,
  );

  print('\nURI schema created:');
  print(uriSchema.toJson());

  // Content encoding and media type example
  var imageSchema = StringSchema(
    title: "Image Schema",
    description: "A schema for base64-encoded PNG images",
    contentEncoding: "base64",
    contentMediaType: "image/png",
  );

  print('\nImage schema with content encoding and media type:');
  print(imageSchema.toJson());
}

/// Example of creating number schemas
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

  // Price validation schema
  var priceSchema = NumberSchema(
    title: "Price Schema",
    description: "A schema for validating price values",
    minimum: 0,
    exclusiveMinimum: 0, // Price must be greater than 0
    multipleOf: 0.01, // Two decimal places
  );

  print('\nPrice schema created:');
  print(priceSchema.toJson());

  // Percentage validation schema
  var percentageSchema = NumberSchema(
    title: "Percentage Schema",
    description: "A schema for validating percentage values",
    minimum: 0,
    maximum: 100,
    examples: [25, 50, 75, 100],
  );

  print('\nPercentage schema created:');
  print(percentageSchema.toJson());
}

/// Example of using logical composition (allOf, anyOf, oneOf, not)
void logicalCompositionExample() {
  // allOf example - must satisfy all schemas
  var allOfSchema = JsonSchema(
    title: "AllOf Schema",
    description: "A schema using allOf to combine constraints",
    allOf: [NumberSchema(minimum: 0), NumberSchema(multipleOf: 5)],
  );

  print('AllOf schema created:');
  print(allOfSchema.toJson());

  // anyOf example - must satisfy at least one schema
  var anyOfSchema = JsonSchema(
    title: "AnyOf Schema",
    description: "A schema using anyOf for alternative types",
    anyOf: [
      StringSchema(format: StringFormat.email),
      StringSchema(format: StringFormat.uri),
    ],
  );

  print('\nAnyOf schema created:');
  print(anyOfSchema.toJson());

  // oneOf example - must satisfy exactly one schema
  var oneOfSchema = JsonSchema(
    title: "OneOf Schema",
    description: "A schema using oneOf for mutually exclusive options",
    oneOf: [
      ObjectSchema(
        required: ["name", "email"],
        properties: {
          "name": StringSchema(),
          "email": StringSchema(format: StringFormat.email),
        },
      ),
      ObjectSchema(
        required: ["companyName", "website"],
        properties: {
          "companyName": StringSchema(),
          "website": StringSchema(format: StringFormat.uri),
        },
      ),
    ],
  );

  print('\nOneOf schema created:');
  print(oneOfSchema.toJson());

  // not example - must not satisfy the schema
  var notSchema = JsonSchema(
    title: "Not Schema",
    description: "A schema using not to exclude certain values",
    notSchema: NumberSchema(
      enumValues: [0, null], // Must not be 0 or null
    ),
  );

  print('\nNot schema created:');
  print(notSchema.toJson());
}

/// Example of using conditional schemas (if/then/else)
void conditionalSchemaExample() {
  // If/then/else example
  var userSchema = ObjectSchema(
    title: "User Schema",
    description: "A schema for user objects with conditional validation",
    properties: {
      "name": StringSchema(),
      "age": NumberSchema(type: [JsonType.integer]),
      "email": StringSchema(),
      "driverLicense": StringSchema(),
    },
    required: ["name", "age", "email"],
    ifSchema: ObjectSchema(properties: {"age": NumberSchema(minimum: 18)}),
    thenSchema: ObjectSchema(required: ["driverLicense"]),
    elseSchema: ObjectSchema(
      properties: {
        "driverLicense": JsonSchema(enumValues: [null]),
      },
    ),
  );

  print('Conditional schema created:');
  print(userSchema.toJson());

  // Another if/then/else example for different response formats
  var responseSchema = ObjectSchema(
    title: "API Response Schema",
    description: "A schema for API responses with conditional validation",
    properties: {
      "status": StringSchema(enumValues: ["success", "error"]),
      "data": JsonSchema(),
      "error": ObjectSchema(
        properties: {
          "code": NumberSchema(type: [JsonType.integer]),
          "message": StringSchema(),
        },
      ),
    },
    required: ["status"],
    ifSchema: ObjectSchema(
      properties: {
        "status": JsonSchema(enumValues: ["success"]),
      },
    ),
    thenSchema: ObjectSchema(required: ["data"]),
    elseSchema: ObjectSchema(required: ["error"]),
  );

  print('\nAPI Response conditional schema:');
  print(responseSchema.toJson());
}
