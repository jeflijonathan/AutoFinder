import 'package:autofinder/config/app_colors.dart';
import 'package:autofinder/config/app_locale.dart';
import 'package:autofinder/config/app_routes.dart';
import 'package:autofinder/services/users/models/user_model.dart';
import 'package:autofinder/views/auth/controllers/auth_controller.dart';
import 'package:autofinder/widgets/button_primary.dart';
import 'package:autofinder/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  void _handleGoogleSignIn() async {
    try {
      await _googleSignIn.initialize();

      final GoogleSignInAccount? googleUser = await _googleSignIn
          .authenticate();

      if (googleUser == null) return;

      UserModel dataDariGoogle = UserModel(
        uid: googleUser.id,
        email: googleUser.email,
        username: googleUser.displayName ?? 'Google User',
        phoneNumber: '',
      );

      if (mounted) {
        context.read<AuthController>().handleLoginWithGoogleRequest(
          context: context,
          googleData: dataDariGoogle,
        );
      }
    } catch (error) {
      final errorString = error.toString().toLowerCase();

      if (errorString.contains('canceled') ||
          errorString.contains('cancelled')) {
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocale.googleSignInFailed.getString(context)}: $error',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGoogleLoading = context.watch<AuthController>().isLoading;
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
                      vertical: 16.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
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
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            AppLocale.welcomeSubtitle.getString(context),
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurfaceVariant,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 36),

                        Container(
                          width: double.infinity,
                          height: 230,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: ShaderMask(
                              shaderCallback: (bounds) {
                                return const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.white,
                                    Colors.white,
                                    Colors.transparent,
                                  ],
                                  stops: [0.0, 0.4, 1.0],
                                ).createShader(bounds);
                              },
                              blendMode: BlendMode.dstIn,
                              child: Container(
                                color: colorScheme.surface,
                                child: Image.asset(
                                  'images/automotif-image.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey.shade200,
                                      child: const Icon(
                                        Icons.directions_car,
                                        size: 64,
                                        color: AppColors.primary,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),

                        ButtonPrimary(
                          text: AppLocale.continueWithGoogle.getString(context),
                          isLoading: isGoogleLoading,
                          variant: ButtonVariant.light,
                          icon: Image.asset(
                            'images/google-icon.png',
                            height: 22,
                            width: 22,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.g_mobiledata, size: 24);
                            },
                          ),
                          onPressed: _handleGoogleSignIn,
                        ),
                        const SizedBox(height: 20),

                        Text(
                          AppLocale.orText.getString(context),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 20),

                        ButtonPrimary(
                          text: AppLocale.signInWithEmail.getString(context),
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.login);
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
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.register,
                                );
                              },
                              child: Text(
                                AppLocale.signUp.getString(context),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          if (isGoogleLoading) const Loading(asOverlay: true),
        ],
      ),
    );
  }
}
