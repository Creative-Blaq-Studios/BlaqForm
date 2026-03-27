import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formkit/formkit.dart';

void main() {
  group('FkFormBuilder', () {
    testWidgets('renders fields declared in the fields map',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FkFormBuilder(
              fields: {
                'name': FkFieldConfig<String>.text(label: 'Name'),
                'email': FkFieldConfig<String>.email(label: 'Email'),
              },
              builder: (scope) {
                return Column(
                  children: [
                    scope.text('name'),
                    scope.email('email'),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Two FkTextField widgets should be rendered.
      expect(find.byType(FkTextField), findsNWidgets(2));
    });

    testWidgets('controllers are auto-created and fields are registered',
        (WidgetTester tester) async {
      late FkFormBuilderScope capturedScope;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FkFormBuilder(
              fields: {
                'name': FkFieldConfig<String>.text(
                  label: 'Name',
                  initialValue: 'Bob',
                ),
              },
              builder: (scope) {
                capturedScope = scope;
                return scope.text('name');
              },
            ),
          ),
        ),
      );

      // controller<String>('name') should work without throwing.
      final ctrl = capturedScope.controller<String>('name');
      expect(ctrl, isA<FkFieldController<String>>());
      expect(ctrl.value, 'Bob');

      // formController.toMap() should contain the key.
      final values = capturedScope.values;
      expect(values.containsKey('name'), isTrue);
      expect(values['name'], 'Bob');
    });

    testWidgets('onSubmit receives form values',
        (WidgetTester tester) async {
      Map<String, dynamic>? submittedValues;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FkFormBuilder(
              fields: {
                'name': FkFieldConfig<String>.text(
                  initialValue: 'Alice',
                  label: 'Name',
                ),
              },
              onSubmit: (values) async {
                submittedValues = values;
              },
              builder: (scope) {
                return Column(
                  children: [
                    scope.text('name'),
                    scope.submitButton('Send'),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Tap the submit button.
      await tester.tap(find.text('Send'));
      await tester.pumpAndSettle();

      expect(submittedValues, isNotNull);
      expect(submittedValues!['name'], 'Alice');
    });

    testWidgets('controllers are disposed when widget is removed',
        (WidgetTester tester) async {
      late FkFieldController<String> capturedController;

      final showForm = ValueNotifier<bool>(true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValueListenableBuilder<bool>(
              valueListenable: showForm,
              builder: (context, show, _) {
                if (!show) return const SizedBox.shrink();
                return FkFormBuilder(
                  fields: {
                    'name': FkFieldConfig<String>.text(label: 'Name'),
                  },
                  builder: (scope) {
                    capturedController = scope.controller<String>('name');
                    return scope.text('name');
                  },
                );
              },
            ),
          ),
        ),
      );

      // Controller should be usable.
      expect(capturedController, isA<FkFieldController<String>>());

      // Remove the widget from tree.
      showForm.value = false;
      await tester.pumpAndSettle();

      // After disposal, adding a listener should throw.
      expect(
        () => capturedController.addListener(() {}),
        throwsA(isA<FlutterError>()),
      );
    });

    testWidgets('password field renders obscured text',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FkFormBuilder(
              fields: {
                'pw': FkFieldConfig<String>.password(label: 'Password'),
              },
              builder: (scope) {
                return scope.password('pw');
              },
            ),
          ),
        ),
      );

      // The underlying TextField should have obscureText set to true.
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, isTrue);
    });

    testWidgets('checkbox field renders and toggles',
        (WidgetTester tester) async {
      late FkFormBuilderScope capturedScope;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FkFormBuilder(
              fields: {
                'agree': FkFieldConfig<bool>.checkbox(
                  label: 'I agree',
                  initialValue: false,
                ),
              },
              builder: (scope) {
                capturedScope = scope;
                return scope.checkbox('agree');
              },
            ),
          ),
        ),
      );

      // CheckboxListTile should render.
      expect(find.byType(CheckboxListTile), findsOneWidget);

      // Initially false.
      expect(capturedScope.controller<bool>('agree').value, false);

      // Tap the checkbox to toggle.
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();

      expect(capturedScope.controller<bool>('agree').value, true);
    });
  });
}
