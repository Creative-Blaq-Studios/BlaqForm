import 'package:flutter_test/flutter_test.dart';
import 'package:blaq_form/blaq_form.dart';

void main() {
  group('BfWizardController', () {
    late BfWizardController controller;

    setUp(() {
      controller = BfWizardController(
        steps: [
          BfWizardStep(title: 'Step 1', fieldNames: ['name']),
          BfWizardStep(title: 'Step 2', fieldNames: ['email']),
          BfWizardStep(title: 'Step 3', fieldNames: ['phone']),
        ],
      );
    });

    tearDown(() {
      controller.dispose();
    });

    test('starts at step 0', () {
      expect(controller.currentStep, 0);
    });

    test('stepCount returns number of steps', () {
      expect(controller.stepCount, 3);
    });

    test('canGoBack is false at first step', () {
      expect(controller.canGoBack, isFalse);
    });

    test('canGoNext is true at first step', () {
      expect(controller.canGoNext, isTrue);
    });

    test('goNext advances to the next step', () {
      controller.goNext();
      expect(controller.currentStep, 1);
    });

    test('goBack moves to the previous step', () {
      controller.goNext();
      expect(controller.currentStep, 1);
      controller.goBack();
      expect(controller.currentStep, 0);
    });

    test('goNext at last step does nothing', () {
      controller.goNext(); // 1
      controller.goNext(); // 2 (last)
      controller.goNext(); // should stay at 2
      expect(controller.currentStep, 2);
    });

    test('goBack at first step does nothing', () {
      controller.goBack();
      expect(controller.currentStep, 0);
    });

    test('goTo jumps to the given step', () {
      controller.goTo(2);
      expect(controller.currentStep, 2);
    });

    test('isLastStep returns true on the last step', () {
      controller.goTo(2);
      expect(controller.isLastStep, isTrue);
      expect(controller.isFirstStep, isFalse);
    });

    test('fieldNamesForCurrentStep returns correct field names', () {
      expect(controller.fieldNamesForCurrentStep, ['name']);
      controller.goNext();
      expect(controller.fieldNamesForCurrentStep, ['email']);
    });
  });
}
