import 'package:flutter/widgets.dart';

import '../form/bf_autovalidate_mode.dart';
import '../form/bf_form.dart';
import '../state/bf_field_controller.dart';
import '../state/bf_form_controller.dart';
import '../validation/bf_validator.dart';
import 'bf_field_config.dart';
import 'bf_form_builder_scope.dart';

/// A zero-boilerplate form widget that auto-creates controllers from a
/// declarative field map.
///
/// [BfFormBuilder] takes a `fields` map of [BfFieldConfig] objects and
/// automatically creates the corresponding [BfFieldController]s and an
/// [BfFormController]. The [builder] callback receives an [BfFormBuilderScope]
/// that provides fluent methods for rendering pre-wired field widgets.
///
/// ```dart
/// BfFormBuilder(
///   fields: {
///     'name': BfFieldConfig<String>.text(label: 'Name'),
///     'email': BfFieldConfig<String>.email(label: 'Email'),
///   },
///   onSubmit: (values) async {
///     await api.register(values);
///   },
///   builder: (scope) => Column(children: [
///     scope.text('name'),
///     scope.email('email'),
///     scope.submitButton('Register'),
///   ]),
/// )
/// ```
class BfFormBuilder extends StatefulWidget {
  /// Creates a form builder.
  ///
  /// [fields] maps field names to their configurations. Controllers are
  /// created automatically in [initState] from each config's
  /// [BfFieldConfig.buildController].
  ///
  /// [builder] receives an [BfFormBuilderScope] for rendering fields.
  ///
  /// [onSubmit] is an optional callback invoked when the scope's
  /// [BfFormBuilderScope.submitButton] is pressed. It receives the form
  /// values map.
  const BfFormBuilder({
    super.key,
    required this.fields,
    required this.builder,
    this.onSubmit,
    this.autovalidateMode = BfAutovalidateMode.onUserInteraction,
    this.crossValidators = const [],
  });

  /// Declarative field configurations keyed by field name.
  final Map<String, BfFieldConfig> fields;

  /// Builder callback that receives an [BfFormBuilderScope] and returns the
  /// form's widget tree.
  final Widget Function(BfFormBuilderScope scope) builder;

  /// Optional callback invoked on form submission with the form values.
  final Future<void> Function(Map<String, dynamic> values)? onSubmit;

  /// Controls when fields display validation errors automatically.
  final BfAutovalidateMode autovalidateMode;

  /// Cross-field validators applied at submit time.
  final List<BfValidator<Map<String, dynamic>>> crossValidators;

  @override
  State<BfFormBuilder> createState() => _BfFormBuilderState();
}

class _BfFormBuilderState extends State<BfFormBuilder> {
  late BfFormController _formController;
  late Map<String, BfFieldController> _controllers;
  late Map<String, BfFieldConfig> _configs;

  @override
  void initState() {
    super.initState();

    _formController = BfFormController(crossValidators: widget.crossValidators);

    _configs = Map.of(widget.fields);
    _controllers = {};

    for (final entry in widget.fields.entries) {
      final controller = entry.value.buildController();
      _controllers[entry.key] = controller;
    }
  }

  @override
  void dispose() {
    // Dispose all field controllers.
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _formController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BfForm(
      controller: _formController,
      autovalidateMode: widget.autovalidateMode,
      child: Builder(
        builder: (innerContext) {
          final scope = BfFormBuilderScope(
            formController: _formController,
            controllers: _controllers,
            configs: _configs,
          );
          scope.onSubmit = widget.onSubmit;
          return widget.builder(scope);
        },
      ),
    );
  }
}
