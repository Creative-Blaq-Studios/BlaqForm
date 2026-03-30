import 'package:flutter/material.dart';
import 'package:blaq_form/blaq_form.dart';

import '../theme/app_theme.dart';
import '../theme/dev_theme.dart';
import '../theme/studio_theme.dart';
import '../widgets/brand_scaffold.dart';

/// Displays the exact same form rendered under both Dev and Studio themes
/// stacked vertically so both are always visible by scrolling.
class ThemeShowcaseExample extends StatelessWidget {
  const ThemeShowcaseExample({required this.notifier, super.key});

  final AppThemeNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return BrandScaffold(
      notifier: notifier,
      title: 'Theme Showcase',
      body: ListView(
        children: const [
          _ThemePane(mode: BfAppTheme.dev),
          SizedBox(height: 2),
          _ThemePane(mode: BfAppTheme.studio),
          SizedBox(height: 40),
        ],
      ),
    );
  }
}

/// Each pane gets its own [Theme] + [Material] so both coexist on screen.
class _ThemePane extends StatefulWidget {
  const _ThemePane({required this.mode});

  final BfAppTheme mode;

  @override
  State<_ThemePane> createState() => _ThemePaneState();
}

class _ThemePaneState extends State<_ThemePane> {
  late final BfFormController _formController;
  late final BfFieldController<String> _nameController;
  late final BfFieldController<String> _emailController;
  late final BfFieldController<String> _roleController;
  late final BfFieldController<bool> _agreeController;

  static const _roles = ['Engineer', 'Designer', 'Product', 'Other'];

  @override
  void initState() {
    super.initState();
    _formController = BfFormController();
    _nameController = BfFieldController<String>(validators: [Bf.required()]);
    _emailController = BfFieldController<String>(
      validators: [Bf.required(), Bf.email()],
    );
    _roleController = BfFieldController<String>(
      validators: [Bf.required(message: 'Select a role')],
    );
    _agreeController = BfFieldController<bool>(initialValue: false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _roleController.dispose();
    _agreeController.dispose();
    _formController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDev = widget.mode == BfAppTheme.dev;
    final themeData = isDev ? DevTheme.themeData : StudioTheme.themeData;

    return Theme(
      data: themeData,
      child: Material(
        color: themeData.scaffoldBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _PaneHeader(mode: widget.mode),
              const SizedBox(height: 16),
              BfForm(
                controller: _formController,
                autovalidateMode: BfAutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BfTextField(
                      name: 'name',
                      controller: _nameController,
                      labelText: 'Name',
                      hintText: 'Your name',
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    BfTextField.email(
                      name: 'email',
                      controller: _emailController,
                      labelText: 'Email',
                      hintText: 'you@example.com',
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    BfDropdownField<String>(
                      name: 'role',
                      controller: _roleController,
                      labelText: 'Role',
                      hintText: 'Select role',
                      items: _roles
                          .map(
                            (r) => DropdownMenuItem(value: r, child: Text(r)),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                    BfCheckboxField(
                      name: 'agree',
                      controller: _agreeController,
                      label: const Text('I agree to the terms'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaneHeader extends StatelessWidget {
  const _PaneHeader({required this.mode});

  final BfAppTheme mode;

  @override
  Widget build(BuildContext context) {
    final isDev = mode == BfAppTheme.dev;
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(width: 8, height: 8, color: const Color(0xFFFF6B00)),
        const SizedBox(width: 8),
        Text(
          isDev ? '// dev theme' : '// studio theme',
          style: const TextStyle(
            fontFamily: 'Courier',
            fontSize: 11,
            color: Color(0xFFFF6B00),
            letterSpacing: 0.1,
          ),
        ),
        const Spacer(),
        Text(
          isDev ? 'Sharp · Dark · Monospace' : 'Rounded · Light · Clean',
          style: TextStyle(
            fontFamily: 'Courier',
            fontSize: 9,
            color: cs.onSurface.withValues(alpha: 0.35),
            letterSpacing: 0.05,
          ),
        ),
      ],
    );
  }
}
