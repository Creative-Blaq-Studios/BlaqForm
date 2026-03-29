import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blaq_form/blaq_form.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('BfRatingField', () {
    testWidgets('renders correct number of star icons', (tester) async {
      // Given: a rating field with maxRating of 5
      final controller = BfFieldController<double>(initialValue: 0.0);

      await tester.pumpWidget(
        buildTestForm(
          child: BfRatingField(
            name: 'rating',
            controller: controller,
            maxRating: 5,
          ),
        ),
      );

      // Then: 5 star icons are rendered (all star_border since rating is 0)
      expect(find.byIcon(Icons.star_border), findsNWidgets(5));

      addTearDown(controller.dispose);
    });

    testWidgets('updates controller on tap', (tester) async {
      // Given: a rating field with no initial rating
      final controller = BfFieldController<double>(initialValue: 0.0);

      await tester.pumpWidget(
        buildTestForm(
          child: BfRatingField(
            name: 'rating',
            controller: controller,
            maxRating: 5,
            size: 36.0,
          ),
        ),
      );

      // Verify initial state: all empty stars
      expect(controller.value, equals(0.0));

      // When: we tap the third star (index 2, right half -> value 3.0)
      // GestureDetector wraps each Icon, so we find all star_border icons
      // and tap the third one
      final thirdStar = find.byIcon(Icons.star_border).at(2);
      await tester.tap(thirdStar);
      await tester.pump();

      // Then: the controller value is updated to 3.0 (whole star)
      expect(controller.value, equals(3.0));

      addTearDown(controller.dispose);
    });
  });
}
