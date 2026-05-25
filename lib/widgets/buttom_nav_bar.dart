import 'package:autofinder/config/app_routes.dart';
import 'package:flutter/material.dart';

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
        color: theme.cardColor, // Mengikuti background komponen adaptif
        border: Border(
          top: BorderSide(
            color: isDark
                ? const Color(0xFF2C2C2C)
                : const Color(0xFFE0E0E0), // Garis pembatas tipis yang halus
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
              label: 'HOME',
            ),
            _buildNavItem(
              context,
              index: 1,
              icon: Icons.search_outlined,
              route: AppRoutes.home,
              label: 'SEARCH',
            ),
            _buildNavItem(
              context,
              index: 2,
              icon: Icons.add_circle_outline,
              route: AppRoutes.addWorkshop,
              label: 'POST',
            ),
            _buildNavItem(
              context,
              index: 3,
              icon: Icons.favorite_outline,
              route: AppRoutes.home,
              label: 'FAVORITE',
            ),
            _buildNavItem(
              context,
              index: 4,
              icon: Icons.person_outline,
              route: AppRoutes.profile,
              label: 'PROFILE',
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

    // Warna aktif mengambil dari primary theme (Warna Biru Utama)
    final primaryColor = theme.colorScheme.primary;

    // Warna non-aktif mengambil dari onSurfaceVariant (Abu-abu adaptif)
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
                    ? primaryColor.withAlpha(
                        26,
                      ) // Transparansi ~10% yang aman lintas SDK versi lama/baru
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
