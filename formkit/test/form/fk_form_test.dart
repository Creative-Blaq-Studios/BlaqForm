import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formkit/formkit.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('FkForm', () {
    testWidgets('FkForm.of() provides controller to descendants',
        (tester) async {
      // Given: an FkFormController and a form with a Builder child
      final formController = FkFormController();
      FkFormController? retrievedController;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FkForm(
              controller: formController,
              child: Builder(
                builder: (context) {
                  retrievedController = FkForm.of(context).controller;
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      );

      // Then: the retrieved controller matches the one provided
      expect(retrievedController, same(formController));

      addTearDown(formController.dispose);
    });

    testWidgets('FkForm.maybeOf() returns null when no form ancestor exists',
        (tester) async {
      // Given: a widget with no FkForm ancestor
      FkFormState? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                result = FkForm.maybeOf(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      // Then: maybeOf returns null
      expect(result, isNull);
    });

    testWidgets('fields auto-register when placed inside FkForm',
        (tester) async {
      // Given: a form controller and a text field controller
      final formController = FkFormController();
      final fieldController = FkFieldController<String>(initialValue: '');

      // When: we place an FkTextField inside an FkForm
      await tester.pumpWidget(
        buildTestForm(
          controller: formController,
          child: FkTextField(
            name: 'email',
            controller: fieldController,
          ),
        ),
      );

      // Then: the field is registered in the form controller
      expect(formController.toMap().containsKey('email'), isTrue);
      expect(formController.field<String>('email'), same(fieldController));

      addTearDown(() {
        formController.dispose();
        fieldController.dispose();
      });
    });

    testWidgets('fields auto-unregister when removed from tree',
        (tester) async {
      // Given: a form controller with a registered field
      final formController = FkFormController();
      final fieldController = FkFieldController<String>(initialValue: '');
      final showField = ValueNotifier<bool>(true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FkForm(
              controller: formController,
              autovalidateMode: FkAutovalidateMode.always,
              child: ValueListenableBuilder<bool>(
                valueListenable: showField,
                builder: (context, show, _) {
                  if (show) {
                    return FkTextField(
                      name: 'email',
                      controller: fieldController,
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      );

      // Verify field is registered
      expect(formController.toMap().containsKey('email'), isTrue);

      // When: the field is removed from the tree
      showField.value = false;
      await tester.pump();

      // Then: the field is unregistered from the form controller
      expect(formController.toMap().containsKey('email'), isFalse);

      addTearDown(() {
        showField.dispose();
        formController.dispose();
        fieldController.dispose();
      });
    });
  });
}
