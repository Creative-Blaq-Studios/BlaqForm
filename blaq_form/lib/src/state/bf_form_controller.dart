import 'package:flutter/foundation.dart';

import '../logging/bf_log_category.dart';
import '../logging/bf_logger.dart';
import '../validation/bf_validation_context.dart';
import '../validation/bf_validation_result.dart';
import '../validation/bf_validator.dart';
import 'bf_field_controller.dart';

/// Aggregates [BfFieldController]s, handles cross-field validation, and gates
/// form submission.
///
/// ```dart
/// final form = BfFormController();
/// form.register('email', emailController);
/// form.register('password', passwordController);
///
/// await form.submit((values) async {
///   await api.login(values['email'], values['password']);
/// });
/// ```
class BfFormController extends ChangeNotifier {
  /// Creates a form controller.
  ///
  /// [crossValidators] receive the full `toMap()` result and can validate
  /// relationships between fields (e.g. "confirm password must match
  /// password").
  BfFormController({
    List<BfValidator<Map<String, dynamic>>> crossValidators = const [],
  }) : crossValidators = List.of(crossValidators);

  // ---------------------------------------------------------------------------
  // Private state
  // ---------------------------------------------------------------------------

  final Map<String, BfFieldController> _fields = {};
  bool _isSubmitting = false;
  final List<BfValidationResult> _crossErrors = [];
  bool _registrationNotifyScheduled = false;
  bool _disposed = false;

  // ---------------------------------------------------------------------------
  // Field management
  // ---------------------------------------------------------------------------

  /// Registers a field controller under [name].
  ///
  /// The form listens for changes on the controller so that aggregate state
  /// (e.g. [isValid], [isDirty]) is kept up-to-date automatically.
  void register(String name, BfFieldController controller) {
    // If a controller with the same name is already registered, unregister it
    // first to avoid duplicate listeners.
    if (_fields.containsKey(name)) {
      unregister(name);
    }
    _fields[name] = controller;
    controller.debugLabel ??= name;
    controller.addListener(_onFieldChanged);
    BfLogger.instance.info(BfLogCategory.form, 'Field registered', field: name);
    _scheduleRegistrationNotify();
  }

  /// Removes the field registered under [name] and stops listening to it.
  void unregister(String name) {
    final controller = _fields.remove(name);
    controller?.removeListener(_onFieldChanged);
    BfLogger.instance.info(
      BfLogCategory.form,
      'Field unregistered',
      field: name,
    );
    _scheduleRegistrationNotify();
  }

  /// Returns the controller registered under [name], cast to
  /// `BfFieldController<T>`.
  ///
  /// Throws a [StateError] if no field with that name is registered.
  BfFieldController<T> field<T>(String name) {
    final controller = _fields[name];
    if (controller == null) {
      throw StateError(
        'BfFormController: no field registered with name "$name".',
      );
    }
    return controller as BfFieldController<T>;
  }

  // ---------------------------------------------------------------------------
  // Aggregate state
  // ---------------------------------------------------------------------------

  /// Whether every registered field is valid **and** no cross-validator errors
  /// exist.
  bool get isValid {
    if (_crossErrors.isNotEmpty) return false;
    return _fields.values.every((f) => f.isValid);
  }

  /// Whether any registered field has been modified from its initial value.
  bool get isDirty => _fields.values.any((f) => f.isDirty);

  /// Whether a [submit] call is currently in progress.
  bool get isSubmitting => _isSubmitting;

  /// A map of field names to their current validation errors.
  ///
  /// Fields without errors map to `null`.
  Map<String, BfValidationResult?> get errors {
    return {for (final entry in _fields.entries) entry.key: entry.value.error};
  }

  // ---------------------------------------------------------------------------
  // Cross-field validation
  // ---------------------------------------------------------------------------

  /// Validators that receive the full form value map and can enforce
  /// constraints across multiple fields.
  List<BfValidator<Map<String, dynamic>>> crossValidators;

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  /// Validates all fields and, if valid, calls [onSubmit] with the form values.
  ///
  /// Returns `true` if validation passed and [onSubmit] completed without
  /// throwing.
  ///
  /// While submission is in progress, [isSubmitting] is `true`.
  Future<bool> submit(
    Future<void> Function(Map<String, dynamic>) onSubmit,
  ) async {
    final log = BfLogger.instance;
    log.info(BfLogCategory.submission, 'Submit started');

    _isSubmitting = true;
    notifyListeners();

    try {
      // Build a validation context that lets validators read sibling values.
      final context = BfValidationContext(
        fieldValueGetter: <V>(String name) {
          final controller = _fields[name];
          return controller?.value as V?;
        },
      );

      // Validate every field.
      bool allValid = true;
      for (final entry in _fields.entries) {
        final valid = await entry.value.validate(context);
        if (!valid) allValid = false;
      }

      if (!allValid) {
        final failing = errors.entries
            .where((e) => e.value != null)
            .map((e) => e.key)
            .toList();
        log.warning(
          BfLogCategory.submission,
          'Submit blocked by field validation',
          detail: 'failing: ${failing.join(', ')}',
        );
        return false;
      }

      // Run cross-field validators against the full value map.
      final values = toMap();
      _crossErrors.clear();
      for (final validator in crossValidators) {
        final result = validator.validate(values, context);
        if (result != null) {
          _crossErrors.add(result);
        }
      }

      if (_crossErrors.isNotEmpty) {
        log.warning(
          BfLogCategory.submission,
          'Submit blocked by cross-field validation',
          detail: _crossErrors.map((e) => e.message).join('; '),
        );
        notifyListeners();
        return false;
      }

      // All validations passed — invoke the callback.
      log.info(
        BfLogCategory.submission,
        'Validation passed, calling onSubmit',
        detail: '${values.length} fields',
      );
      await onSubmit(values);
      log.info(BfLogCategory.submission, 'Submit completed successfully');
      return true;
    } catch (e) {
      log.error(
        BfLogCategory.submission,
        'Submit failed with exception',
        detail: '$e',
      );
      rethrow;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Resets all registered fields to their initial state.
  void reset() {
    _crossErrors.clear();
    for (final controller in _fields.values) {
      controller.reset();
    }
    BfLogger.instance.info(BfLogCategory.reset, 'Form reset');
    notifyListeners();
  }

  /// Returns a map of all registered field names to their current values.
  Map<String, dynamic> toMap() {
    return {for (final entry in _fields.entries) entry.key: entry.value.value};
  }

  @override
  void dispose() {
    _disposed = true;
    for (final controller in _fields.values) {
      controller.removeListener(_onFieldChanged);
    }
    _fields.clear();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  /// Batches registration/unregistration notifications into a single microtask.
  /// This prevents "setState() called during build" when multiple fields
  /// register with the controller during the same build pass, and also
  /// coalesces many registrations into one notification.
  void _scheduleRegistrationNotify() {
    if (_registrationNotifyScheduled) return;
    _registrationNotifyScheduled = true;
    Future.microtask(() {
      _registrationNotifyScheduled = false;
      if (!_disposed) notifyListeners();
    });
  }

  /// Called whenever any registered field notifies. Propagates the change so
  /// widgets listening to the form controller rebuild.
  void _onFieldChanged() {
    notifyListeners();
  }
}
