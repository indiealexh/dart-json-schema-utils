import './json_schema.dart';

/// Represents an Opinionated JSON Schema Document (i.e. A Root Json Schema object)
///
/// This class requires $schema, $id, title and description to be set
class JsonSchemaDocument extends JsonSchema with JsonSchemaIdRequired {
  @override
  final String schema = "http://json-schema.org/draft-07/schema#";
  @override
  final String id;
  @override
  final String title;
  @override
  final String description;

  ///
  /// [FormatException] is thrown.
  factory JsonSchemaDocument(String id, String title, String description) {
    if (id.isEmpty) {
      throw "id is empty";
    }
    var idUri = Uri.parse(id);
    if (title.isEmpty) {
      throw "Title is empty";
    }
    if (description.isEmpty) {
      throw "Description is empty";
    }

    return JsonSchemaDocument._internal(idUri.toString(), title, description);
  }

  JsonSchemaDocument._internal(this.id, this.title, this.description);
}

// class JsonSchema extends JsonSchemaBase {
// }

mixin JsonSchemaIdRequired {
  String get schema;

  String get id;

  String get title;

  String get description;
}
