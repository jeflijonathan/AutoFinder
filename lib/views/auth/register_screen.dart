import 'package:autofinder/config/app_colors.dart';
import 'package:autofinder/config/app_locale.dart';
import 'package:autofinder/views/auth/controllers/auth_controller.dart';
import 'package:autofinder/views/auth/utils/register_form.dart';
import 'package:autofinder/widgets/button_primary.dart';
import 'package:autofinder/widgets/custom_textfield.dart';
import 'package:autofinder/widgets/loading.dart';
import 'package:autofinder/widgets/phone_number_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    context.read<AuthController>().handleRegisterRequest(
      context: context,
      email: _emailController.text.trim(),
      username: _usernameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      password: _passwordController.text,
    );
  }

  void _navigateBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthController>().isLoading;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: theme.brightness == Brightness.dark
                    ? [
                        const Color(0xFF1E2128),
                        const Color(0xFF121212),
                        colorScheme.surface,
                      ]
                    : [
                        const Color(0xFFEFF3F9),
                        const Color(0xFFF6F8FC),
                        colorScheme.surface,
                      ],
              ),
              image: DecorationImage(
                image: const AssetImage('images/background-2.png'),
                fit: BoxFit.cover,
                colorFilter: theme.brightness == Brightness.dark
                    ? ColorFilter.mode(
                        Colors.black.withAlpha(150),
                        BlendMode.darken,
                      )
                    : null,
              ),
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 24.0,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 24),
                              decoration: BoxDecoration(
                                color: colorScheme.surface,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(
                                      theme.brightness == Brightness.dark
                                          ? 40
                                          : 12,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: TextButton.icon(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  foregroundColor: colorScheme.onSurface,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.arrow_back_ios_new,
                                  size: 16,
                                ),
                                label: Text(
                                  AppLocale.back.getString(context),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                onPressed: isLoading ? null : _navigateBack,
                              ),
                            ),
                          ),

                          Text(
                            AppLocale.title.getString(context),
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 12),

                          Text(
                            AppLocale.welcomeTitle.getString(context),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Text(
                              AppLocale.registerSubtitle.getString(context),
                              style: TextStyle(
                                fontSize: 14,
                                color: colorScheme.onSurfaceVariant,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 36),

                          // 🟢 Input: Email
                          CustomTextField(
                            label: AppLocale.email.getString(context),
                            hintText: 'nama@email.com',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) =>
                                RegisterValidators.email(context)(value),
                          ),
                          const SizedBox(height: 20),

                          // 🟢 Input: Username
                          CustomTextField(
                            label: AppLocale.username.getString(context),
                            hintText: 'username_123',
                            controller: _usernameController,
                            validator: (value) =>
                                RegisterValidators.username(context)(value),
                          ),
                          const SizedBox(height: 20),

                          // 🟢 Input: Nomor Telepon
                          PhoneNumberTextField(
                            label: AppLocale.phoneNumber.getString(context),
                            controller: _phoneController,
                            validator: (value) =>
                                RegisterValidators.phoneNumber(context)(value),
                          ),
                          const SizedBox(height: 20),

                          // 🟢 Input: Password
                          CustomTextField(
                            label: AppLocale.password.getString(context),
                            hintText: '••••••••',
                            controller: _passwordController,
                            obscureText: true,
                            isPassword: true,
                            validator: (value) =>
                                RegisterValidators.password(context)(value),
                          ),
                          const SizedBox(height: 20),

                          // 🟢 Input: Konfirmasi Password
                          CustomTextField(
                            label: AppLocale.confirmation.getString(context),
                            hintText: AppLocale.confirmPasswordHint.getString(
                              context,
                            ),
                            controller: _confirmPasswordController,
                            obscureText: true,
                            isPassword: true,
                            validator: (value) =>
                                RegisterValidators.confirmPassword(
                                  context: context,
                                  value: value,
                                  originalPassword: _passwordController.text,
                                ),
                          ),
                          const SizedBox(height: 36),

                          Selector<AuthController, bool>(
                            selector: (_, controller) => controller.isLoading,
                            builder: (context, isLoading, child) {
                              return ButtonPrimary(
                                text: AppLocale.signUp.getString(context),
                                isLoading: isLoading,
                                onPressed: () {
                                  if (!isLoading) {
                                    _handleRegister();
                                  }
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 36),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${AppLocale.alreadyHaveAccount.getString(context)} ',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              GestureDetector(
                                onTap: isLoading
                                    ? null
                                    : () {
                                        Navigator.pushReplacementNamed(
                                          context,
                                          '/login',
                                        );
                                      },
                                child: Text(
                                  AppLocale.signIn.getString(context),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (isLoading) const Loading(asOverlay: true),
        ],
      ),
    );
  }
}
