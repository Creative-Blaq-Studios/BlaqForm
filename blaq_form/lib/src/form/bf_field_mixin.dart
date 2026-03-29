import 'package:flutter/widgets.dart';

import '../state/bf_field_controller.dart';
import 'bf_autovalidate_mode.dart';
import 'bf_form.dart';

/// Mixin that provides auto-registration behavior for field widgets.
///
/// Any widget using this mixin must provide [fieldName] and [controller].
/// When placed inside an [BfForm], the field auto-registers in
/// [didChangeDependencies] and auto-unregisters in [dispose].
///
/// ```dart
/// class _MyFieldState extends State<MyField>
///     with BfFieldMixin<MyField, String> {
///   @override
///   String get fieldName => widget.name;
///
///   @override
///   BfFieldController<String> get controller => widget.controller;
/// }
/// ```
mixin BfFieldMixin<W extends StatefulWidget, T> on State<W> {
  /// The name this field registers under in the form.
  String get fieldName;

  /// The field controller managing this field's state.
  BfFieldController<T> get controller;

  BfFormState? _formState;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newFormState = BfForm.maybeOf(context);
    if (newFormState != _formState) {
      // Re-parenting: unregister from old form, register with new.
      _formState?.controller.unregister(fieldName);
      _formState = newFormState;
      _formState?.controller.register(fieldName, controller);
    }
  }

  @override
  void dispose() {
    _formState?.controller.unregister(fieldName);
    super.dispose();
  }

  /// Whether to show validation errors based on the form's autovalidate mode.
  ///
  /// Returns `true` when validation errors should be visible to the user,
  /// taking into account the current [BfAutovalidateMode] and the field's
  /// interaction state.
  ///
  /// If the field is not inside an [BfForm], this defaults to showing errors
  /// only when the field has been touched (matching
  /// [BfAutovalidateMode.onUserInteraction] behavior).
  bool get shouldShowError {
    final hasError = controller.error != null;
    if (!hasError) return false;

    final mode = _formState?.autovalidateMode;

    // When not inside a form, default to showing errors after user interaction.
    if (mode == null) {
      return controller.isTouched;
    }

    switch (mode) {
      case BfAutovalidateMode.disabled:
        return false;
      case BfAutovalidateMode.onUserInteraction:
        return controller.isTouched;
      case BfAutovalidateMode.always:
        return true;
      case BfAutovalidateMode.onSubmit:
        final formState = _formState;
        if (formState == null) return false;
        return formState.hasBeenSubmitted ||
            formState.controller.isSubmitting;
    }
  }
}
