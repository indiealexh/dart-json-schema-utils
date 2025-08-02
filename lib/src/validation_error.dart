import 'json_schema_base.dart';

/// Represents a validation error that occurred during JSON Schema validation.
///
/// This class provides detailed information about a validation failure, including:
/// - The path to the location in the instance where the error occurred
/// - The validation keyword that failed
/// - The expected value or constraint
/// - The actual value that failed validation
/// - A human-readable error message
///
/// Example usage:
/// ```dart
/// // Create a schema
/// final schema = StringJsonSchema();
/// schema.minLength = 3;
///
/// // Validate a value
/// final result = schema.validate('ab', '/properties/name');
///
/// if (!result.isValid) {
///   // Access error details
///   for (final error in result.errors) {
///     print('Error at ${error.path}: ${error.message}');
///     print('Keyword: ${error.keyword}');
///     print('Expected: ${error.expected}, Actual: ${error.actual}');
///   }
/// }
/// ```
class ValidationError {
  /// The JSON pointer path to the location in the instance where the error occurred.
  ///
  /// For example: "/properties/name" or "/items/0/type"
  final String path;

  /// The validation keyword that failed (e.g., "type", "minimum", "pattern").
  final String keyword;

  /// The expected value or constraint.
  ///
  /// This could be a type, a pattern, a minimum value, etc.
  final dynamic expected;

  /// The actual value that failed validation.
  final dynamic actual;

  /// A human-readable error message describing the validation failure.
  final String message;

  /// The schema that was being validated against when the error occurred.
  final JsonSchemaBase schema;

  /// Creates a new [ValidationError] with the specified details.
  ValidationError({
    required this.path,
    required this.keyword,
    required this.expected,
    required this.actual,
    required this.message,
    required this.schema,
  });

  /// Creates a [ValidationError] for a type validation failure.
  factory ValidationError.typeMismatch({
    required String path,
    required dynamic expected,
    required dynamic actual,
    required JsonSchemaBase schema,
  }) {
    // Convert expected type to a simple string representation
    String expectedStr;
    if (expected is List) {
      // For a list of types, join them with 'or'
      expectedStr = expected
          .map((e) {
            // Extract the type name from the toString() representation
            String typeStr = e.toString();
            if (typeStr.contains('.')) {
              typeStr = typeStr.split('.').last.toLowerCase();
            }
            return typeStr;
          })
          .join(' or ');
    } else {
      // For a single type
      String typeStr = expected.toString();
      if (typeStr.contains('.')) {
        typeStr = typeStr.split('.').last.toLowerCase();
      }
      expectedStr = typeStr;
    }

    return ValidationError(
      path: path,
      keyword: 'type',
      expected: expected,
      actual: actual,
      message: 'Expected $expectedStr but got ${actual.runtimeType}',
      schema: schema,
    );
  }

  /// Creates a [ValidationError] for a minimum value validation failure.
  factory ValidationError.minimumViolation({
    required String path,
    required num expected,
    required num actual,
    required JsonSchemaBase schema,
    bool exclusive = false,
  }) {
    return ValidationError(
      path: path,
      keyword: exclusive ? 'exclusiveMinimum' : 'minimum',
      expected: expected,
      actual: actual,
      message: exclusive
          ? 'Value $actual must be greater than $expected'
          : 'Value $actual must be greater than or equal to $expected',
      schema: schema,
    );
  }

  /// Creates a [ValidationError] for a maximum value validation failure.
  factory ValidationError.maximumViolation({
    required String path,
    required num expected,
    required num actual,
    required JsonSchemaBase schema,
    bool exclusive = false,
  }) {
    return ValidationError(
      path: path,
      keyword: exclusive ? 'exclusiveMaximum' : 'maximum',
      expected: expected,
      actual: actual,
      message: exclusive
          ? 'Value $actual must be less than $expected'
          : 'Value $actual must be less than or equal to $expected',
      schema: schema,
    );
  }

  /// Creates a [ValidationError] for a multipleOf validation failure.
  factory ValidationError.multipleOfViolation({
    required String path,
    required num divisor,
    required num actual,
    required JsonSchemaBase schema,
  }) {
    return ValidationError(
      path: path,
      keyword: 'multipleOf',
      expected: divisor,
      actual: actual,
      message: 'Value $actual must be a multiple of $divisor',
      schema: schema,
    );
  }

