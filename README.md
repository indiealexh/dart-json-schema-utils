# json_schema_utils

![JSONSchema Utils Logo](https://raw.githubusercontent.com/indiealexh/dart-json-schema-utils/refs/heads/main/docs/assets/dart-json-schema-utils-header.webp)

JSONSchema Utils provides tools to help programmatically build JSONSchema Documents

Compatible with all Dart environments, including Flutter (Web, Mobile and Desktop), Dart Cli, WASM, Server etc.

## Features

 - JSONSchema Support
 - Opinionated JSONSchema Document
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
   }
}
```
