import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formkit/formkit.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('FkOtpField', () {
    testWidgets('renders the correct number of text fields', (tester) async {
      final controller = FkFieldController<String>();

      await tester.pumpWidget(buildTestForm(
        child: FkOtpField(
          name: 'otp',
          controller: controller,
          length: 4,
        ),
      ));

      // Should have 4 TextField widgets for the 4 OTP boxes
      expect(find.byType(TextField), findsNWidgets(4));
    });

    testWidgets('concatenates box inputs into controller value',
        (tester) async {
      final controller = FkFieldController<String>();

      await tester.pumpWidget(buildTestForm(
        child: FkOtpField(
          name: 'otp',
          controller: controller,
          length: 4,
        ),
      ));

      final textFields = find.byType(TextField);

      // Type a digit into each box
      await tester.enterText(textFields.at(0), '1');
      await tester.pump();
      await tester.enterText(textFields.at(1), '2');
      await tester.pump();
      await tester.enterText(textFields.at(2), '3');
      await tester.pump();
      await tester.enterText(textFields.at(3), '4');
      await tester.pump();

      expect(controller.value, '1234');
    });

    testWidgets('syncs from external controller value change',
        (tester) async {
      final controller = FkFieldController<String>();

      await tester.pumpWidget(buildTestForm(
        child: FkOtpField(
          name: 'otp',
          controller: controller,
          length: 4,
        ),
      ));

      controller.value = '5678';
      await tester.pump();

      // Each box should show its digit
      expect(find.text('5'), findsOneWidget);
      expect(find.text('6'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
    });

    testWidgets(
        'KeyboardListener focus nodes are stable across rebuilds (no leak)',
        (tester) async {
      final controller = FkFieldController<String>();

      await tester.pumpWidget(buildTestForm(
        child: FkOtpField(
          name: 'otp',
          controller: controller,
          length: 2,
        ),
      ));

      // Find all KeyboardListener widgets and collect their focusNodes
      final listenersBefore = tester
          .widgetList<KeyboardListener>(find.byType(KeyboardListener))
          .map((kl) => kl.focusNode)
          .toList();

      // Trigger a rebuild
      controller.value = '12';
      await tester.pump();

      final listenersAfter = tester
          .widgetList<KeyboardListener>(find.byType(KeyboardListener))
          .map((kl) => kl.focusNode)
          .toList();

      // The FocusNodes should be the SAME objects (reused, not recreated).
      // If they're different, it means new FocusNodes are leaked every rebuild.
      expect(listenersAfter.length, listenersBefore.length);
      for (var i = 0; i < listenersBefore.length; i++) {
        expect(
          identical(listenersAfter[i], listenersBefore[i]),
          isTrue,
          reason:
              'KeyboardListener FocusNode at index $i was recreated on rebuild — memory leak',
        );
      }
    });
  });
}
