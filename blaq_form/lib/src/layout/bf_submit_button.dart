import 'package:flutter/material.dart';

import '../form/form.dart';
import '../state/bf_form_controller.dart';

/// A submit button that integrates with [BfFormController].
///
/// Automatically disables when the form is invalid or submitting, and shows a
/// loading indicator during submission.
///
/// Must be placed inside an [BfForm] so it can look up the controller via
/// [BfForm.of].
///
/// ```dart
/// BfSubmitButton(
///   onSubmit: (controller) async {
///     await controller.submit((values) async {
///       await api.register(values);
///     });
///   },
/// )
/// ```
class BfSubmitButton extends StatelessWidget {
  /// Creates a submit button that integrates with the nearest [BfForm].
  ///
  /// [onSubmit] is called when the button is pressed and receives the form's
  /// [BfFormController].
  const BfSubmitButton({
    super.key,
    required this.onSubmit,
    this.child,
    this.label,
    this.loadingWidget,
    this.disableWhenInvalid = true,
    this.style,
  });

  /// Called when the button is pressed. Receives the form controller.
  ///
  /// Typically calls [BfFormController.submit] internally:
  /// ```dart
  /// onSubmit: (controller) => controller.submit((values) async { ... }),
  /// ```
  final Future<void> Function(BfFormController controller) onSubmit;

  /// Custom child widget for the button.
  ///
  /// When provided, [label] is ignored.
  final Widget? child;

  /// Text label displayed on the button when [child] is `null`.
  ///
  /// Defaults to `'Submit'`.
  final String? label;

  /// Widget shown during submission.
  ///
  /// Defaults to a small [CircularProgressIndicator].
  final Widget? loadingWidget;

  /// Whether to disable the button when the form is invalid.
  ///
  /// Defaults to `true`.
  final bool disableWhenInvalid;

  /// Optional button style applied to the underlying [ElevatedButton].
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    final controller = BfForm.of(context).controller;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final isSubmitting = controller.isSubmitting;
        final isDisabled =
            isSubmitting || (disableWhenInvalid && !controller.isValid);

        return ElevatedButton(
          style: style,
          onPressed: isDisabled ? null : () => onSubmit(controller),
          child: isSubmitting
              ? (loadingWidget ?? _defaultLoadingWidget())
              : (child ?? Text(label ?? 'Submit')),
        );
      },
    );
  }

  Widget _defaultLoadingWidget() {
    return const SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }
}
