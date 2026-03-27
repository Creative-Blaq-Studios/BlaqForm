import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formkit/formkit.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('FkSliderField', () {
    testWidgets('renders a Slider widget', (tester) async {
      // Given: a double controller
      final controller = FkFieldController<double>(initialValue: 0.5);

      // When: we render an FkSliderField
      await tester.pumpWidget(
        buildTestForm(
          child: FkSliderField(
            name: 'volume',
            controller: controller,
            min: 0.0,
            max: 1.0,
          ),
        ),
      );

      // Then: a Slider is rendered
      expect(find.byType(Slider), findsOneWidget);

      addTearDown(controller.dispose);
    });

    testWidgets('updates controller on drag', (tester) async {
      // Given: a slider field with a known range
      final controller = FkFieldController<double>(initialValue: 0.0);

      await tester.pumpWidget(
        buildTestForm(
          child: FkSliderField(
            name: 'volume',
            controller: controller,
            min: 0.0,
            max: 100.0,
            divisions: 100,
          ),
        ),
      );

      // Verify initial value (slider auto-sets min if null, but we set 0.0)
      expect(controller.value, equals(0.0));

      // When: we drag the slider to the right (approximate center of the track)
      final slider = find.byType(Slider);
      final sliderCenter = tester.getCenter(slider);
      // Drag from center-left to center-right to change the value
      await tester.drag(slider, Offset(sliderCenter.dx, 0));
      await tester.pump();

      // Then: the controller value has been updated from the initial value
      expect(controller.value, isNot(equals(0.0)));

      addTearDown(controller.dispose);
    });
  });
}
