import 'package:autofinder/config/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:form_validator/form_validator.dart';

class RegisterValidators {
  /// Validasi Email
  static String? Function(String?) email(BuildContext context) {
    return ValidationBuilder(
          requiredMessage: AppLocale.emailEmpty.getString(context),
        )
        .email(AppLocale.emailInvalid.getString(context))
        .maxLength(50, AppLocale.emailMaxLength.getString(context))
        .build();
  }

  /// Validasi Username
  static String? Function(String?) username(BuildContext context) {
    return ValidationBuilder(
          requiredMessage: AppLocale.usernameEmpty.getString(
            context,
          ), // Pastikan key ini ada di AppLocale Anda
        )
        .minLength(
          3,
          AppLocale.usernameMinLength.getString(context),
        ) // Pastikan key ini ada di AppLocale Anda
        .build();
  }

  /// Validasi Nomor Telepon
  static String? Function(String?) phoneNumber(BuildContext context) {
    return ValidationBuilder(
          requiredMessage: AppLocale.phoneEmpty.getString(
            context,
          ), // Pastikan key ini ada di AppLocale Anda
        )
        .phone(
          AppLocale.phoneInvalid.getString(context),
        ) // Pastikan key ini ada di AppLocale Anda
        .build();
  }

  /// Validasi Password
  static String? Function(String?) password(BuildContext context) {
    return ValidationBuilder(
      requiredMessage: AppLocale.passwordEmpty.getString(context),
    ).minLength(6, AppLocale.passwordMinLength.getString(context)).build();
  }

  /// Validasi Konfirmasi Password
  static String? confirmPassword({
    required BuildContext context,
    required String? value,
    required String originalPassword,
  }) {
    if (value == null || value.isEmpty) {
      return AppLocale.passwordConfirmEmpty.getString(
        context,
      ); // Pastikan key ini ada di AppLocale Anda
    }
    if (value != originalPassword) {
      return AppLocale.passwordMismatch.getString(
        context,
      ); // Pastikan key ini ada di AppLocale Anda
    }
    return null;
  }
}
