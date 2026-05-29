import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final String title;
  final String? subtitle;
  final double? fontSizeTitle;
  final double? fontSizeSubtitle;
  final int? maxLinesSubtitle;

  const Header({
    super.key,
    required this.title,
    this.subtitle,
    this.fontSizeSubtitle,
    this.fontSizeTitle,
    this.maxLinesSubtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: fontSizeTitle ?? 24,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              if (subtitle != null && subtitle!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: fontSizeSubtitle ?? 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.justify,
                  maxLines: maxLinesSubtitle ?? 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
