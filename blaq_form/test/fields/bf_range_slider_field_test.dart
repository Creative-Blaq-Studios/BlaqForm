import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blaq_form/blaq_form.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('BfRangeSliderField', () {
    testWidgets('renders a RangeSlider widget', (tester) async {
      final controller = BfFieldController<RangeValues>(
        initialValue: const RangeValues(20, 80),
      );

      await tester.pumpWidget(
        buildTestForm(
          child: BfRangeSliderField(
            name: 'priceRange',
            controller: controller,
            min: 0,
            max: 100,
          ),
        ),
      );

      expect(find.byType(RangeSlider), findsOneWidget);

      addTearDown(controller.dispose);
    });

    testWidgets('renders label text', (tester) async {
      final controller = BfFieldController<RangeValues>(
        initialValue: const RangeValues(10, 90),
      );

      await tester.pumpWidget(
        buildTestForm(
          child: BfRangeSliderField(
            name: 'range',
            controller: controller,
            min: 0,
            max: 100,
            labelText: 'Price Range',
          ),
        ),
      );

      expect(find.text('Price Range'), findsOneWidget);

      addTearDown(controller.dispose);
    });

    testWidgets('initialises controller value to full range when null',
        (tester) async {
      // Controller with no initial value — the widget should default to [min, max].
      final controller = BfFieldController<RangeValues>();

      await tester.pumpWidget(
        buildTestForm(
          child: BfRangeSliderField(
            name: 'range',
            controller: controller,
            min: 0,
            max: 50,
          ),
        ),
      );

      await tester.pump();

      expect(controller.value, isNotNull);
      expect(controller.value!.start, equals(0.0));
      expect(controller.value!.end, equals(50.0));

      addTearDown(controller.dispose);
    });

    testWidgets('displays current range values when showValues is true',
        (tester) async {
      final controller = BfFieldController<RangeValues>(
        initialValue: const RangeValues(25, 75),
      );

      await tester.pumpWidget(
        buildTestForm(
          child: BfRangeSliderField(
            name: 'range',
            controller: controller,
            min: 0,
            max: 100,
            showValues: true,
          ),
        ),
      );

      // The widget formats values with 2 decimal places when no divisions set.
      expect(find.textContaining('25'), findsWidgets);
      expect(find.textContaining('75'), findsWidgets);

      addTearDown(controller.dispose);
    });

    testWidgets('does not display values when showValues is false',
        (tester) async {
      final controller = BfFieldController<RangeValues>(
        initialValue: const RangeValues(30, 70),
      );

      await tester.pumpWidget(
        buildTestForm(
          child: BfRangeSliderField(
            name: 'range',
            controller: controller,
            min: 0,
            max: 100,
            showValues: false,
          ),
        ),
      );

      // The header row with values should not appear.
      expect(find.textContaining('30'), findsNothing);
      expect(find.textContaining('70'), findsNothing);

      addTearDown(controller.dispose);
    });

    testWidgets('disabled slider passes null onChanged to RangeSlider',
        (tester) async {
      final controller = BfFieldController<RangeValues>(
        initialValue: const RangeValues(0, 100),
      );

      await tester.pumpWidget(
        buildTestForm(
          child: BfRangeSliderField(
            name: 'range',
            controller: controller,
            min: 0,
            max: 100,
            enabled: false,
          ),
        ),
      );

      final slider = tester.widget<RangeSlider>(find.byType(RangeSlider));
      expect(slider.onChanged, isNull);

      addTearDown(controller.dispose);
    });
  });
}
