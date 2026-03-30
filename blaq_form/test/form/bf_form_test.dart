import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blaq_form/blaq_form.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('BfForm', () {
    testWidgets('BfForm.of() provides controller to descendants', (
      tester,
    ) async {
      // Given: an BfFormController and a form with a Builder child
      final formController = BfFormController();
      BfFormController? retrievedController;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BfForm(
              controller: formController,
              child: Builder(
                builder: (context) {
                  retrievedController = BfForm.of(context).controller;
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

    testWidgets('BfForm.maybeOf() returns null when no form ancestor exists', (
      tester,
    ) async {
      // Given: a widget with no BfForm ancestor
      BfFormState? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                result = BfForm.maybeOf(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      // Then: maybeOf returns null
      expect(result, isNull);
    });

    testWidgets('fields auto-register when placed inside BfForm', (
      tester,
    ) async {
      // Given: a form controller and a text field controller
      final formController = BfFormController();
      final fieldController = BfFieldController<String>(initialValue: '');

      // When: we place an BfTextField inside an BfForm
      await tester.pumpWidget(
        buildTestForm(
          controller: formController,
          child: BfTextField(name: 'email', controller: fieldController),
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

    testWidgets('fields auto-unregister when removed from tree', (
      tester,
    ) async {
      // Given: a form controller with a registered field
      final formController = BfFormController();
      final fieldController = BfFieldController<String>(initialValue: '');
      final showField = ValueNotifier<bool>(true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BfForm(
              controller: formController,
              autovalidateMode: BfAutovalidateMode.always,
              child: ValueListenableBuilder<bool>(
                valueListenable: showField,
                builder: (context, show, _) {
                  if (show) {
                    return BfTextField(
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
