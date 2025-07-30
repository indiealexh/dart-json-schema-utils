/// Represents the possible data types that a JSON schema can define.
/// See: https://json-schema.org/draft-07/draft-handrews-json-schema-01#section-6.1.1
enum JsonType {
  string,
  number,
  integer,
  object,
  array,
  boolean,

  /// Represents the JSON `null` type.
  nullValue,
}
