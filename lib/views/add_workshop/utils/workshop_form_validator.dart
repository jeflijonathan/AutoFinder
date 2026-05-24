import 'package:form_validator/form_validator.dart';

class WorkshopValidators {
  static String? phone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number cannot be empty';
    return ValidationBuilder()
        .phone('Format phone number is invalid')
        .build()(value);
  }

  static String? name(String? value) {
    if (value == null || value.isEmpty) return 'Workshop name cannot be empty';
    return ValidationBuilder()
        .minLength(3, 'Minimum 3 characters')
        .maxLength(100, 'Maximum 100 characters')
        .build()(value);
  }

  static String? mission(String? value) {
    if (value == null || value.isEmpty) return 'Mission statement cannot be empty';
    return ValidationBuilder()
        .minLength(10, 'Minimum 10 characters')
        .build()(value);
  }
}
