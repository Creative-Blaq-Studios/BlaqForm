import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formkit/formkit.dart';

void main() {
  group('FkDirtyGuard', () {
    testWidgets('allows pop when form is not dirty', (tester) async {
      final form = FkFormController();
      final field1 = FkFieldController<String>(
        validators: [Fk.required()],
      );
      form.register('name', field1);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FkDirtyGuard(
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
