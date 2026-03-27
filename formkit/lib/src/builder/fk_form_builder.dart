import 'package:flutter/widgets.dart';

import '../form/fk_autovalidate_mode.dart';
import '../form/fk_form.dart';
import '../state/fk_field_controller.dart';
import '../state/fk_form_controller.dart';
import '../validation/fk_validator.dart';
import 'fk_field_config.dart';
import 'fk_form_builder_scope.dart';

/// A zero-boilerplate form widget that auto-creates controllers from a
/// declarative field map.
///
/// [FkFormBuilder] takes a `fields` map of [FkFieldConfig] objects and
/// automatically creates the corresponding [FkFieldController]s and an
/// [FkFormController]. The [builder] callback receives an [FkFormBuilderScope]
/// that provides fluent methods for rendering pre-wired field widgets.
///
/// ```dart
/// FkFormBuilder(
///   fields: {
///     'name': FkFieldConfig<String>.text(label: 'Name'),
///     'email': FkFieldConfig<String>.email(label: 'Email'),
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
class FkFormBuilder extends StatefulWidget {
  /// Creates a form builder.
  ///
  /// [fields] maps field names to their configurations. Controllers are
  /// created automatically in [initState] from each config's
  /// [FkFieldConfig.buildController].
  ///
  /// [builder] receives an [FkFormBuilderScope] for rendering fields.
  ///
  /// [onSubmit] is an optional callback invoked when the scope's
  /// [FkFormBuilderScope.submitButton] is pressed. It receives the form
  /// values map.
  const FkFormBuilder({
    super.key,
    required this.fields,
    required this.builder,
    this.onSubmit,
    this.autovalidateMode = FkAutovalidateMode.onUserInteraction,
    this.crossValidators = const [],
  });

  /// Declarative field configurations keyed by field name.
  final Map<String, FkFieldConfig> fields;

  /// Builder callback that receives an [FkFormBuilderScope] and returns the
  /// form's widget tree.
  final Widget Function(FkFormBuilderScope scope) builder;

  /// Optional callback invoked on form submission with the form values.
  final Future<void> Function(Map<String, dynamic> values)? onSubmit;

  /// Controls when fields display validation errors automatically.
  final FkAutovalidateMode autovalidateMode;

  /// Cross-field validators applied at submit time.
  final List<FkValidator<Map<String, dynamic>>> crossValidators;

  @override
  State<FkFormBuilder> createState() => _FkFormBuilderState();
}

class _FkFormBuilderState extends State<FkFormBuilder> {
  late FkFormController _formController;
  late Map<String, FkFieldController> _controllers;
  late Map<String, FkFieldConfig> _configs;

  @override
  void initState() {
    super.initState();

    _formController = FkFormController(
      crossValidators: widget.crossValidators,
    );

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
    return FkForm(
      controller: _formController,
      autovalidateMode: widget.autovalidateMode,
      child: Builder(
        builder: (innerContext) {
          final scope = FkFormBuilderScope(
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
