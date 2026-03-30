import 'dart:async';

import 'package:flutter/foundation.dart';

import '../logging/bf_log_category.dart';
import '../logging/bf_logger.dart';
import '../validation/bf_async_validator.dart';
import '../validation/bf_validation_context.dart';
import '../validation/bf_validation_result.dart';
import '../validation/bf_validator.dart';

/// The atomic unit of form state. Every field binds to one controller.
///
/// Owns the current [value], dirty/touched flags, the latest validation
/// [error], and notifies listeners whenever any of these change.
///
/// ```dart
/// final email = BfFieldController<String>(
///   validators: [Bf.required(), Bf.email()],
/// );
/// ```
class BfFieldController<T> extends ChangeNotifier {
  /// Creates a field controller.
  ///
  /// [initialValue] is the value the field resets to.
  /// [validators] are run synchronously whenever [value] changes.
  /// [asyncValidators] are debounced by [asyncDebounce] after sync validators
  /// pass.
  BfFieldController({
    T? initialValue,
    List<BfValidator<T>> validators = const [],
    List<BfAsyncValidator<T>> asyncValidators = const [],
    Duration asyncDebounce = const Duration(milliseconds: 400),
    this.debugLabel,
  }) : _initialValue = initialValue,
       _value = initialValue,
       _validators = validators,
       _asyncValidators = asyncValidators,
       _asyncDebounce = asyncDebounce;

  /// Optional label used in [BfLogger] output to identify this controller.
  ///
  /// When a field registers with an [BfFormController], the form automatically
  /// sets this to the field name if it is still `null`.
  String? debugLabel;

  // ---------------------------------------------------------------------------
  // Private state
  // ---------------------------------------------------------------------------

  final T? _initialValue;
  T? _value;
  bool _isDirty = false;
  bool _isTouched = false;
  bool _isValidating = false;
  BfValidationResult? _error;

  final List<BfValidator<T>> _validators;
  final List<BfAsyncValidator<T>> _asyncValidators;
  final Duration _asyncDebounce;

  Timer? _debounceTimer;

  /// Monotonically increasing token used to discard stale async results.
  int _asyncToken = 0;

  // ---------------------------------------------------------------------------
  // Core state — getters
  // ---------------------------------------------------------------------------

  /// The current value of this field.
  T? get value => _value;

  /// Sets the field value.
  ///
  /// This marks the field as dirty, runs synchronous validators immediately,
  /// and schedules asynchronous validators (debounced).
  set value(T? newValue) {
    _value = newValue;
    _isDirty = true;
    BfLogger.instance.debug(
      BfLogCategory.field,
      'Value changed',
      field: debugLabel,
      detail: '$newValue',
    );
    _runSyncValidation();
    _scheduleAsyncValidation();
    notifyListeners();
  }

  /// Whether the field value has been changed from its initial value.
  bool get isDirty => _isDirty;

  /// Whether the user has interacted with this field (e.g. focused then
  /// blurred).
  bool get isTouched => _isTouched;

  /// Whether the field is currently valid.
  ///
  /// A field is valid when it has no synchronous error **and** no asynchronous
  /// error.
  bool get isValid => _error == null && !_isValidating;

  /// Whether an asynchronous validation is currently in flight.
  bool get isValidating => _isValidating;

  /// The current validation error, or `null` if the field is valid.
  BfValidationResult? get error => _error;

