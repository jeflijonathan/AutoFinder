import 'package:autofinder/config/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';

class SecurityForm {
  static String? Function(String?) currentPassword(BuildContext context) {
    return ValidationBuilder(
      requiredMessage: AppLocale.currentPasswordEmpty,
    ).build();
  }

  static String? Function(String?) newPassword(BuildContext context) {
    return ValidationBuilder(
      requiredMessage: AppLocale.newPasswordEmpty,
    ).minLength(6, AppLocale.passwordMinLength).build();
  }

  static String? confirmPassword({
    required BuildContext context,
    required String? value,
    required String originalPassword,
  }) {
    if (value == null || value.isEmpty) {
      return AppLocale.confirmPasswordEmpty;
    }
    if (value != originalPassword) {
      return AppLocale.passwordMismatch;
    }
    return null;
  }
}
