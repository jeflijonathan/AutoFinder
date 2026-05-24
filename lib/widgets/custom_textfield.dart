import 'package:flutter/material.dart';
import 'package:autofinder/config/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool isPassword;
  final String? Function(String?)? validator;

  // 🌟 TAMBAHKAN PARAMETER BARU DI SINI
  final int? maxLines;
  final int minLines;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.isPassword = false,
    this.validator,
    this.maxLines = 1, // Default 1 baris seperti TextField biasa
    this.minLines = 1, // Default minimal 1 baris
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    // 💡 VALIDASI LOGIKA: Password tidak boleh multi-line (textarea)
    // Jika itu password, kunci maxLines ke angka 1 agar tidak error di Flutter.
    final effectiveMaxLines = widget.isPassword ? 1 : widget.maxLines;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),

        TextFormField(
          controller: widget.controller,

          // Jika untuk textarea, ganti keyboardType ke TextInputType.multiline
          keyboardType: effectiveMaxLines != 1
              ? TextInputType.multiline
              : widget.keyboardType,

          obscureText: _obscured,
          validator: widget.validator,

          // 🌟 TERAPKAN DI SINI
          maxLines: effectiveMaxLines,
          minLines: widget.minLines,

          style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: const TextStyle(
              color: AppColors.inputHint,
              fontSize: 15,
            ),
            fillColor: AppColors.inputBackground,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.error, width: 1.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscured
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.inputHint,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscured = !_obscured;
                      });
                    },
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
