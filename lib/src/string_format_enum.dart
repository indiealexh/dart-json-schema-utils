/// An enum for the standard string formats defined in JSON Schema.
enum StringFormat {
  dateTime("date-time"),
  date("date"),
  time("time"),
  email("email"),
  idnEmail("idn-email"),
  hostname("hostname"),
  idnHostname("idn-hostname"),
  ipv4("ipv4"),
  ipv6("ipv6"),
  uri("uri"),
  uriReference("uri-reference"),
  iri("iri"),
  iriReference("iri-reference"),
  uriTemplate("uri-template"),
  jsonPointer("json-pointer"),
  relativeJsonPointer("relative-json-pointer"),
  regex("regex");

  final String formatValue;

  const StringFormat(this.formatValue);

  factory StringFormat.byTypeValue(String formatValue) {
    for (var value in StringFormat.values) {
      if (value.formatValue == formatValue) return value;
    }
    throw ArgumentError.value(
      formatValue,
      "formatValue",
      "No enum value with that name",
    );
  }
}
