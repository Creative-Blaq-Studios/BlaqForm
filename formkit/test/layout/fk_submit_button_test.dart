import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formkit/formkit.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('FkSubmitButton', () {
    testWidgets('renders an ElevatedButton', (tester) async {
      // Given: a form with a submit button
      final formController = FkFormController();

      await tester.pumpWidget(
        buildTestForm(
          controller: formController,
          child: FkSubmitButton(
            onSubmit: (_) async {},
          ),
        ),
      );

      // Then: an ElevatedButton is rendered with default label
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Submit'), findsOneWidget);

      addTearDown(formController.dispose);
    });

    testWidgets('button is disabled when form is invalid', (tester) async {
      // Given: a form controller with an invalid field
      final formController = FkFormController();
      final fieldController = FkFieldController<String>(
        initialValue: '',
        validators: [const AlwaysInvalidValidator('Required')],
      );

      await tester.pumpWidget(
        buildTestForm(
          controller: formController,
          child: Column(
            children: [
              FkTextField(
                name: 'email',
                controller: fieldController,
              ),
              FkSubmitButton(
                onSubmit: (_) async {},
              ),
            ],
          ),
        ),
      );

      // Trigger validation by setting value
      fieldController.value = '';
      await tester.pump();

      // Then: the button is disabled (onPressed is null)
      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button.onPressed, isNull);

      addTearDown(() {
        formController.dispose();
        fieldController.dispose();
      });
    });

    testWidgets('button shows loading indicator when isSubmitting',
        (tester) async {
      // Given: a form controller and a submit that takes time
      final formController = FkFormController();
      final submitCompleter = Completer<void>();

      await tester.pumpWidget(
        buildTestForm(
          controller: formController,
          child: FkSubmitButton(
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

    testWidgets('button calls onSubmit callback', (tester) async {
      // Given: a form with a valid field and a submit button
      final formController = FkFormController();
      bool onSubmitCalled = false;

      await tester.pumpWidget(
        buildTestForm(
          controller: formController,
          child: FkSubmitButton(
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
