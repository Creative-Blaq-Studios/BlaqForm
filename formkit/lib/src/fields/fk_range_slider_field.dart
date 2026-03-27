import 'package:flutter/material.dart';

import '../form/form.dart';
import '../state/fk_field_controller.dart';

/// A range slider field bound to [FkFieldController<RangeValues>].
///
/// Renders a standard Flutter [RangeSlider] that syncs its start and end
/// positions with the controller value. Optionally displays the current
/// range and a label.
///
/// ```dart
/// FkRangeSliderField(
///   name: 'priceRange',
///   controller: priceRangeController,
///   min: 0,
///   max: 1000,
///   divisions: 100,
/// )
/// ```
class FkRangeSliderField extends StatefulWidget {
  /// Creates a range slider field bound to [controller].
  const FkRangeSliderField({
    super.key,
    required this.name,
    required this.controller,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.labelText,
    this.showValues = true,
    this.enabled = true,
    this.activeColor,
    this.inactiveColor,
  });

  /// The name used to register this field with an [FkFormController].
  final String name;

  /// The field controller that owns the value and validation state.
  final FkFieldController<RangeValues> controller;

  /// The minimum value the range slider can take.
  final double min;

  /// The maximum value the range slider can take.
  final double max;

  /// The number of discrete divisions on the slider.
  final int? divisions;

  /// Label text displayed above the range slider.
  final String? labelText;

  /// Whether to display the current range values.
  final bool showValues;

  /// Whether the field accepts user interaction.
  final bool enabled;

  /// The color of the active portion of the slider track.
  final Color? activeColor;

  /// The color of the inactive portion of the slider track.
  final Color? inactiveColor;

  @override
  State<FkRangeSliderField> createState() => _FkRangeSliderFieldState();
}

class _FkRangeSliderFieldState extends State<FkRangeSliderField> {
  FkFormState? _formState;

  // ---------------------------------------------------------------------------
  // Auto-registration (mirrors FkFieldMixin)
  // ---------------------------------------------------------------------------

  String get _fieldName => widget.name;

  FkFieldController<RangeValues> get _controller => widget.controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newFormState = FkForm.maybeOf(context);
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
    // Initialize controller to full range if no value has been set.
    if (widget.controller.value == null) {
      widget.controller.value = RangeValues(widget.min, widget.max);
    }
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant FkRangeSliderField oldWidget) {
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

  void _onChanged(RangeValues values) {
    widget.controller.markTouched();
    widget.controller.value = values;
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Formats a value for display, using integers when divisions are set.
  String _formatValue(double value) {
    return widget.divisions != null
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorText =
        fkShouldShowError(controller: _controller, formState: _formState) ? widget.controller.error?.message : null;
    final currentValues =
        widget.controller.value ?? RangeValues(widget.min, widget.max);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.labelText != null || widget.showValues)
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0, left: 4.0, right: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.labelText != null)
                  Text(
                    widget.labelText!,
                    style: theme.textTheme.bodyMedium,
                  ),
                if (widget.showValues)
                  Text(
                    '${_formatValue(currentValues.start)} – ${_formatValue(currentValues.end)}',
                    style: theme.textTheme.bodyMedium,
                  ),
              ],
            ),
          ),
        RangeSlider(
          values: RangeValues(
            currentValues.start.clamp(widget.min, widget.max),
            currentValues.end.clamp(widget.min, widget.max),
          ),
          min: widget.min,
          max: widget.max,
          divisions: widget.divisions,
          activeColor: widget.activeColor,
          inactiveColor: widget.inactiveColor,
          onChanged: widget.enabled ? _onChanged : null,
          labels: widget.divisions != null
              ? RangeLabels(
                  _formatValue(currentValues.start),
                  _formatValue(currentValues.end),
                )
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
