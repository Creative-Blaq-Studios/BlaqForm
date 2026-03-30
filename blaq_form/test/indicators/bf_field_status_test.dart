import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blaq_form/blaq_form.dart';

void main() {
  group('BfFieldStatus', () {
    testWidgets('shows check icon when valid and touched', (tester) async {
      final controller = BfFieldController<String>(validators: [Bf.required()]);

      // Set a valid value and mark as touched
      controller.value = 'hello';
      controller.markTouched();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: BfFieldStatus(controller: controller)),
        ),
      );

      expect(find.byIcon(Icons.check_circle), findsOneWidget);

      controller.dispose();
    });

    testWidgets('shows error icon when has error and touched', (tester) async {
      final controller = BfFieldController<String>(validators: [Bf.required()]);

      // Touch without setting a value (required validator will fail)
      controller.markTouched();
      await controller.validate();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: BfFieldStatus(controller: controller)),
        ),
      );

      expect(find.byIcon(Icons.error), findsOneWidget);

      controller.dispose();
    });

    testWidgets('shows loading when validating', (tester) async {
      // Use a Completer that never completes to keep the controller in the
      // isValidating state without leaving a pending Timer.
      final neverComplete = Completer<bool>();
      addTearDown(() {
        if (!neverComplete.isCompleted) neverComplete.complete(true);
      });

      final controller = BfFieldController<String>(
        asyncValidators: [Bf.unique<String>((value) => neverComplete.future)],
      );

      controller.value = 'test';
      controller.markTouched();

      // Trigger validate but don't await — starts async validation.
      final future = controller.validate();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: BfFieldStatus(controller: controller)),
        ),
      );

      // Should show loading indicator while validating
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete the future and let it settle so no pending timers remain.
      neverComplete.complete(true);
      await future;
      await tester.pump();

      controller.dispose();
    });

    testWidgets('shows nothing when untouched', (tester) async {
      final controller = BfFieldController<String>(validators: [Bf.required()]);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: BfFieldStatus(controller: controller)),
        ),
      );

      // Should show an empty SizedBox — no icons, no indicators
      expect(find.byIcon(Icons.check_circle), findsNothing);
      expect(find.byIcon(Icons.error), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(SizedBox), findsWidgets);

      controller.dispose();
    });
  });
}
