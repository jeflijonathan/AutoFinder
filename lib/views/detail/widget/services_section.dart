import 'package:flutter/material.dart';

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
          'Available Services',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...services.map((service) {
          // Provide some default icons based on keywords in the service string
          IconData icon = Icons.build_circle_outlined;
          final s = service.toLowerCase();
          if (s.contains('oil')) icon = Icons.oil_barrel_outlined;
          if (s.contains('brake')) icon = Icons.album_outlined;
          if (s.contains('align') || s.contains('chassis')) icon = Icons.compare_arrows;
          if (s.contains('ecu') || s.contains('remap') || s.contains('tune')) icon = Icons.memory;

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
                      color: isDark ? Colors.grey[300] : Colors.grey[800],
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
