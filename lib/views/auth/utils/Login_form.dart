import 'package:autofinder/config/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:form_validator/form_validator.dart';

class LoginForm {
  /// Mengembalikan fungsi validator: String? Function(String?)
  static String? Function(String?) email(BuildContext context) {
    return ValidationBuilder(
          requiredMessage: AppLocale.emailEmpty.getString(context),
        )
        .email(AppLocale.emailInvalid.getString(context))
        .maxLength(50, AppLocale.emailMaxLength.getString(context))
        .build(); // 🟢 BERHENTI DI SINI (Jangan tambahkan tanda kurung lagi)
  }

  /// Mengembalikan fungsi validator: String? Function(String?)
  static String? Function(String?) password(BuildContext context) {
    return ValidationBuilder(
          requiredMessage: AppLocale.passwordEmpty.getString(context),
        )
        .minLength(6, AppLocale.passwordMinLength.getString(context))
        .build(); // 🟢 BERHENTI DI SINI (Jangan tambahkan tanda kurung lagi)
  }
}
