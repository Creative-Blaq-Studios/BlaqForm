import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blaq_form/blaq_form.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('BfFormSection', () {
    testWidgets('renders title and description', (tester) async {
      // Given: a form section with title and description
      await tester.pumpWidget(
        buildTestForm(
          child: BfFormSection(
            title: 'Personal Info',
            description: 'Enter your details below.',
            children: const [SizedBox()],
          ),
        ),
      );

      // Then: the title and description are rendered
      expect(find.text('Personal Info'), findsOneWidget);
      expect(find.text('Enter your details below.'), findsOneWidget);
    });

    testWidgets('renders children', (tester) async {
      // Given: a form section with children
      await tester.pumpWidget(
        buildTestForm(
          child: BfFormSection(
            title: 'Section',
            children: const [Text('Child 1'), Text('Child 2')],
          ),
        ),
      );

      // Then: the children are rendered
      expect(find.text('Child 1'), findsOneWidget);
      expect(find.text('Child 2'), findsOneWidget);
    });

    testWidgets('collapsible section collapses and expands on tap', (
      tester,
    ) async {
      // Given: a collapsible section that starts expanded
      await tester.pumpWidget(
        buildTestForm(
          child: BfFormSection(
            title: 'Collapsible',
            collapsible: true,
            initiallyExpanded: true,
            children: const [Text('Hidden Content')],
          ),
        ),
      );

      // Children are visible initially
      expect(find.text('Hidden Content'), findsOneWidget);

      // When: the header is tapped to collapse
      await tester.tap(find.text('Collapsible'));
      await tester.pumpAndSettle();

      // Then: the children are hidden (SizeTransition collapses)
      // The widget still exists but has zero size
      final sizeTransition = tester.widget<SizeTransition>(
        find.byType(SizeTransition),
      );
      expect(sizeTransition.sizeFactor.value, equals(0.0));

      // When: the header is tapped again to expand
      await tester.tap(find.text('Collapsible'));
      await tester.pumpAndSettle();

      // Then: the children are visible again
      final expandedTransition = tester.widget<SizeTransition>(
        find.byType(SizeTransition),
      );
      expect(expandedTransition.sizeFactor.value, equals(1.0));
    });

    testWidgets('non-collapsible section always shows children', (
      tester,
    ) async {
      // Given: a non-collapsible section
      await tester.pumpWidget(
        buildTestForm(
          child: BfFormSection(
            title: 'Always Visible',
            collapsible: false,
            children: const [Text('Always shown')],
          ),
        ),
      );

      // Then: the children are visible
      expect(find.text('Always shown'), findsOneWidget);

      // And: there is no SizeTransition (not collapsible)
      expect(find.byType(SizeTransition), findsNothing);

      // And: there is no expand icon
      expect(find.byIcon(Icons.expand_more), findsNothing);
    });
  });
}
