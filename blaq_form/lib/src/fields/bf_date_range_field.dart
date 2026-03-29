import 'package:flutter/material.dart';

import '../form/form.dart';
import '../state/bf_field_controller.dart';

/// A date range picker field bound to [BfFieldController<DateTimeRange>].
///
/// Renders an [InputDecorator] that displays the currently selected date range
/// in "start — end" format. Tapping the field opens a [showDateRangePicker]
/// dialog. The selected range is written back to the controller.
///
/// ```dart
/// BfDateRangeField(
///   name: 'vacation',
///   controller: vacationController,
///   firstDate: DateTime.now(),
///   lastDate: DateTime.now().add(Duration(days: 365)),
/// )
/// ```
class BfDateRangeField extends StatefulWidget {
  /// Creates a date range picker field bound to [controller].
  const BfDateRangeField({
    super.key,
    required this.name,
    required this.controller,
    this.firstDate,
    this.lastDate,
    this.labelText,
    this.hintText,
    this.decoration,
    this.enabled = true,
  });

  /// The name used to register this field with an [BfFormController].
  final String name;

  /// The field controller that owns the value and validation state.
  final BfFieldController<DateTimeRange> controller;

  /// The earliest selectable date. Defaults to 1970-01-01.
  final DateTime? firstDate;

  /// The latest selectable date. Defaults to 2100-12-31.
  final DateTime? lastDate;

  /// Label text displayed above or within the field.
  final String? labelText;

  /// Placeholder text shown when no date range is selected.
  final String? hintText;

  /// Optional custom [InputDecoration]. When provided, [labelText] and
  /// [hintText] are ignored.
  final InputDecoration? decoration;

  /// Whether the field accepts user interaction.
  final bool enabled;

  @override
  State<BfDateRangeField> createState() => _BfDateRangeFieldState();
}

class _BfDateRangeFieldState extends State<BfDateRangeField> {
  BfFormState? _formState;

  // ---------------------------------------------------------------------------
  // Auto-registration (mirrors BfFieldMixin)
  // ---------------------------------------------------------------------------

  String get _fieldName => widget.name;

  BfFieldController<DateTimeRange> get _controller => widget.controller;

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
  void didUpdateWidget(covariant BfDateRangeField oldWidget) {
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

    final firstDate = widget.firstDate ?? DateTime(1970);
    final lastDate = widget.lastDate ?? DateTime(2100, 12, 31);

    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: widget.controller.value,
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

  /// Formats a [DateTime] as `yyyy-MM-dd`.
  String _formatDate(DateTime date) {
    final yyyy = date.year.toString().padLeft(4, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '$yyyy-$mm-$dd';
  }

  /// Formats a [DateTimeRange] as "start \u2014 end".
  String _formatRange(DateTimeRange range) {
    return '${_formatDate(range.start)} \u2014 ${_formatDate(range.end)}';
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final errorText =
        bfShouldShowError(controller: _controller, formState: _formState) ? widget.controller.error?.message : null;

    final rangeValue = widget.controller.value;
    final displayText = rangeValue != null ? _formatRange(rangeValue) : null;

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
