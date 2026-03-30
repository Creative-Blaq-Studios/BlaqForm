/// Represents the result of a failed validation.
///
/// Contains a human-readable [message], an optional machine-readable [code]
/// for i18n mapping, and optional [params] for interpolation.
///
/// ```dart
/// BfValidationResult(
///   'Must be at least 8 characters',
///   code: 'min_length',
///   params: {'min': 8, 'actual': 3},
/// );
/// ```
class BfValidationResult {
  /// Human-readable error message.
  final String message;

  /// Machine-readable error code (e.g., `'required'`, `'min_length'`).
  ///
  /// Useful for i18n — map the code to a locale-specific string.
  final String? code;

  /// Additional parameters associated with the validation failure.
  ///
  /// For example, `{'min': 8, 'actual': 3}` for a min-length violation.
  final Map<String, dynamic> params;

  /// Creates a validation result indicating a failure.
  ///
  /// [message] is the human-readable error text.
  /// [code] is an optional machine-readable identifier.
  /// [params] are optional key-value pairs for interpolation.
  const BfValidationResult(this.message, {this.code, this.params = const {}});

  @override
  String toString() => 'BfValidationResult(message: $message, code: $code)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BfValidationResult &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          code == other.code;

  @override
  int get hashCode => message.hashCode ^ code.hashCode;
}
