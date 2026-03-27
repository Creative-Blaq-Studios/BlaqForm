import 'package:flutter/material.dart';

import '../form/form.dart';
import '../state/fk_field_controller.dart';

/// A dropdown selection field bound to [FkFieldController<T>].
///
/// Renders a [DropdownButtonFormField] and keeps its selection in sync with
/// the provided [FkFieldController]. Validation errors are displayed
/// automatically based on the form's autovalidate mode.
///
/// ```dart
/// FkDropdownField<String>(
///   name: 'country',
///   controller: countryController,
///   items: countries.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
/// )
/// ```
class FkDropdownField<T> extends StatefulWidget {
  /// Creates a dropdown field bound to [controller].
  const FkDropdownField({
    super.key,
    required this.name,
    required this.controller,
    required this.items,
    this.itemBuilder,
    this.hintText,
    this.labelText,
    this.decoration,
    this.enabled = true,
    this.isExpanded = true,
  });

  /// The name used to register this field with an [FkFormController].
  final String name;

  /// The field controller that owns the value and validation state.
  final FkFieldController<T> controller;

  /// The list of items the user can select from.
  final List<DropdownMenuItem<T>> items;

  /// Optional builder for rendering each item widget.
  ///
  /// When provided, this is used for display purposes alongside [items].
  final Widget Function(T)? itemBuilder;

  /// Placeholder text shown when no item is selected.
  final String? hintText;

  /// Label text displayed above or within the field.
  final String? labelText;

  /// Optional custom [InputDecoration]. When provided, [hintText] and
  /// [labelText] are ignored.
  final InputDecoration? decoration;

  /// Whether the dropdown accepts user interaction.
  final bool enabled;

  /// Whether the dropdown should expand to fill its parent's width.
  final bool isExpanded;

  @override
  State<FkDropdownField<T>> createState() => _FkDropdownFieldState<T>();
}

class _FkDropdownFieldState<T> extends State<FkDropdownField<T>> {
  FkFormState? _formState;

  // ---------------------------------------------------------------------------
  // Auto-registration (mirrors FkFieldMixin for generic widgets)
  // ---------------------------------------------------------------------------

  String get _fieldName => widget.name;

  FkFieldController<T> get _controller => widget.controller;

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
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant FkDropdownField<T> oldWidget) {
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
        fkShouldShowError(controller: _controller, formState: _formState)
            ? widget.controller.error?.message
            : null;

    final effectiveDecoration = widget.decoration ??
        InputDecoration(
          hintText: widget.hintText,
          labelText: widget.labelText,
        );

    // Use a ValueKey so the DropdownButtonFormField is rebuilt when the
    // controller value changes externally (e.g. reset). This ensures
    // initialValue is re-read, working around it being read only once.
    return DropdownButtonFormField<T>(
      key: ValueKey<T?>(widget.controller.value),
      initialValue: widget.controller.value,
      items: widget.items,
      onChanged: widget.enabled ? _onChanged : null,
      isExpanded: widget.isExpanded,
      decoration: effectiveDecoration.copyWith(errorText: errorText),
    );
  }
}
