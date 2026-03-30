import 'package:flutter/widgets.dart';

import '../state/bf_form_controller.dart';
import 'bf_autovalidate_mode.dart';

/// A form widget that wraps an [BfFormController] and provides it to
/// descendants via an [InheritedWidget].
///
/// Fields placed inside an [BfForm] can auto-register themselves by using
/// [BfFieldMixin], which looks up the nearest [BfFormState] through the
/// widget tree.
///
/// ```dart
/// BfForm(
///   controller: formController,
///   autovalidateMode: BfAutovalidateMode.onUserInteraction,
///   child: Column(children: [ /* fields */ ]),
/// )
/// ```
class BfForm extends StatefulWidget {
  /// Creates a form widget.
  ///
  /// [controller] is the [BfFormController] that aggregates all registered
  /// field controllers.
  ///
  /// [autovalidateMode] determines when fields display validation errors.
  /// Defaults to [BfAutovalidateMode.onUserInteraction].
  const BfForm({
    super.key,
    required this.controller,
    this.autovalidateMode = BfAutovalidateMode.onUserInteraction,
    required this.child,
  });

  /// The form controller that manages field registration and validation.
  final BfFormController controller;

  /// Controls when fields in this form show validation errors automatically.
  final BfAutovalidateMode autovalidateMode;

  /// The widget subtree that contains the form fields.
  final Widget child;

  /// Returns the nearest [BfFormState] or `null` if none exists.
  ///
  /// Use this when a field may or may not be inside an [BfForm].
  static BfFormState? maybeOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_BfFormScope>();
    return scope?._formState;
  }

  /// Returns the nearest [BfFormState].
  ///
  /// Throws a [FlutterError] if no [BfForm] ancestor is found.
  static BfFormState of(BuildContext context) {
    final state = maybeOf(context);
    if (state == null) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary(
          'BfForm.of() called with a context that does not '
          'contain an BfForm.',
        ),
        ErrorDescription(
          'No BfForm ancestor could be found starting from the context '
          'that was passed to BfForm.of().',
        ),
        ErrorHint(
          'This can happen if the context you used comes from a '
          'widget above the BfForm in the widget tree.',
        ),
        context.describeElement('The context used was'),
      ]);
    }
    return state;
  }

  @override
  State<BfForm> createState() => BfFormState();
}

/// The state for an [BfForm] widget.
///
/// Provides access to the [controller] and [autovalidateMode] for descendant
/// widgets, and tracks whether the form has been submitted at least once.
class BfFormState extends State<BfForm> {
  /// The [BfFormController] associated with this form.
  BfFormController get controller => widget.controller;

  /// The current autovalidate mode for this form.
  BfAutovalidateMode get autovalidateMode => widget.autovalidateMode;

  /// Whether the form has been submitted at least once.
  ///
  /// This is used by [BfAutovalidateMode.onSubmit] to determine whether
  /// validation errors should be displayed.
  bool get hasBeenSubmitted => _hasBeenSubmitted;
  bool _hasBeenSubmitted = false;

  /// Marks the form as having been submitted.
  ///
  /// After calling this, fields using [BfAutovalidateMode.onSubmit] will
  /// begin displaying validation errors.
  void markSubmitted() {
    if (!_hasBeenSubmitted) {
      setState(() {
        _hasBeenSubmitted = true;
      });
    }
  }

  bool _wasSubmitting = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant BfForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    final isSubmitting = widget.controller.isSubmitting;
    if (isSubmitting && !_wasSubmitting) {
      markSubmitted();
    }
    _wasSubmitting = isSubmitting;
  }

  @override
  Widget build(BuildContext context) {
    return _BfFormScope(formState: this, child: widget.child);
  }
}

/// An [InheritedWidget] that propagates the [BfFormState] down the tree.
class _BfFormScope extends InheritedWidget {
  const _BfFormScope({required BfFormState formState, required super.child})
    : _formState = formState;

  final BfFormState _formState;

  @override
  bool updateShouldNotify(_BfFormScope oldWidget) {
    return _formState != oldWidget._formState;
  }
}
