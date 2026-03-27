import '../state/fk_field_controller.dart';
import 'fk_autovalidate_mode.dart';
import 'fk_form.dart';

/// Determines whether a field should display its validation error.
///
/// Used by field widgets that can't use [FkFieldMixin] due to generic
/// type parameter constraints.
bool fkShouldShowError({
  required FkFieldController controller,
  required FkFormState? formState,
}) {
  if (controller.error == null) return false;

  final mode = formState?.autovalidateMode;
  if (mode == null) return controller.isTouched;

  switch (mode) {
    case FkAutovalidateMode.disabled:
      return false;
    case FkAutovalidateMode.onUserInteraction:
      return controller.isTouched;
    case FkAutovalidateMode.always:
      return true;
    case FkAutovalidateMode.onSubmit:
      if (formState == null) return false;
      return formState.hasBeenSubmitted || formState.controller.isSubmitting;
  }
}
