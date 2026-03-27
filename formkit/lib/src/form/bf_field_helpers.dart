import '../state/bf_field_controller.dart';
import 'bf_autovalidate_mode.dart';
import 'bf_form.dart';

/// Determines whether a field should display its validation error.
///
/// Used by field widgets that can't use [BfFieldMixin] due to generic
/// type parameter constraints.
bool bfShouldShowError({
  required BfFieldController controller,
  required BfFormState? formState,
}) {
  if (controller.error == null) return false;

  final mode = formState?.autovalidateMode;
  if (mode == null) return controller.isTouched;

  switch (mode) {
    case BfAutovalidateMode.disabled:
      return false;
    case BfAutovalidateMode.onUserInteraction:
      return controller.isTouched;
    case BfAutovalidateMode.always:
      return true;
    case BfAutovalidateMode.onSubmit:
      if (formState == null) return false;
      return formState.hasBeenSubmitted || formState.controller.isSubmitting;
  }
}
