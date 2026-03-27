import 'package:flutter/material.dart';

import '../form/form.dart';
import '../state/fk_field_controller.dart';

/// A date picker field bound to [FkFieldController<DateTime>].
///
/// Renders an [InputDecorator] that displays the currently selected date.
/// Tapping the field opens a [showDatePicker] dialog. The selected date is
/// written back to the controller.
///
/// ```dart
/// FkDateField(
///   name: 'birthDate',
///   controller: birthDateController,
///   firstDate: DateTime(1900),
///   lastDate: DateTime.now(),
/// )
/// ```
class FkDateField extends StatefulWidget {
  /// Creates a date picker field bound to [controller].
  const FkDateField({
    super.key,
    required this.name,
    required this.controller,
    this.firstDate,
    this.lastDate,
    this.labelText,
    this.hintText,
    this.decoration,
    this.dateFormat,
    this.enabled = true,
  });

  /// The name used to register this field with an [FkFormController].
  final String name;

  /// The field controller that owns the value and validation state.
  final FkFieldController<DateTime> controller;

  /// The earliest selectable date. Defaults to 1970-01-01.
  final DateTime? firstDate;

  /// The latest selectable date. Defaults to 2100-12-31.
  final DateTime? lastDate;

  /// Label text displayed above or within the field.
  final String? labelText;

  /// Placeholder text shown when no date is selected.
  final String? hintText;

  /// Optional custom [InputDecoration]. When provided, [labelText] and
  /// [hintText] are ignored.
  final InputDecoration? decoration;

  /// A simple date format string (e.g. `'yyyy-MM-dd'`).
  ///
  /// Only the tokens `yyyy`, `MM`, and `dd` are supported. If `null`, the
  /// date is formatted as `yyyy-MM-dd` by default.
  final String? dateFormat;

  /// Whether the field accepts user interaction.
  final bool enabled;

  @override
  State<FkDateField> createState() => _FkDateFieldState();
}

class _FkDateFieldState extends State<FkDateField> {
  FkFormState? _formState;

  // ---------------------------------------------------------------------------
  // Auto-registration (mirrors FkFieldMixin)
  // ---------------------------------------------------------------------------

  String get _fieldName => widget.name;

  FkFieldController<DateTime> get _controller => widget.controller;

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
  void didUpdateWidget(covariant FkDateField oldWidget) {
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

  Future<void> _openPicker() async {
    if (!widget.enabled) return;

    final initialDate = widget.controller.value ?? DateTime.now();
    final firstDate = widget.firstDate ?? DateTime(1970);
    final lastDate = widget.lastDate ?? DateTime(2100, 12, 31);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    widget.controller.markTouched();

    if (picked != null) {
      widget.controller.value = picked;
    }
  }

  // ---------------------------------------------------------------------------
  // Formatting
  // ---------------------------------------------------------------------------

  /// Formats a [DateTime] using the simple format string or the default
  /// `yyyy-MM-dd` representation.
  String _formatDate(DateTime date) {
    final format = widget.dateFormat ?? 'yyyy-MM-dd';
    final yyyy = date.year.toString().padLeft(4, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return format
        .replaceAll('yyyy', yyyy)
        .replaceAll('MM', mm)
        .replaceAll('dd', dd);
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final errorText =
        fkShouldShowError(controller: _controller, formState: _formState) ? widget.controller.error?.message : null;

    final dateValue = widget.controller.value;
    final displayText = dateValue != null ? _formatDate(dateValue) : null;

    final effectiveDecoration = widget.decoration ??
        InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
        );

    return GestureDetector(
      onTap: widget.enabled ? _openPicker : null,
      child: InputDecorator(
        decoration: effectiveDecoration.copyWith(
          errorText: errorText,
        ),
        isEmpty: displayText == null,
        child: displayText != null ? Text(displayText) : null,
      ),
    );
  }
}
