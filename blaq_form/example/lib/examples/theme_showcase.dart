import 'package:flutter/material.dart';
import 'package:blaq_form/blaq_form.dart';

import '../theme/app_theme.dart';
import '../theme/dev_theme.dart';
import '../theme/studio_theme.dart';
import '../widgets/brand_scaffold.dart';
import '../widgets/deferred_progress.dart';

/// Side-by-side (tablet) or tabbed (phone) display of the exact same form
/// rendered under Dev and Studio themes simultaneously.
class ThemeShowcaseExample extends StatelessWidget {
  const ThemeShowcaseExample({required this.notifier, super.key});

  final AppThemeNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 700;
    return BrandScaffold(
      notifier: notifier,
      title: 'Theme Showcase',
      body: isWide ? const _WideLayout() : const _TabbedLayout(),
    );
  }
}

class _WideLayout extends StatelessWidget {
  const _WideLayout();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: _ThemePane(mode: BfAppTheme.dev)),
        VerticalDivider(width: 1),
        Expanded(child: _ThemePane(mode: BfAppTheme.studio)),
      ],
    );
  }
}

class _TabbedLayout extends StatelessWidget {
  const _TabbedLayout();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: '// dev'),
              Tab(text: '// studio'),
            ],
            labelStyle: TextStyle(
              fontFamily: 'Courier',
              fontSize: 11,
              letterSpacing: 0.1,
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [
                _ThemePane(mode: BfAppTheme.dev),
                _ThemePane(mode: BfAppTheme.studio),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Renders the showcase form wrapped in its own [Theme] so both panes
/// can coexist on screen regardless of the global toggle.
class _ThemePane extends StatefulWidget {
  const _ThemePane({required this.mode});

  final BfAppTheme mode;

  @override
  State<_ThemePane> createState() => _ThemePaneState();
}

class _ThemePaneState extends State<_ThemePane>
    with AutomaticKeepAliveClientMixin {
  late final BfFormController _formController;
  late final BfFieldController<String> _nameController;
  late final BfFieldController<String> _emailController;
  late final BfFieldController<String> _roleController;
  late final BfFieldController<bool> _agreeController;
  late final BfFieldController<double> _experienceController;

  static const _roles = ['Engineer', 'Designer', 'Product', 'Other'];

  @override
  bool get wantKeepAlive => true;

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
    _experienceController = BfFieldController<double>(initialValue: 1.0);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _roleController.dispose();
    _agreeController.dispose();
    _experienceController.dispose();
    _formController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final themeData = widget.mode == BfAppTheme.dev
        ? DevTheme.themeData
        : StudioTheme.themeData;

    return Theme(
      data: themeData,
      child: Builder(
        builder: (context) {
          return Container(
            color: themeData.scaffoldBackgroundColor,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PaneLabel(mode: widget.mode),
                  const SizedBox(height: 20),
                  DeferredProgress(
                    controller: _formController,
                    color: const Color(0xFFFF6B00),
                    backgroundColor: widget.mode == BfAppTheme.dev
                        ? const Color(0xFF1A1A1A)
                        : const Color(0xFFEBEBEB),
                    height: 3,
                    labelBuilder: (v, t) => '$v / $t',
                  ),
                  const SizedBox(height: 20),
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
                        const SizedBox(height: 14),
                        BfTextField.email(
                          name: 'email',
                          controller: _emailController,
                          labelText: 'Email',
                          hintText: 'you@example.com',
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 14),
                        BfDropdownField<String>(
                          name: 'role',
                          controller: _roleController,
                          labelText: 'Role',
                          hintText: 'Select role',
                          items: _roles
                              .map(
                                (r) =>
                                    DropdownMenuItem(value: r, child: Text(r)),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 14),
                        BfSliderField(
                          name: 'experience',
                          controller: _experienceController,
                          min: 0,
                          max: 10,
                          divisions: 10,
                          labelText: 'Years of experience',
                          activeColor: const Color(0xFFFF6B00),
                        ),
                        const SizedBox(height: 8),
                        BfCheckboxField(
                          name: 'agree',
                          controller: _agreeController,
                          label: const Text('I agree to the terms'),
                        ),
                        const SizedBox(height: 20),
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
          );
        },
      ),
    );
  }
}

class _PaneLabel extends StatelessWidget {
  const _PaneLabel({required this.mode});

  final BfAppTheme mode;

  @override
  Widget build(BuildContext context) {
    final isDev = mode == BfAppTheme.dev;
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
      ],
    );
  }
}
