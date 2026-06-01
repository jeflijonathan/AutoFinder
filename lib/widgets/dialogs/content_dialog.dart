import 'package:flutter/material.dart';

class ContentDialog extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const ContentDialog({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: child,
    );
  }
}
