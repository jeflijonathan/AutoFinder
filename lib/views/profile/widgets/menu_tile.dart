import 'package:flutter/material.dart';

class MenuTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final Color? titleColor;
  final Color? subtitleColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const MenuTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    this.titleColor,
    this.subtitleColor,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final finalTitleColor = titleColor ?? theme.colorScheme.onSurface;
    final finalSubtitleColor =
        subtitleColor ?? theme.colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: finalTitleColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: finalSubtitleColor),
                  ),
                ],
              ),
            ),

            trailing ??
                (onTap != null
                    ? const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Color(0xFF9CA3AF),
                      )
                    : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}
