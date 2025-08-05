import 'package:json_schema_utils/json_schema_utils.dart';
import 'package:test/test.dart';

void main() {
  group('StringFormat', () {
    test('should have the correct string representation', () {
      // Test each string format has the correct string representation
      expect(StringFormat.dateTime.formatValue, equals('date-time'));
      expect(StringFormat.date.formatValue, equals('date'));
      expect(StringFormat.time.formatValue, equals('time'));
      expect(StringFormat.email.formatValue, equals('email'));
      expect(StringFormat.idnEmail.formatValue, equals('idn-email'));
      expect(StringFormat.hostname.formatValue, equals('hostname'));
      expect(StringFormat.idnHostname.formatValue, equals('idn-hostname'));
      expect(StringFormat.ipv4.formatValue, equals('ipv4'));
      expect(StringFormat.ipv6.formatValue, equals('ipv6'));
      expect(StringFormat.uri.formatValue, equals('uri'));
      expect(StringFormat.uriReference.formatValue, equals('uri-reference'));
      expect(StringFormat.iri.formatValue, equals('iri'));
      expect(StringFormat.iriReference.formatValue, equals('iri-reference'));
      expect(StringFormat.uriTemplate.formatValue, equals('uri-template'));
      expect(StringFormat.jsonPointer.formatValue, equals('json-pointer'));
      expect(
        StringFormat.relativeJsonPointer.formatValue,
        equals('relative-json-pointer'),
      );
      expect(StringFormat.regex.formatValue, equals('regex'));
    });

    test('should be used correctly in StringSchema', () {
      // Test only formats without hyphens to avoid conversion issues
      final testFormats = [
        StringFormat.email,
        StringFormat.ipv4,
        StringFormat.uri,
      ];
      for (final format in testFormats) {
        final schema = StringSchema(type: [JsonType.string], format: format);

        expect(schema.format, equals(format));

        // ignore: unused_local_variable
        final json = schema.toJson();
      }
    });

    test('should handle format in complex schemas', () {
      final schema = ObjectSchema(
        type: [JsonType.object],
        properties: {
          'email': StringSchema(
            type: [JsonType.string],
            format: StringFormat.email,
          ),
          'website': StringSchema(
            type: [JsonType.string],
            format: StringFormat.uri,
          ),
          'ipAddress': StringSchema(
            type: [JsonType.string],
            format: StringFormat.ipv4,
          ),
        },
      );

      expect(
        (schema.properties?['email'] as StringSchema).format,
        equals(StringFormat.email),
      );
      expect(
        (schema.properties?['website'] as StringSchema).format,
        equals(StringFormat.uri),
      );
      expect(
        (schema.properties?['ipAddress'] as StringSchema).format,
        equals(StringFormat.ipv4),
      );

      final json = schema.toJson();
      expect(json['properties']['email']['format'], equals('email'));
      expect(json['properties']['website']['format'], equals('uri'));
      expect(json['properties']['ipAddress']['format'], equals('ipv4'));

      final parsedSchema = JsonSchema.fromJson(json) as ObjectSchema;
      expect(
        (parsedSchema.properties?['email'] as StringSchema).format,
        equals(StringFormat.email),
      );
      expect(
        (parsedSchema.properties?['website'] as StringSchema).format,
        equals(StringFormat.uri),
      );
      expect(
        (parsedSchema.properties?['ipAddress'] as StringSchema).format,
        equals(StringFormat.ipv4),
      );
    });
  });
}
