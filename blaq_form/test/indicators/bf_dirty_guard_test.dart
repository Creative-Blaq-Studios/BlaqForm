import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blaq_form/blaq_form.dart';

void main() {
  group('BfDirtyGuard', () {
    testWidgets('allows pop when form is not dirty', (tester) async {
      final form = BfFormController();
      final field1 = BfFieldController<String>(
        validators: [Bf.required()],
      );
      form.register('name', field1);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BfDirtyGuard(
              controller: form,
              child: const Text('Form Content'),
            ),
          ),
        ),
      );

      // The child content should be rendered
      expect(find.text('Form Content'), findsOneWidget);

      // Form is not dirty, so PopScope should allow pop
      final popScope = tester.widgetList<PopScope<Object?>>(
        find.bySubtype<PopScope<Object?>>(),
      ).last;
      expect(popScope.canPop, isTrue);

      form.dispose();
      field1.dispose();
    });
  });
}
