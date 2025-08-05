# json_schema_utils

> [!WARNING]
> This Library is under active development and should be considered experimental and subject to large scale change.
> Please provide feedback of any missing features or bugs!


![JSONSchema Utils Logo](https://raw.githubusercontent.com/indiealexh/dart-json-schema-utils/refs/heads/main/doc/assets/dart-json-schema-utils-header.webp)

JSONSchema Utils provides tools to help programmatically build JSONSchema Documents

Compatible with all Dart environments, including Flutter (Web, Mobile and Desktop), Dart Cli, WASM, Server etc.

## Features

 - JSONSchema Support
 - Opinionated Root JSONSchema Document for compatibility with external $ref and schema registries
   - Required $schema (Currently only supports [JSON Schema Draft 7](https://json-schema.org/draft-07))
   - Required $id
   - Required title
   - Required description
 - Validation of JSON Schema properties according to the Draft-07 specification
   - Validates that properties set in JsonSchema objects are valid
   - Throws exceptions with detailed error messages when validation fails
   - Validates nested schemas recursively

## Planned Features

 - Validation of schema restrictions to avoid conflict or impossible schemas
 - Support for Additional JSON Schema versions
   - [JSON Schema 2019-09](https://json-schema.org/draft/2019-09)
   - [JSON Schema 2020-12](https://json-schema.org/draft/2020-12)
 - Support for utilizing Schema Registries for loading, storage and versioning of schemas (possibly with a separate package TBD)
   - [Apicurio Registry](https://www.apicur.io/registry/)

## Getting started

## Usage

### Creating JSON Schemas

```dart
// Create a simple person schema
void createPersonSchema() {
  try {
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
    );

    // Convert the schema to JSON
    final schemaJson = personSchema.toJson();
    print(schemaJson);
  } catch (e) {
    print('Error: $e');
  }
}
```

### Schema Validation

The library automatically validates JSON Schema properties according to the Draft-07 specification. Validation occurs in the constructor of each JsonSchema class and throws a `JsonSchemaValidationException` if validation fails.

```dart
void validationExample() {
  try {
    // This will throw an exception because minLength is negative
    final invalidSchema = StringSchema(
      title: "Invalid Schema",
      description: "This schema has invalid properties",
      minLength: -5,  // Invalid: minLength must be non-negative
    );
  } catch (e) {
    print('Validation error: $e');
    // Output: Validation error: JsonSchemaValidationException: minLength must be a non-negative integer.
  }
  
  try {
    // This will throw an exception because maxLength < minLength
    final invalidSchema = StringSchema(
      title: "Invalid Schema",
      description: "This schema has invalid properties",
      minLength: 10,
      maxLength: 5,  // Invalid: maxLength must be >= minLength
    );
  } catch (e) {
    print('Validation error: $e');
    // Output: Validation error: JsonSchemaValidationException: maxLength must be greater than or equal to minLength.
  }
  
  try {
    // This will throw an exception because the pattern is invalid
    final invalidSchema = StringSchema(
      title: "Invalid Schema",
      description: "This schema has invalid properties",
      pattern: "[",  // Invalid: not a valid regular expression
    );
  } catch (e) {
    print('Validation error: $e');
    // Output: Validation error: JsonSchemaValidationException: Invalid regular expression in pattern: [
  }
  
  // This is valid and will not throw an exception
  final validSchema = StringSchema(
    title: "Valid Schema",
    description: "This schema has valid properties",
    minLength: 5,
    maxLength: 100,
    pattern: r"^[a-zA-Z0-9]+$",
  );
  
  // Nested schemas are also validated
  final objectSchema = ObjectSchema(
    title: "Object Schema",
    description: "A schema with nested schemas",
    properties: {
      "name": StringSchema(
        type: [JsonType.string],
        minLength: 1,
      ),
      "age": NumberSchema(
        type: [JsonType.integer],
        minimum: 0,
      ),
    },
    required: ["name", "age"],
  );
}
```
