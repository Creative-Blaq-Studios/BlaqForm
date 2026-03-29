import 'bf_validation_context.dart';
import 'bf_validation_result.dart';

/// Base abstract class for asynchronous validators.
///
/// Use [BfAsyncValidator] for validations that require I/O operations,
/// such as checking uniqueness against a remote server or verifying
/// data in a local database.
///
/// ```dart
/// class UsernameAvailableValidator extends BfAsyncValidator<String> {
///   final ApiClient api;
///   const UsernameAvailableValidator(this.api);
///
///   @override
///   Future<BfValidationResult?> validate(
///     String? value, [
///     BfValidationContext? context,
///   ]) async {
///     if (value == null || value.isEmpty) return null;
///     final available = await api.checkUsername(value);
///     if (available) return null;
///     return BfValidationResult('Username is already taken', code: 'unique');
///   }
/// }
/// ```
abstract class BfAsyncValidator<T> {
  /// Creates an async validator.
  const BfAsyncValidator();

  /// Asynchronously validates the given [value].
  ///
  /// Returns `null` if the value is valid, or an [BfValidationResult]
  /// describing the validation failure.
  ///
  /// The optional [context] provides access to sibling field values
  /// for cross-field validation.
  Future<BfValidationResult?> validate(
    T? value, [
    BfValidationContext? context,
  ]);
}
