import 'bf_validation_context.dart';
import 'bf_validation_result.dart';

/// Base abstract class for synchronous validators.
///
/// All validators in FlutterFormKit extend this class. Validators are objects
/// (not callbacks), enabling composition, serialization, and rich error metadata.
///
/// Validators can be composed using [and], [or], and [when]:
///
/// ```dart
/// final validator = Bf.required().and(Bf.minLength(8));
/// final result = validator.validate('hi');
/// // result?.message == 'Must be at least 8 characters'
/// ```
abstract class BfValidator<T> {
  /// Creates a validator.
  const BfValidator();

  /// Validates the given [value].
  ///
  /// Returns `null` if the value is valid, or an [BfValidationResult]
  /// describing the validation failure.
  ///
  /// The optional [context] provides access to sibling field values
  /// for cross-field validation.
  BfValidationResult? validate(T? value, [BfValidationContext? context]);

  /// Composes this validator with [other] using AND logic.
  ///
  /// Both validators must pass for the result to be valid.
  /// If this validator fails, its error is returned immediately
  /// without running [other].
  ///
  /// ```dart
  /// final validator = Bf.required().and(Bf.email());
  /// ```
  BfValidator<T> and(BfValidator<T> other) => _AndValidator<T>(this, other);

  /// Composes this validator with [other] using OR logic.
  ///
  /// At least one validator must pass for the result to be valid.
  /// Returns the error from [other] only if both validators fail.
  ///
  /// ```dart
  /// final validator = Bf.email().or(Bf.url());
  /// ```
  BfValidator<T> or(BfValidator<T> other) => _OrValidator<T>(this, other);

  /// Wraps this validator with a condition.
  ///
  /// The validator only runs when [predicate] returns `true`.
  /// If [predicate] returns `false`, validation is skipped and
  /// the value is considered valid.
  ///
  /// The [predicate] receives the [BfValidationContext] (if any) so it can
  /// inspect sibling field values for conditional validation:
  ///
  /// ```dart
  /// final validator = Bf.required().when((ctx) {
  ///   return ctx?.sibling<String>('type') == 'business';
  /// });
  /// ```
  BfValidator<T> when(bool Function(BfValidationContext? context) predicate) =>
      _ConditionalValidator<T>(this, predicate);
}

/// Composes two validators with AND logic.
///
/// Both [first] and [second] must pass. Short-circuits on the first failure.
class _AndValidator<T> extends BfValidator<T> {
  final BfValidator<T> _first;
  final BfValidator<T> _second;

  const _AndValidator(this._first, this._second);

  @override
  BfValidationResult? validate(T? value, [BfValidationContext? context]) {
    return _first.validate(value, context) ?? _second.validate(value, context);
  }
}

/// Composes two validators with OR logic.
///
/// At least one of [first] or [second] must pass.
class _OrValidator<T> extends BfValidator<T> {
  final BfValidator<T> _first;
  final BfValidator<T> _second;

  const _OrValidator(this._first, this._second);

  @override
  BfValidationResult? validate(T? value, [BfValidationContext? context]) {
    final firstResult = _first.validate(value, context);
    if (firstResult == null) return null;

    final secondResult = _second.validate(value, context);
    if (secondResult == null) return null;

    // Both failed — return the second validator's error
    return secondResult;
  }
}

/// Wraps a validator with a conditional predicate.
///
/// The wrapped validator only runs when [predicate] returns `true`.
class _ConditionalValidator<T> extends BfValidator<T> {
  final BfValidator<T> _validator;
  final bool Function(BfValidationContext? context) _predicate;

  const _ConditionalValidator(this._validator, this._predicate);

  @override
  BfValidationResult? validate(T? value, [BfValidationContext? context]) {
    if (!_predicate(context)) return null;
    return _validator.validate(value, context);
  }
}
