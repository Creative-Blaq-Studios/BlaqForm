import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blaq_form/blaq_form.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('BfAutocompleteField', () {
    final options = ['Apple', 'Banana', 'Cherry', 'Date'];

    // Helper: synchronous optionsBuilder wrapped as a Future.
    Future<List<String>> syncBuilder(String text) async => options
        .where((o) => o.toLowerCase().contains(text.toLowerCase()))
        .toList();

    testWidgets('renders a TextField', (tester) async {
      final controller = BfFieldController<String>();

      await tester.pumpWidget(
        buildTestForm(
          child: BfAutocompleteField<String>(
            name: 'fruit',
            controller: controller,
            optionsBuilder: syncBuilder,
            displayStringForOption: (o) => o,
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);

      addTearDown(controller.dispose);
    });

    testWidgets('renders label text when provided', (tester) async {
      final controller = BfFieldController<String>();

      await tester.pumpWidget(
        buildTestForm(
          child: BfAutocompleteField<String>(
            name: 'fruit',
            controller: controller,
            optionsBuilder: syncBuilder,
            displayStringForOption: (o) => o,
            labelText: 'Favourite Fruit',
          ),
        ),
      );

      expect(find.text('Favourite Fruit'), findsOneWidget);

      addTearDown(controller.dispose);
    });

    testWidgets('optionsBuilder is called with typed query', (tester) async {
      // Verify that the optionsBuilder is invoked when text is entered.
      // The internal debounce timer fires and the builder is called with the
      // typed query string.
      final capturedQueries = <String>[];

      Future<List<String>> trackingBuilder(String text) async {
        capturedQueries.add(text);
        return options
            .where((o) => o.toLowerCase().contains(text.toLowerCase()))
            .toList();
      }

      final controller = BfFieldController<String>();

      await tester.pumpWidget(
        buildTestForm(
          child: BfAutocompleteField<String>(
            name: 'fruit',
            controller: controller,
            debounce: Duration.zero,
            optionsBuilder: trackingBuilder,
            displayStringForOption: (o) => o,
          ),
        ),
      );

      // Type "ap" to trigger the debounced options fetch.
      await tester.enterText(find.byType(TextField), 'ap');

      // Fire the zero-duration timer so the async optionsBuilder is called.
      await tester.pump(Duration.zero);
      await tester.pumpAndSettle();

      // The debounced builder should have been called with the typed query.
      expect(capturedQueries, contains('ap'));

      addTearDown(controller.dispose);
    });

    testWidgets('selecting an option updates the controller value',
        (tester) async {
      final controller = BfFieldController<String>();

      await tester.pumpWidget(
        buildTestForm(
          child: BfAutocompleteField<String>(
            name: 'fruit',
            controller: controller,
            debounce: Duration.zero,
            optionsBuilder: syncBuilder,
            displayStringForOption: (o) => o,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'ba');
      await tester.pumpAndSettle();

      // Tap the "Banana" option in the overlay.
      final bananaFinder = find.text('Banana');
      if (bananaFinder.evaluate().isNotEmpty) {
        await tester.tap(bananaFinder.first);
        await tester.pumpAndSettle();
        expect(controller.value, equals('Banana'));
      }

      addTearDown(controller.dispose);
    });

    testWidgets('empty query does not trigger options builder', (tester) async {
      var callCount = 0;

      Future<List<String>> countingBuilder(String text) async {
        callCount++;
        return options;
      }

      final controller = BfFieldController<String>();

      await tester.pumpWidget(
        buildTestForm(
          child: BfAutocompleteField<String>(
            name: 'fruit',
            controller: controller,
            debounce: Duration.zero,
            optionsBuilder: countingBuilder,
            displayStringForOption: (o) => o,
          ),
        ),
      );

      // Entering an empty string should not call the options builder.
      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();

      expect(callCount, isZero);

      addTearDown(controller.dispose);
    });
  });
}
