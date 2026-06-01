import 'package:autofinder/widgets/translated_text.dart';
import 'package:flutter/material.dart';
import 'package:autofinder/config/app_locale.dart';
import 'package:flutter_localization/flutter_localization.dart';

class AboutSection extends StatelessWidget {
  final String description;

  const AboutSection({super.key, required this.description});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8F9FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocale.aboutTheWorkshop.getString(context),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          TranslatedText(
            description.isNotEmpty
                ? description
                : 'No description available for this workshop.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.grey : Colors.grey,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
