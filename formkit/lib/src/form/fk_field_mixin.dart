import 'package:flutter/widgets.dart';

import '../state/fk_field_controller.dart';
import 'fk_autovalidate_mode.dart';
import 'fk_form.dart';

/// Mixin that provides auto-registration behavior for field widgets.
///
/// Any widget using this mixin must provide [fieldName] and [controller].
/// When placed inside an [FkForm], the field auto-registers in
/// [didChangeDependencies] and auto-unregisters in [dispose].
///
/// ```dart
/// class _MyFieldState extends State<MyField>
///     with FkFieldMixin<MyField, String> {
///   @override
///   String get fieldName => widget.name;
///
///   @override
///   FkFieldController<String> get controller => widget.controller;
/// }
/// ```
mixin FkFieldMixin<W extends StatefulWidget, T> on State<W> {
  /// The name this field registers under in the form.
  String get fieldName;

  /// The field controller managing this field's state.
  FkFieldController<T> get controller;

  FkFormState? _formState;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newFormState = FkForm.maybeOf(context);
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
  /// taking into account the current [FkAutovalidateMode] and the field's
  /// interaction state.
  ///
  /// If the field is not inside an [FkForm], this defaults to showing errors
  /// only when the field has been touched (matching
  /// [FkAutovalidateMode.onUserInteraction] behavior).
  bool get shouldShowError {
    final hasError = controller.error != null;
    if (!hasError) return false;

    final mode = _formState?.autovalidateMode;

    // When not inside a form, default to showing errors after user interaction.
    if (mode == null) {
      return controller.isTouched;
    }

    switch (mode) {
      case FkAutovalidateMode.disabled:
        return false;
      case FkAutovalidateMode.onUserInteraction:
        return controller.isTouched;
      case FkAutovalidateMode.always:
        return true;
      case FkAutovalidateMode.onSubmit:
        final formState = _formState;
        if (formState == null) return false;
        return formState.hasBeenSubmitted ||
            formState.controller.isSubmitting;
    }
  }
}
