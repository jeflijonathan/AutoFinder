import 'package:form_validator/form_validator.dart';

class RegisterValidators {
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

  static String? username(String? value) {
    if (value == null || value.isEmpty) return 'Username tidak boleh kosong';
    return ValidationBuilder()
        .minLength(3, 'Username minimal 3 karakter')
        .build()(value);
  }

  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty)
      return 'Nomor telepon tidak boleh kosong';
    return ValidationBuilder().phone('Nomor telepon tidak valid').build()(
      value,
    );
  }

  static String? confirmPassword(String? value, String originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    if (value != originalPassword) {
      return 'Konfirmasi password tidak cocok';
    }
    return null;
  }
}
