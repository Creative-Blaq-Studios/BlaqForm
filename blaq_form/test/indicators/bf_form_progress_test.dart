import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blaq_form/blaq_form.dart';

void main() {
  group('BfFormProgress', () {
    testWidgets('shows 0% when no fields have values', (tester) async {
      final form = BfFormController();
      final field1 = BfFieldController<String>(validators: [Bf.required()]);
      final field2 = BfFieldController<String>(validators: [Bf.required()]);
      form.register('name', field1);
      form.register('email', field2);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: BfFormProgress(controller: form)),
        ),
      );
      // Flush the post-frame callback that activates the listener.
      await tester.pump();

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
      final form = BfFormController();
      final field1 = BfFieldController<String>(validators: [Bf.required()]);
      final field2 = BfFieldController<String>(validators: [Bf.required()]);
      form.register('name', field1);
      form.register('email', field2);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: BfFormProgress(controller: form)),
        ),
      );
      await tester.pump();

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
