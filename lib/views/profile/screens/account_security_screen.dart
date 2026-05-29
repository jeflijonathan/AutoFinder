import 'package:autofinder/config/app_colors.dart';
import 'package:autofinder/config/app_locale.dart';
import 'package:autofinder/views/auth/controllers/auth_controller.dart';
import 'package:autofinder/widgets/button_primary.dart';
import 'package:autofinder/widgets/custom_textfield.dart';
import 'package:autofinder/widgets/loading.dart';
import 'package:autofinder/views/profile/utils/security_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:provider/provider.dart';

class AccountSecurityScreen extends StatefulWidget {
  const AccountSecurityScreen({super.key});

  @override
  State<AccountSecurityScreen> createState() => _AccountSecurityScreenState();
}

class _AccountSecurityScreenState extends State<AccountSecurityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleUpdatePassword() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<AuthController>().handleUpdatePassword(
      context: context,
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
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

                        // Header Banner Box
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
                                AppLocale.securityOfAccount.getString(context),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AppLocale.securityDesc.getString(context),
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

                        // Subtitle Section
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.lock_outline,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              AppLocale.password.getString(context),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Input: Current Password
                        CustomTextField(
                          label: AppLocale.currentPassword.getString(context),
                          hintText: '••••••••',
                          controller: _currentPasswordController,
                          obscureText: true,
                          isPassword: true,
                          validator: SecurityForm.currentPassword(context),
                        ),
                        const SizedBox(height: 20),

                        // Input: New Password
                        CustomTextField(
                          label: AppLocale.newPassword.getString(context),
                          hintText: '••••••••',
                          controller: _newPasswordController,
                          obscureText: true,
                          isPassword: true,
                          validator: SecurityForm.newPassword(context),
                        ),
                        const SizedBox(height: 20),

                        // Input: Confirmation Password
                        CustomTextField(
                          label: AppLocale.confirmation.getString(context),
                          hintText: AppLocale.confirmPasswordHint.getString(
                            context,
                          ),
                          controller: _confirmPasswordController,
                          obscureText: true,
                          isPassword: true,
                          validator: (value) => SecurityForm.confirmPassword(
                            context: context,
                            value: value,
                            originalPassword: _newPasswordController.text,
                          ),
                        ),
                        const SizedBox(height: 36),

                        // Button: Update Password
                        ButtonPrimary(
                          text: AppLocale.updatePassword.getString(context),
                          isLoading: isLoading,
                          onPressed: () {
                            if (!isLoading) _handleUpdatePassword();
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Top Floating Back Button
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
                    AppLocale.accountSecuritySettings.getString(context),
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
