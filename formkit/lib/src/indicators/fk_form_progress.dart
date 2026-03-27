import 'package:flutter/material.dart';

import '../state/fk_form_controller.dart';

/// Displays a [LinearProgressIndicator] reflecting how many fields in the form
/// are currently valid.
///
/// By default a label like "3 of 5" is rendered below the progress bar.
/// Customise or hide it via [showLabel] and [labelBuilder].
///
/// ```dart
/// FkFormProgress(controller: formController)
/// ```
class FkFormProgress extends StatelessWidget {
  /// Creates a form-progress indicator.
  const FkFormProgress({
    required this.controller,
    this.showLabel = true,
    this.labelBuilder,
    this.color,
    this.backgroundColor,
    this.height = 4.0,
    super.key,
  });

  /// The [FkFormController] whose field-level validity is tracked.
  final FkFormController controller;

  /// Whether to display the textual label (e.g. "3 of 5").
  final bool showLabel;

  /// Optional builder to customise the label text.
  ///
  /// Receives the number of valid fields and the total field count.
  /// When `null`, a default "X of Y" string is used.
  final String Function(int valid, int total)? labelBuilder;

  /// The colour of the filled portion of the progress bar.
  ///
  /// Defaults to the theme's primary colour.
  final Color? color;

  /// The colour of the unfilled portion of the progress bar.
  final Color? backgroundColor;

  /// The height of the progress bar in logical pixels.
  final double height;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final errors = controller.errors;
        final total = errors.length;
        // A field counts as "valid" for progress purposes when it has been
        // modified (dirty) and currently has no validation error.
        var valid = 0;
        for (final name in errors.keys) {
          final field = controller.field(name);
          if (field.isDirty && errors[name] == null) {
            valid++;
          }
        }
        final progress = total == 0 ? 0.0 : valid / total;

        final label = labelBuilder?.call(valid, total) ?? '$valid of $total';

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: progress,
              color: color,
              backgroundColor: backgroundColor,
              minHeight: height,
            ),
            if (showLabel) ...[
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        );
      },
    );
  }
}
