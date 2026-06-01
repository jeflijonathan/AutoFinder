import 'package:flutter/material.dart';

class BaseDialog extends StatelessWidget {
  final Widget child;

  const BaseDialog({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: child,
      ),
    );
  }
}
