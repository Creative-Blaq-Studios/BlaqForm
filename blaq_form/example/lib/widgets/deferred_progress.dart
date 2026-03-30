import 'package:flutter/material.dart';
import 'package:blaq_form/blaq_form.dart';

/// Wraps [BfFormProgress] but defers its first build to the next frame,
/// avoiding "setState() called during build" when fields register with
/// the controller during the same build pass.
class DeferredProgress extends StatefulWidget {
  const DeferredProgress({
    required this.controller,
    this.labelBuilder,
    this.color,
    this.backgroundColor,
    this.height = 3.0,
    super.key,
  });

  final BfFormController controller;
  final String Function(int valid, int total)? labelBuilder;
  final Color? color;
  final Color? backgroundColor;
  final double height;

  @override
  State<DeferredProgress> createState() => _DeferredProgressState();
}

class _DeferredProgressState extends State<DeferredProgress> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return SizedBox(
        height: widget.height,
        child: LinearProgressIndicator(
          value: 0,
          color: widget.color,
          backgroundColor: widget.backgroundColor,
          minHeight: widget.height,
        ),
      );
    }
    return BfFormProgress(
      controller: widget.controller,
      color: widget.color,
      backgroundColor: widget.backgroundColor,
      height: widget.height,
      labelBuilder: widget.labelBuilder,
    );
  }
}
