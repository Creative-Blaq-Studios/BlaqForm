import 'package:flutter/material.dart';

import '../form/form.dart';
import '../state/bf_field_controller.dart';

/// A single-selection radio group bound to [BfFieldController<T>].
///
/// Renders a [Column] of [RadioListTile] widgets. Selecting an option
/// updates the controller's value to the chosen item.
///
/// ```dart
/// BfRadioGroupField<String>(
///   name: 'size',
///   controller: sizeController,
///   options: ['Small', 'Medium', 'Large'],
///   labelBuilder: (s) => s,
/// )
/// ```
class BfRadioGroupField<T> extends StatefulWidget {
  /// Creates a single-selection radio group bound to [controller].
  const BfRadioGroupField({
    super.key,
    required this.name,
    required this.controller,
    required this.options,
    required this.labelBuilder,
    this.enabled = true,
  });

  /// The name used to register this field with an [BfFormController].
  final String name;

  /// The field controller that owns the value and validation state.
  final BfFieldController<T> controller;

  /// The list of selectable options.
  final List<T> options;

  /// Builds a display label for each option.
  final String Function(T) labelBuilder;

  /// Whether the radio buttons accept user interaction.
  final bool enabled;

  @override
  State<BfRadioGroupField<T>> createState() => _BfRadioGroupFieldState<T>();
}

class _BfRadioGroupFieldState<T> extends State<BfRadioGroupField<T>> {
  BfFormState? _formState;

  // ---------------------------------------------------------------------------
  // Auto-registration (mirrors BfFieldMixin for generic widgets)
  // ---------------------------------------------------------------------------

  String get _fieldName => widget.name;

  BfFieldController<T> get _controller => widget.controller;

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
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant BfRadioGroupField<T> oldWidget) {
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

  void _onChanged(T? value) {
    widget.controller.value = value;
    widget.controller.markTouched();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final errorText =
        bfShouldShowError(controller: _controller, formState: _formState)
        ? widget.controller.error?.message
        : null;

    return RadioGroup<T>(
      groupValue: widget.controller.value,
      onChanged: _onChanged,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ...widget.options.map((option) {
            return RadioListTile<T>(
              title: Text(widget.labelBuilder(option)),
              value: option,
              enabled: widget.enabled,
            );
          }),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 4.0),
              child: Text(
                errorText,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12.0,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
