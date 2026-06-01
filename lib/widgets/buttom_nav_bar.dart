import 'package:autofinder/config/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart'; // 1. Tambahkan import ini
import 'package:autofinder/config/app_locale.dart';

class ButtonNavBar extends StatelessWidget {
  final int currentIndex;

  const ButtonNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              context,
              index: 0,
              icon: Icons.home_outlined,
              route: AppRoutes.home,
              label: AppLocale.home.getString(context).toUpperCase(),
            ),
            _buildNavItem(
              context,
              index: 1,
              icon: Icons.search_outlined,
              route: AppRoutes.search,
              label: AppLocale.search.getString(context).toUpperCase(),
            ),
            _buildNavItem(
              context,
              index: 2,
              icon: Icons.add_circle_outline,
              route: AppRoutes.addWorkshop,
              label: AppLocale.post.getString(context).toUpperCase(),
            ),
            _buildNavItem(
              context,
              index: 3,
              icon: Icons.favorite_outline,
              route: AppRoutes.home,
              label: AppLocale.favorite.getString(context).toUpperCase(),
            ),
            _buildNavItem(
              context,
              index: 4,
              icon: Icons.person_outline,
              route: AppRoutes.profile,
              label: AppLocale.profile
                  .getString(context)
                  .toUpperCase(), // 6. Lokalisasi & jadikan uppercase
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String route,
    required String label,
  }) {
    final theme = Theme.of(context);
    final isSelected = currentIndex == index;
    final primaryColor = theme.colorScheme.primary;
    final unselectedColor = theme.colorScheme.onSurfaceVariant;
    final activeColor = isSelected ? primaryColor : unselectedColor;

    return GestureDetector(
      onTap: () {
        if (currentIndex == index) return;
        Navigator.pushReplacementNamed(context, route);
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor.withAlpha(26)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(icon, color: activeColor, size: 24),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: activeColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
