import 'package:flutter/material.dart';

import '../state/bf_form_controller.dart';

/// Displays a [LinearProgressIndicator] reflecting how many fields in the form
/// are currently valid.
///
/// By default a label like "3 of 5" is rendered below the progress bar.
/// Customise or hide it via [showLabel] and [labelBuilder].
///
/// ```dart
/// BfFormProgress(controller: formController)
/// ```
class BfFormProgress extends StatefulWidget {
  /// Creates a form-progress indicator.
  const BfFormProgress({
    required this.controller,
    this.showLabel = true,
    this.labelBuilder,
    this.color,
    this.backgroundColor,
    this.height = 4.0,
    super.key,
  });

  /// The [BfFormController] whose field-level validity is tracked.
  final BfFormController controller;

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
  State<BfFormProgress> createState() => _BfFormProgressState();
}

class _BfFormProgressState extends State<BfFormProgress> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    // Defer listening by one frame so that sibling fields can register with
    // the controller during the initial build without triggering
    // "setState() called during build" on this widget.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LinearProgressIndicator(
            value: 0,
            color: widget.color,
            backgroundColor: widget.backgroundColor,
            minHeight: widget.height,
          ),
          if (widget.showLabel) ...[
            const SizedBox(height: 4),
            Text(
              widget.labelBuilder?.call(0, 0) ?? '0 of 0',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      );
    }

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final errors = widget.controller.errors;
        final total = errors.length;
        var valid = 0;
        for (final name in errors.keys) {
          final field = widget.controller.field(name);
          if (field.isDirty && errors[name] == null) {
            valid++;
          }
        }
        final progress = total == 0 ? 0.0 : valid / total;
        final label =
            widget.labelBuilder?.call(valid, total) ?? '$valid of $total';

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: progress,
              color: widget.color,
              backgroundColor: widget.backgroundColor,
              minHeight: widget.height,
            ),
            if (widget.showLabel) ...[
              const SizedBox(height: 4),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ],
        );
      },
    );
  }
}
