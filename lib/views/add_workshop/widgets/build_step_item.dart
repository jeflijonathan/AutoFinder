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
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: widget.isActive
                ? const Color(0xFF0052CC)
                : (widget.isCompleted
                      ? const Color(0xFF0052CC).withOpacity(0.5)
                      : const Color(0xFFE5E7EB)),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${widget.stepNumber}',
              style: TextStyle(
                color: widget.isActive || widget.isCompleted
                    ? Colors.white
                    : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.title,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: widget.isActive
                ? const Color(0xFF0052CC)
                : const Color(0xFF4B5563),
          ),
        ),
      ],
    );
    ;
  }
}
