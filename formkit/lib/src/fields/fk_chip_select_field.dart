import 'package:flutter/material.dart';

import '../form/form.dart';
import '../state/fk_field_controller.dart';

/// A chip-based multi-select field bound to [FkFieldController<List<T>>].
///
/// Renders the provided [options] as [FilterChip] widgets inside a [Wrap].
/// Tapping a chip toggles its selection in the controller's value list.
///
/// ```dart
/// FkChipSelectField<String>(
///   name: 'tags',
///   controller: tagsController,
///   options: ['Flutter', 'Dart', 'Firebase'],
///   labelBuilder: (tag) => tag,
/// )
/// ```
class FkChipSelectField<T> extends StatefulWidget {
  /// Creates a chip-based multi-select field bound to [controller].
  const FkChipSelectField({
    super.key,
    required this.name,
    required this.controller,
    required this.options,
    required this.labelBuilder,
    this.avatarBuilder,
    this.labelText,
    this.enabled = true,
    this.wrap = true,
    this.spacing = 8.0,
    this.runSpacing = 4.0,
  });

  /// The name used to register this field with an [FkFormController].
  final String name;

  /// The field controller that owns the value and validation state.
  final FkFieldController<List<T>> controller;

  /// The full list of selectable options.
  final List<T> options;

  /// Converts an option to its display label string.
  final String Function(T) labelBuilder;

  /// Optional builder for a leading avatar widget on each chip.
  final Widget Function(T)? avatarBuilder;

  /// Label text displayed above the chips.
  final String? labelText;

  /// Whether the field accepts user interaction.
  final bool enabled;

  /// Whether chips should wrap to the next line.
  ///
  /// When `true` (default), chips are rendered in a [Wrap] widget. When
  /// `false`, they are laid out in a single scrollable row.
  final bool wrap;

  /// Horizontal spacing between chips.
  final double spacing;

  /// Vertical spacing between chip rows (only applies when [wrap] is `true`).
  final double runSpacing;

  @override
  State<FkChipSelectField<T>> createState() => _FkChipSelectFieldState<T>();
}

class _FkChipSelectFieldState<T> extends State<FkChipSelectField<T>> {
  FkFormState? _formState;

  // ---------------------------------------------------------------------------
  // Auto-registration (mirrors FkFieldMixin)
  // ---------------------------------------------------------------------------

  String get _fieldName => widget.name;

  FkFieldController<List<T>> get _controller => widget.controller;

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
    // Initialize to empty list if the controller has no value.
    _controller.value ??= <T>[];
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant FkChipSelectField<T> oldWidget) {
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

  void _onChipToggled(T option) {
    if (!widget.enabled) return;

    _controller.markTouched();

    final currentList = List<T>.from(_controller.value ?? <T>[]);
    if (currentList.contains(option)) {
      currentList.remove(option);
    } else {
      currentList.add(option);
    }
    _controller.value = currentList;
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final selectedValues = _controller.value ?? <T>[];
    final errorText =
        fkShouldShowError(controller: _controller, formState: _formState) ? _controller.error?.message : null;

    final chips = widget.options.map((option) {
      final isSelected = selectedValues.contains(option);
      return FilterChip(
        label: Text(widget.labelBuilder(option)),
        selected: isSelected,
        avatar: widget.avatarBuilder?.call(option),
        onSelected: widget.enabled ? (_) => _onChipToggled(option) : null,
      );
    }).toList();

    final Widget chipLayout;
    if (widget.wrap) {
      chipLayout = Wrap(
        spacing: widget.spacing,
        runSpacing: widget.runSpacing,
        children: chips,
      );
    } else {
      chipLayout = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: chips
              .expand(
                  (chip) => [chip, SizedBox(width: widget.spacing)])
              .toList()
            ..removeLast(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.labelText != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              widget.labelText!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        chipLayout,
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              errorText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
          ),
      ],
    );
  }
}
