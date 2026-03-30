import 'package:flutter/widgets.dart';

import '../builder/bf_field_config.dart';
import '../builder/bf_form_builder_scope.dart';
import '../form/bf_autovalidate_mode.dart';
import '../form/bf_form.dart';
import '../state/bf_field_controller.dart';
import '../state/bf_form_controller.dart';
import '../validation/bf_validator.dart';
import 'bf_wizard_controller.dart';
import 'bf_wizard_step.dart';

/// A multi-step form widget that combines [BfFormController] with
/// [BfWizardController] for wizard-style form flows.
///
/// Similar to [BfFormBuilder] but adds step-based navigation. The [builder]
/// callback receives the [BuildContext], an [BfFormBuilderScope] for rendering
/// fields, and an [BfWizardController] for navigating between steps.
///
/// ```dart
/// BfWizard(
///   fields: {
///     'name': BfFieldConfig<String>.text(label: 'Name'),
///     'email': BfFieldConfig<String>.email(label: 'Email'),
///   },
///   steps: [
///     BfWizardStep(title: 'Info', fieldNames: ['name']),
///     BfWizardStep(title: 'Contact', fieldNames: ['email']),
///   ],
///   builder: (context, scope, wizard) => Column(children: [
///     if (wizard.currentStep == 0) scope.text('name'),
///     if (wizard.currentStep == 1) scope.email('email'),
///   ]),
///   onComplete: (values) async => print(values),
/// )
/// ```
class BfWizard extends StatefulWidget {
  /// Creates a wizard form widget.
  const BfWizard({
    super.key,
    required this.fields,
    required this.steps,
    required this.builder,
    this.onComplete,
    this.autovalidateMode = BfAutovalidateMode.onUserInteraction,
    this.crossValidators = const [],
  });

  /// Declarative field configurations keyed by field name.
  final Map<String, BfFieldConfig> fields;

  /// The wizard steps, each declaring which fields belong to it.
  final List<BfWizardStep> steps;

  /// Builder callback that receives context, scope, and wizard controller.
  final Widget Function(
    BuildContext context,
    BfFormBuilderScope scope,
    BfWizardController wizard,
  )
  builder;

  /// Optional callback invoked when the wizard is completed (all steps valid).
  final Future<void> Function(Map<String, dynamic> values)? onComplete;

  /// Controls when fields display validation errors automatically.
  final BfAutovalidateMode autovalidateMode;

  /// Cross-field validators applied at completion time.
  final List<BfValidator<Map<String, dynamic>>> crossValidators;

  @override
  State<BfWizard> createState() => _BfWizardState();
}

class _BfWizardState extends State<BfWizard> {
  late BfFormController _formController;
  late Map<String, BfFieldController> _controllers;
  late Map<String, BfFieldConfig> _configs;
  late BfWizardController _wizardController;

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

    _wizardController = BfWizardController(steps: widget.steps);
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
          scope.onSubmit = widget.onComplete;
          return widget.builder(innerContext, scope, _wizardController);
        },
      ),
    );
  }
}
