import 'package:flutter/widgets.dart';

import '../builder/fk_field_config.dart';
import '../builder/fk_form_builder_scope.dart';
import '../form/fk_autovalidate_mode.dart';
import '../form/fk_form.dart';
import '../state/fk_field_controller.dart';
import '../state/fk_form_controller.dart';
import '../validation/fk_validator.dart';
import 'fk_wizard_controller.dart';
import 'fk_wizard_step.dart';

/// A multi-step form widget that combines [FkFormController] with
/// [FkWizardController] for wizard-style form flows.
///
/// Similar to [FkFormBuilder] but adds step-based navigation. The [builder]
/// callback receives the [BuildContext], an [FkFormBuilderScope] for rendering
/// fields, and an [FkWizardController] for navigating between steps.
///
/// ```dart
/// FkWizard(
///   fields: {
///     'name': FkFieldConfig<String>.text(label: 'Name'),
///     'email': FkFieldConfig<String>.email(label: 'Email'),
///   },
///   steps: [
///     FkWizardStep(title: 'Info', fieldNames: ['name']),
///     FkWizardStep(title: 'Contact', fieldNames: ['email']),
///   ],
///   builder: (context, scope, wizard) => Column(children: [
///     if (wizard.currentStep == 0) scope.text('name'),
///     if (wizard.currentStep == 1) scope.email('email'),
///   ]),
///   onComplete: (values) async => print(values),
/// )
/// ```
class FkWizard extends StatefulWidget {
  /// Creates a wizard form widget.
  const FkWizard({
    super.key,
    required this.fields,
    required this.steps,
    required this.builder,
    this.onComplete,
    this.autovalidateMode = FkAutovalidateMode.onUserInteraction,
    this.crossValidators = const [],
  });

  /// Declarative field configurations keyed by field name.
  final Map<String, FkFieldConfig> fields;

  /// The wizard steps, each declaring which fields belong to it.
  final List<FkWizardStep> steps;

  /// Builder callback that receives context, scope, and wizard controller.
  final Widget Function(
    BuildContext context,
    FkFormBuilderScope scope,
    FkWizardController wizard,
  ) builder;

  /// Optional callback invoked when the wizard is completed (all steps valid).
  final Future<void> Function(Map<String, dynamic> values)? onComplete;

  /// Controls when fields display validation errors automatically.
  final FkAutovalidateMode autovalidateMode;

  /// Cross-field validators applied at completion time.
  final List<FkValidator<Map<String, dynamic>>> crossValidators;

  @override
  State<FkWizard> createState() => _FkWizardState();
}

class _FkWizardState extends State<FkWizard> {
  late FkFormController _formController;
  late Map<String, FkFieldController> _controllers;
  late Map<String, FkFieldConfig> _configs;
  late FkWizardController _wizardController;

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

    _wizardController = FkWizardController(steps: widget.steps);
    _wizardController.addListener(_onWizardChanged);
  }

  @override
  void dispose() {
    _wizardController.removeListener(_onWizardChanged);
    _wizardController.dispose();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _formController.dispose();
    super.dispose();
  }

  void _onWizardChanged() {
    setState(() {});
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
          scope.onSubmit = widget.onComplete;
          return widget.builder(innerContext, scope, _wizardController);
        },
      ),
    );
  }
}
