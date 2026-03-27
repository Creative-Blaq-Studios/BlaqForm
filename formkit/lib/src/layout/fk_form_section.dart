import 'package:flutter/material.dart';

import '../theme/fk_form_theme.dart';

/// A collapsible section within a form, with optional title and description.
///
/// Use this widget to visually group related form fields under a heading.
/// When [collapsible] is `true`, the user can expand or collapse the section
/// by tapping the header row.
///
/// ```dart
/// FkFormSection(
///   title: 'Personal Information',
///   description: 'Enter your name and contact details.',
///   collapsible: true,
///   children: [
///     FkTextField(name: 'firstName'),
///     FkTextField(name: 'lastName'),
///   ],
/// )
/// ```
class FkFormSection extends StatefulWidget {
  /// Creates a form section.
  ///
  /// [children] are the widgets displayed inside the section body.
  /// If [collapsible] is `true`, a tap target is rendered in the header to
  /// toggle visibility of the children.
  const FkFormSection({
    super.key,
    this.title,
    this.description,
    this.collapsible = false,
    this.initiallyExpanded = true,
    this.padding,
    required this.children,
  });

  /// Optional title displayed at the top of the section.
  ///
  /// Rendered using the theme's `titleLarge` text style.
  final String? title;

  /// Optional description displayed below the [title].
  ///
  /// Rendered using the theme's `bodySmall` text style.
  final String? description;

  /// Whether the section can be collapsed by the user.
  ///
  /// When `false` (the default), the [children] are always visible.
  final bool collapsible;

  /// Whether the section starts in the expanded state.
  ///
  /// Only meaningful when [collapsible] is `true`. Defaults to `true`.
  final bool initiallyExpanded;

  /// Padding around the entire section. Defaults to zero.
  final EdgeInsetsGeometry? padding;

  /// The widgets displayed inside the section body.
  final List<Widget> children;

  @override
  State<FkFormSection> createState() => _FkFormSectionState();
}

class _FkFormSectionState extends State<FkFormSection>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late final AnimationController _animationController;
  late final Animation<double> _expandAnimation;
  late final Animation<double> _iconTurns;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
      value: _isExpanded ? 1.0 : 0.0,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _iconTurns = Tween<double>(begin: 0.0, end: 0.5).animate(_expandAnimation);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  bool get _hasHeader => widget.title != null || widget.description != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final fkTheme = FkFormTheme.of(context);

    final content = Padding(
      padding: widget.padding ??
          EdgeInsets.symmetric(vertical: fkTheme.sectionSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_hasHeader) _buildHeader(textTheme),
          if (widget.collapsible)
            SizeTransition(
              sizeFactor: _expandAnimation,
              axisAlignment: -1.0,
              child: _buildBody(),
            )
          else
            _buildBody(),
        ],
      ),
    );

    return content;
  }

  Widget _buildHeader(TextTheme textTheme) {
    final titleWidget = widget.title != null
        ? Text(widget.title!, style: textTheme.titleLarge)
        : null;

    final descriptionWidget = widget.description != null
        ? Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(widget.description!, style: textTheme.bodySmall),
          )
        : null;

    final headerContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ?titleWidget,
        ?descriptionWidget,
      ],
    );

    if (widget.collapsible) {
      return GestureDetector(
        onTap: _toggleExpanded,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            children: [
              Expanded(child: headerContent),
              RotationTransition(
                turns: _iconTurns,
                child: const Icon(Icons.expand_more),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: headerContent,
    );
  }

  Widget _buildBody() {
    final fkTheme = FkFormTheme.of(context);
    final spacedChildren = <Widget>[];
    for (int i = 0; i < widget.children.length; i++) {
      spacedChildren.add(widget.children[i]);
      if (i < widget.children.length - 1) {
        spacedChildren.add(SizedBox(height: fkTheme.fieldSpacing));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: spacedChildren,
    );
  }
}
