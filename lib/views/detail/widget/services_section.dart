import 'package:flutter/material.dart';
import 'package:autofinder/config/app_locale.dart';
import 'package:flutter_localization/flutter_localization.dart';

class ServicesSection extends StatelessWidget {
  final List<String> services;

  const ServicesSection({super.key, required this.services});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (services.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocale.availableServices.getString(context),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...services.map((service) {
          IconData icon = Icons.build_circle_outlined;
          final s = service.toLowerCase();

          if (s.contains('oil') || s.contains('oli') || s.contains('オイル')) {
            icon = Icons.oil_barrel_outlined;
          }
          if (s.contains('brake') || s.contains('rem') || s.contains('ブレーキ')) {
            icon = Icons.album_outlined;
          }
          if (s.contains('align') ||
              s.contains('chassis') ||
              s.contains('kaki') ||
              s.contains('sasis')) {
            icon = Icons.compare_arrows;
          }
          if (s.contains('ecu') || s.contains('remap') || s.contains('tune')) {
            icon = Icons.memory;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              children: [
                Icon(icon, color: Colors.blue.shade700, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    service,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.grey : Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
