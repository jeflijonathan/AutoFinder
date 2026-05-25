import 'package:autofinder/views/auth/controllers/auth_controller.dart';
import 'package:autofinder/widgets/buttom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:autofinder/widgets/navbar.dart';
import 'package:autofinder/config/app_colors.dart';
import 'package:autofinder/main.dart'; // Import main.dart untuk memanggil themeNotifier

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
    final authController = context.watch<AuthController>();
    final user = authController.currentUser;
    final username = user?.username ?? 'Master Mechanic';
    final email = user?.email ?? 'lead.engineer@mechanical-atelier.com';

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: const Navbar(),
      bottomNavigationBar: const ButtonNavBar(currentIndex: 4),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 32),

              // --- SECTION PROFIL (FOTO, NAMA, EMAIL) ---
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.primary,
                              width: 2,
                            ),
                            image: const DecorationImage(
                              image: AssetImage(
                                'assets/images/profile_placeholder.png',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Nama Pengguna
                    Text(
                      username,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Email Pengguna
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 15,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // --- ISI KONTEN MENU ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // GROUP 1: ACCOUNT & SECURITY
                    _buildGroupSection(
                      context: context,
                      title: 'ACCOUNT & SECURITY',
                      children: [
                        _buildMenuTile(
                          context: context,
                          icon: Icons.person_outline,
                          iconColor: AppColors.primary,
                          iconBgColor: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFEFF6FF),
                          title: 'Edit Profile',
                          subtitle:
                              'Update your personal details and credentials',
                          onTap: () {
                            // Navigasi ke Edit Profile
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildMenuTile(
                          context: context,
                          icon: Icons.shield_outlined,
                          iconColor: AppColors.primary,
                          iconBgColor: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFEFF6FF),
                          title: 'Account Security',
                          subtitle: 'Update your password',
                          onTap: () {
                            // Navigasi ke Account Security
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // GROUP 2: PREFERENCES
                    _buildGroupSection(
                      context: context,
                      title: 'PREFERENCES',
                      children: [
                        _buildMenuTile(
                          context: context,
                          icon: Icons.dark_mode_outlined,
                          iconColor: AppColors.primary,
                          iconBgColor: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFEFF6FF),
                          title: 'Dark/Light Mode',
                          subtitle: 'Switch between precision themes',
                          trailing: Switch(
                            value: themeNotifier.value == ThemeMode.dark,
                            activeColor: AppColors.primary,
                            onChanged: (value) {
                              setState(() {
                                themeNotifier.value = value
                                    ? ThemeMode.dark
                                    : ThemeMode.light;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // GROUP 3: LOGOUT (Card Background Kemerahan Tetap Dipertahankan)
                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF2D1F1F)
                            : const Color(0xFFFFF5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _buildMenuTile(
                        context: context,
                        icon: Icons.logout,
                        iconColor: AppColors.error,
                        iconBgColor: isDark
                            ? const Color(0xFF451A1A)
                            : const Color(0xFFFEE2E2),
                        title: 'Logout',
                        titleColor: AppColors.error,
                        subtitle: 'Sign out of your atelier account',
                        subtitleColor: isDark
                            ? const Color(0xFFFCA5A5)
                            : AppColors.error,
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

  Widget _buildGroupSection({
    required BuildContext context,
    required String title,
    required List<Widget> children,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.groupBgDark : AppColors.groupBgLight,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    Color? titleColor,
    Color? subtitleColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    final finalTitleColor = titleColor ?? theme.colorScheme.onSurface;
    final finalSubtitleColor =
        subtitleColor ?? theme.colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
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
