import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blaq_form/blaq_form.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('BfSubmitButton', () {
    testWidgets('renders an ElevatedButton', (tester) async {
      // Given: a form with a submit button
      final formController = BfFormController();

      await tester.pumpWidget(
        buildTestForm(
          controller: formController,
          child: BfSubmitButton(onSubmit: (_) async {}),
        ),
      );

      // Then: an ElevatedButton is rendered with default label
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Submit'), findsOneWidget);

      addTearDown(formController.dispose);
    });

    testWidgets('button is disabled when form is invalid', (tester) async {
      // Given: a form controller with an invalid field
      final formController = BfFormController();
      final fieldController = BfFieldController<String>(
        initialValue: '',
        validators: [const AlwaysInvalidValidator('Required')],
      );

      await tester.pumpWidget(
        buildTestForm(
          controller: formController,
          child: Column(
            children: [
              BfTextField(name: 'email', controller: fieldController),
              BfSubmitButton(onSubmit: (_) async {}),
            ],
          ),
        ),
      );

      // Trigger validation by setting value
      fieldController.value = '';
      await tester.pump();

      // Then: the button is disabled (onPressed is null)
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);

      addTearDown(() {
        formController.dispose();
        fieldController.dispose();
      });
    });

    testWidgets('button shows loading indicator when isSubmitting', (
      tester,
    ) async {
      // Given: a form controller and a submit that takes time
      final formController = BfFormController();
      final submitCompleter = Completer<void>();

      await tester.pumpWidget(
        buildTestForm(
          controller: formController,
          child: BfSubmitButton(
            disableWhenInvalid: false,
            onSubmit: (controller) async {
              await controller.submit((_) => submitCompleter.future);
            },
          ),
        ),
      );

      // When: the button is pressed (starts submission)
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Then: a CircularProgressIndicator is shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Submit'), findsNothing);

      // Clean up: complete the submission
      submitCompleter.complete();
      await tester.pump();

      addTearDown(formController.dispose);
    });

    testWidgets('button is disabled on pristine form with validators', (
      tester,
    ) async {
      // Given: a form with required fields that haven't been touched
      final formController = BfFormController();
      final fieldController = BfFieldController<String>(
        validators: [Bf.required()],
      );

      await tester.pumpWidget(
        buildTestForm(
          controller: formController,
          child: Column(
            children: [
              BfTextField(name: 'name', controller: fieldController),
              BfSubmitButton(onSubmit: (_) async {}),
            ],
          ),
        ),
      );
      await tester.pump(); // flush registration microtask

      // Then: button is disabled — field is pristine + has validators
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);

      // When: user fills in the field
      fieldController.value = 'John';
      await tester.pump();

      // Then: button becomes enabled
      final enabledButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(enabledButton.onPressed, isNotNull);

      addTearDown(() {
        formController.dispose();
        fieldController.dispose();
      });
    });

    testWidgets('button calls onSubmit callback', (tester) async {
      // Given: a form with a valid field and a submit button
      final formController = BfFormController();
      bool onSubmitCalled = false;

      await tester.pumpWidget(
        buildTestForm(
          controller: formController,
          child: BfSubmitButton(
            disableWhenInvalid: false,
            onSubmit: (controller) async {
              onSubmitCalled = true;
            },
          ),
        ),
      );

      // When: the button is pressed
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Then: the onSubmit callback is invoked
      expect(onSubmitCalled, isTrue);

      addTearDown(formController.dispose);
    });
  });
}
