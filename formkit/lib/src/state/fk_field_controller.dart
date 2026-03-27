import 'dart:async';

import 'package:flutter/foundation.dart';

import '../logging/fk_log_category.dart';
import '../logging/fk_logger.dart';
import '../validation/fk_async_validator.dart';
import '../validation/fk_validation_context.dart';
import '../validation/fk_validation_result.dart';
import '../validation/fk_validator.dart';

/// The atomic unit of form state. Every field binds to one controller.
///
/// Owns the current [value], dirty/touched flags, the latest validation
/// [error], and notifies listeners whenever any of these change.
///
/// ```dart
/// final email = FkFieldController<String>(
///   validators: [Fk.required(), Fk.email()],
/// );
/// ```
class FkFieldController<T> extends ChangeNotifier {
  /// Creates a field controller.
  ///
  /// [initialValue] is the value the field resets to.
  /// [validators] are run synchronously whenever [value] changes.
  /// [asyncValidators] are debounced by [asyncDebounce] after sync validators
  /// pass.
  FkFieldController({
    T? initialValue,
    List<FkValidator<T>> validators = const [],
    List<FkAsyncValidator<T>> asyncValidators = const [],
    Duration asyncDebounce = const Duration(milliseconds: 400),
    this.debugLabel,
  })  : _initialValue = initialValue,
        _value = initialValue,
        _validators = validators,
        _asyncValidators = asyncValidators,
        _asyncDebounce = asyncDebounce;

  /// Optional label used in [FkLogger] output to identify this controller.
  ///
  /// When a field registers with an [FkFormController], the form automatically
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
  FkValidationResult? _error;

  final List<FkValidator<T>> _validators;
  final List<FkAsyncValidator<T>> _asyncValidators;
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
    FkLogger.instance.debug(
      FkLogCategory.field,
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
  FkValidationResult? get error => _error;

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  /// Runs all validators (sync first, then async) and returns `true` if the
  /// field is valid.
  ///
  /// An optional [context] can be provided for cross-field validation support.
  Future<bool> validate([FkValidationContext? context]) async {
    // Cancel any pending debounce so we don't get a stale result afterwards.
    _cancelDebounce();

    final log = FkLogger.instance;

    // Run sync validators.
    for (final validator in _validators) {
      final result = validator.validate(_value, context);
      if (result != null) {
        _error = result;
        log.debug(
          FkLogCategory.validation,
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
        FkLogCategory.validation,
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
            FkLogCategory.validation,
            'Async result discarded (stale)',
            field: debugLabel,
          );
          return false;
        }

        if (result != null) {
          _error = result;
          _isValidating = false;
          log.debug(
            FkLogCategory.validation,
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
        FkLogCategory.validation,
        'Async validation passed',
        field: debugLabel,
      );
      notifyListeners();
    } else {
      _error = null;
      notifyListeners();
    }

    log.debug(
      FkLogCategory.validation,
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

  /// Marks the field as touched.
  ///
  /// Typically called when the field loses focus.
  void markTouched() {
    if (_isTouched) return;
    _isTouched = true;
    FkLogger.instance.verbose(
      FkLogCategory.field,
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
    FkLogger.instance.info(
      FkLogCategory.reset,
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
  void _runSyncValidation([FkValidationContext? context]) {
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
