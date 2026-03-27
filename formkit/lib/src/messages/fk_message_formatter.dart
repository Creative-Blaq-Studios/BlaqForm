import '../validation/fk_validation_result.dart';

/// Utility for interpolating message templates used in validation errors.
///
/// Templates use curly-brace tokens: `{field}` is replaced with the field
/// name, and any other token `{key}` is replaced with the matching entry in
/// [params]. Tokens with no corresponding value are left unchanged.
///
/// ```dart
/// FkMessageFormatter.format(
///   '{field} must be at least {min} characters',
///   fieldName: 'Password',
///   params: {'min': 8},
/// ); // → 'Password must be at least 8 characters'
/// ```
abstract class FkMessageFormatter {
  /// Replaces `{field}` with [fieldName] and `{key}` with `params[key]`
  /// values throughout [template].
  ///
  /// - If [fieldName] is `null`, the `{field}` token is left as-is.
  /// - If a `{key}` token has no matching entry in [params], it is left as-is.
  /// - Unknown tokens that appear in neither [fieldName] nor [params] are
  ///   left unchanged.
  static String format(
    String template, {
    String? fieldName,
    Map<String, dynamic> params = const {},
  }) {
    var result = template;

    if (fieldName != null) {
      result = result.replaceAll('{field}', fieldName);
    }

    for (final entry in params.entries) {
      result = result.replaceAll('{${entry.key}}', '${entry.value}');
    }

    return result;
  }

  /// Formats the message inside [validationResult] using its own [params]
  /// and the optional [fieldName].
  ///
  /// Equivalent to calling [format] with `validationResult.message` and
  /// `validationResult.params`.
  static String formatResult(
    FkValidationResult validationResult, {
    String? fieldName,
  }) {
    return format(
      validationResult.message,
      fieldName: fieldName,
      params: validationResult.params,
    );
  }
}
