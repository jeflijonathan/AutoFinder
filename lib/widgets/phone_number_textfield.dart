import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhoneNumberTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final void Function(String)? onCountryChanged;
  final String label;

  const PhoneNumberTextField({
    super.key,
    required this.controller,
    this.validator,
    this.onCountryChanged,
    required this.label,
  });

  @override
  State<PhoneNumberTextField> createState() => _PhoneNumberTextFieldState();
}

class _PhoneNumberTextFieldState extends State<PhoneNumberTextField> {
  final List<Map<String, String>> _countryCodes = [
    {'code': '+62', 'flag': '🇮🇩', 'name': 'Indonesia'},
    {'code': '+1', 'flag': '🇺🇸', 'name': 'USA'},
    {'code': '+60', 'flag': '🇲🇾', 'name': 'Malaysia'},
    {'code': '+65', 'flag': '🇸🇬', 'name': 'Singapore'},
  ];

  late String _selectedCode;

  @override
  void initState() {
    super.initState();
    _selectedCode = _countryCodes[0]['code']!;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface, // Label teks adaptif
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          keyboardType: TextInputType.phone,
          validator: widget.validator,
          inputFormatters: [
            // 1. Pastikan hanya menerima angka murni saat diketik/copas
            FilteringTextInputFormatter.digitsOnly,

            // 2. Pembatas total angka: Maksimal 11 digit (ex: 82182616803)
            LengthLimitingTextInputFormatter(11),

            // 3. Formatter Kustom untuk Pola XXX-XXXX-XXXX
            TextInputFormatter.withFunction((oldValue, newValue) {
              final text = newValue.text;

              // Cegah angka 0 di awal ketikan
              if (text.startsWith('0')) {
                return oldValue;
              }

              final buffer = StringBuffer();
              for (int i = 0; i < text.length; i++) {
                buffer.write(text[i]);
                final digitIndex = i + 1;

                // Tambah '-' setelah digit ke-3 ATAU digit ke-7,
                // dengan syarat bukan di akhir baris ketikan
                if ((digitIndex == 3 || digitIndex == 7) &&
                    digitIndex != text.length) {
                  buffer.write('-');
                }
              }

              final formattedString = buffer.toString();
              return newValue.copyWith(
                text: formattedString,
                selection: TextSelection.collapsed(
                  offset: formattedString.length,
                ),
              );
            }),
          ],
          style: TextStyle(
            fontSize: 16,
            color: theme.colorScheme.onSurface, // Input teks utama adaptif
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: '821-8261-6803',
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurfaceVariant.withAlpha(
                150,
              ), // Hint melunak adaptif
            ),
            filled: true,
            fillColor: isDark
                ? const Color(0xFF2C2C2C)
                : const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: theme
                        .colorScheme
                        .outlineVariant, // Pembatas vertikal adaptif
                    width: 1.5,
                  ),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCode,
                  isDense: true,
                  dropdownColor: theme
                      .cardColor, // Mencegah popup background crash/putih statis saat dark mode
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  items: _countryCodes.map<DropdownMenuItem<String>>((
                    Map<String, String> country,
                  ) {
                    return DropdownMenuItem<String>(
                      value: country['code']!,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            country['flag']!,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            country['code']!,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme
                                  .colorScheme
                                  .onSurface, // Kode dropdown adaptif
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    if (value != null) {
                      setState(() {
                        _selectedCode = value;
                        widget.controller.clear();
                      });
                      if (widget.onCountryChanged != null) {
                        widget.onCountryChanged!(value);
                      }
                    }
                  },
                ),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme
                    .colorScheme
                    .outlineVariant, // Garis border normal adaptif
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary, // Garis fokus utama dinamis
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.error, // Eror adaptif
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