  /// Creates a [ValidationError] for a minLength validation failure.
  factory ValidationError.minLengthViolation({
    required String path,
    required int expected,
    required String actual,
    required JsonSchemaBase schema,
  }) {
    return ValidationError(
      path: path,
      keyword: 'minLength',
      expected: expected,
      actual: actual.length,
      message:
          'String length ${actual.length} is less than minimum length $expected',
      schema: schema,
    );
  }

  /// Creates a [ValidationError] for a maxLength validation failure.
  factory ValidationError.maxLengthViolation({
    required String path,
    required int expected,
    required String actual,
    required JsonSchemaBase schema,
  }) {
    return ValidationError(
      path: path,
      keyword: 'maxLength',
      expected: expected,
      actual: actual.length,
      message:
          'String length ${actual.length} exceeds maximum length $expected',
      schema: schema,
    );
  }

  /// Creates a [ValidationError] for a pattern validation failure.
  factory ValidationError.patternViolation({
    required String path,
    required String pattern,
    required String actual,
    required JsonSchemaBase schema,
  }) {
    return ValidationError(
      path: path,
      keyword: 'pattern',
      expected: pattern,
      actual: actual,
      message: 'String does not match pattern: $pattern',
      schema: schema,
    );
  }

  /// Creates a [ValidationError] for a format validation failure.
  factory ValidationError.formatViolation({
    required String path,
    required String format,
    required String actual,
    required String details,
    required JsonSchemaBase schema,
  }) {
    return ValidationError(
      path: path,
      keyword: 'format',
      expected: format,
      actual: actual,
      message: 'Invalid $format format: $details',
      schema: schema,
    );
  }

  /// Creates a [ValidationError] for an enum validation failure.
  factory ValidationError.enumViolation({
    required String path,
    required List<dynamic> expected,
    required dynamic actual,
    required JsonSchemaBase schema,
  }) {
    return ValidationError(
      path: path,
      keyword: 'enum',
      expected: expected,
      actual: actual,
      message: 'Value must be one of: $expected',
      schema: schema,
    );
  }

  /// Creates a [ValidationError] for a const validation failure.
  factory ValidationError.constViolation({
    required String path,
    required dynamic expected,
    required dynamic actual,
    required JsonSchemaBase schema,
  }) {
    return ValidationError(
      path: path,
      keyword: 'const',
      expected: expected,
      actual: actual,
      message: 'Value must be equal to: $expected',
      schema: schema,
    );
  }

  /// Creates a [ValidationError] for a required property validation failure.
  factory ValidationError.requiredPropertyViolation({
    required String path,
    required String propertyName,
    required JsonSchemaBase schema,
  }) {
    return ValidationError(
      path: path,
      keyword: 'required',
      expected: propertyName,
      actual: null,
      message: 'Required property "$propertyName" is missing',
      schema: schema,
    );
  }

  /// Creates a [ValidationError] for a minItems validation failure.
  factory ValidationError.minItemsViolation({
    required String path,
    required int expected,
    required List<dynamic> actual,
    required JsonSchemaBase schema,
  }) {
    return ValidationError(
      path: path,
      keyword: 'minItems',
      expected: expected,
      actual: actual.length,
      message:
          'Array length ${actual.length} is less than minimum length $expected',
      schema: schema,
    );
  }

  /// Creates a [ValidationError] for a maxItems validation failure.
  factory ValidationError.maxItemsViolation({
    required String path,
    required int expected,
    required List<dynamic> actual,
    required JsonSchemaBase schema,
  }) {
    return ValidationError(
      path: path,
      keyword: 'maxItems',
      expected: expected,
      actual: actual.length,
      message: 'Array length ${actual.length} exceeds maximum length $expected',
      schema: schema,
    );
  }

  /// Creates a [ValidationError] for a uniqueItems validation failure.
  factory ValidationError.uniqueItemsViolation({
    required String path,
    required List<dynamic> actual,
    required int duplicateIndex1,
    required int duplicateIndex2,
    required JsonSchemaBase schema,
  }) {
    return ValidationError(
      path: path,
      keyword: 'uniqueItems',
      expected: true,
      actual: false,
      message:
          'Array items at positions $duplicateIndex1 and $duplicateIndex2 are duplicates',
      schema: schema,
    );
  }

