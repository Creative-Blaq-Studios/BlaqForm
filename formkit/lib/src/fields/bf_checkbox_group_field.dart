import 'package:flutter/material.dart';

import '../form/form.dart';
import '../state/bf_field_controller.dart';

/// A multi-select checkbox group bound to [BfFieldController<List<T>>].
///
/// Renders a [Column] of [CheckboxListTile] widgets. Toggling an item
/// adds or removes it from the controller's [List<T>] value. The controller
/// value is initialized to an empty list if `null`.
///
/// ```dart
/// BfCheckboxGroupField<String>(
///   name: 'toppings',
///   controller: toppingsController,
///   options: ['Cheese', 'Pepperoni', 'Mushrooms'],
///   labelBuilder: (t) => t,
/// )
/// ```
class BfCheckboxGroupField<T> extends StatefulWidget {
  /// Creates a multi-select checkbox group bound to [controller].
  const BfCheckboxGroupField({
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
  final BfFieldController<List<T>> controller;

  /// The list of selectable options.
  final List<T> options;

  /// Builds a display label for each option.
  final String Function(T) labelBuilder;

  /// Whether the checkboxes accept user interaction.
  final bool enabled;

  @override
  State<BfCheckboxGroupField<T>> createState() =>
      _BfCheckboxGroupFieldState<T>();
}

class _BfCheckboxGroupFieldState<T> extends State<BfCheckboxGroupField<T>> {
  BfFormState? _formState;

  // ---------------------------------------------------------------------------
  // Auto-registration (mirrors BfFieldMixin for generic widgets)
  // ---------------------------------------------------------------------------

  String get _fieldName => widget.name;

  BfFieldController<List<T>> get _controller => widget.controller;

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
    // Initialize with empty list if the controller value is null.
    if (widget.controller.value == null) {
      widget.controller.value = <T>[];
    }
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant BfCheckboxGroupField<T> oldWidget) {
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

  void _onToggle(T item, bool? checked) {
    final current = List<T>.from(widget.controller.value ?? <T>[]);
    if (checked == true) {
      if (!current.contains(item)) {
        current.add(item);
      }
    } else {
      current.remove(item);
    }
    widget.controller.value = current;
    widget.controller.markTouched();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final errorText =
        bfShouldShowError(controller: _controller, formState: _formState) ? widget.controller.error?.message : null;
    final selectedValues = widget.controller.value ?? <T>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ...widget.options.map((option) {
          return CheckboxListTile(
            title: Text(widget.labelBuilder(option)),
            value: selectedValues.contains(option),
            onChanged: widget.enabled ? (checked) => _onToggle(option, checked) : null,
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
    );
  }
}
