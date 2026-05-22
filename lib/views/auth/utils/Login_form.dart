import 'package:form_validator/form_validator.dart';

class LoginValidators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email tidak boleh kosong';
    return ValidationBuilder()
        .email('Format email tidak valid')
        .maxLength(50, 'Maksimal 50 karakter')
        .build()(value);
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password tidak boleh kosong';
    return ValidationBuilder()
        .minLength(6, 'Password minimal 6 karakter')
        .build()(value);
  }
}
