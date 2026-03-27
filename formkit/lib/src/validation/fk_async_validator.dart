import 'fk_validation_context.dart';
import 'fk_validation_result.dart';

/// Base abstract class for asynchronous validators.
///
/// Use [FkAsyncValidator] for validations that require I/O operations,
/// such as checking uniqueness against a remote server or verifying
/// data in a local database.
///
/// ```dart
/// class UsernameAvailableValidator extends FkAsyncValidator<String> {
///   final ApiClient api;
///   const UsernameAvailableValidator(this.api);
///
///   @override
///   Future<FkValidationResult?> validate(
///     String? value, [
///     FkValidationContext? context,
///   ]) async {
///     if (value == null || value.isEmpty) return null;
///     final available = await api.checkUsername(value);
///     if (available) return null;
///     return FkValidationResult('Username is already taken', code: 'unique');
///   }
/// }
/// ```
abstract class FkAsyncValidator<T> {
  /// Creates an async validator.
  const FkAsyncValidator();

  /// Asynchronously validates the given [value].
  ///
  /// Returns `null` if the value is valid, or an [FkValidationResult]
  /// describing the validation failure.
  ///
  /// The optional [context] provides access to sibling field values
  /// for cross-field validation.
  Future<FkValidationResult?> validate(
    T? value, [
    FkValidationContext? context,
  ]);
}
