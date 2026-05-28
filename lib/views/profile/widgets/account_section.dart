import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart'; // 1. Tambahkan import ini
import 'package:autofinder/config/app_locale.dart'; // 2. Tambahkan import AppLocale Anda
import 'package:autofinder/config/app_colors.dart';
import 'package:autofinder/config/app_routes.dart';
import 'package:autofinder/views/profile/widgets/group_section.dart';
import 'package:autofinder/views/profile/widgets/menu_tile.dart';

class AccountSection extends StatelessWidget {
  final bool isDark;
  final bool isGoogleLogin;

  const AccountSection({
    super.key,
    required this.isDark,
    this.isGoogleLogin = false,
  });

  @override
  Widget build(BuildContext context) {
    final tileBgColor = isDark ? AppColors.cardBgDark : AppColors.cardBgLight;

    return GroupSection(
      title: AppLocale.accountAndSecurity.getString(context),
      children: [
        MenuTile(
          icon: Icons.person_outline,
          iconColor: AppColors.primary,
          iconBgColor: tileBgColor,
          title: AppLocale.editProfile.getString(context),
          subtitle: AppLocale.editProfileSubtitle.getString(context),
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.editProfile);
          },
        ),
        if (!isGoogleLogin) ...[
          const SizedBox(height: 12),
          MenuTile(
            icon: Icons.shield_outlined,
            iconColor: AppColors.primary,
            iconBgColor: tileBgColor,
            title: AppLocale.accountSecurity.getString(context),
            subtitle: AppLocale.accountSecuritySubtitle.getString(context),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.accountSecurity);
            },
          ),
        ],
      ],
    );
  }
}