  /// Creates a [ValidationError] for a minProperties validation failure.
  factory ValidationError.minPropertiesViolation({
    required String path,
    required int expected,
    required Map<String, dynamic> actual,
    required JsonSchemaBase schema,
  }) {
    return ValidationError(
      path: path,
      keyword: 'minProperties',
      expected: expected,
      actual: actual.length,
      message:
          'Object has ${actual.length} properties, which is less than the required minimum of $expected',
      schema: schema,
    );
  }

  /// Creates a [ValidationError] for a maxProperties validation failure.
  factory ValidationError.maxPropertiesViolation({
    required String path,
    required int expected,
    required Map<String, dynamic> actual,
    required JsonSchemaBase schema,
  }) {
    return ValidationError(
      path: path,
      keyword: 'maxProperties',
      expected: expected,
      actual: actual.length,
      message:
          'Object has ${actual.length} properties, which exceeds the maximum of $expected',
      schema: schema,
    );
  }

  /// Creates a [ValidationError] for a contains validation failure.
  factory ValidationError.containsViolation({
    required String path,
    required List<dynamic> actual,
    required JsonSchemaBase schema,
  }) {
    return ValidationError(
      path: path,
      keyword: 'contains',
      expected: 'at least one item matching the schema',
      actual: 'no matching items',
      message: 'Array does not contain any items matching the schema',
      schema: schema,
    );
  }

  /// Creates a [ValidationError] for a generic validation failure.
  factory ValidationError.generic({
    required String path,
    required String keyword,
    required dynamic expected,
    required dynamic actual,
    required String message,
    required JsonSchemaBase schema,
  }) {
    return ValidationError(
      path: path,
      keyword: keyword,
      expected: expected,
      actual: actual,
      message: message,
      schema: schema,
    );
  }

  @override
  String toString() {
    return 'ValidationError: $message (at $path)';
  }
}

/// Represents the result of a JSON Schema validation operation.
///
/// This class contains information about whether the validation was successful,
/// and if not, a list of validation errors that occurred.
class ValidationResult {
  /// Whether the validation was successful.
  final bool isValid;

  /// A list of validation errors that occurred during validation.
  ///
  /// This list will be empty if [isValid] is true.
  final List<ValidationError> errors;

  /// Creates a new [ValidationResult] with the specified validity and errors.
  ValidationResult({required this.isValid, this.errors = const []});

  /// Creates a successful validation result with no errors.
  factory ValidationResult.success() {
    return ValidationResult(isValid: true);
  }

  /// Creates a failed validation result with the specified errors.
  factory ValidationResult.failure(List<ValidationError> errors) {
    return ValidationResult(isValid: false, errors: errors);
  }

  /// Creates a failed validation result with a single error.
  factory ValidationResult.singleFailure(ValidationError error) {
    return ValidationResult(isValid: false, errors: [error]);
  }

  /// Combines multiple validation results into a single result.
  ///
  /// The combined result is valid only if all input results are valid.
  /// The errors from all input results are concatenated.
  factory ValidationResult.combine(List<ValidationResult> results) {
    final allErrors = <ValidationError>[];
    bool valid = true;

    for (final result in results) {
      if (!result.isValid) {
        valid = false;
      }
      allErrors.addAll(result.errors);
    }

    return ValidationResult(isValid: valid, errors: allErrors);
  }

  /// Returns a new [ValidationResult] with errors filtered by the given predicate.
  ValidationResult where(bool Function(ValidationError) predicate) {
    final filteredErrors = errors.where(predicate).toList();
    return ValidationResult(
      isValid: filteredErrors.isEmpty,
      errors: filteredErrors,
    );
  }

  /// Returns a new [ValidationResult] with errors at the specified path.
  ValidationResult atPath(String path) {
    return where((error) => error.path == path);
  }

  /// Returns a new [ValidationResult] with errors for the specified keyword.
  ValidationResult forKeyword(String keyword) {
    return where((error) => error.keyword == keyword);
  }

  @override
  String toString() {
    if (isValid) {
      return 'ValidationResult: Valid';
    } else {
      return 'ValidationResult: Invalid\n${errors.join('\n')}';
    }
  }
}