  /// Whether this field has any sync or async validators.
  ///
  /// Used by [BfFormController] to determine whether a pristine field
  /// should count as "unproven" (has validators but hasn't been touched)
  /// or "always valid" (no validators, nothing to fail).
  bool get hasValidators =>
      _validators.isNotEmpty || _asyncValidators.isNotEmpty;

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  /// Runs all validators (sync first, then async) and returns `true` if the
  /// field is valid.
  ///
  /// An optional [context] can be provided for cross-field validation support.
  Future<bool> validate([BfValidationContext? context]) async {
    // Cancel any pending debounce so we don't get a stale result afterwards.
    _cancelDebounce();

    final log = BfLogger.instance;

    // Run sync validators.
    for (final validator in _validators) {
      final result = validator.validate(_value, context);
      if (result != null) {
        _error = result;
        log.debug(
          BfLogCategory.validation,
          'Sync validation failed',
          field: debugLabel,
          detail: '${result.code}: ${result.message}',
        );
        notifyListeners();
        return false;
      }
    }

    // Sync passed — run async validators sequentially.
    if (_asyncValidators.isNotEmpty) {
      _isValidating = true;
      _error = null;
      log.verbose(
        BfLogCategory.validation,
        'Async validation started',
        field: debugLabel,
      );
      notifyListeners();

      final token = ++_asyncToken;

      for (final asyncValidator in _asyncValidators) {
        final result = await asyncValidator.validate(_value, context);

        // If the value changed while we were awaiting, discard.
        if (token != _asyncToken) {
          log.verbose(
            BfLogCategory.validation,
            'Async result discarded (stale)',
            field: debugLabel,
          );
          return false;
        }

        if (result != null) {
          _error = result;
          _isValidating = false;
          log.debug(
            BfLogCategory.validation,
            'Async validation failed',
            field: debugLabel,
            detail: '${result.code}: ${result.message}',
          );
          notifyListeners();
          return false;
        }
      }

      _isValidating = false;
      _error = null;
      log.verbose(
        BfLogCategory.validation,
        'Async validation passed',
        field: debugLabel,
      );
      notifyListeners();
    } else {
      _error = null;
      notifyListeners();
    }

    log.debug(
      BfLogCategory.validation,
      'All validators passed',
      field: debugLabel,
    );
    return true;
  }

  /// Clears the current validation error without re-running validators.
  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  /// Marks the field as dirty and runs validation.
  ///
  /// Use this for **edit screens** where fields are pre-populated with
  /// existing data via [initialValue]. Without this, a pre-filled field
  /// with validators is considered "unproven" by [BfFormController.isValid],
  /// which keeps [BfSubmitButton] disabled.
  ///
  /// ```dart
  /// final email = BfFieldController<String>(
  ///   initialValue: existingUser.email,
  ///   validators: [Bf.required(), Bf.email()],
  /// );
  /// email.markDirty(); // now counts as validated for the submit button
  /// ```
  void markDirty() {
    if (_isDirty) return;
    _isDirty = true;
    _runSyncValidation();
    BfLogger.instance.verbose(
      BfLogCategory.field,
      'Marked dirty',
      field: debugLabel,
    );
    notifyListeners();
  }

  /// Marks the field as touched.
  ///
  /// Typically called when the field loses focus.
  void markTouched() {
    if (_isTouched) return;
    _isTouched = true;
    BfLogger.instance.verbose(
      BfLogCategory.field,
      'Marked touched',
      field: debugLabel,
    );
    notifyListeners();
  }

  /// Resets the field to its initial state.
  ///
  /// Restores [value] to the initial value passed in the constructor and clears
  /// dirty, touched, validating, and error state.
  void reset() {
    _cancelDebounce();
    _asyncToken++;
    _value = _initialValue;
    _isDirty = false;
    _isTouched = false;
    _isValidating = false;
    _error = null;
    BfLogger.instance.info(
      BfLogCategory.reset,
      'Field reset',
      field: debugLabel,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _cancelDebounce();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  /// Runs synchronous validators and sets [_error] to the first failure.
  void _runSyncValidation([BfValidationContext? context]) {
    for (final validator in _validators) {
      final result = validator.validate(_value, context);
      if (result != null) {
        _error = result;
        return;
      }
    }
    // All sync validators passed — clear any previous sync error.
    _error = null;
  }

  /// Debounces async validators. Cancels any previous pending invocation.
  void _scheduleAsyncValidation() {
    _cancelDebounce();

    if (_asyncValidators.isEmpty || _error != null) return;

    _debounceTimer = Timer(_asyncDebounce, () async {
      _isValidating = true;
      notifyListeners();

      final token = ++_asyncToken;

      for (final asyncValidator in _asyncValidators) {
        final result = await asyncValidator.validate(_value);
        if (token != _asyncToken) return; // value changed, discard

        if (result != null) {
          _error = result;
          _isValidating = false;
          notifyListeners();
          return;
        }
      }

      _isValidating = false;
      notifyListeners();
    });
  }

  void _cancelDebounce() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }
}
