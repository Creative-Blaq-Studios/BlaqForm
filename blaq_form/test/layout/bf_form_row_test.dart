import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blaq_form/blaq_form.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('BfFormRow', () {
    testWidgets('renders children in a Row', (tester) async {
      // Given: an BfFormRow with two children
      await tester.pumpWidget(
        buildTestForm(
          child: BfFormRow(
            children: const [
              Text('Left'),
              Text('Right'),
            ],
          ),
        ),
      );

      // Then: both children are rendered
      expect(find.text('Left'), findsOneWidget);
      expect(find.text('Right'), findsOneWidget);

      // And: they are inside a Row
      expect(find.byType(Row), findsOneWidget);

      // And: each child is wrapped in an Expanded
      final expandedWidgets = tester.widgetList<Expanded>(
        find.byType(Expanded),
      );
      expect(expandedWidgets.length, equals(2));
    });

    testWidgets('applies flex ratios when provided', (tester) async {
      // Given: an BfFormRow with specific flex ratios
      await tester.pumpWidget(
        buildTestForm(
          child: BfFormRow(
            flexes: const [2, 1],
            children: const [
              Text('Wide'),
              Text('Narrow'),
            ],
          ),
        ),
      );

      // Then: the Expanded widgets have the correct flex values
      final expandedWidgets = tester.widgetList<Expanded>(
        find.byType(Expanded),
      ).toList();

      expect(expandedWidgets[0].flex, equals(2));
      expect(expandedWidgets[1].flex, equals(1));
    });

    testWidgets('uses equal flex when flexes is null', (tester) async {
      // Given: an BfFormRow without flexes
      await tester.pumpWidget(
        buildTestForm(
          child: BfFormRow(
            children: const [
              Text('A'),
              Text('B'),
              Text('C'),
            ],
          ),
        ),
      );

      // Then: all Expanded widgets have flex 1
      final expandedWidgets = tester.widgetList<Expanded>(
        find.byType(Expanded),
      ).toList();

      expect(expandedWidgets.length, equals(3));
      for (final expanded in expandedWidgets) {
        expect(expanded.flex, equals(1));
      }
    });
  });
}
