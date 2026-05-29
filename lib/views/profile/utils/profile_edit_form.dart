import 'package:autofinder/config/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:form_validator/form_validator.dart';

class ProfileForm {
  static String? Function(String?) username(BuildContext context) {
    return ValidationBuilder(
      requiredMessage: AppLocale.usernameEmpty.getString(context),
    ).minLength(3, AppLocale.usernameMinLength.getString(context)).build();
  }

  static String? Function(String?) phoneNumber(BuildContext context) {
    return ValidationBuilder(
      requiredMessage: AppLocale.phoneNumberEmpty.getString(context),
    ).phone(AppLocale.phoneNumberInvalid.getString(context)).build();
  }

  static String? confirmPassword({
    required BuildContext context,
    required String? value,
    required String originalPassword,
  }) {
    if (value == null || value.isEmpty) {
      return AppLocale.confirmPasswordEmpty.getString(context);
    }
    if (value != originalPassword) {
      return AppLocale.passwordMismatch.getString(context);
    }
    return null;
  }
}
