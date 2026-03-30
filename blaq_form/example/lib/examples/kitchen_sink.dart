import 'package:flutter/material.dart';
import 'package:blaq_form/blaq_form.dart';

import '../theme/app_theme.dart';
import '../widgets/brand_scaffold.dart';

/// Every BlaqForm field widget in one scrollable form.
class KitchenSinkExample extends StatefulWidget {
  const KitchenSinkExample({required this.notifier, super.key});

  final AppThemeNotifier notifier;

  @override
  State<KitchenSinkExample> createState() => _KitchenSinkExampleState();
}

class _KitchenSinkExampleState extends State<KitchenSinkExample> {
  late final BfFormController _formController;
  late final BfFieldController<String> _textController;
  late final BfFieldController<String> _emailController;
  late final BfFieldController<String> _passwordController;
  late final BfFieldController<String> _dropdownController;
  late final BfFieldController<bool> _checkboxController;
  late final BfFieldController<List<String>> _checkboxGroupController;
  late final BfFieldController<String> _radioController;
  late final BfFieldController<bool> _switchController;
  late final BfFieldController<double> _sliderController;
  late final BfFieldController<double> _ratingController;
  late final BfFieldController<DateTime> _dateController;
  late final BfFieldController<List<String>> _chipSelectController;

  static const _options = ['Option A', 'Option B', 'Option C'];
  static const _chipOptions = [
    'Flutter',
    'Dart',
    'Firebase',
    'Riverpod',
    'Bloc',
  ];

  @override
  void initState() {
    super.initState();
    _formController = BfFormController();
    _textController = BfFieldController<String>(validators: [Bf.required()]);
    _emailController = BfFieldController<String>(
      validators: [Bf.required(), Bf.email()],
    );
    _passwordController = BfFieldController<String>(
      validators: [Bf.required(), Bf.minLength(8)],
    );
    _dropdownController = BfFieldController<String>(
      validators: [Bf.required(message: 'Select an option')],
    );
    _checkboxController = BfFieldController<bool>(initialValue: false);
    _checkboxGroupController = BfFieldController<List<String>>(
      initialValue: [],
    );
    _radioController = BfFieldController<String>(
      validators: [Bf.required(message: 'Select one')],
    );
    _switchController = BfFieldController<bool>(initialValue: false);
    _sliderController = BfFieldController<double>(initialValue: 0.5);
    _ratingController = BfFieldController<double>(initialValue: 0);
    _dateController = BfFieldController<DateTime>(
      validators: [Bf.required(message: 'Pick a date')],
    );
    _chipSelectController = BfFieldController<List<String>>(initialValue: []);
  }

  @override
  void dispose() {
    _textController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _dropdownController.dispose();
    _checkboxController.dispose();
    _checkboxGroupController.dispose();
    _radioController.dispose();
    _switchController.dispose();
    _sliderController.dispose();
    _ratingController.dispose();
    _dateController.dispose();
    _chipSelectController.dispose();
    _formController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BrandScaffold(
      notifier: widget.notifier,
      title: 'Kitchen Sink',
      body: BfDirtyGuard(
        controller: _formController,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: BfFormProgress(
                controller: _formController,
                color: const Color(0xFFFF6B00),
                backgroundColor: const Color(0xFF1A1A1A),
                height: 3,
                labelBuilder: (v, t) => '$v / $t complete',
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: BfForm(
                  controller: _formController,
                  autovalidateMode: BfAutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SinkSection(
                        label: 'text fields',
                        children: [
                          BfTextField(
                            name: 'text',
                            controller: _textController,
                            labelText: 'BfTextField',
                            hintText: 'Plain text input',
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),
                          BfTextField.email(
                            name: 'email',
                            controller: _emailController,
                            labelText: 'BfTextField.email',
                            hintText: 'you@example.com',
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),
                          BfTextField.password(
                            name: 'password',
                            controller: _passwordController,
                            labelText: 'BfTextField.password',
                            hintText: 'At least 8 characters',
                            textInputAction: TextInputAction.next,
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      _SinkSection(
                        label: 'selection',
                        children: [
                          BfDropdownField<String>(
                            name: 'dropdown',
                            controller: _dropdownController,
                            labelText: 'BfDropdownField',
                            hintText: 'Pick one',
                            items: _options
                                .map(
                                  (o) => DropdownMenuItem(
                                    value: o,
                                    child: Text(o),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 16),
                          BfRadioGroupField<String>(
                            name: 'radio',
                            controller: _radioController,
                            options: _options,
                            labelBuilder: (o) => o,
                          ),
                          const SizedBox(height: 16),
                          BfCheckboxGroupField<String>(
                            name: 'checkboxGroup',
                            controller: _checkboxGroupController,
                            options: _options,
                            labelBuilder: (o) => o,
                          ),
                          const SizedBox(height: 16),
                          BfChipSelectField<String>(
                            name: 'chipSelect',
                            controller: _chipSelectController,
                            options: _chipOptions,
                            labelText: 'BfChipSelectField',
                            labelBuilder: (o) => o,
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      _SinkSection(
                        label: 'toggles',
                        children: [
                          BfCheckboxField(
                            name: 'checkbox',
                            controller: _checkboxController,
                            label: const Text('BfCheckboxField'),
                          ),
                          const SizedBox(height: 8),
                          BfSwitchField(
                            name: 'switch',
                            controller: _switchController,
                            label: const Text('BfSwitchField'),
                            subtitle: const Text('Toggle me'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      _SinkSection(
                        label: 'numeric',
                        children: [
                          BfSliderField(
                            name: 'slider',
                            controller: _sliderController,
                            min: 0,
                            max: 100,
                            divisions: 20,
                            labelText: 'BfSliderField',
                            activeColor: const Color(0xFFFF6B00),
                          ),
                          const SizedBox(height: 16),
                          BfRatingField(
                            name: 'rating',
                            controller: _ratingController,
                            labelText: 'BfRatingField',
                            color: const Color(0xFFFF6B00),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      _SinkSection(
                        label: 'date & time',
                        children: [
                          BfDateField(
                            name: 'date',
                            controller: _dateController,
                            labelText: 'BfDateField',
                            hintText: 'Pick a date',
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2040),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      BfSubmitButton(
                        label: 'Submit All Fields',
                        disableWhenInvalid: false,
                        onSubmit: (controller) async {
                          final success = await controller.submit((
                            values,
                          ) async {
                            await Future.delayed(const Duration(seconds: 2));
                          });
                          if (success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('All fields submitted!'),
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SinkSection extends StatelessWidget {
  const _SinkSection({required this.label, required this.children});

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '// $label',
              style: const TextStyle(
                fontFamily: 'Courier',
                fontSize: 10,
                color: Color(0xFFFF6B00),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: Divider(color: cs.outline, height: 1)),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }
}
