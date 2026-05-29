import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:autofinder/config/app_locale.dart';
import 'package:autofinder/config/app_colors.dart';
import 'package:autofinder/views/auth/controllers/auth_controller.dart';
import 'package:autofinder/widgets/buttom_nav_bar.dart';
import 'package:autofinder/widgets/navbar.dart';
import 'package:autofinder/views/profile/widgets/menu_tile.dart';
import 'package:autofinder/views/profile/widgets/profile_header.dart';
import 'package:autofinder/views/profile/widgets/account_section.dart';
import 'package:autofinder/views/profile/widgets/preferences_section.dart';
import 'package:autofinder/views/profile/widgets/image_source_sheet.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _handleLogout() {
    context.read<AuthController>().handleLogoutRequest(context: context);
  }

  @override
  Widget build(BuildContext context) {
    final profileController = context.watch<AuthController>();
    final user = profileController.currentUser;

    final username = user?.username ?? 'Master Mechanic';
    final email = user?.email ?? 'lead.engineer@mechanical-atelier.com';
    final profilePic =
        user?.profilePictureUrl ??
        'https://ui-avatars.com/api/?name=${Uri.encodeComponent(username)}&background=0D8ABC&color=fff';

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.cardBgDark : AppColors.cardBgLight;

    return Scaffold(
      appBar: const Navbar(),
      bottomNavigationBar: const ButtonNavBar(currentIndex: 4),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 32),
              Center(
                child: ProfileHeader(
                  username: username,
                  email: email,
                  profilePic: profilePic,
                  onEditProfilePic: () {
                    ImageSourceSheet.show(
                      context: context,
                      onSourceSelected: (source) {
                        profileController.handleUpdateProfilePicture(
                          context,
                          source,
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 32),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AccountSection(
                      isDark: isDark,
                      isGoogleLogin: profileController.isGoogleLogin,
                    ),
                    const SizedBox(height: 20),

                    PreferencesSection(isDark: isDark),
                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 15,
                      ),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: MenuTile(
                        icon: Icons.logout,
                        iconColor: AppColors.error,
                        iconBgColor: bgColor,
                        title: AppLocale.logout.getString(
                          context,
                        ), // 3. Menggunakan Lokalisasi
                        titleColor: AppColors.error,
                        subtitle: AppLocale.logoutSubtitle.getString(
                          context,
                        ), // 4. Menggunakan Lokalisasi
                        onTap: _handleLogout,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
