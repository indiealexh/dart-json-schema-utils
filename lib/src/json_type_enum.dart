/// An enum representing the primitive types allowed in JSON Schema.
enum JsonType {
  object("object"),
  array("array"),
  string("string"),
  number("number"),
  integer("integer"),
  boolean("boolean"),
  nullValue("null");

  final String typeValue;

  const JsonType(this.typeValue);

  factory JsonType.byTypeValue(String typeValue) {
    for (var value in JsonType.values) {
      if (value.typeValue == typeValue) return value;
    }
    throw ArgumentError.value(
      typeValue,
      "name",
      "No enum value with that name",
    );
  }
}
