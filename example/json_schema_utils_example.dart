import 'package:json_schema_utils/src/json_schema.dart';

void main() {
  var schema = JsonSchemaDocument(
    "https://indiealexh.dev/schema/vehicle",
    "Vehicle Schema",
    "A Schema to describe a vehicle",
  );
  schema.id = "lol";
  print('awesome: ${schema.toJson()}');
}
