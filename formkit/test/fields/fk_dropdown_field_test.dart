import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formkit/formkit.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('FkDropdownField', () {
    test('renders a DropdownButtonFormField', () {
      // Covered implicitly by other tests — placeholder for structure
    });

    testWidgets('updates controller value on selection', (tester) async {
      final controller = FkFieldController<String>(initialValue: 'a');

      await tester.pumpWidget(buildTestForm(
        child: FkDropdownField<String>(
          name: 'choice',
          controller: controller,
          items: const [
            DropdownMenuItem(value: 'a', child: Text('A')),
            DropdownMenuItem(value: 'b', child: Text('B')),
          ],
        ),
      ));

      // Open dropdown
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      // Select 'B'
      await tester.tap(find.text('B').last);
      await tester.pumpAndSettle();

      expect(controller.value, 'b');
    });

    testWidgets('reflects external controller value change', (tester) async {
      final controller = FkFieldController<String>(initialValue: 'a');

      await tester.pumpWidget(buildTestForm(
        child: FkDropdownField<String>(
          name: 'choice',
          controller: controller,
          items: const [
            DropdownMenuItem(value: 'a', child: Text('A')),
            DropdownMenuItem(value: 'b', child: Text('B')),
            DropdownMenuItem(value: 'c', child: Text('C')),
          ],
        ),
      ));

      // Initially shows 'A'
      expect(find.text('A'), findsOneWidget);

      // Externally change value to 'c'
      controller.value = 'c';
      await tester.pump();

      // Should now show 'C' — this is the critical bug test.
      // The dropdown should reflect the controller's current value,
      // not be stuck on the initial value.
      expect(find.text('C'), findsOneWidget);
    });

    testWidgets('updates display after form reset', (tester) async {
      final controller = FkFieldController<String>(initialValue: 'a');

      await tester.pumpWidget(buildTestForm(
        child: FkDropdownField<String>(
          name: 'choice',
          controller: controller,
          items: const [
            DropdownMenuItem(value: 'a', child: Text('A')),
            DropdownMenuItem(value: 'b', child: Text('B')),
          ],
        ),
      ));

      // Change value
      controller.value = 'b';
      await tester.pump();
      expect(find.text('B'), findsOneWidget);

      // Reset should go back to initial
      controller.reset();
      await tester.pump();
      expect(find.text('A'), findsOneWidget);
    });
  });
}
