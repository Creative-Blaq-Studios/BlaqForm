import 'package:flutter/foundation.dart';

import '../state/bf_field_controller.dart';
import '../state/bf_form_controller.dart';
import '../validation/bf_validation_context.dart';
import 'bf_wizard_step.dart';

/// Controls wizard navigation state and step-scoped validation.
///
/// [BfWizardController] manages the current step index and provides
/// navigation methods. It extends [ChangeNotifier] so widgets can
/// rebuild when the active step changes.
///
/// ```dart
/// final wizard = BfWizardController(
///   steps: [
///     BfWizardStep(title: 'Name', fieldNames: ['name']),
///     BfWizardStep(title: 'Email', fieldNames: ['email']),
///   ],
/// );
///
/// wizard.goNext();       // advance
/// wizard.goBack();       // retreat
/// wizard.goTo(0);        // jump
/// await wizard.validateAndGoNext(formController);
/// ```
class BfWizardController extends ChangeNotifier {
  /// Creates a wizard controller for the given [steps].
  BfWizardController({required List<BfWizardStep> steps})
    : _steps = List.unmodifiable(steps);

  final List<BfWizardStep> _steps;
  int _currentStep = 0;

  // ---------------------------------------------------------------------------
  // Properties
  // ---------------------------------------------------------------------------

  /// The index of the currently active step.
  int get currentStep => _currentStep;

  /// The total number of steps.
  int get stepCount => _steps.length;

  /// The [BfWizardStep] configuration for the current step.
  BfWizardStep get currentStepConfig => _steps[_currentStep];

  /// All step configurations.
  List<BfWizardStep> get steps => _steps;

  /// Whether the user can navigate backwards (not on the first step).
  bool get canGoBack => _currentStep > 0;

  /// Whether the user can navigate forwards (not on the last step).
  bool get canGoNext => _currentStep < _steps.length - 1;

  /// Whether the current step is the first step.
  bool get isFirstStep => _currentStep == 0;

  /// Whether the current step is the last step.
  bool get isLastStep => _currentStep == _steps.length - 1;

  /// The field names declared for the current step.
  List<String> get fieldNamesForCurrentStep => currentStepConfig.fieldNames;

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  /// Advances to the next step if not already on the last step.
  void goNext() {
    if (!canGoNext) return;
    _currentStep++;
    notifyListeners();
  }

  /// Moves to the previous step if not already on the first step.
  void goBack() {
    if (!canGoBack) return;
    _currentStep--;
    notifyListeners();
  }

  /// Jumps to the step at [index].
  ///
  /// The [index] is clamped to the valid range `[0, stepCount - 1]`.
  void goTo(int index) {
    final clamped = index.clamp(0, _steps.length - 1);
    if (clamped == _currentStep) return;
    _currentStep = clamped;
    notifyListeners();
  }

  /// Validates only the fields belonging to the current step and advances
  /// if all pass.
  ///
  /// Returns `true` if validation passed and the step was advanced (or if
  /// already on the last step and validation passed).
  Future<bool> validateAndGoNext(BfFormController formController) async {
    final context = BfValidationContext(
      fieldValueGetter: <V>(String name) {
        try {
          return formController.field<V>(name).value;
        } catch (_) {
          return null;
        }
      },
    );

    bool allValid = true;
    for (final fieldName in fieldNamesForCurrentStep) {
      BfFieldController<dynamic> field;
      try {
        field = formController.field<dynamic>(fieldName);
      } catch (_) {
        continue;
      }
      final valid = await field.validate(context);
      if (!valid) allValid = false;
    }

    if (!allValid) return false;

    if (canGoNext) {
      goNext();
    }
    return true;
  }
}
