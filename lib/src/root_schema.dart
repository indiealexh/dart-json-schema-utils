import './json_schema.dart';

class RootSchema {
  /// From `$schema`: The URI identifying the dialect of the schema.
  final Uri schemaVersion;

  /// From `$id`: A URI for the schema, used for identification and resolution.
  final Uri id;

  /// From `title`: A short, descriptive title for the schema.
  final String title;

  /// From `description`: A more detailed explanation of the schema's purpose.
  final String description;

  final JsonSchema schema;

  RootSchema(
    this.schemaVersion,
    this.id,
    this.title,
    this.description,
    this.schema,
  );

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json.addAll(schema.toJson());
    json[r'$schema'] = schemaVersion.toString();
    json[r'$id'] = id.toString();
    json['title'] = title;
    json['description'] = description;
    return json;
  }

  factory RootSchema.fromJson(Map<String, dynamic> json) {
    JsonSchema baseSchema = JsonSchema.fromJson(json);
    if (baseSchema.schemaVersion == null ||
        baseSchema.id == null ||
        baseSchema.title == null ||
        baseSchema.description == null) {
      // TODO: Improve this exception (see [JsonSchemaValidationException])
      throw Exception(
        r"Root Schema requires $schema, $id, title and description",
      );
    }
    return RootSchema(
      baseSchema.schemaVersion!,
      baseSchema.id!,
      baseSchema.title!,
      baseSchema.description!,
      baseSchema,
    );
  }
}
