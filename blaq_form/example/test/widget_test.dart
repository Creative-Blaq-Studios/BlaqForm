import 'package:flutter_test/flutter_test.dart';

import 'package:example/main.dart';

void main() {
  testWidgets('Example app renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const BlaqFormExampleApp());

    expect(find.text('BlaqForm Examples'), findsOneWidget);
    expect(find.text('Signup Form'), findsOneWidget);
    expect(find.text('Checkout Form'), findsOneWidget);
  });
}
