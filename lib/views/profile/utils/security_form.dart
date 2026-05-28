class SecurityForm {
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
