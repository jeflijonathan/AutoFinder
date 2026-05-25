import 'package:flutter/material.dart';

class BuildStepItem extends StatefulWidget {
  final int stepNumber;
  final String title;
  final bool isCompleted;
  final bool isActive;

  const BuildStepItem({
    super.key,
    required this.stepNumber,
    required this.title,
    required this.isCompleted,
    required this.isActive,
  });

  @override
  State<BuildStepItem> createState() => _BuildStepItemState();
}

class _BuildStepItemState extends State<BuildStepItem> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryColor = theme.colorScheme.primary;
    final unselectedColor = theme.colorScheme.onSurfaceVariant;

    // Menentukan warna background lingkaran stepper secara dinamis
    Color circleColor;
    if (widget.isActive) {
      circleColor = primaryColor;
    } else if (widget.isCompleted) {
      circleColor = primaryColor.withAlpha(
        128,
      ); // Transparansi ~50% dari warna utama
    } else {
      circleColor = isDark
          ? const Color(0xFF2C2C2C)
          : const Color(0xFFE5E7EB); // Background mati adaptif
    }

    // Menentukan warna teks di dalam lingkaran
    final Color textColor = widget.isActive || widget.isCompleted
        ? Colors.white
        : theme.colorScheme.onSurface;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: circleColor, shape: BoxShape.circle),
          child: Center(
            child: Text(
              '${widget.stepNumber}',
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.title,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: widget.isActive ? primaryColor : unselectedColor,
          ),
        ),
      ],
    );
  }
}
