import 'package:flutter/material.dart';

import '../form/form.dart';
import '../state/bf_field_controller.dart';

/// A slider field bound to [BfFieldController<double>].
///
/// Renders a standard Flutter [Slider] that syncs its position with the
/// controller value. Optionally shows the current numeric value and a label.
///
/// ```dart
/// BfSliderField(
///   name: 'volume',
///   controller: volumeController,
///   min: 0,
///   max: 100,
///   divisions: 100,
/// )
/// ```
class BfSliderField extends StatefulWidget {
  /// Creates a slider field bound to [controller].
  const BfSliderField({
    super.key,
    required this.name,
    required this.controller,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.labelText,
    this.showValue = true,
    this.enabled = true,
    this.activeColor,
    this.inactiveColor,
  });

  /// The name used to register this field with an [BfFormController].
  final String name;

  /// The field controller that owns the value and validation state.
  final BfFieldController<double> controller;

  /// The minimum value the slider can take.
  final double min;

  /// The maximum value the slider can take.
  final double max;

  /// The number of discrete divisions on the slider.
  final int? divisions;

  /// Label text displayed above the slider.
  final String? labelText;

  /// Whether to display the current value next to the label.
  final bool showValue;

  /// Whether the field accepts user interaction.
  final bool enabled;

  /// The color of the active portion of the slider track.
  final Color? activeColor;

  /// The color of the inactive portion of the slider track.
  final Color? inactiveColor;

  @override
  State<BfSliderField> createState() => _BfSliderFieldState();
}

class _BfSliderFieldState extends State<BfSliderField> {
  BfFormState? _formState;

  // ---------------------------------------------------------------------------
  // Auto-registration (mirrors BfFieldMixin)
  // ---------------------------------------------------------------------------

  String get _fieldName => widget.name;

  BfFieldController<double> get _controller => widget.controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newFormState = BfForm.maybeOf(context);
    if (newFormState != _formState) {
      _formState?.controller.unregister(_fieldName);
      _formState = newFormState;
      _formState?.controller.register(_fieldName, _controller);
    }
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    // Initialize controller to min if no value has been set.
    if (widget.controller.value == null) {
      widget.controller.value = widget.min;
    }
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant BfSliderField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _formState?.controller.unregister(_fieldName);
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Callbacks
  // ---------------------------------------------------------------------------

  void _onControllerChanged() {
    setState(() {});
  }

  void _onChanged(double value) {
    widget.controller.markTouched();
    widget.controller.value = value;
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorText =
        bfShouldShowError(controller: _controller, formState: _formState)
        ? widget.controller.error?.message
        : null;
    final currentValue = widget.controller.value ?? widget.min;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.labelText != null || widget.showValue)
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0, left: 4.0, right: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.labelText != null)
                  Text(widget.labelText!, style: theme.textTheme.bodyMedium),
                if (widget.showValue)
                  Text(
                    currentValue.toStringAsFixed(
                      widget.divisions != null ? 0 : 2,
                    ),
                    style: theme.textTheme.bodyMedium,
                  ),
              ],
            ),
          ),
        Slider(
          value: currentValue.clamp(widget.min, widget.max),
          min: widget.min,
          max: widget.max,
          divisions: widget.divisions,
          activeColor: widget.activeColor,
          inactiveColor: widget.inactiveColor,
          onChanged: widget.enabled ? _onChanged : null,
          label: widget.divisions != null
              ? currentValue.toStringAsFixed(0)
              : null,
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 12.0),
            child: Text(
              errorText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}
