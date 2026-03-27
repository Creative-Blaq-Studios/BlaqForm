import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formkit/formkit.dart';

void main() {
  group('FkFormProgress', () {
    testWidgets('shows 0% when no fields have values', (tester) async {
      final form = FkFormController();
      final field1 = FkFieldController<String>(
        validators: [Fk.required()],
      );
      final field2 = FkFieldController<String>(
        validators: [Fk.required()],
      );
      form.register('name', field1);
      form.register('email', field2);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FkFormProgress(controller: form),
          ),
        ),
      );

      expect(find.text('0 of 2'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(indicator.value, 0.0);

      form.dispose();
      field1.dispose();
      field2.dispose();
    });

    testWidgets('updates when fields become valid', (tester) async {
      final form = FkFormController();
      final field1 = FkFieldController<String>(
        validators: [Fk.required()],
      );
      final field2 = FkFieldController<String>(
        validators: [Fk.required()],
      );
      form.register('name', field1);
      form.register('email', field2);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FkFormProgress(controller: form),
          ),
        ),
      );

      // Set one field to a valid value
      field1.value = 'John';
      await tester.pump();

      expect(find.text('1 of 2'), findsOneWidget);

      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(indicator.value, 0.5);

      form.dispose();
      field1.dispose();
      field2.dispose();
    });
  });
}
