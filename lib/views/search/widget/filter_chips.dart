import 'package:flutter/material.dart';

class FilterChips extends StatelessWidget {
  final bool openNowSelected;
  final bool topRatedSelected;
  final VoidCallback onOpenNowTap;
  final VoidCallback onTopRatedTap;
  final VoidCallback onMoreFiltersTap;

  const FilterChips({
    super.key,
    required this.openNowSelected,
    required this.topRatedSelected,
    required this.onOpenNowTap,
    required this.onTopRatedTap,
    required this.onMoreFiltersTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildChip(
            context,
            label: 'Open Now',
            isSelected: openNowSelected,
            onTap: onOpenNowTap,
          ),
          const SizedBox(width: 8),
          _buildChip(
            context,
            label: 'Top Rated',
            icon: Icons.star,
            isSelected: topRatedSelected,
            onTap: onTopRatedTap,
          ),
          const SizedBox(width: 8),
          _buildChip(
            context,
            label: 'More Filters',
            icon: Icons.tune,
            isSelected: false,
            onTap: onMoreFiltersTap,
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required String label,
    IconData? icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isSelected
        ? theme.colorScheme.primary.withAlpha(30)
        : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0));
        
    final textColor = isSelected
        ? theme.colorScheme.primary
        : (isDark ? Colors.grey[300] : Colors.grey[700]);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: textColor),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: textColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
