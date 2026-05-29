import 'package:autofinder/config/app_locale.dart';
import 'package:flutter/material.dart';

class BuildStepItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryColor = theme.colorScheme.primary;
    final unselectedColor = theme.colorScheme.onSurfaceVariant;

    Color circleColor;
    if (isActive) {
      circleColor = primaryColor;
    } else if (isCompleted) {
      circleColor = primaryColor.withAlpha(128);
    } else {
      circleColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE5E7EB);
    }

    final Color textColor = isActive || isCompleted
        ? Colors.white
        : theme.colorScheme.onSurface;

    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              child: Text(
                '$stepNumber',
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 8),

          FutureBuilder<String>(
            future: AppLocale.translateLive(title),
            builder: (context, snapshot) {
              final displayedTitle = snapshot.data ?? title;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    displayedTitle,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isActive ? primaryColor : unselectedColor,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
