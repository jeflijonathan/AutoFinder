import 'package:autofinder/config/app_colors.dart';
import 'package:autofinder/config/app_locale.dart'; // Impor AppLocale Anda
import 'package:autofinder/views/auth/controllers/auth_controller.dart';
import 'package:autofinder/widgets/button_primary.dart';
import 'package:autofinder/widgets/custom_textfield.dart';
import 'package:autofinder/widgets/loading.dart';
import 'package:autofinder/widgets/phone_number_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart'; // Impor untuk extension .getString(context)
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthController>().currentUser;
    _usernameController.text = user?.username ?? '';
    _emailController.text = user?.email ?? '';
    _phoneController.text = user?.phoneNumber ?? '';
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<AuthController>().handleUpdateProfile(
      context: context,
      username: _usernameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
    );
  }

  void _navigateBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, '/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthController>().isLoading;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Main Content
            Center(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 60),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                AppLocale.personalInformation.getString(
                                  context,
                                ),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AppLocale.personalInfoDesc.getString(context),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white70,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Input: Full Name
                        CustomTextField(
                          label: AppLocale.fullName.getString(context),
                          hintText: AppLocale.fullNameHint.getString(context),
                          controller: _usernameController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Full name cannot be empty';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Input: Email (read-only)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocale.email.getString(context),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: theme.brightness == Brightness.dark
                                    ? const Color(0xFF2C2C2C)
                                    : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.mail_outline,
                                    size: 18,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _emailController.text,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Input: Phone Number
                        PhoneNumberTextField(
                          label: AppLocale.phoneNumber.getString(context),
                          controller: _phoneController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Phone number cannot be empty';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 36),

                        ButtonPrimary(
                          text: AppLocale.saveChanges.getString(context),
                          isLoading: isLoading,
                          onPressed: () {
                            if (!isLoading) _handleSave();
                          },
                        ),
                        const SizedBox(height: 16),

                        // Cancel Button
                        Center(
                          child: GestureDetector(
                            onTap: isLoading ? null : _navigateBack,
                            child: Text(
                              AppLocale.cancel.getString(context),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              top: 16,
              left: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? const Color(0xFF1E1E1E)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    foregroundColor: theme.brightness == Brightness.dark
                        ? AppColors.textLight
                        : AppColors.textPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                  label: Text(
                    AppLocale.profileSettings.getString(context),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: isLoading ? null : _navigateBack,
                ),
              ),
            ),

            if (isLoading) const Loading(asOverlay: true),
          ],
        ),
      ),
    );
  }
}
