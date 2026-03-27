import 'package:flutter/widgets.dart';

import '../state/fk_form_controller.dart';
import 'fk_autovalidate_mode.dart';

/// A form widget that wraps an [FkFormController] and provides it to
/// descendants via an [InheritedWidget].
///
/// Fields placed inside an [FkForm] can auto-register themselves by using
/// [FkFieldMixin], which looks up the nearest [FkFormState] through the
/// widget tree.
///
/// ```dart
/// FkForm(
///   controller: formController,
///   autovalidateMode: FkAutovalidateMode.onUserInteraction,
///   child: Column(children: [ /* fields */ ]),
/// )
/// ```
class FkForm extends StatefulWidget {
  /// Creates a form widget.
  ///
  /// [controller] is the [FkFormController] that aggregates all registered
  /// field controllers.
  ///
  /// [autovalidateMode] determines when fields display validation errors.
  /// Defaults to [FkAutovalidateMode.onUserInteraction].
  const FkForm({
    super.key,
    required this.controller,
    this.autovalidateMode = FkAutovalidateMode.onUserInteraction,
    required this.child,
  });

  /// The form controller that manages field registration and validation.
  final FkFormController controller;

  /// Controls when fields in this form show validation errors automatically.
  final FkAutovalidateMode autovalidateMode;

  /// The widget subtree that contains the form fields.
  final Widget child;

  /// Returns the nearest [FkFormState] or `null` if none exists.
  ///
  /// Use this when a field may or may not be inside an [FkForm].
  static FkFormState? maybeOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_FkFormScope>();
    return scope?._formState;
  }

  /// Returns the nearest [FkFormState].
  ///
  /// Throws a [FlutterError] if no [FkForm] ancestor is found.
  static FkFormState of(BuildContext context) {
    final state = maybeOf(context);
    if (state == null) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('FkForm.of() called with a context that does not '
            'contain an FkForm.'),
        ErrorDescription(
            'No FkForm ancestor could be found starting from the context '
            'that was passed to FkForm.of().'),
        ErrorHint('This can happen if the context you used comes from a '
            'widget above the FkForm in the widget tree.'),
        context.describeElement('The context used was'),
      ]);
    }
    return state;
  }

  @override
  State<FkForm> createState() => FkFormState();
}

/// The state for an [FkForm] widget.
///
/// Provides access to the [controller] and [autovalidateMode] for descendant
/// widgets, and tracks whether the form has been submitted at least once.
class FkFormState extends State<FkForm> {
  /// The [FkFormController] associated with this form.
  FkFormController get controller => widget.controller;

  /// The current autovalidate mode for this form.
  FkAutovalidateMode get autovalidateMode => widget.autovalidateMode;

  /// Whether the form has been submitted at least once.
  ///
  /// This is used by [FkAutovalidateMode.onSubmit] to determine whether
  /// validation errors should be displayed.
  bool get hasBeenSubmitted => _hasBeenSubmitted;
  bool _hasBeenSubmitted = false;

  /// Marks the form as having been submitted.
  ///
  /// After calling this, fields using [FkAutovalidateMode.onSubmit] will
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
  void didUpdateWidget(covariant FkForm oldWidget) {
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
    return _FkFormScope(
      formState: this,
      child: widget.child,
    );
  }
}

/// An [InheritedWidget] that propagates the [FkFormState] down the tree.
class _FkFormScope extends InheritedWidget {
  const _FkFormScope({
    required FkFormState formState,
    required super.child,
  }) : _formState = formState;

  final FkFormState _formState;

  @override
  bool updateShouldNotify(_FkFormScope oldWidget) {
    return _formState != oldWidget._formState;
  }
}
