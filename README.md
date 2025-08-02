# json_schema_utils

> [!WARNING]
> This Library is under active development and should be considered experimental and subject to large scale change.
> Please provide feedback of any missing features or bugs!


![JSONSchema Utils Logo](https://raw.githubusercontent.com/indiealexh/dart-json-schema-utils/refs/heads/main/doc/assets/dart-json-schema-utils-header.webp)

JSONSchema Utils provides tools to help programmatically build JSONSchema Documents

Compatible with all Dart environments, including Flutter (Web, Mobile and Desktop), Dart Cli, WASM, Server etc.

## Features

 - JSONSchema Support
 - Opinionated JSONSchema Document for compatibility with external $ref and schema registries
   - Required $schema (Currently only supports [JSON Schema Draft 7](https://json-schema.org/draft-07))
   - Required $id
   - Required title
   - Required description
 - Validation of spec / schema compliance while building examples

## Planned Features

 - Validation of schema restrictions to avoid conflict or impossible schemas
 - Support for Additional JSON Schema versions
   - [JSON Schema 2019-09](https://json-schema.org/draft/2019-09)
   - [JSON Schema 2020-12](https://json-schema.org/draft/2020-12)
 - Support for utilizing Schema Registries for loading, storage and versioning of schemas (possibly with a separate package TBD)
   - [Apicurio Registry](https://www.apicur.io/registry/)

## Getting started

## Usage

```dart
class Example {
   Example() {
      try {
         var schema = JsonSchemaDocument(
            "https://indiealexh.dev/schema/vehicle",
            "Vehicle Schema",
            "A Schema to describe a vehicle",
         );
         schema
            ..comment = "This is a comment"
            ..defaultValue = {"type": "sedan"}
            ..examples = [
               {"type": "sedan"},
               {"type": "suv"},
            ]
            ..readOnly = true
            ..writeOnly = false;
      } catch (e) {
         print('Error: $e');
      }

      try {

         // Create a StringJsonSchema for email validation
         var emailSchema = StringJsonSchema()
            ..title = "Email Schema"
            ..description = "A schema for validating email addresses"
            ..format = "email"
            ..minLength = 5
            ..maxLength = 100
            ..pattern = r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$";
         var schema = JsonSchemaDocument(
            "https://indiealexh.dev/schema/email-list",
            "Email List Schema",
            "A Schema to describe a list of emails",
         );
         schema
            ..comment = "This is a comment"
            ..defaultValue = []
            ..examples = [
               ["example@example.com"],
               ["example@example.com","example2@example.com"]
            ]
            ..type = JsonType.array
            ..contains = emailSchema
            ..readOnly = true
            ..writeOnly = false;
      } catch (e) {
         print('Error: $e');
      }

   }
}
```
