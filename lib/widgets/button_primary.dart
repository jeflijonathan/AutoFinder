import 'package:flutter/material.dart';
import 'package:autofinder/config/app_colors.dart';

enum ButtonVariant {
  primary,
  secondary,
  success,
  danger,
  warning,
  info,
  dark,
  light,
}

class ButtonPrimary extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonVariant variant;
  final Color? color;
  final Color? textColor;
  final Widget? icon;
  final bool isLoading;

  const ButtonPrimary({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.color,
    this.textColor,
    this.icon,
    this.isLoading = false,
  });

  Color get _bgColor {
    if (color != null) return color!;
    return switch (variant) {
      ButtonVariant.primary => AppColors.buttonPrimary,
      ButtonVariant.secondary => AppColors.buttonSecondary,
      ButtonVariant.success => AppColors.buttonSuccess,
      ButtonVariant.danger => AppColors.buttonDanger,
      ButtonVariant.warning => AppColors.buttonWarning,
      ButtonVariant.info => AppColors.buttonInfo,
      ButtonVariant.dark => AppColors.buttonDark,
      ButtonVariant.light => AppColors.buttonLight,
    };
  }

  Color get _fgColor {
    if (textColor != null) return textColor!;
    // Tombol putih → teks gelap agar tetap terbaca
    if (variant == ButtonVariant.light) return AppColors.textPrimary;
    return Colors.white;
  }

  BorderSide get _border {
    if (variant == ButtonVariant.light) {
      return const BorderSide(color: AppColors.border, width: 1.5);
    }
    return BorderSide.none;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _bgColor,
          foregroundColor: _fgColor,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: _border,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(_fgColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[icon!, const SizedBox(width: 12)],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _fgColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
