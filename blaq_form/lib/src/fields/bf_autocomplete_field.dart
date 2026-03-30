import 'dart:async';

import 'package:flutter/material.dart';

import '../form/form.dart';
import '../state/bf_field_controller.dart';

/// An autocomplete/search field with async suggestions.
///
/// Bound to [BfFieldController<T>] where T is the selected item type.
/// Uses Flutter's built-in [Autocomplete] widget as the foundation and wraps
/// the [optionsBuilder] with debouncing logic.
///
/// ```dart
/// BfAutocompleteField<City>(
///   name: 'city',
///   controller: cityController,
///   optionsBuilder: (query) => cityService.search(query),
///   displayStringForOption: (city) => city.name,
/// )
/// ```
class BfAutocompleteField<T extends Object> extends StatefulWidget {
  /// Creates an autocomplete field bound to [controller].
  const BfAutocompleteField({
    super.key,
    required this.name,
    required this.controller,
    required this.optionsBuilder,
    required this.displayStringForOption,
    this.labelText,
    this.hintText,
    this.decoration,
    this.enabled = true,
    this.debounce = const Duration(milliseconds: 300),
    this.optionBuilder,
  });

  /// The name used to register this field with an [BfFormController].
  final String name;

  /// The field controller that owns the value and validation state.
  final BfFieldController<T> controller;

  /// Async callback that returns matching options for the given query.
  final Future<List<T>> Function(String query) optionsBuilder;

  /// Converts an option to its display string.
  final String Function(T) displayStringForOption;

  /// Label text displayed above or within the field.
  final String? labelText;

  /// Placeholder text shown when no value is selected.
  final String? hintText;

  /// Optional custom [InputDecoration]. When provided, [labelText] and
  /// [hintText] are ignored.
  final InputDecoration? decoration;

  /// Whether the field accepts user interaction.
  final bool enabled;

  /// Duration to debounce the [optionsBuilder] calls.
  final Duration debounce;

  /// Optional custom builder for each option in the dropdown.
  final Widget Function(BuildContext, T)? optionBuilder;

  @override
  State<BfAutocompleteField<T>> createState() => _BfAutocompleteFieldState<T>();
}

class _BfAutocompleteFieldState<T extends Object>
    extends State<BfAutocompleteField<T>> {
  BfFormState? _formState;
  Timer? _debounceTimer;
  List<T> _currentOptions = [];

  /// Tracks whether we are programmatically updating the text field so we can
  /// avoid re-triggering the options builder.
  bool _isUpdatingText = false;

  // ---------------------------------------------------------------------------
  // Auto-registration (mirrors BfFieldMixin)
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
  void didUpdateWidget(covariant BfAutocompleteField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
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

  /// Debounced options fetcher. Cancels any pending timer and schedules a new
  /// async fetch after the configured [BfAutocompleteField.debounce] duration.
  void _fetchOptions(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounce, () async {
      try {
        final results = await widget.optionsBuilder(query);
        if (mounted) {
          setState(() {
            _currentOptions = results;
          });
        }
      } catch (_) {
        // Silently swallow — the caller's optionsBuilder should handle its
        // own error reporting if needed.
      }
    });
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

    final effectiveDecoration =
        widget.decoration ??
        InputDecoration(labelText: widget.labelText, hintText: widget.hintText);

    return Autocomplete<T>(
      displayStringForOption: widget.displayStringForOption,
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (_isUpdatingText) return _currentOptions;

        final query = textEditingValue.text;
        if (query.isEmpty) {
          return const Iterable.empty();
        }
        _fetchOptions(query);
        return _currentOptions;
      },
      onSelected: (T selection) {
        _controller.markTouched();
        _controller.value = selection;
      },
      optionsViewBuilder: widget.optionBuilder != null
          ? (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4.0,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (ctx, index) {
                        final option = options.elementAt(index);
                        return InkWell(
                          onTap: () => onSelected(option),
                          child: widget.optionBuilder!(ctx, option),
                        );
                      },
                    ),
                  ),
                ),
              );
            }
          : null,
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
            // Sync controller value to text field when it changes externally.
            final currentValue = _controller.value;
            final expectedText = currentValue != null
                ? widget.displayStringForOption(currentValue)
                : '';
            if (textEditingController.text != expectedText &&
                !focusNode.hasFocus) {
              _isUpdatingText = true;
              textEditingController.text = expectedText;
              _isUpdatingText = false;
            }

            return TextField(
              controller: textEditingController,
              focusNode: focusNode,
              enabled: widget.enabled,
              decoration: effectiveDecoration.copyWith(errorText: errorText),
              onSubmitted: (_) => onFieldSubmitted(),
              onTap: () => _controller.markTouched(),
            );
          },
    );
  }
}
