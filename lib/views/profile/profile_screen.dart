import 'package:autofinder/views/auth/controllers/auth_controller.dart';
import 'package:autofinder/widgets/buttom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:autofinder/config/app_colors.dart';
import 'package:autofinder/widgets/button_primary.dart';
import 'package:provider/provider.dart';

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
    final username = user?.username ?? 'Pengguna';
    final email = user?.email ?? 'email@example.com';
    final phoneNumber = user?.phoneNumber ?? '-';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Auto Finder',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.error),
            onPressed: _handleLogout,
          ),
        ],
      ),
      bottomNavigationBar: const ButtonNavBar(currentIndex: 1),
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, Color(0xFF1E88E5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: Text(
                              username.isNotEmpty
                                  ? username[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Selamat Datang,',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                                Text(
                                  username,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Account Information Section
                const Text(
                  'Informasi Akun',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),

                // Info Cards Container
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: email,
                      ),
                      const Divider(height: 1),
                      _buildInfoRow(
                        icon: Icons.phone_android_outlined,
                        label: 'Nomor Telepon',
                        value: phoneNumber,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                // Find Workshop Promo/Banner Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.search,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cari Bengkel Terbaik',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Temukan bengkel terdekat dan tepercaya di sekitar Anda sekarang!',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                // Logout Button
                ButtonPrimary(
                  text: 'Keluar dari Akun',
                  color: AppColors.error,
                  onPressed: _handleLogout,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
